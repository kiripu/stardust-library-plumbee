package idv.cjcat.stardustextended.twoD.starling {

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.common.particles.Particle;

import starling.display.QuadBatch;

public class StarlingHandler extends ParticleHandler {

    private var _batch:QuadBatch;

    public function set quadBatch(batch:QuadBatch) : void{
        _batch = batch;
    }

    override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void {
        for (var i:int = 0; i < particles.length; i++) {
            var starlingParticle:StarlingParticle = particles[i] as StarlingParticle;
            starlingParticle.update();
            _batch.addQuad(starlingParticle.image, 1, starlingParticle.image.texture);
        }
    }

    override public function getXMLTagName():String {
        return "StarlingHandler";
    }
}
}
