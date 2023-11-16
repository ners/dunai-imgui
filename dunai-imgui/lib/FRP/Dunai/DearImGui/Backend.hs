{-# LANGUAGE AllowAmbiguousTypes #-}

module FRP.Dunai.DearImGui.Backend where

import Internal.Prelude

class Backend b where
    type Window b
    type WindowConfig b
    withWindow :: Text -> WindowConfig b -> (Window b -> IO ()) -> IO ()
    renderFrame :: (MonadGUI m) => Window b -> MSF m () () -> MSF m () ()
    quit :: (MonadGUI m) => MSF m () Bool

runApp :: forall b m. (Backend b, MonadGUI m) => (forall c. m c -> IO c) -> Text -> WindowConfig b -> MSF m () () -> IO ()
runApp nt title config f = withWindow @b title config $ \window -> do
    let mainLoop = proc _ -> do
            renderFrame @b window f -< ()
            quit @b -< ()
    reactimateB $ morphS nt mainLoop

runAppIO :: forall b. (Backend b) => Text -> WindowConfig b -> MSF IO () () -> IO ()
runAppIO = runApp @b id
