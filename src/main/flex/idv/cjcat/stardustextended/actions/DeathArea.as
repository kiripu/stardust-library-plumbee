package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.actions.areas.RectArea;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.actions.areas.Area;
import idv.cjcat.stardustextended.actions.areas.AreaCollection;
import idv.cjcat.stardustextended.actions.areas.IAreaContainer;

/**
 * Causes particles to be marked dead when they are not contained inside a specified zone.
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
public class DeathArea extends Action implements IAreaContainer
{

    /**
     * If a particle leave this area (<code>Area.contains()</code> returns false), it will be marked dead.
     */
    protected var areaCollection : AreaCollection;

    public function get areas() : Vector.<Area>
    {
        return areaCollection.areas;
    }

    public function set areas(value : Vector.<Area>) : void
    {
        areaCollection.areas = value;
    }

    /**
     * Inverts the area region.
     */
    public var inverted : Boolean;

    public function DeathArea(zones : Vector.<Area> = null, inverted : Boolean = false)
    {
        priority = -6;

        areaCollection = new AreaCollection();
        if (zones)
        {
            areaCollection.areas = zones;
        }
        else
        {
            areaCollection.areas.push(new RectArea());
        }
        this.inverted = inverted;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var dead : Boolean = areaCollection.contains(particle.x, particle.y);
        if (inverted) dead = !dead;
        if (dead) particle.isDead = true;
    }

}
}