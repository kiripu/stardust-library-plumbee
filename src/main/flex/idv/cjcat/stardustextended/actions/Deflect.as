package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.actions.triggers.DeflectorTrigger;
import idv.cjcat.stardustextended.deflectors.Deflector;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * This action is useful to manipulate a particle's position and velocity as you like.
 *
 * <p>
 * Each deflector returns a <code>MotionData4D</code> object, which contains four numeric properties: x, y, vx, and vy,
 * according to the particle's position and velocity.
 * The particle's position and velocity are then reassigned to the new values (x, y) and (vx, vy), respectively.
 * </p>
 *
 * <p>
 * Deflectors can be used to create obstacles, bounding boxes, etc.
 * </p>
 *
 * <p>
 * Default priority = -5;
 * </p>
 *
 * @see idv.cjcat.stardustextended.deflectors.Deflector
 */
public class Deflect extends Action
{

    protected var _deflectors : Vector.<Deflector>;

    public function Deflect()
    {
        _priority = -5;
        _deflectors = new Vector.<Deflector>();
    }

    /**
     * Adds a deflector to the simulation.
     * @param    deflector
     */
    public function addDeflector(deflector : Deflector) : void
    {
        _deflectors.push(deflector);
    }

    /**
     * Removes a deflector from the simulation.
     * @param    deflector
     */
    public function removeDeflector(deflector : Deflector) : void
    {
        var index : int = _deflectors.indexOf(deflector);
        _deflectors.splice(index, 1);
    }

    public function get deflectors() : Vector.<Deflector>
    {
        return _deflectors;
    }

    public function set deflectors(val : Vector.<Deflector>) : void
    {
        _deflectors = val;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        for each (var deflector : Deflector in _deflectors)
        {
            var md4D : MotionData4D = deflector.getMotionData4D(particle);
            if (md4D)
            {
                particle.isDeflected = true;
                particle.x = md4D.x;
                particle.y = md4D.y;
                particle.vx = md4D.vx;
                particle.vy = md4D.vy;
                MotionData4DPool.recycle(md4D);
            } else
            {
                particle.isDeflected = false;
            }
        }
    }

}
}