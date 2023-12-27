module FRP.Dunai.DearImGui.Widgets.Slider where

import Data.Generics.Product qualified as Lens
import DearImGui qualified
import GHC.Float (double2Float, float2Double)
import GHC.Records (HasField)
import Internal.Prelude

data Slider v = Slider
    { disabled :: Bool
    , label :: Text
    , range :: (v, v)
    , value :: v
    }
    deriving stock (Generic, Eq, Show)

type HasRange a v =
    ( HasField "range" a (v, v)
    , Lens.HasField "range" a a (v, v) (v, v)
    )

type IsSlider s v =
    ( IsWidget s
    , HasLabel s
    , HasRange s v
    , HasValue s v
    )

slider :: forall m s v v'. (MonadGUI m, IsSlider s v) => (Text -> IORef v' -> v' -> v' -> m Bool) -> (v -> v') -> (v' -> v) -> MSF m s s
slider f from to = proc s -> do
    ref <- arrM newIORef -< from s.value
    void $ arrM (\(label, value, (from -> minValue, from -> maxValue)) -> f label value minValue maxValue) -< (s.label, ref, s.range)
    value <- arrM readIORef -< ref
    returnA -< s & #value .~ to value

sliderFloat :: forall m s. (MonadGUI m, IsSlider s Float) => MSF m s s
sliderFloat = slider DearImGui.sliderFloat id id

sliderDouble :: forall m s. (MonadGUI m, IsSlider s Double) => MSF m s s
sliderDouble = slider DearImGui.sliderFloat double2Float float2Double

sliderInt :: forall m s i. (MonadGUI m, Integral i, IsSlider s i) => MSF m s s
sliderInt = slider DearImGui.sliderInt fromIntegral fromIntegral

-- TODO implement enum upstream
