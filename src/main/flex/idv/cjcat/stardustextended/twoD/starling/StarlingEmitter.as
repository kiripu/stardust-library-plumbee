package idv.cjcat.stardustextended.twoD.starling {

import idv.cjcat.stardustextended.common.clocks.Clock;

import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.twoD.emitters.Emitter2D;

public class StarlingEmitter extends Emitter2D {

    public function StarlingEmitter(clock:Clock = null, particleHandler:ParticleHandler = null) {
        super(clock, particleHandler);
        factory = new PooledStarlingParticleFactory();
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName():String {
        return "StarlingEmitter";
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}
