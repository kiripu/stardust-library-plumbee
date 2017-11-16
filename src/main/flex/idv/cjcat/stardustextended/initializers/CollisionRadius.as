package idv.cjcat.stardustextended.initializers
{
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Particles are simulated as circles for collision simulation.
 *
 * <p>
 * This initializer sets the collision radius of a particle.
 * </p>
 */
public class CollisionRadius extends Initializer
{

    /**
     * The collsion radius.
     */
    public var radius : Number;

    public function CollisionRadius(radius : Number = 0)
    {
        this.radius = radius;
    }

    override public final function initialize(particle : Particle) : void
    {
        particle.collisionRadius = radius;
    }
}
}