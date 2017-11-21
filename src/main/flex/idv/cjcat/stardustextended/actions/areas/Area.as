package idv.cjcat.stardustextended.actions.areas {
import flash.geom.Point;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.math.StardustMath;

public class Area extends StardustElement implements IPosition
{

    public var x : Number;
    public var y : Number;
    protected var _rotation : Number;
    protected var angleCos : Number;
    protected var angleSin : Number;
    protected const position : Point = new Point();

    public function Area()
    {
        rotation = 0;
    }
    
    /**
     * [Abstract Method] Determines if a point is contained in the area, true if contained.
     */
    public function contains(x : Number, y : Number) : Boolean
    {
        //abstract method
        return false;
    }

    public function get rotation() : Number
    {
        return _rotation;
    }

    public function set rotation(value : Number) : void
    {
        var valInRad : Number = value * StardustMath.DEGREE_TO_RADIAN;
        angleCos = Math.cos(valInRad);
        angleSin = Math.sin(valInRad);
        _rotation = value;
    }

    /**
     * Sets the position of this area.
     */
    public function setPosition(xc:Number, yc:Number):void
    {
        x = xc;
        y = yc;
    }

    /**
     * Gets the position of this area.
     */
    public function getPosition():Point
    {
        position.setTo(x, y);
        return position;
    }
}
}
