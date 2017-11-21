package idv.cjcat.stardustextended.actions.areas
{
import idv.cjcat.stardustextended.math.StardustMath;

public class SectorArea extends Area
{
    public var minRadius : Number;
    public var maxRadius : Number;
    private var _minAngle : Number;
    private var _maxAngle : Number;
    private var _minAngleRad : Number;
    private var _maxAngleRad : Number;

    public function SectorArea(x : Number = 0, y : Number = 0, minRadius : Number = 0, maxRadius : Number = 100,
                               minAngle : Number = 0, maxAngle : Number = 360)
    {
        this.x = x;
        this.y = y;
        this.minRadius = minRadius;
        this.maxRadius = maxRadius;
        this._minAngle = minAngle;
        this._maxAngle = maxAngle;
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
        updateRadValues();
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
        updateRadValues();
    }

    private function updateRadValues() : void
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
    }

    override public function contains(x : Number, y : Number) : Boolean
    {
        const dx : Number = this.x - x;
        const dy : Number = this.y - y;
        var squaredDistance : Number = dx * dx + dy * dy;
        const isInsideOuterCircle : Boolean = (squaredDistance <= maxRadius * maxRadius);
        if (!isInsideOuterCircle) {
            return false;
        }
        const isInsideInnerCircle : Boolean = (squaredDistance <= minRadius * minRadius);
        if (isInsideInnerCircle) {
            return false;
        }
        const angle : Number = Math.atan2(dy, dx) + Math.PI;
        // TODO: does not work for edge cases, e.g. when minAngle = -20 and maxAngle = 20
        if (angle > _maxAngleRad || angle < _minAngleRad) {
            return false;
        }
        return true;
    }
}
}
