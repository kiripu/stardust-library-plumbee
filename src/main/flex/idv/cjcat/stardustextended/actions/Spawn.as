package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.actions.triggers.DeathTrigger;
import idv.cjcat.stardustextended.actions.triggers.Trigger;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Spawns new particles at the position of existing particles.
 * This action can be used to create effects such as fireworks, rocket trails, etc.
 *
 * You must specify an emitter that will emit the new particles. This action offsets the emitters newly created
 * particles position to the position this emitters particles.
 * You should set the spawner emitter's active property to false so it does not emit particles by itself.
 * Furthermore to spawn particles you need to add a trigger to this action.
 */
public class Spawn extends Action
{

    public var inheritDirection : Boolean;
    public var inheritVelocity : Boolean;
    private var _spawnerEmitter : Emitter;
    private var _spawnerEmitterId : String;
    private var _trigger : Trigger;

    public function Spawn(inheritDirection : Boolean = true, inheritVelocity : Boolean = false, trigger : Trigger = null)
    {
        super();
        priority = -10;
        this.inheritDirection = inheritDirection;
        this.inheritVelocity = inheritVelocity;
        this.trigger = trigger;
    }

    [Transient]
    public function set spawnerEmitter(em : Emitter) : void
    {
        _spawnerEmitter = em;
        _spawnerEmitterId = em ? em.name : null;
    }

    public function get spawnerEmitter() : Emitter
    {
        return _spawnerEmitter;
    }

    public function get spawnerEmitterId() : String
    {
        return _spawnerEmitterId;
    }

    public function set spawnerEmitterId(val : String) : void
    {
        _spawnerEmitterId = val;
    }

    public function get trigger() : Trigger
    {
        return _trigger;
    }

    public function set trigger(value : Trigger) : void
    {
        if (value == null) {
            value = new DeathTrigger();
        }
        _trigger = value;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        if (_spawnerEmitter == null) {
            return;
        }
        if (_trigger.testTrigger(emitter, particle, timeDelta)) {
            var p : Particle;
            var newParticles : Vector.<Particle> = _spawnerEmitter.createParticles(_spawnerEmitter.clock.getTicks(timeDelta));
            var len : uint = newParticles.length;
            for (var m : int = 0; m < len; ++m) {
                p = newParticles[m];
                p.x += particle.x;
                p.y += particle.y;
                if (inheritVelocity) {
                    p.vx += particle.vx;
                    p.vy += particle.vy;
                }
                if (inheritDirection) {
                    p.rotation += particle.rotation;
                }
            }
        }
    }

}
}