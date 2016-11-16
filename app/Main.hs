{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Prelude hiding (putStrLn, putStr)
import Control.Concurrent.Async (mapConcurrently)
import qualified Data.ByteString.Lazy as BS
import Data.Monoid ((<>))
import Data.Text (Text, unpack)
import Data.Text.IO (putStrLn, putStr)
import Text.Pandoc
import Text.Pandoc.Options
import Text.Pandoc.SelfContained
import Options.Generic
import System.INotify

type OutputFile = (Text, String)

data ResumeOptions = ResumeOptions { watch :: Bool } deriving (Generic)

instance ParseRecord ResumeOptions

fontUri :: Text
fontUri = "https://fonts.googleapis.com/css?family=Hind+Siliguri:"
  <> "400,700,500,300,600"

writeFile' :: OutputFile -> IO ()
writeFile' (path, contents)
  = putStr ("[Writing: " <> path <> "] ")
  >> writeFile (unpack path) contents

getOptions :: IO ResumeOptions
getOptions = getRecord "Ed's Resume Generator"

generate :: IO ()
generate = do
  putStrLn "Generating..."

  raw <- readFile "resume.md"
  rawTemplate <- readFile "default.html5"

  let htmlOptions = def
              { writerHtml5 = True
              , writerVerbose = True
              , writerVariables
                = [ ("css", "style.css")
                , ("css", unpack fontUri)
                , ("pagetitle", "Resume")
                ]
              , writerTemplate = rawTemplate
              , writerStandalone = True
              }
  let markdownOptions = def { writerExtensions = plainExtensions }

  case readMarkdown def raw of
    Left a -> print a
    Right b -> do
      compiled <- makeSelfContained htmlOptions (writeHtmlString htmlOptions b)

      mapConcurrently writeFile'
        [ ("build/resume.html", compiled)
        , ("build/resume.asciidoc", writeAsciiDoc def b)
        , ("build/resume.json", writeJSON def b)
        , ("build/resume.md", writeMarkdown markdownOptions b)
        ]

      putStrLn "\nDone!"

main :: IO ()
main = do
  options <- getOptions

  case (watch options) of
    True -> do
      generate
      inotify <- initINotify
      rw <- addWatch inotify [Modify] "." (const generate)
      putStrLn "Watching for changes..."
      getLine
      removeWatch rw
    False -> generate
