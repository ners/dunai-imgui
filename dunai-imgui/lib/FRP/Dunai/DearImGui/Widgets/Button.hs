module FRP.Dunai.DearImGui.Widgets.Button where

import Internal.Prelude
import DearImGui qualified

data Button = Button
    { label :: Text
    , clicked :: Bool
    }
    deriving stock (Generic)

type IsButton b =
    ( HasLabel b
    , HasClicked b
    )

button :: (MonadIO m, IsButton b) => MSF m b b
button = proc b -> do
    clicked <- arrM DearImGui.button -< b.label
    returnA -< b & #clicked .~ clicked
