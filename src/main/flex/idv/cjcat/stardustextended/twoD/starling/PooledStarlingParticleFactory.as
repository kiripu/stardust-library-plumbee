package idv.cjcat.stardustextended.twoD.starling {
import idv.cjcat.stardustextended.common.particles.PooledParticleFactory;

public class PooledStarlingParticleFactory extends PooledParticleFactory {
    public function PooledStarlingParticleFactory() {
        particlePool = StarlingParticlePool.getInstance();
    }
}
}
