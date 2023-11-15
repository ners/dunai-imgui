module FRP.Dunai.DearImGui.Widgets.InputText where

import Data.IORef (newIORef, readIORef)
import Data.Tuple.Extra (uncurry3)
import DearImGui qualified
import Internal.Prelude

data InputText = InputText
    { label :: Text
    , value :: Text
    , changed :: Bool
    }
    deriving stock (Generic)

type IsInputText b =
    ( HasLabel b
    , HasValue b Text
    , HasChanged b
    )

textInput :: (MonadIO m, IsInputText t) => MSF m t t
textInput = proc t -> do
    ref <- arrM (liftIO . newIORef) -< t.value
    changed <- arrM (uncurry3 DearImGui.inputText) -< (t.label, ref, 99999)
    if changed
        then do
            value <- arrM (liftIO . readIORef) -< ref
            returnA -< t & #value .~ value
        else returnA -< t
