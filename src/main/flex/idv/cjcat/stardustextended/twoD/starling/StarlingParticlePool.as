package idv.cjcat.stardustextended.twoD.starling {

import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.particles.ParticlePool;

public class StarlingParticlePool extends ParticlePool {

    private static var _instance:StarlingParticlePool;

    public static function getInstance():StarlingParticlePool {
        if (!_instance) _instance = new StarlingParticlePool();
        return _instance;
    }

    override protected function createNewParticle():Particle {
        return new StarlingParticle();
    }
}
}