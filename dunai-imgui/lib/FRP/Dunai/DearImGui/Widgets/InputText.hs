{-# OPTIONS_GHC -Wno-name-shadowing #-}

module FRP.Dunai.DearImGui.Widgets.InputText where

import Data.IORef (newIORef, readIORef)
import Data.Tuple.Extra (uncurry3)
import DearImGui (ImVec2 (ImVec2))
import DearImGui qualified
import Internal.Prelude

uncurry4 :: (a -> b -> c -> d -> e) -> (a, b, c, d) -> e
uncurry4 f (a, b, c, d) = f a b c d

data InputText = InputText
    { label :: Text
    , value :: Text
    , changed :: Bool
    }
    deriving stock (Generic, Eq, Show)

type IsInputText b =
    ( HasLabel b
    , HasValue b Text
    , HasChanged b
    )

inputText :: (MonadIO m, IsInputText t) => MSF m t t
inputText = proc t -> do
    ref <- arrM (liftIO . newIORef) -< t.value
    -- changed <- arrM (uncurry4 DearImGui.inputTextMultiline) -< (t.label, ref, 99999, vec)
    changed <- arrM (uncurry3 DearImGui.inputText) -< (t.label, ref, 99999)
    value <- arrM (liftIO . readIORef) -< ref
    let modify = #changed .~ changed >>> #value .~ value
    returnA -< modify t

-- where
--  vec = ImVec2 0 0
