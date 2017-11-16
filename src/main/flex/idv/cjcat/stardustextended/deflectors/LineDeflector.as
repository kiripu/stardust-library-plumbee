package idv.cjcat.stardustextended.deflectors
{
import flash.geom.Point;

import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Infinitely long line-shaped obstacle.
 * One side of the line is free space, and the other side is "solid",
 * not allowing any particle to go through.
 * The line is defined by a point it passes through and its normal vector.
 *
 * <p>
 * When a particle hits the border, it bounces back.
 * </p>
 */
public class LineDeflector extends Deflector
{

    /**
     * The X coordinate of a point the border passes through.
     */
    public var x : Number;
    /**
     * The Y coordinate of a point the border passes through.
     */
    public var y : Number;
    private var _normal : Vec2D;

    public function LineDeflector(x : Number = 0, y : Number = 0, nx : Number = 0, ny : Number = -1)
    {
        this.x = x;
        this.y = y;
        _normal = Vec2DPool.get(nx, ny);
    }

    public function set normalX(value : Number) : void { _normal.x = value; }
    public function get normalX() : Number { return _normal.x; }

    public function set normalY(value : Number) : void { _normal.y = value; }
    public function get normalY() : Number { return _normal.y; }

    /**
     * The normal of the border, pointing to the free space side.
     */
    [Transient]
    public function get normal() : Vec2D
    {
        return _normal;
    }

    private var r : Vec2D;
    private var dot : Number;
    private var radius : Number;
    private var dist : Number;
    private var v : Vec2D;
    private var factor : Number;

    override protected function calculateMotionData4D(particle : Particle) : MotionData4D
    {
        //normal displacement
        r = Vec2DPool.get(particle.x - x, particle.y - y);
        r = r.project(_normal);

        dot = r.dot(_normal);
        radius = particle.collisionRadius * particle.scale;
        dist = r.length;

        if (dot > 0) {
            if (dist > radius) {
                //no collision detected
                Vec2DPool.recycle(r);
                return null;
            } else {
                r.length = radius - dist;
            }
        } else {
            //collision detected
            r.length = -(dist + radius);
        }

        v = Vec2DPool.get(particle.vx, particle.vy);
        v = v.project(_normal);

        factor = 1 + bounce;

        Vec2DPool.recycle(r);
        Vec2DPool.recycle(v);
        return MotionData4DPool.get(particle.x + r.x, particle.y + r.y,
                (particle.vx - v.x * factor) * slipperiness, (particle.vy - v.y * factor) * slipperiness);
    }

    override public function setPosition(xc : Number, yc : Number) : void
    {
        x = xc;
        y = yc;
    }

    override public function getPosition() : Point
    {
        position.setTo(x, y);
        return position;
    }

}
}