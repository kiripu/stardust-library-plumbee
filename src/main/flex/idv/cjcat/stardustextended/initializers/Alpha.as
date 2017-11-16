package idv.cjcat.stardustextended.initializers
{

import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Sets a particle's alpha value based on the <code>random</code> property.
 */
public class Alpha extends Initializer
{

    private var _random : Random;

    public function Alpha(random : Random = null)
    {
        this.random = random;
    }

    override public final function initialize(particle : Particle) : void
    {
        particle.initAlpha = particle.alpha = random.random();
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

}
}