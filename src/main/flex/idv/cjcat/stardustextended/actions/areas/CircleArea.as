package idv.cjcat.stardustextended.actions.areas
{

public class CircleArea extends Area
{
    private var _radius : Number;
    private var _radiusSQ : Number;

    public function CircleArea(x : Number = 0, y : Number = 0, radius : Number = 100)
    {
        this.x = x;
        this.y = y;
        this.radius = radius;
    }

    /**
     * The radius of the area.
     */
    public function get radius() : Number
    {
        return _radius;
    }

    public function set radius(value : Number) : void
    {
        _radius = value;
        _radiusSQ = value * value;
    }

    override public function contains(x : Number, y : Number) : Boolean
    {
        var dx : Number = this.x - x;
        var dy : Number = this.y - y;
        return ((dx * dx + dy * dy) <= _radiusSQ) ? true : false;
    }
}
}
