package idv.cjcat.stardustextended.initializers
{
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Sets a particle's mass value based on the <code>random</code> property.
 *
 * <p>
 * A particle's mass is important in collision and gravity simulation.
 * </p>
 */
public class Mass extends Initializer
{

    private var _random : Random;

    public function Mass(random : Random = null)
    {
        this.random = random;
    }

    public function get random() : Random
    {
        return _random;
    }

    public function set random(value : Random) : void
    {
        if (!value) value = new UniformRandom(1, 0);
        _random = value;
    }

    override public final function initialize(particle : Particle) : void
    {
        particle.mass = random.random();
    }

}
}