{-# LANGUAGE OverloadedStrings #-}
module Server
    ( server
    ) where

import           Control.Concurrent       (forkIO)
import           Control.Concurrent.STM   (STM, TChan, atomically, newTChan,
                                           readTChan, writeTChan)
import qualified Data.ByteString          as B
import           Data.ByteString.Lazy     (fromStrict)
import           Data.Text                (Text)
import qualified Data.Text                as T
import           Network.HTTP.Types       (status200)
import           Network.Wai              (Application, pathInfo, requestBody,
                                           responseLBS)
import           Network.Wai.Handler.Warp (run)


type Message = B.ByteString


-- Any state the server holds should be typed here.
data State = State
    { messages :: [Message]
    , lastTime :: Int
    -- Add more state here.
    }


-- These are the messages that any request channel can receive.
-- Each request from a browser/client gets one request channel that the server
-- can write results into.
data RequestMessage
    = History [Message]


data ServerMessage
    = AddMessage B.ByteString
    | GetHistory (TChan RequestMessage)


newRequestMessageChan :: STM (TChan RequestMessage)
newRequestMessageChan = newTChan


processRequestChan :: TChan RequestMessage -> IO B.ByteString
processRequestChan requestChan = do
    message <- atomically $ readTChan requestChan
    case message of
        History messages ->
            return (B.intercalate "\n" messages)


app :: TChan ServerMessage -> Application
app serverChan request respond =
    case (pathInfo request) of
        ["history"] -> do
            requestChan <- atomically newRequestMessageChan
            atomically (writeTChan serverChan (GetHistory requestChan))
            result <- processRequestChan requestChan
            respond (responseLBS status200 [] (fromStrict result))

        otherwise -> do
            message <- requestBody request
            atomically (writeTChan serverChan (AddMessage message))
            respond (responseLBS status200 [] (fromStrict message))


processServerMessage :: State -> ServerMessage -> IO State
processServerMessage state (AddMessage message) =
    let
        nextState = state {
            messages = message : (messages state)
        }
    in do
        putStrLn "Received a message from a request:"
        print message
        return nextState

processServerMessage state (GetHistory chan) = do
    atomically (writeTChan chan (History (messages state)))
    return state


processServerChan :: TChan ServerMessage -> IO ()
processServerChan chan =
    let
        loop :: State -> IO ()
        loop state = atomically (readTChan chan) >>= processServerMessage state >>= loop

        -- This is the initial state with default values.
        initial :: State
        initial = State
            { messages = []
            , lastTime = -1
            }
    in
        loop initial


newServerMessageChan :: STM (TChan ServerMessage)
newServerMessageChan = newTChan


server :: IO ()
server = do
    putStrLn "Running on 8080"

    globalMessageChan <- atomically newServerMessageChan
    forkIO (processServerChan globalMessageChan)
    run 8080 (app globalMessageChan)
