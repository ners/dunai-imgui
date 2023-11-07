module Data.MonadicStreamFunction.Extra where

import Control.Monad.Base (MonadBase (liftBase))
import Data.MonadicStreamFunction (MSF, constM, morphS)
import Prelude
import Control.Monad.IO.Class (MonadIO(liftIO))

liftConstM :: (MonadBase m1 m2) => m1 b -> MSF m2 a b
liftConstM = constM . liftBase

constMLiftIO :: (MonadIO m) => IO b -> MSF m a b
constMLiftIO = constM . liftIO

liftIOS :: (MonadIO m) => MSF IO a b -> MSF m a b
liftIOS = morphS liftIO
