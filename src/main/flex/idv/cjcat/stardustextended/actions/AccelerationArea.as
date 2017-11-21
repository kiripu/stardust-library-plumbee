package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.actions.areas.Area;
import idv.cjcat.stardustextended.actions.areas.AreaCollection;
import idv.cjcat.stardustextended.actions.areas.IAreaContainer;
import idv.cjcat.stardustextended.actions.areas.RectArea;

/**
 * Causes particles to change acceleration specified area.
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
public class AccelerationArea extends Action implements IAreaContainer
{
    protected var areaCollection : AreaCollection;
    /**
     * Inverts the area region.
     */
    public var inverted : Boolean;

    /**
     * The acceleration applied in each step to particles inside the area.
     */
    public var acceleration : Number;
    /**
     * Flag whether to use the particle's speed or the direction variable. Default is true.
     */
    public var useParticleDirection : Boolean;

    /**
     * Acceleration type: 0 = constant, 1 = linear
     */
    public var accelerationType : uint = 1;

    private var _directionX : Number;

    private var _directionY : Number;

    /**
     * the direction of the acceleration. Only used if useParticleDirection is false
     */
    public function get direction() : Number
    {
        return Math.atan2(_directionY, _directionX) * StardustMath.RADIAN_TO_DEGREE;
    }

    public function set direction(value : Number) : void
    {
        var rad : Number = value * StardustMath.DEGREE_TO_RADIAN;
        _directionX = Math.cos(rad);
        _directionY = Math.sin(rad);
    }

    public function get areas() : Vector.<Area>
    {
        return areaCollection.areas;
    }

    public function set areas(value : Vector.<Area>) : void
    {
        areaCollection.areas = value;
    }

    public function AccelerationArea(areas : Vector.<Area> = null, _inverted : Boolean = false)
    {
        priority = -6;
        inverted = _inverted;
        acceleration = 3;
        useParticleDirection = true;
        direction = -90;
        areaCollection = new AreaCollection();
        if (areas)
        {
            areaCollection.areas = areas;
        }
        else
        {
            areaCollection.areas.push(new RectArea());
        }
    }

    // Normalized linear acceleration, so values are in the same range as constant.
    private var accelNormalized : Number;

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        accelNormalized = acceleration / 20 + 1;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var affected : Boolean = areaCollection.contains(particle.x, particle.y);
        if (inverted)
        {
            affected = !affected;
        }
        if (affected)
        {
            if (useParticleDirection)
            {
                if (accelerationType == 0)
                {
                    var v : Vec2D = Vec2DPool.get(particle.vx, particle.vy);
                    const vecLength : Number = v.length;
                    if (vecLength > 0)
                    {
                        var finalVal : Number;
                        finalVal = vecLength + acceleration;
                        if (finalVal < 0)
                        {
                            finalVal = 0;
                        }
                        v.length = finalVal;
                        particle.vx = v.x;
                        particle.vy = v.y;
                    }
                    Vec2DPool.recycle(v);
                }
                else if (accelerationType == 1)
                {
                    particle.vx *= accelNormalized;
                    particle.vy *= accelNormalized;
                }
            }
            else
            {
                if (accelerationType == 0)
                {
                    particle.vx = particle.vx + acceleration * _directionX;
                    particle.vy = particle.vy + acceleration * _directionY;
                }
                else if (accelerationType == 1)
                {
                    particle.vx *= acceleration * _directionX;
                    particle.vy *= acceleration * _directionY;
                }
            }
        }
    }

}
}