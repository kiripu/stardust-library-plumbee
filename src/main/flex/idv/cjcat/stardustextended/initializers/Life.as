package idv.cjcat.stardustextended.initializers
{
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Sets a particle's life value based on the <code>random</code> property.
 */
public class Life extends Initializer
{

    private var _random : Random;

    public function Life(random : Random = null)
    {
        this.random = random;
    }

    override public final function initialize(particle : Particle) : void
    {
        particle.initLife = particle.life = random.random();
    }

    /**
     * A partilce's life is set according to this property.
     */
    public function get random() : Random
    {
        return _random;
    }

    public function set random(value : Random) : void
    {
        if (!value) value = new UniformRandom(0, 0);
        _random = value;
    }

}
}