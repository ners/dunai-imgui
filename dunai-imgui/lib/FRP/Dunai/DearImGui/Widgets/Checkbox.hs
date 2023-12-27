module FRP.Dunai.DearImGui.Widgets.Checkbox where

import DearImGui qualified
import Internal.Prelude

data Checkbox = Checkbox
    { disabled :: Bool
    , label :: Text
    , checked :: Bool
    }
    deriving stock (Generic, Eq, Show)

type IsCheckbox b =
    ( IsWidget b
    , HasLabel b
    , HasChecked b
    )

checkbox :: (MonadGUI m, IsCheckbox b) => MSF m b b
checkbox = proc b -> do
    ref <- arrM newIORef -< b.checked
    void $ arrM (uncurry DearImGui.checkbox) -< (b.label, ref)
    checked <- arrM readIORef -< ref
    returnA -< b & #checked .~ checked
