package idv.cjcat.stardustextended.actions.areas {
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

public class RectArea extends Area
{

    public var width : Number;
    public var height : Number;

    public function RectArea(x : Number = 0, y : Number = 0, width : Number = 150, height : Number = 50)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    override public function contains(xc : Number, yc : Number) : Boolean
    {
        if (_rotation != 0) {
            // rotate the point backwards instead, it has the same result
            var vec : Vec2D = Vec2DPool.get(xc, yc);
            vec.rotate(-_rotation);
            xc = vec.x;
            yc = vec.y;
        }
        if ((xc < x) || (xc > (x + width))) return false;
        else if ((yc < y) || (yc > (y + height))) return false;
        return true;
    }
}
}
