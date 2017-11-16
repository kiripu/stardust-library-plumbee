package idv.cjcat.stardustextended.deflectors
{
import flash.geom.Point;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Used along with the <code>Deflect</code> action.
 *
 * @see idv.cjcat.stardustextended.actions.Deflect
 */
public class Deflector extends StardustElement implements IPosition
{

    public var active : Boolean;
    public var bounce : Number;
    protected const position : Point = new Point();
    /**
     * Determines how slippery the surfaces are. A value of 1 (default) means that the surface is fully slippery,
     * a value of 0 means that particles will not slide on its surface at all.
     */
    public var slipperiness : Number;

    public function Deflector()
    {
        active = true;
        bounce = 0.8;
        slipperiness = 1;
    }

    public final function getMotionData4D(particle : Particle) : MotionData4D
    {
        if (active) {
            return calculateMotionData4D(particle);
        }
        return null;
    }

    /**
     * [Abstract Method] Returns a <code>MotionData4D</code> object representing the deflected position and velocity coordinates for a particle.
     * Returns null if no deflection occurred. A non-null value can trigger the <code>DeflectorTrigger</code> action trigger.
     * @param    particle
     * @return
     * @see idv.cjcat.stardustextended.actions.triggers.DeflectorTrigger
     */
    protected function calculateMotionData4D(particle : Particle) : MotionData4D
    {
        //abstract method
        return null;
    }

    /**
     * [Abstract Method] Sets the position of this Deflector.
     */
    public function setPosition(xc : Number, yc : Number) : void
    {
        throw new Error("This method must be overridden by subclasses");
    }

    /**
     * [Abstract Method] Gets the position of this Deflector.
     */
    public function getPosition() : Point
    {
        throw new Error("This method must be overridden by subclasses");
    }

}
}