package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.actions.waypoints.Waypoint;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Causes particles to go through a series of waypoints.
 *
 * @see idv.cjcat.stardustextended.actions.waypoints.Waypoint
 */
public class FollowWaypoints extends Action
{

    /**
     * Whether the particles head for the first waypoint after passing through the last waypoint.
     */
    public var loop : Boolean;
    /**
     * Whether the particles' mass is taken into account.
     * If true, the acceleration applied to a particle is divided by the particle's mass.
     */
    public var massless : Boolean;
    private var _waypoints : Vector.<Waypoint>;
    protected var _timeDeltaOneSec : Number;

    public function FollowWaypoints(waypoints : Vector.<Waypoint> = null, loop : Boolean = false, massless : Boolean = true)
    {
        this.loop = loop;
        this.massless = massless;
        this.waypoints = waypoints;
        if (waypoints) {
            _waypoints = waypoints;
        }
        else {
            _waypoints = new Vector.<Waypoint>();
            _waypoints.push(new Waypoint(0, 0));
        }
    }

    /**
     * An array of waypoints.
     */
    public function get waypoints() : Vector.<Waypoint>
    {
        return _waypoints;
    }

    public function set waypoints(value : Vector.<Waypoint>) : void
    {
        if (!value) value = new Vector.<Waypoint>();
        _waypoints = value;
    }

    /**
     * Adds a waypoint to the waypoint array.
     * @param    waypoint
     */
    public function addWaypoint(waypoint : Waypoint) : void
    {
        _waypoints.push(waypoint);
    }

    /**
     * Removes all waypoints from the waypoint array.
     */
    public function clearWaypoints() : void
    {
        _waypoints = new Vector.<Waypoint>();
    }

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        _timeDeltaOneSec = time * 60;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var numWPs : uint = _waypoints.length;
        if (numWPs == 0) return;

        if (!particle.dictionary[FollowWaypoints]) {
            particle.dictionary[FollowWaypoints] = 0;
        }

        var index : int = particle.dictionary[FollowWaypoints];
        if (index >= numWPs) {
            index = numWPs - 1;
            particle.dictionary[FollowWaypoints] = index;
        }

        var waypoint : Waypoint = _waypoints[index] as Waypoint;
        var dx : Number = particle.x - waypoint.x;
        var dy : Number = particle.y - waypoint.y;
        if (dx * dx + dy * dy <= waypoint.radius * waypoint.radius) {
            if (index < numWPs - 1) {
                particle.dictionary[FollowWaypoints]++;
                waypoint = _waypoints[index + 1];
            }
            else {
                if (loop) {
                    particle.dictionary[FollowWaypoints] = 0;
                    waypoint = _waypoints[0];
                }
                else {
                    return;
                }
            }
            dx = particle.x - waypoint.x;
            dy = particle.y - waypoint.y;
        }

        var r : Vec2D = Vec2DPool.get(dx, dy);
        var len : Number = r.length;
        if (len < waypoint.epsilon) {
            len = waypoint.epsilon;
        }
        r.length = -waypoint.strength * Math.pow(len, -0.5 * waypoint.attenuationPower);
        if (!massless) r.length /= particle.mass;
        Vec2DPool.recycle(r);

        particle.vx += r.x * _timeDeltaOneSec;
        particle.vy += r.y * _timeDeltaOneSec;
    }

}
}