package idv.cjcat.stardustextended.particles {

	import idv.cjcat.stardustextended.initializers.Initializer;
	import idv.cjcat.stardustextended.initializers.InitializerCollection;
	import idv.cjcat.stardustextended.initializers.InitializerCollector;
	
	/**
	 * Each emitter has a particle factory for creating new particles. 
	 * This class is also used by bursters to manually create particles with associated initializers.
	 * @see idv.cjcat.stardustextended.flashdisplay.bursters.Burster
	 * @see idv.cjcat.stardustextended.emitters.Emitter
	 */
	public class ParticleFactory implements InitializerCollector {

		private var _initializerCollection:InitializerCollection;

		public function ParticleFactory() {
			_initializerCollection = new InitializerCollection();
		}
		
		/**
		 * Creates particles with associated initializers.
		 * @param count
         * @param currentTime
		 * @return the newly created particles
		 */
		public final function createParticles(count:int, currentTime : Number):Vector.<Particle> {
            var particles:Vector.<Particle> = new Vector.<Particle>();
            if (count > 0)
            {
                var i:int;
                var len:int;
                for (i = 0; i < count; i++) {
                    var particle:Particle = createNewParticle();
                    particle.init();
                    particles.push(particle);
                }

                var initializers:Array = _initializerCollection.initializers;
                for (i = 0, len = initializers.length; i < len; ++i)
                {
                    Initializer(initializers[i]).doInitialize(particles, currentTime);
                }
            }
            return particles;
		}
		
		/** @private */
		protected function createNewParticle():Particle {
			return new Particle();
		}
		
		/**
		 * Adds an initializer to the factory.
		 * @param	initializer
		 */
		public function addInitializer(initializer:Initializer):void {
			_initializerCollection.addInitializer(initializer);
		}
		
		/**
		 * Removes an initializer from the factory.
		 * @param	initializer
		 */
		public final function removeInitializer(initializer:Initializer):void {
			_initializerCollection.removeInitializer(initializer);
		}
		
		/**
		 * Removes all initializers from the factory.
		 */
		public final function clearInitializers():void {
			_initializerCollection.clearInitializers();
		}

		public function get initializerCollection():InitializerCollection {
			return _initializerCollection;
		}
	}
}