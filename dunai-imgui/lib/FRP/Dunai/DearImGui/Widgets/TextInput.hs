module FRP.Dunai.DearImGui.Widgets.TextInput where

import Internal.Prelude

data TextInput = TextInput
    { label :: Text
    , value :: Text
    }
    deriving stock (Generic)

type IsTextInput b =
    ( HasLabel b
    , HasValue b Text
    )

textInput :: (MonadIO m, IsTextInput t) => MSF m t t
textInput = proc b -> do
    arrM (liftIO . print) -< b.value
    returnA -< b
