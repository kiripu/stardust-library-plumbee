package idv.cjcat.stardustextended.initializers
{
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Sets a particle's scale value based on the <code>random</code> property.
 */
public class Scale extends Initializer
{

    private var _random : Random;

    public function Scale(random : Random = null)
    {
        this.random = random;
    }

    override public final function initialize(particle : Particle) : void
    {
        particle.initScale = particle.scale = random.random();
    }

    /**
     * A partilce's scale is set according to this property.
     */
    public function get random() : Random
    {
        return _random;
    }

    public function set random(value : Random) : void
    {
        if (!value) value = new UniformRandom(1, 0);
        _random = value;
    }

}
}