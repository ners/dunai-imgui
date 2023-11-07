module MyLib (someFunc) where

import Control.Exception
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Managed
import DearImGui
import DearImGui.OpenGL3
import DearImGui.SDL
import DearImGui.SDL.OpenGL
import Graphics.GL.Core32
import SDL
import Prelude

someFunc :: IO ()
someFunc = do
    -- Initialize SDL
    initializeAll

    runManaged do
        -- Create a window using SDL. As we're using OpenGL, we need to enable OpenGL too.
        window <- do
            let config = defaultWindow{windowGraphicsContext = OpenGLContext defaultOpenGL}
            managed $ bracket (createWindow "Hello, Dear ImGui!" config) destroyWindow

        -- Create an OpenGL context
        glContext <- managed $ bracket (glCreateContext window) glDeleteContext

        -- Create an ImGui context
        _context <- managed $ bracket createContext destroyContext

        -- Initialize ImGui's SDL2 backend
        managed_ $ bracket_ (sdl2InitForOpenGL window glContext) sdl2Shutdown

        -- Initialize ImGui's OpenGL backend
        managed_ $ bracket_ openGL3Init openGL3Shutdown

        liftIO $ mainLoop window

mainLoop :: Window -> IO ()
mainLoop window = unlessQuit do
    -- Tell ImGui we're starting a new frame
    openGL3NewFrame
    sdl2NewFrame
    newFrame

    -- Build the GUI
    withWindowOpen "Hello, ImGui!" do
        -- Add a text widget
        text "Hello, ImGui!"

        -- Add a button widget, and call 'putStrLn' when it's clicked
        button "Clickety Click" >>= \case
            False -> pure ()
            True -> putStrLn "Ow!"

    -- Show the ImGui demo window
    showDemoWindow

    -- Render
    glClear GL_COLOR_BUFFER_BIT

    render
    openGL3RenderDrawData =<< getDrawData

    glSwapWindow window

    mainLoop window
  where
    -- Process the event loop
    unlessQuit :: IO () -> IO ()
    unlessQuit action = do
        shouldQuit <- checkEvents
        unless shouldQuit action

    checkEvents :: IO Bool
    checkEvents = do
        pollEventWithImGui >>= \case
            Nothing ->
                pure False
            Just event ->
                (isQuit event ||) <$> checkEvents

    isQuit :: Event -> Bool
    isQuit event =
        SDL.eventPayload event == SDL.QuitEvent
