package idv.cjcat.stardustextended.actions.triggers
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * This trigger will be triggered when a particle is alive.
 */
public class LifeTrigger extends Trigger
{

    /**
     * For this trigger to work, a particle's life must also be within the lower and upper bounds when this property is set to true,
     * or outside of the range if this property is set to false.
     */
    public var triggerWithinBounds : Boolean;

    private var _lowerBound : Number;
    private var _upperBound : Number;

    public function LifeTrigger(lowerBound : Number = 0, upperBound : Number = Number.MAX_VALUE, triggerWithinBounds : Boolean = true)
    {
        this.lowerBound = lowerBound;
        this.upperBound = upperBound;
        this.triggerWithinBounds = triggerWithinBounds;
    }

    override public final function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        if (triggerWithinBounds) {
            if ((particle.life >= _lowerBound) && (particle.life <= _upperBound)) {
                return true;
            }
        } else {
            if ((particle.life < _lowerBound) || (particle.life > _upperBound)) {
                return true;
            }
        }
        return false;
    }

    /**
     * The lower bound of effective range.
     */
    public function get lowerBound() : Number
    {
        return _lowerBound;
    }

    public function set lowerBound(value : Number) : void
    {
        if (value > _upperBound) _upperBound = value;
        _lowerBound = value;
    }

    /**
     * The upper bound of effective range.
     */
    public function get upperBound() : Number
    {
        return _upperBound;
    }

    public function set upperBound(value : Number) : void
    {
        if (value < _lowerBound) _lowerBound = value;
        _upperBound = value;
    }

}
}