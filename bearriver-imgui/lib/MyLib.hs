module MyLib where

import Control.Monad.IO.Class (MonadIO (liftIO))
import Control.Monad.Trans.MSF (runReaderS_)
import DearImGui qualified
import FRP.BearRiver
import FRP.Dunai.DearImGui.Backend (runAppIO)
import FRP.Dunai.DearImGui.Backend.SDL2OpenGL3
import FRP.Dunai.DearImGui.Types (ID)
import FRP.Dunai.DearImGui.Widgets (button)
import SDL qualified
import Prelude

someFunc :: IO ()
someFunc = do
    let config = SDL.defaultWindow{SDL.windowGraphicsContext = SDL.OpenGLContext SDL.defaultOpenGL}
    runAppIO @SDL2OpenGL3 "Hello, Dear ImGui!" config (runReaderS_ frame 0.1)

frame :: forall m. (MonadIO m) => SF m () ()
frame = proc _ -> do
    button sf1 -< "fox"
    button sf2 -< "derg"
  where
    sf1 :: SF m Bool ()
    sf1 = proc p -> do
        if p
            then arrM (liftIO . putStrLn) -< "fox"
            else returnA -< ()
    sf2 :: SF m Bool ()
    sf2 = proc p -> do
        if p
            then arrM (liftIO . putStrLn) -< "derg"
            else returnA -< ()
