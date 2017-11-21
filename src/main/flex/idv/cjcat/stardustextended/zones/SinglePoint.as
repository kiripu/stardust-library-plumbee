package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Single point zone.
 */
public class SinglePoint extends Contour
{

    public function SinglePoint(x : Number = 0, y : Number = 0)
    {
        _x = x;
        _y = y;
        updateArea();
    }

    override protected function calculateMotionData2D() : MotionData2D
    {
        return MotionData2DPool.get(0, 0);
    }

    override protected function updateArea() : void
    {
        area = virtualThickness * virtualThickness * Math.PI;
    }

}

}