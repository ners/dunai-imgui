{-# OPTIONS_GHC -Wno-monomorphism-restriction #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}

module FRP.Dunai.DearImGui.Widgets.InputText where

import Data.MonadicStreamFunction (iPre)
import Data.Tuple.Extra (uncurry3)
import DearImGui qualified as DearImgui
import Internal.Prelude

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

-- | TODO Cajun will write nice docs here :-)
inputText' :: forall m t. (MonadGUI m, IsInputText t) => MSF m t t
inputText' = proc t -> do
    ref <- arrM newIORef -< t.value
    -- FIXME input text callbacks are not supported in dear-imgui.hs.
    -- Changes must be made to the library itself and upstreamed
    changed <- arrM (uncurry3 DearImgui.inputText) -< (t.label, ref, 99999)
    value <- arrM readIORef -< ref
    let modify = #changed .~ changed <<< #value .~ value
    returnA -< modify t

-- | TODO Cajun will write nice docs here :-)
inputTextCustom :: forall m t. (MonadGUI m, IsInputText t) => MSF m t t -> t -> MSF m () t
inputTextCustom sf initialT = proc () -> do
    rec outputT <- sf <<< inputText' <<< iPre initialT -< outputT
    returnA -< outputT

-- | TODO Cajun will write nice docs here :-)
inputText :: forall m t. (MonadGUI m, IsInputText t) => t -> MSF m () t
inputText = inputTextCustom (arr id)
