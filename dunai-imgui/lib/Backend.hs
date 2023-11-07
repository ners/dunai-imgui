{-# LANGUAGE AllowAmbiguousTypes #-}

module Backend where

import Control.Monad.IO.Class (MonadIO)
import Data.MonadicStreamFunction (MSF, morphS)
import Data.Text (Text)
import Prelude
import Control.Monad.Trans.MSF (reactimateB)

class Backend b where
    type Window b
    type WindowConfig b
    withWindow :: Text -> WindowConfig b -> (Window b -> IO ()) -> IO ()
    renderFrame :: (MonadIO m) => Window b -> MSF m () () -> MSF m () ()
    quit :: (MonadIO m) => MSF m () Bool

runApp :: forall b m. (Backend b, MonadIO m) => (forall c. m c -> IO c) -> Text -> WindowConfig b -> MSF m () () -> IO ()
runApp nt title config f = withWindow @b title config $ \window -> do
    let mainLoop = proc _ -> do
            renderFrame @b window f -< ()
            quit @b -< ()
    reactimateB $ morphS nt mainLoop

runAppIO :: forall b. (Backend b) => Text -> WindowConfig b -> MSF IO () () -> IO ()
runAppIO = runApp @b id
