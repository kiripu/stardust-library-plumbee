package idv.cjcat.stardustextended.actions.triggers
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.actions.areas.Area;
import idv.cjcat.stardustextended.actions.areas.AreaCollection;
import idv.cjcat.stardustextended.actions.areas.IAreaContainer;
import idv.cjcat.stardustextended.actions.areas.RectArea;

/**
 * This trigger is triggered when a particle is contained in a zone.
 */
public class AreaTrigger extends Trigger implements IAreaContainer
{
    protected var areaCollection : AreaCollection;

    public function get areas() : Vector.<Area>
    {
        return areaCollection.areas;
    }

    public function set areas(value : Vector.<Area>) : void
    {
        areaCollection.areas = value;
    }

    public function AreaTrigger(areas : Vector.<Area> = null)
    {
        areaCollection = new AreaCollection();
        if (areas)
        {
            areaCollection.areas = areas;
        }
        else {
            areaCollection.areas.push(new RectArea());
        }
    }

    override public function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        return areaCollection.contains(particle.x, particle.y);
    }
}
}