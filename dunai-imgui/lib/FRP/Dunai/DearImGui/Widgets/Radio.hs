module FRP.Dunai.DearImGui.Widgets.Radio where

import DearImGui qualified
import Internal.Prelude

data Gender = Male | Female | Other Text

type IsRadio r = (IsWidget r, HasLabel r)

radio :: forall m r. (MonadGUI m, IsRadio r) => MSF m r r
radio = error "Not yet implemented upstream"
