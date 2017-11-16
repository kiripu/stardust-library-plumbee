package idv.cjcat.stardustextended.math
{
/**
 * This class calls a <code>Random</code> object's <code>random()</code> method multiple times,
 * and averages the value.
 *
 * <p>
 * The larger the sample count, the more normally distributed the results.
 * </p>
 */
public class AveragedRandom extends Random
{

    public var randomObj : Random;
    public var sampleCount : int;

    public function AveragedRandom(randomObj : Random = null, sampleCount : int = 3)
    {
        this.randomObj = randomObj;
        this.sampleCount = sampleCount;
    }

    override public final function random() : Number
    {
        if (!randomObj) return 0;

        var sum : Number = 0;
        for (var i : int = 0; i < sampleCount; i++) sum += randomObj.random();

        return sum / sampleCount;
    }

}
}