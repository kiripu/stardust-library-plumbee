package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;

/**
 * Line segment zone.
 */
public class Line extends Contour
{

    override public function set x(value : Number) : void
    {
        _x = value;
        updateArea();
    }

    override public function set y(value : Number) : void
    {
        _y = value;
        updateArea();
    }

    private var _x2 : Number;
    /**
     * The X coordinate of the other end of the line.
     */
    public function get x2() : Number
    {
        return _x2;
    }

    public function set x2(value : Number) : void
    {
        _x2 = value;
        updateArea();
    }

    private var _y2 : Number;
    /**
     * The Y coordinate of the other end of the line.
     */
    public function get y2() : Number
    {
        return _y2;
    }

    public function set y2(value : Number) : void
    {
        _y2 = value;
        updateArea();
    }

    private var _random : Random;

    public function Line(x1 : Number = 0, y1 : Number = 0, x2 : Number = 0, y2 : Number = 0, random : Random = null)
    {
        this._x = x1;
        this._y = y1;
        this._x2 = x2;
        this._y2 = y2;
        this.random = random;
        updateArea();
    }

    override public function setPosition(xc : Number, yc : Number) : void
    {
        var xDiff : Number = _x2 - _x;
        var yDiff : Number = _y2 - _y;
        _x = xc;
        _y = yc;
        _x2 = xc + xDiff;
        _y2 = yc + yDiff;
    }

    public function get random() : Random
    {
        return _random;
    }

    public function set random(value : Random) : void
    {
        if (!value) value = new UniformRandom();
        _random = value;
    }

    override protected function calculateMotionData2D() : MotionData2D
    {
        _random.setRange(0, 1);
        var rand : Number = _random.random();
        return MotionData2DPool.get(StardustMath.interpolate(0, 0, 1, _x2 - _x, rand), StardustMath.interpolate(0, 0, 1, _y2 - _y, rand));
    }

    override protected function updateArea() : void
    {
        var dx : Number = _x - _x2;
        var dy : Number = _y - _y2;
        area = Math.sqrt(dx * dx + dy * dy) * virtualThickness;
    }

}
}