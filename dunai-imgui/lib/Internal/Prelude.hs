module Internal.Prelude
    ( module Prelude
    , module Control.Arrow
    , module Control.Lens.Operators
    , module Control.Monad.Fix
    , module Control.Monad.Managed
    , module Control.Monad.Trans.MSF
    , module Data.Functor
    , module Data.MonadicStreamFunction
    , module Data.MonadicStreamFunction.Extra
    , module Data.Text
    , module Debug.Trace
    , module FRP.Dunai.DearImGui.Types
    , module GHC.Generics
    , module UnliftIO
    , module UnliftIO.IO
    , module UnliftIO.IORef
    , traceMSF
    )
where

import Control.Arrow
import Control.Lens.Operators
import Control.Monad.Fix (MonadFix)
import Control.Monad.Managed (managed, managed_, runManaged)
import Control.Monad.Trans.MSF (reactimateB)
import Data.Functor
import Data.MonadicStreamFunction (MSF, arrM, constM, morphS, returnA)
import Data.MonadicStreamFunction.Extra
import Data.Text (Text)
import Debug.Trace
import FRP.Dunai.DearImGui.Types
import GHC.Generics (Generic)
import Prelude
import UnliftIO
import UnliftIO.IO
import UnliftIO.IORef

traceMSF :: forall a m. (Show a, Monad m) => String -> MSF m a a
traceMSF prefix = proc a -> do
    arrM traceM -< prefix <> show a
    returnA -< a
