package idv.cjcat.stardustextended.math
{
/**
 * This class generates uniformly distributed random numbers.
 */
public class UniformRandom extends Random
{

    /**
     * The expected value of the random number.
     */
    public var center : Number;
    /**
     * The variation of the random number.
     *
     * <p>
     * The range of the generated random number is [center - radius, center + radius].
     * </p>
     */
    public var radius : Number;

    public function UniformRandom(center : Number = 0.5, radius : Number = 0)
    {
        this.center = center;
        this.radius = radius;
    }

    [Inline]
    override public final function random() : Number
    {
        if (radius)
        {
            return radius * 2 * (Math.random() - 0.5) + center;
        }
        else
        {
            return center;
        }
    }

    override public function setRange(lowerBound : Number, upperBound : Number) : void
    {
        var diameter : Number = upperBound - lowerBound;
        radius = 0.5 * diameter;
        center = lowerBound + radius;
    }

    override public function getRange() : Array
    {
        return [center - radius, center + radius];
    }

}
}