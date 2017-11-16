package idv.cjcat.stardustextended.zones
{
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;

/**
 * Rectangular zone.
 */
public class RectZone extends Zone
{

    private var _randomX : Random;
    private var _randomY : Random;
    private var _width : Number;
    private var _height : Number;

    public function RectZone(x : Number = 0, y : Number = 0, width : Number = 150, height : Number = 50, randomX : Random = null, randomY : Random = null)
    {
        if (!randomX) randomX = new UniformRandom();
        if (!randomY) randomY = new UniformRandom();

        this._x = x;
        this._y = y;
        this.width = width;
        this.height = height;
        this.randomX = randomX;
        this.randomY = randomY;
    }

    public function get width() : Number
    {
        return _width;
    }

    public function set width(value : Number) : void
    {
        _width = value;
        updateArea();
    }

    public function get height() : Number
    {
        return _height;
    }

    public function set height(value : Number) : void
    {
        _height = value;
        updateArea();
    }

    public function get randomX() : Random
    {
        return _randomX;
    }

    public function set randomX(value : Random) : void
    {
        if (!value) value = new UniformRandom();
        _randomX = value;
    }

    public function get randomY() : Random
    {
        return _randomY;
    }

    public function set randomY(value : Random) : void
    {
        if (!value) value = new UniformRandom();
        _randomY = value;
    }

    override protected function updateArea() : void
    {
        area = _width * _height;
    }

    override public function calculateMotionData2D() : MotionData2D
    {
        _randomX.setRange(0, _width);
        _randomY.setRange(0, _height);
        return MotionData2DPool.get(_randomX.random(), _randomY.random());
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
        if ((xc < _x) || (xc > (_x + _width))) return false;
        else if ((yc < _y) || (yc > (_y + _height))) return false;
        return true;
    }


}
}