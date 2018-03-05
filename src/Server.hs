{-# LANGUAGE OverloadedStrings #-}
module Server
    ( server
    ) where

import           Network.HTTP.Types       (status400)
import           Network.Wai              (Application, responseLBS)
import           Network.Wai.Handler.Warp (run)

app :: Application
app _ respond =
    respond $ responseLBS status400 [] "Hello world."


server :: IO ()
server = do
    run 8080 app
