package idv.cjcat.stardustextended.twoD.actions
{

    import idv.cjcat.stardustextended.common.actions.Action;
    import idv.cjcat.stardustextended.common.actions.triggers.DeathTrigger;
    import idv.cjcat.stardustextended.common.actions.triggers.Trigger;
    import idv.cjcat.stardustextended.common.emitters.Emitter;
    import idv.cjcat.stardustextended.common.particles.Particle;
    import idv.cjcat.stardustextended.common.xml.XMLBuilder;
    import idv.cjcat.stardustextended.twoD.geom.Vec2D;
	
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
		
		public var inheritDirection:Boolean;
		public var inheritVelocity:Boolean;
        public var spawnerEmitter : Emitter;
        public var spawnerEmitterId : String;
        private var _trigger : Trigger;

		public function Spawn(inheritDirection:Boolean = true, inheritVelocity:Boolean = false, trigger : Trigger = null)
        {
            super();
            priority = -10;
			this.inheritDirection = inheritDirection;
			this.inheritVelocity = inheritVelocity;
            this.trigger = trigger;
		}

        public function get trigger() : Trigger
        {
            return _trigger;
        }

        public function set trigger(value : Trigger) : void
        {
            if (value == null)
            {
                value = new DeathTrigger();
            }
            _trigger = value;
        }

		override public function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void
        {
            if (spawnerEmitter == null)
            {
                return;
            }
            if (_trigger.testTrigger(emitter, particle, timeDelta))
            {
                var p:Particle;
                var v:Vec2D;
                var newParticles : Vector.<Particle> = spawnerEmitter.createParticles(timeDelta);
                var len : uint = newParticles.length;
                for (var m : int = 0; m < len; ++m)
                {
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

		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Spawn";
		}

        override public function getRelatedObjects():Array {
            return [_trigger];
        }

		override public function toXML():XML {
			var xml:XML = super.toXML();
			
			xml.@inheritDirection = inheritDirection;
			xml.@inheritVelocity = inheritVelocity;
            xml.@trigger = _trigger.name;

            if (spawnerEmitter)
            {
                xml.@spawnerEmitter = spawnerEmitter.name;
            }

			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
			
			inheritDirection = (xml.@inheritDirection == "true");
			inheritVelocity = (xml.@inheritVelocity == "true");

            if (xml.@spawnerEmitter) spawnerEmitterId = xml.@spawnerEmitter;
            _trigger = builder.getElementByName(xml.@trigger) as Trigger;
        }
		
		//------------------------------------------------------------------------------------------------
		//end of XML

    }
}