module FRP.Dunai.DearImGui.Widgets.Plotting where

import Data.Functor.Identity
import DearImGui qualified as ImGui (plotLines)
import Foreign.C.Types (CFloat (..))
import Internal.Prelude

-- | TODO: Cajun: write docs
type IsPlotLineBarbie b f =
    ( HasLabel b
    , HasValue b (f Float)
    )

type IsPlotLine b = IsPlotLineBarbie b Identity

type IsHaltingPlotLine b = IsPlotLineBarbie b Maybe

data PlotLineData f = PlotLineData
    { value :: f Float
    , label :: Text
    }
    deriving stock (Generic)

-- | Make a plot over time holding @n@ maximum datapoints. When a datapoint is
-- received, it is put into the FILO queue. Effectively, the leftmost datapoint
-- is removed in favor of the new rightmost datapoint. This plot cannot "halt,"
-- since it always requires input.
plotLines :: (MonadIO m, IsPlotLine t) => Int -> MSF m t ()
plotLines len = proc t -> do
    list <- holdList len -< Just . CFloat $ runIdentity t.value
    arrM $ uncurry ImGui.plotLines -< (t.label, list)

-- | A plot that allows for input to be halted, unlike 'plotLines'. When
-- 'Nothing' is provided in @t.value@, the list values do not change, and thus
-- the plot will not change.
plotLinesHalting :: (MonadIO m, IsHaltingPlotLine t) => Int -> MSF m t ()
plotLinesHalting len = proc t -> do
    list <- holdList len -< CFloat <$> t.value
    arrM $ uncurry ImGui.plotLines -< (t.label, list)

holdList :: (Monad m) => Int -> MSF m (Maybe a) [a]
holdList maxLen = proc a -> do
    (list, _) <- accumHoldBy accumFunc ([], 0) -< a
    returnA -< list
  where
    accumFunc :: ([a], Int) -> a -> ([a], Int)
    accumFunc (xs, n) x =
        if n >= maxLen
            then (tail xs ++ [x], n)
            else (xs ++ [x], n + 1)
