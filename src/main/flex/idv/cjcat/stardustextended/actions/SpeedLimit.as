package idv.cjcat.stardustextended.actions
{
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Limits a particle's maximum traveling speed.
 */
public class SpeedLimit extends Action
{

    /**
     * The speed limit.
     */
    public var limit : Number;
    private var speedSQ : Number;
    private var limitSQ : Number;
    private var factor : Number;

    public function SpeedLimit(limit : Number = 100)
    {
        this.limit = limit;
    }

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        limitSQ = limit * limit;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        speedSQ = particle.vx * particle.vx + particle.vy * particle.vy;
        if (speedSQ > limitSQ) {
            factor = limit / Math.sqrt(speedSQ);
            particle.vx *= factor;
            particle.vy *= factor;
        }
    }

}
}