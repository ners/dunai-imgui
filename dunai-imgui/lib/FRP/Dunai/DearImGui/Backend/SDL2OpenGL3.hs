module FRP.Dunai.DearImGui.Backend.SDL2OpenGL3 where

import DearImGui (createContext, destroyContext, getDrawData, newFrame, render)
import DearImGui.OpenGL3 (openGL3Init, openGL3NewFrame, openGL3RenderDrawData, openGL3Shutdown)
import DearImGui.SDL (pollEventsWithImGui, sdl2NewFrame, sdl2Shutdown)
import DearImGui.SDL.OpenGL (sdl2InitForOpenGL)
import FRP.Dunai.DearImGui.Backend
import Graphics.GL qualified as GL
import Internal.Prelude
import SDL qualified

data SDL2OpenGL3

instance Backend SDL2OpenGL3 where
    type Window SDL2OpenGL3 = SDL.Window
    type WindowConfig SDL2OpenGL3 = SDL.WindowConfig
    withWindow title config f = do
        SDL.initializeAll
        runManaged do
            window <- managed $ bracket (SDL.createWindow title config) SDL.destroyWindow

            -- Create an OpenGL context
            glContext <- managed $ bracket (SDL.glCreateContext window) SDL.glDeleteContext

            -- Create an ImGui context
            _context <- managed $ bracket createContext destroyContext

            -- Initialize ImGui's SDL2 backend
            managed_ $ bracket_ (sdl2InitForOpenGL window glContext) sdl2Shutdown

            -- Initialize ImGui's OpenGL backend
            managed_ $ bracket_ openGL3Init openGL3Shutdown

            liftIO $ f window
    renderFrame window f = proc a -> do
        constMLiftIO newFrame' -< ()
        f -< a
        constMLiftIO render' -< ()
      where
        newFrame' :: IO ()
        newFrame' = do
            openGL3NewFrame
            sdl2NewFrame
            newFrame
        render' :: IO ()
        render' = do
            GL.glClear GL.GL_COLOR_BUFFER_BIT
            render
            openGL3RenderDrawData =<< getDrawData
            SDL.glSwapWindow window
    quit = proc _ -> do
        constM (any isQuit <$> pollEventsWithImGui) -< ()
      where
        isQuit :: SDL.Event -> Bool
        isQuit e = SDL.eventPayload e == SDL.QuitEvent
