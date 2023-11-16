module FRP.Dunai.DearImGui.Types where

import Control.Monad.Fix (MonadFix)
import Data.Generics.Labels ()
import Data.Generics.Product qualified as Lens
import Data.Text (Text)
import GHC.Records (HasField)
import UnliftIO (MonadUnliftIO)
import Prelude

-- | A widget ID by name
type ID = Text

type HasLabel a =
    ( HasField "label" a Text
    , Lens.HasField "label" a a Text Text
    )

type HasClicked a =
    ( HasField "clicked" a Bool
    , Lens.HasField "clicked" a a Bool Bool
    )

type HasValue a v =
    ( HasField "value" a v
    , Lens.HasField "value" a a v v
    )

type HasChanged a =
    ( HasField "changed" a Bool
    , Lens.HasField "changed" a a Bool Bool
    )

type MonadGUI m =
    ( MonadUnliftIO m
    , MonadFix m
    )
