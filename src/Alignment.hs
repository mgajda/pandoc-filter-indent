{-# LANGUAGE FlexibleContexts #-}
module Alignment where

import Data.Text (Text)
import Data.Tuple.Optics
import Optics.Lens

import Token ( MyLoc, MyTok )

-- | Datatype to present columns with alignment requirements.
data Align =
    ALeft
  | ACenter
  | AIndent -- indentation spacing
  deriving (Eq, Ord, Show)

-- | Records tokenized and converted to common token format.
type Processed = (MyTok, MyLoc, Text, Maybe Int, Maybe (Align, Int))

-- | Access text content.
tokenType :: Field1 a a MyTok MyTok => Lens' a MyTok
tokenType  = _1

-- | Access text content.
textContent :: Field3 a a Text Text => Lens' a Text
textContent  = _3


