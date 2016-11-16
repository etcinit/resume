#!/usr/bin/env stack
-- stack --install-ghc runghc --package shake

import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util

options :: ShakeOptions
options = shakeOptions
  { shakeFiles = "_build"
  , shakeProgress = progressSimple
  }

main :: IO ()
main = shakeArgs options $ do
  phony "publish" $ do
    putNormal "Preparing to publish..."
    () <- withTempDir $ \dir -> do
      () <- cmd "cp" "-R" "." dir
      () <- cmd (Cwd dir) "rm" "-Rf" ".git"
      () <- cmd (Cwd dir) "git" "init"
      () <- cmd (Cwd dir) "git" "add" "."
      () <- cmd (Cwd dir) "git" "commit" "--message" "Publish"
      () <- cmd (Cwd dir) "git" "remote" "add" "origin"
        "git@github.com:etcinit/resume.git"
      cmd (Cwd dir) "git" "push" "-f" "origin" "master"
    withTempDir $ \dir -> do
      () <- cmd "cp" "build/resume.html" (dir </> "index.html")
      () <- cmd (Cwd dir) "git" "init"
      () <- cmd (Cwd dir) "git" "checkout" "-b" "gh-pages"
      () <- cmd (Cwd dir) "git" "add" "."
      () <- cmd (Cwd dir) "git" "commit" "--message" "Publish"
      () <- cmd (Cwd dir) "git" "remote" "add" "origin"
        "git@github.com:etcinit/resume.git"
      cmd (Cwd dir) "git" "push" "-f" "origin" "gh-pages"

  phony "generate" $ do
    () <- cmd "mkdir" "-p" "build"
    () <- cmd "stack" "build"
    cmd "stack" "exec" "resume"

  phony "clean" $ do
    removeFilesAfter "build" ["//*"]
    removeFilesAfter "../resume-public" ["//*"]
