module Main where

import Prelude

import Control.Apply
import Control.Bind
import Control.Monad.Aff
import Control.Monad.Eff
import Control.Monad.Eff.Class
import Control.Monad.Eff.Exception
import Control.Monad.Eff.Console hiding (error)

import Data.Array
import Data.Maybe

import Test.Phantomjs
import Test.Phantomjs.System
import Test.Phantomjs.Object
import Test.Phantomjs.Webpage
import Test.Phantomjs.Filesystem
import Test.Phantomjs.ChildProcess


main :: forall e. Eff ( phantomjs :: PHANTOMJS
                      , console :: CONSOLE | e) Unit
main = do
  args <- args
  content <- read "README.md"
  log content
  child <- spawn "ls" ["-la", "/"]
  print args
  page <- create
  let outfile = "screenshot.jpg"
  let timeout = 5000
  maybe
    ((print $ error "No url given") *> exit 0)
    (\url -> (runAff
              (print >=> const (exit 1))
              (const (log $ "Screenshot of " ++
                      url ++
                      " saved to " ++
                      outfile ++
                      "."))
              (screenshot page url outfile timeout)))
    (index args 1)



timeoutError :: Int -> Error
timeoutError ms = error $ "Timed out after " ++ show ms ++ " seconds"

type Url = String
type Timeout = Int

screenshot :: forall e. Page -> Url -> File -> Timeout -> Aff ( phantomjs :: PHANTOMJS
                                                              , console :: CONSOLE
                                                              | e) Unit
screenshot page url outfile timeout = do
  open page url
  liftEff $ log "Successfully connected."
