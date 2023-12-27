module FRP.Dunai.DearImGui.Widgets.Checkbox where

import DearImGui qualified
import Internal.Prelude

data Checkbox = Checkbox
    { disabled :: Bool
    , label :: Text
    , checked :: Bool
    }
    deriving stock (Generic, Eq, Show)

type IsCheckbox c =
    ( IsWidget c
    , HasLabel c
    , HasChecked c
    )

checkbox :: (MonadGUI m, IsCheckbox c) => MSF m c c
checkbox = proc b -> do
    ref <- arrM newIORef -< b.checked
    void $ arrM (uncurry DearImGui.checkbox) -< (b.label, ref)
    checked <- arrM readIORef -< ref
    returnA -< b & #checked .~ checked
