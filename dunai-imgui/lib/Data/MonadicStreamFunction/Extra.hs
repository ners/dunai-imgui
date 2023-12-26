module Data.MonadicStreamFunction.Extra where

import Control.Monad.Base (MonadBase (liftBase))
import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.MonadicStreamFunction (Arrow (..), MSF, constM, feedback, morphS)
import Prelude

liftConstM :: (MonadBase m1 m2) => m1 b -> MSF m2 a b
liftConstM = constM . liftBase

constMLiftIO :: (MonadIO m) => IO b -> MSF m a b
constMLiftIO = constM . liftIO

liftIOS :: (MonadIO m) => MSF IO a b -> MSF m a b
liftIOS = morphS liftIO

-- | Zero-order hold accumulatr parameterized by the accumulation function. This
-- is the same implementation as 'FRP.Yampa.accumHoldBy', but using 'Maybe'
-- instead of 'FRP.Yampa.Event'.
accumHoldBy :: (Monad m) => (b -> a -> b) -> b -> MSF m (Maybe a) b
accumHoldBy f b = feedback b $ arr $ \(a, b') ->
    let b'' = maybe b' (f b') a
     in (b'', b'')
