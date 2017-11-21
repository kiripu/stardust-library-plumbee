package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;

/**
 * Sector-shaped zone.
 */
public class Sector extends Zone
{

    private var _randomT : Random;
    private var _minRadius : Number;
    private var _maxRadius : Number;
    private var _minAngle : Number;
    private var _maxAngle : Number;
    private var _minAngleRad : Number;
    private var _maxAngleRad : Number;

    public function Sector(x : Number = 0, y : Number = 0, minRadius : Number = 0, maxRadius : Number = 100,
                           minAngle : Number = 0, maxAngle : Number = 360)
    {
        _randomT = new UniformRandom();

        this._x = x;
        this._y = y;
        this._minRadius = minRadius;
        this._maxRadius = maxRadius;
        this._minAngle = minAngle;
        this._maxAngle = maxAngle;

        updateArea();
    }

    /**
     * The minimum radius of the sector.
     */
    public function get minRadius() : Number
    {
        return _minRadius;
    }

    public function set minRadius(value : Number) : void
    {
        _minRadius = value;
        updateArea();
    }

    /**
     * The maximum radius of the sector.
     */
    public function get maxRadius() : Number
    {
        return _maxRadius;
    }

    public function set maxRadius(value : Number) : void
    {
        _maxRadius = value;
        updateArea();
    }

    /**
     * The minimum angle of the sector.
     */
    public function get minAngle() : Number
    {
        return _minAngle;
    }

    public function set minAngle(value : Number) : void
    {
        _minAngle = value;
        updateArea();
    }

    /**
     * The maximum angle of the sector.
     */
    public function get maxAngle() : Number
    {
        return _maxAngle;
    }

    public function set maxAngle(value : Number) : void
    {
        _maxAngle = value;
        updateArea();
    }

    override protected function calculateMotionData2D() : MotionData2D
    {
        if (_maxRadius == 0) return MotionData2DPool.get(_x, _y);

        _randomT.setRange(_minAngleRad, _maxAngleRad);
        var theta : Number = _randomT.random();
        var r : Number = StardustMath.interpolate(0, _minRadius, 1, _maxRadius, Math.sqrt(Math.random()));

        return MotionData2DPool.get(r * Math.cos(theta), r * Math.sin(theta));
    }

    override protected function updateArea() : void
    {
        _minAngleRad = _minAngle * StardustMath.DEGREE_TO_RADIAN;
        _maxAngleRad = _maxAngle * StardustMath.DEGREE_TO_RADIAN;
        if (Math.abs(_minAngleRad) > StardustMath.TWO_PI)
        {
            _minAngleRad = _minAngleRad % StardustMath.TWO_PI;
        }
        if (Math.abs(_maxAngleRad) > StardustMath.TWO_PI)
        {
            _maxAngleRad = _maxAngleRad % StardustMath.TWO_PI;
        }
        var dT : Number = _maxAngleRad - _minAngleRad;

        var dRSQ : Number = _minRadius * _minRadius - _maxRadius * _maxRadius;

        area = Math.abs(dRSQ * dT);
    }

}
}