module FRP.Dunai.DearImGui.Widgets.Button where

import DearImGui qualified
import Internal.Prelude

data Button = Button
    { disabled :: Bool
    , label :: Text
    , clicked :: Bool
    }
    deriving stock (Generic, Eq, Show)

type IsButton b =
    ( IsWidget b
    , HasLabel b
    , HasClicked b
    )

button :: (MonadGUI m, IsButton b) => MSF m b b
button = proc b -> do
    clicked <- arrM DearImGui.button -< b.label
    returnA -< b & #clicked .~ clicked
