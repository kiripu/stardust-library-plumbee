package idv.cjcat.stardustextended.initializers
{

import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Sets a particle's initial rotation value, in degrees, based on the <code>random</code> property.
 */
public class Rotation extends Initializer
{

    private var _random : Random;

    public function Rotation(random : Random = null)
    {
        this.random = random;
    }

    override public function initialize(particle : Particle) : void
    {
        particle.rotation = random.random();
    }


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