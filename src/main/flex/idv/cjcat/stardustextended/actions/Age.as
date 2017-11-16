package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Causes a particle's life to decrease.
 */
public class Age extends Action
{

    /**
     * The multiplier of aging, 1 by default.
     *
     * <p>
     * For instance, a multiplier value of 2 causes a particle to age twice as fast as normal.
     * </p>
     *
     * <p>
     * Alternatively, you can assign a negative value to the multiplier.
     * This causes a particle's age to "increase".
     * You can then use this increasing value with <code>LifeTrigger</code> and other custom actions to create various effects.
     * </p>
     */
    public var multiplier : Number;

    public function Age(multiplier : Number = 1)
    {
        this.multiplier = multiplier;
    }

    override public final function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        particle.life -= timeDelta * multiplier;
        if (particle.life < 0) particle.life = 0;
    }

}
}