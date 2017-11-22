package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Applies random acceleration to particles.
 *
 * <p>
 * Default priority = -3
 * </p>
 */
public class RandomDrift extends Action
{

    /**
     * Whether the particles acceleration is divided by their masses before applied to them, true by default.
     * When set to true, it simulates a gravity that applies equal acceleration on all particles.
     */
    public var massless : Boolean;
    protected var _randomX : Random;
    protected var _randomY : Random;
    protected var _timeDeltaOneSec : Number;

    public function RandomDrift(randomX : Random = null, randomY : Random = null)
    {
        _priority = -3;

        this.massless = true;
        this.randomX = randomX;
        this.randomY = randomY;
    }

    /**
     * The random object used to generate a random number for the acceleration's x component in the range [-maxX, maxX], uniform random by default.
     * You don't have to set the random object's range. The range is automatically set each time before the random generation.
     */
    final public function set randomX(value : Random) : void
    {
        if (!value) value = new UniformRandom(0, 10);
        _randomX = value;
    }

    public function get randomX() : Random
    {
        return _randomX;
    }

    /**
     * The random object used to generate a random number for the acceleration's y component in the range [-maxX, maxX], uniform random by default.
     * You don't have to set the random object's range. The range is automatically set each time before the random generation.
     */
    final public function set randomY(value : Random) : void
    {
        if (!value) value = new UniformRandom(0, 10);
        _randomY = value;
    }

    public function get randomY() : Random
    {
        return _randomY;
    }

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        _timeDeltaOneSec = time * 60;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var rx : Number = _randomX.random();
        var ry : Number = _randomY.random();

        if (!massless) {
            var factor : Number = 1 / particle.mass;
            rx *= factor;
            ry *= factor;
        }

        particle.vx += rx * _timeDeltaOneSec;
        particle.vy += ry * _timeDeltaOneSec;
    }

}
}