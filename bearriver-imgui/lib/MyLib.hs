module MyLib where

import Control.Monad.Trans.MSF (runReaderS_)
import FRP.BearRiver
import FRP.Dunai.DearImGui.Backend (runAppIO)
import FRP.Dunai.DearImGui.Backend.SDL2OpenGL3
import FRP.Dunai.DearImGui.Widgets
import SDL qualified
import Internal.Prelude

someFunc :: IO ()
someFunc = do
    let config = SDL.defaultWindow{SDL.windowGraphicsContext = SDL.OpenGLContext SDL.defaultOpenGL}
    runAppIO @SDL2OpenGL3 "Hello, Dear ImGui!" config (runReaderS_ frame 0.1)

frame :: forall m. (MonadIO m) => SF m () ()
frame = proc _ -> do
    --t' <- (traceMSF "inputText before: " >>> inputText >>> traceMSF "inputText after: ") -< t
    t' <- inputText -< t
    if t'.changed
        then arrM (liftIO . print) -< t'.value
        else returnA -< ()
    button1' <- button -< button1
    button2' <- button -< button2
    button1Clicked -< button1'.clicked
    button2Clicked -< button2'.clicked
  where
    button1 =
        Button
            { label = "fox"
            , clicked = False
            }
    button2 =
        Button
            { label = "derg"
            , clicked = False
            }
    button1Clicked :: SF m Bool ()
    button1Clicked = proc p -> do
        if p
            then arrM (liftIO . putStrLn) -< "fox"
            else returnA -< ()
    button2Clicked :: SF m Bool ()
    button2Clicked = proc p -> do
        if p
            then arrM (liftIO . putStrLn) -< "derg"
            else returnA -< ()
    t :: InputText
    t =
        InputText
            { label = "Text por favor"
            , value = ""
            , changed = False
            }
