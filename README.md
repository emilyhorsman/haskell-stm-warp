# haskell-stm-warp

## Running the Haskell back-end

(`$` character denotes the beginning of a prompt, it should not be included.)

### Install Stack

```
$ curl -sSL https://get.haskellstack.org/ | sh
```

Consult the [installation guide](https://docs.haskellstack.org/en/stable/README/#how-to-install) if you’re on Windows.

### Install haskell-stm-warp

```
$ git clone https://github.com/emilyhorsman/haskell-stm-warp.git
$ cd haskell-stm-warp
$ stack setup
$ stack build
```

### Run the haskell-stm-warp server

```
$ stack exec haskell-stm-warp-exe
```

## Development Standards

* All Haskell is run through [stylish-haskell](https://github.com/jaspervdj/stylish-haskell) and [hlint](https://hackage.haskell.org/package/hlint)

## Output

```
> curl -i http://localhost:8080/ -d 'Goodbye'
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Mon, 05 Mar 2018 01:32:28 GMT
Server: Warp/3.2.13

Goodbye⏎
> curl -i http://localhost:8080/ -d 'Hello'
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Mon, 05 Mar 2018 01:32:30 GMT
Server: Warp/3.2.13

Hello⏎
> curl -i http://localhost:8080/history
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Mon, 05 Mar 2018 01:32:31 GMT
Server: Warp/3.2.13

Hello
Goodbye⏎
```
