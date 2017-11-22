package idv.cjcat.stardustextended.actions.triggers
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

public class DeflectorTrigger extends Trigger
{

    override public function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        return particle.isDeflected;
    }

}
}