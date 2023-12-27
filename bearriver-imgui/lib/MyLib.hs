module MyLib where

import Control.Monad.Trans.MSF (runReaderS_)
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import DearImGui qualified
import FRP.BearRiver
import FRP.Dunai.DearImGui.Backend (runAppIO)
import FRP.Dunai.DearImGui.Backend.SDL2OpenGL3
import FRP.Dunai.DearImGui.Widgets
import FRP.Dunai.DearImGui.Widgets.Checkbox
import FRP.Dunai.DearImGui.Widgets.Plotting
import FRP.Dunai.DearImGui.Widgets.Slider
import GHC.Float (double2Float)
import Internal.Prelude
import SDL qualified

someFunc :: IO ()
someFunc = do
    let config = SDL.defaultWindow{SDL.windowGraphicsContext = SDL.OpenGLContext SDL.defaultOpenGL}
    runAppIO @SDL2OpenGL3 "Hello, Dear ImGui!" config (runReaderS_ frame 0.1)

frame :: forall m. (MonadGUI m) => SF m () ()
frame = proc _ -> do
    constM DearImGui.showDemoWindow -< ()
    t' <- inputTextCustom noCovfefe t -< ()
    if t'.changed
        then arrM (liftIO . print) -< t'.value
        else returnA -< ()
    button1' <- button -< button1
    button2' <- button -< button2
    buttonClicked -< button1'
    buttonClicked -< button2'
    rec check1' <- checkbox <<< iPre check1 -< check1'
    rec float1' <- sliderFloat <<< iPre float1 -< float1'
    sinWave <- arr (double2Float . sin) <<< FRP.BearRiver.time -< ()
    let sinVal = if sinWave > 0 then Just sinWave else Nothing
        opposite = if sinWave < 0 then Just sinWave else Nothing
    plotLinesHalting 100 -< PlotLineData{value = sinVal, label = "positive sin"}
    plotLinesHalting 100 -< PlotLineData{value = opposite, label = "negative sin"}
  where
    button1 =
        Button
            { disabled = False
            , label = "fox"
            , clicked = False
            }
    button2 =
        Button
            { disabled = False
            , label = "derg"
            , clicked = False
            }
    check1 =
        Checkbox
            { disabled = False
            , label = "foo"
            , checked = False
            }
    float1 :: Slider Float
    float1 =
        Slider
            { disabled = False
            , label = "Choose a float"
            , range = (0, 100)
            , value = 0
            }
    buttonClicked :: SF m Button ()
    buttonClicked = proc p -> do
        if p.clicked
            then arrM (liftIO . Text.putStrLn) -< p.label <> " clicked"
            else returnA -< ()
    t :: InputText
    t =
        InputText
            { disabled = False
            , label = "Text por favor"
            , value = ""
            , changed = False
            }
    noCovfefe :: SF m InputText InputText
    noCovfefe = arr $ #value %~ Text.replace "covfefe" "coverage"
