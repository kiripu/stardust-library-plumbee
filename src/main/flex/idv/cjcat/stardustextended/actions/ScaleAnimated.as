package idv.cjcat.stardustextended.actions {
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Alters a particle's scale during its lifetime
 */
public class ScaleAnimated extends Action
{

    /// <summary>
    /// Number of gradient steps. Higher values result in smoother transition, but more memory usage.
    /// </summary>
    public var numSteps : int = 50;

    private var _interpolatedValues : Vector.<Number>;
    private var _ratios : Array;
    private var _scales : Array;

    [Transient]
    public function get ratios() : Array
    {
        return _ratios;
    }

    [Transient]
    public function get scales() : Array
    {
        return _scales;
    }

    // These are used in JSON serialization.
    // Getting trough numbers in cross platform way nicely is hard.

    public function get ratiosStr() : String  { return _ratios.join(","); }
    public function set ratiosStr(value : String) : void { _ratios = value.split(","); }

    public function get scalesStr() : String { return _scales.join(","); }
    public function set scalesStr(value : String) : void { _scales = value.split(","); }

    public function ScaleAnimated(setDefaultValues : Boolean = false) {
        super();
        _interpolatedValues = new <Number>[];
        if (setDefaultValues)
        {
            setGradient([0, 255], [1, 2]);
        }
    }

    /**
     * Sets the gradient values. Both vectors must be the same length, and must have less than 16 values.
     * @param ratios Array of uint ratios ordered, in increasing order. First value should be 0, last 255.
     * @param scales Array of Number scales
     */
    public function setGradient(ratios : Array, scales : Array) : void
    {
        _ratios = ratios;
        _scales = scales;
        _interpolatedValues = new Vector.<Number>(numSteps);

        var  stepSize : Number = numSteps / 255;
        for (var i : int = 0; i < _ratios.length - 1; i++)
        {
            var start : Number = ratios[i] * stepSize;
            var end : Number = ratios[i + 1] * stepSize;
            for (var j : int = start; j < end; j++)
            {
                var percent : Number = (j - start) / (end - start);
                _interpolatedValues[numSteps - j - 1] = _scales[i] * (1 - percent) + _scales[i + 1] * percent;
            }
        }
    }

    override public final function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var ratio : uint = (numSteps - 1) * particle.life / particle.initLife;
        particle.scale = _interpolatedValues[ratio];
    }

    public override function OnDeserializationComplete() : void
    {
        setGradient(_ratios, _scales);
    }

}
}
