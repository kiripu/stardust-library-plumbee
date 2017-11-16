package idv.cjcat.stardustextended.fields
{
import flash.geom.Point;

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Radial field.
 */
public class RadialField extends Field
{

    /**
     * The X coordinate of the center of the field.
     */
    public var x : Number;
    /**
     * The Y coordinate of the center of the field.
     */
    public var y : Number;
    /**
     * The strength of the field.
     */
    public var strength : Number;
    /**
     * The attenuation power of the field, in powers per pixel.
     */
    public var attenuationPower : Number;
    /**
     * If a point is closer to the center than this value,
     * it's treated as if it's this far from the center.
     * This is to prevent simulation from blowing up for points too near to the center.
     */
    public var epsilon : Number;

    public function RadialField(x : Number = 0, y : Number = 0, strength : Number = 1, attenuationPower : Number = 0, epsilon : Number = 1)
    {
        this.x = x;
        this.y = y;
        this.strength = strength;
        this.attenuationPower = attenuationPower;
        this.epsilon = epsilon;
    }

    override protected function calculateMotionData2D(particle : Particle) : MotionData2D
    {
        var r : Vec2D = Vec2DPool.get(particle.x - x, particle.y - y);
        var len : Number = r.length;
        if (len < epsilon) len = epsilon;
        r.length = strength * Math.pow(len, -0.5 * attenuationPower);
        Vec2DPool.recycle(r);

        return MotionData2DPool.get(r.x, r.y);
    }

    override public function setPosition(xc : Number, yc : Number) : void
    {
        x = xc;
        y = yc;
    }

    override public function getPosition() : Point
    {
        position.setTo(x, y);
        return position;
    }
}
}