module Main where

import Control.Monad    (unless)
import Data.Time        (Day, TimeZone, defaultTimeLocale, getCurrentTime, formatTime, localDay, utcToLocalTime, hoursToTimeZone)
import System.Directory (doesFileExist)
import System.Process   (callProcess)

logPath :: Day -> FilePath
logPath = formatTime defaultTimeLocale "logs/%Y/%y.%m.%d"

logUrl :: Day -> FilePath
logUrl = formatTime defaultTimeLocale "http://tunes.org/~nef/logs/haskell/%y.%m.%d"

tunesOrgTimezone :: TimeZone
tunesOrgTimezone = hoursToTimeZone (-8)

main :: IO ()
main =
  do now <- getCurrentTime
     let nowPst = utcToLocalTime tunesOrgTimezone now
     processDay (localDay nowPst)

-- | Download the log for the given day. Continue processing the previous
-- day if this log wasn't already downloaded.
processDay :: Day -> IO ()
processDay day =
  do let filename = logPath day
         url      = logUrl  day
     existed <- doesFileExist filename
     download filename url
     unless existed (processDay (pred day))

download :: FilePath -> String -> IO ()
download filename url = callProcess "curl" ["-fo",filename,url]
-- -f curl should fail on HTTP error (e.g. 404) which manifests as a Haskell exception
