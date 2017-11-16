package idv.cjcat.stardustextended.actions.triggers
{

import idv.cjcat.stardustextended.deflectors.Deflector;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

public class DeflectorTrigger extends Trigger
{

    public var deflector : Deflector;

    public function DeflectorTrigger(deflector : Deflector = null)
    {
        this.deflector = deflector;
    }

    override public function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        return Boolean(particle.dictionary[deflector]);
    }

}
}