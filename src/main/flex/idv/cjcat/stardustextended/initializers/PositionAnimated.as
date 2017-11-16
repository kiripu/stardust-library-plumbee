package idv.cjcat.stardustextended.initializers
{

import flash.geom.Point;

import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Sets a particle's initial position based on the zone plus on a value in the positions array.
 * The current position is: positions[currentFrame] + random point in the zone.
 */
public class PositionAnimated extends Initializer implements IZoneContainer
{

    protected var zoneCollection : ZoneCollection;

    public function get zones() : Vector.<Zone>
    {
        return zoneCollection.zones;
    }

    public function set zones(value : Vector.<Zone>) : void
    {
        zoneCollection.zones = value;
    }

    public var inheritVelocity : Boolean = false;
    public var positions : Vector.<Point>;
    private var prevPos : uint;
    private var currentPos : uint;

    public function PositionAnimated(zones : Vector.<Zone> = null)
    {
        zoneCollection = new ZoneCollection();
        if (zones) {
            zoneCollection.zones = zones;
        }
        else {
            zoneCollection.zones.push(new RectZone())
        }
    }

    override public function doInitialize(particles : Vector.<Particle>, currentTime : Number) : void
    {
        if (positions) {
            currentPos = currentTime % positions.length;
            prevPos = (currentPos > 0) ? currentPos - 1 : positions.length - 1;
        }
        super.doInitialize(particles, currentTime);
    }

    override public function initialize(particle : Particle) : void
    {
        var md2D : MotionData2D = zoneCollection.getRandomPointInZones();
        if (md2D) {
            particle.x = md2D.x;
            particle.y = md2D.y;

            if (positions) {
                particle.x = md2D.x + positions[currentPos].x;
                particle.y = md2D.y + positions[currentPos].y;

                if (inheritVelocity) {
                    particle.vx += positions[currentPos].x - positions[prevPos].x;
                    particle.vy += positions[currentPos].y - positions[prevPos].y;
                }
            }
            else {
                particle.x = md2D.x;
                particle.y = md2D.y;
            }
            MotionData2DPool.recycle(md2D);
        }
    }

    [Transient]
    public function get currentPosition() : Point
    {
        if (positions) {
            return positions[currentPos];
        }
        return null;
    }

}
}