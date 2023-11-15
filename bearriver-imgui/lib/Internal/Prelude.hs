module Internal.Prelude
    ( module Prelude
    , module Control.Arrow
    , module Control.Exception
    , module Control.Lens.Operators
    , module Control.Monad.IO.Class
    , module Control.Monad.Trans.MSF
    , module Data.MonadicStreamFunction
    , module Data.Text
    , module Debug.Trace
    , module FRP.Dunai.DearImGui.Types
    , module GHC.Generics
    , traceMSF
    )
where

import Control.Arrow
import Control.Exception (bracket, bracket_)
import Control.Lens.Operators
import Control.Monad.IO.Class (MonadIO (liftIO))
import Control.Monad.Trans.MSF (reactimateB)
import Data.MonadicStreamFunction (MSF, arrM, constM, morphS, returnA)
import Data.Text (Text)
import Debug.Trace
import FRP.Dunai.DearImGui.Types
import GHC.Generics (Generic)
import Prelude

traceMSF :: forall a m. (Show a, Monad m) => String -> MSF m a a
traceMSF prefix = proc a -> do
    arrM traceM -< prefix <> show a
    returnA -< a
