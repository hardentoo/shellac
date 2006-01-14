{-
 - 
 -  Copyright 2005-2006, Robert Dockins.
 -  
 -}


{- | This module implements a simple Shellac backend that uses only
     the primitaves from "System.IO".  It provides no history or
     command completion capabilities.  You get whatever line editing
     capabilities 'hGetLine' has and that's it.
-}

module System.Console.Shell.Backend.Basic
( basicBackend
) where

import System.IO   ( stdout, stderr, stdin, hFlush, hPutStr, hPutStrLn
	           , hGetLine, hGetChar, hGetBuffering, hSetBuffering
                   , BufferMode(..)
                   )
import qualified Control.Exception as Ex

import System.Console.Shell.Backend

basicBackend :: ShellBackend ()
basicBackend = ShBackend
  { initBackend                      = return ()
  , outputString                     = \_ str -> hPutStr stdout str
  , outputErrString                  = \_ str -> hPutStr stderr str
  , flushOutput                      = \_ -> hFlush stdout
  , getSingleChar                    = \_ -> basicGetSingleChar
  , getInput                         = \_ -> basicGetInput
  , addHistory                       = \_ _ -> return ()
  , setWordBreakChars                = \_ _ -> return ()
  , getWordBreakChars                = \_ -> return " \t\n\r\v`~!@#$%^&*()=[]{};\\\'\",<>"
  , setAttemptedCompletionFunction   = \_ _ -> return ()
  , setDefaultCompletionFunction     = \_ _ -> return ()
  , completeFilename                 = \_ _ -> return []
  , completeUsername                 = \_ _ -> return []
  , clearHistoryState                = \_ -> return ()
  , getMaxHistoryEntries             = \_ -> return 0
  , setMaxHistoryEntries             = \_ _ -> return ()
  , readHistory                      = \_ _ -> return ()
  , writeHistory                     = \_ _ -> return ()
  }

basicGetSingleChar :: String -> IO (Maybe Char)
basicGetSingleChar prompt = do
   hPutStr stdout prompt
   hFlush stdout
   Ex.bracket (hGetBuffering stdin) (hSetBuffering stdin) $ \_ -> do
      hSetBuffering stdin NoBuffering
      c <- hGetChar stdin
      hPutStrLn stdout ""
      return (Just c)

basicGetInput :: String -> IO (Maybe String)
basicGetInput prompt = do
   hPutStr stdout prompt
   hFlush stdout
   x <- hGetLine stdin
   return (Just x)
