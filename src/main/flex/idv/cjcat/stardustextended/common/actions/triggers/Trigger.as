package idv.cjcat.stardustextended.common.actions.triggers
{

import idv.cjcat.stardustextended.common.StardustElement;
import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.particles.Particle;

public class Trigger extends StardustElement
{

    public function testTrigger(emitter:Emitter, particle:Particle, time:Number):Boolean
    {
        throw new Error("This method must be overridden");
    }

    //XML
    //------------------------------------------------------------------------------------------------
    override public function getXMLTagName():String
    {
        throw new Error("This method must be overridden");
    }

    override public function getElementTypeXMLTag():XML
    {
        return <triggers/>;
    }
    //------------------------------------------------------------------------------------------------
    //end of XML
}
}
