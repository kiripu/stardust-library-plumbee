package idv.cjcat.stardustextended.common.clocks {
import idv.cjcat.stardustextended.common.math.Random;
import idv.cjcat.stardustextended.common.math.StardustMath;
import idv.cjcat.stardustextended.common.math.UniformRandom;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
	
	/**
	 * The impulse clock causes the emitter to create a single bursts of particles.
	 */
	public class ImpulseClock extends Clock {

        /**
         * Sets the duration of a impulse in steps
         */
        public var impulseLength :int = 1;
        /**
		 * The time between impulses.
		 */
		public var impulseInterval:int = 33;
		/**
		 * How many particles to create in a step if its in an impulse.
		 */
		public var ticksPerCall:Number;

        /**
         * The delay in steps until the the clock starts
         */
        public function set initialDelay(value : Random) : void {
            _initialDelay = value;
            setCurrentInitialDelay()
        }
        public function get initialDelay() : Random { return _initialDelay; }
        protected var _initialDelay : Random;

        protected var currentInitialDelay : Number;
        protected var currentTime : Number;
        protected var currentImpulseInterval : Number;
		
		public function ImpulseClock(impulseCount:int = 1, repeatCount:int = 1, _initialDelay : Random = null)
        {
			this.ticksPerCall = impulseCount;
			this.impulseLength = repeatCount;
            initialDelay = _initialDelay ? _initialDelay : new UniformRandom(0, 0);
            currentTime = 0;
            currentImpulseInterval = 0;
		}

		override public final function getTicks(time:Number):int
        {
            var ticks : int = 0;
            currentTime = currentTime + time;
            if (currentTime > currentInitialDelay)
            {
                currentImpulseInterval = currentImpulseInterval - time;
                if (currentImpulseInterval < 0)
                {
                    if (impulseLength > 0)
                    {
                        ticks = StardustMath.randomFloor(ticksPerCall * time);
                    }
                    if (currentImpulseInterval <= -impulseLength)
                    {
                       currentImpulseInterval = impulseInterval;
                    }
                }
            }
            return ticks;
		}

        override public function reset() : void
        {
            currentImpulseInterval = 0;
            currentTime = 0;
            setCurrentInitialDelay();
        }

        [Inline]
        private final function setCurrentInitialDelay() : void
        {
            var val : Number = _initialDelay.random();
            currentInitialDelay =  val > 0 ? val : 0;
        }

		//XML
		//------------------------------------------------------------------------------------------------
		override public function getXMLTagName():String {
			return "ImpulseClock";
		}

        override public function getRelatedObjects():Array
        {
            return [_initialDelay];
        }

		override public function toXML():XML {
			var xml:XML = super.toXML();
			xml.@impulseCount = ticksPerCall;
			xml.@repeatCount = impulseLength;
			xml.@burstInterval = impulseInterval;
            xml.@initialDelay = _initialDelay.name;
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
			// these are legacy names, changing them would break existing simulations
			if (xml.@impulseCount.length()) ticksPerCall = parseFloat(xml.@impulseCount);
			if (xml.@repeatCount.length()) impulseLength = parseInt(xml.@repeatCount);
			if (xml.@burstInterval.length()) impulseInterval = parseInt(xml.@burstInterval);
            if (xml.@initialDelay.length()) initialDelay =  builder.getElementByName(xml.@initialDelay) as Random;
		}
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}