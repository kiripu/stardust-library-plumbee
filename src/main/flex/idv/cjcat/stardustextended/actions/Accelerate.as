package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Accelerates particles along their velocity directions.
 */
public class Accelerate extends Action
{

    /**
     * The amount of acceleration in each emitter step.
     */
    public var acceleration : Number;

    public function Accelerate(acceleration : Number = 0.1)
    {
        this.acceleration = acceleration;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var v : Vec2D = Vec2DPool.get(particle.vx, particle.vy);
        const vecLength : Number = v.length;
        if (vecLength > 0) {
            var finalVal : Number = vecLength + acceleration * timeDelta;
            if (finalVal < 0) {
                finalVal = 0;
            }
            v.length = finalVal;
            particle.vx = v.x;
            particle.vy = v.y;
        }
        Vec2DPool.recycle(v);
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Accelerate";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@acceleration = acceleration;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@acceleration.length()) acceleration = parseFloat(xml.@acceleration);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}