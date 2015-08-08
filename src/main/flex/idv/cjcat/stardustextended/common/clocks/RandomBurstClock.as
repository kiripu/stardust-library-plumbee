package idv.cjcat.stardustextended.common.clocks
{

import idv.cjcat.stardustextended.common.math.Random;
import idv.cjcat.stardustextended.common.math.StardustMath;
import idv.cjcat.stardustextended.common.math.UniformRandom;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
	
	/**
	 * This clock can be used to create randomized bursts
	 */
	public class RandomBurstClock extends Clock
    {

        /**
         * The delay in steps until the first burst happens
         */
        public function set initialDelay(value : Random) : void {
            _initialDelay = value;
            setCurrentInitialDelay()
        }
        public function get initialDelay() : Random { return _initialDelay; }
        private var _initialDelay : Random;

        /**
         * The length of a burst in steps.
         */
        public function set burstLength(value : Random) : void {
            _burstLength = value;
            setCurrentBurstLength();
        }
        public function get burstLength() : Random { return _burstLength; }
        private var _burstLength : Random;

        /**
         * The time between a bursts in steps.
         */
        public function set burstInterval(value : Random) : void {
            _burstInterval = value;
            setCurrentBurstInterval();
        }
        public function get burstInterval() : Random { return _burstInterval; }
        private var _burstInterval : Random;

        /**
         * How many particles to create in each emitter step.
         * If less than one, it's the probability of an emitter to create a single particle in each step.
         */
        public var ticksPerCall : Random;

        /**
         * The time elapsed since getTicks() was first called (calling reset() resets this value).
         * This is used by the clock internally to keep track of what phase are we in currently.
         */
        protected var currentTime : Number;
        protected var currentBurstInterval : Number;
        protected var currentBurstLength : Number;
        protected var currentInitialDelay : Number;

		public function RandomBurstClock(_burstInterval : Random = null,
                                         _burstLength : Random = null,
                                         _ticksPerCall : Random = null,
                                         _initialDelay : Random = null)
		{
            burstInterval = _burstInterval ? _burstInterval : new UniformRandom(20, 10);
            burstLength = _burstLength ? _burstLength : new UniformRandom(20, 15);
            ticksPerCall = _ticksPerCall ? _ticksPerCall : new UniformRandom(3, 0);
            initialDelay = _initialDelay ? _initialDelay : new UniformRandom(0, 0);
            currentTime = 0;
		}

		override public final function getTicks(time:Number):int
        {
            var ticks : int = 0;
            currentTime = currentTime + time;
            if (currentTime > currentInitialDelay)
            {
                currentBurstInterval = currentBurstInterval - time;
                if (currentBurstInterval <= 0)
                {
                    if (currentBurstLength > 0)
                    {
                        ticks = StardustMath.randomFloor(ticksPerCall.random() * time);
                        if (ticks < 0)
                        {
                            ticks = 0;
                        }
                    }
                    if (currentBurstInterval <= -currentBurstLength)
                    {
                        setCurrentBurstLength();
                        setCurrentBurstInterval();
                    }
                }
            }
            return ticks;
		}

        [Inline]
        private final function setCurrentBurstLength() : void
        {
            var burstLen : Number = _burstLength.random();
            currentBurstLength = burstLen > 0 ? burstLen : 0;
        }

        [Inline]
        private final function setCurrentBurstInterval() : void
        {
            var val : Number = _burstInterval.random();
            currentBurstInterval = val > 0 ? val : 0;
        }

        [Inline]
        private final function setCurrentInitialDelay() : void
        {
            var val : Number = _initialDelay.random();
            currentInitialDelay =  val > 0 ? val : 0;
        }

        /**
         * Resets the clock and randomizes all values
         */
        override public function reset() : void
        {
            currentTime = 0;
            setCurrentInitialDelay();
            setCurrentBurstLength();
            setCurrentBurstInterval();
        }

		//XML
		//------------------------------------------------------------------------------------------------
        override public function getRelatedObjects():Array {
            return [_burstInterval, _burstLength, _initialDelay, ticksPerCall];
        }

        override public function getXMLTagName():String
        {
			return "RandomBurstClock";
		}
		
		override public function toXML():XML
        {
			var xml : XML = super.toXML();
            xml.@burstInterval = _burstInterval.name;
            xml.@burstLength = _burstLength.name;
            xml.@initialDelay = _initialDelay.name;
            xml.@ticksPerCall = ticksPerCall.name;
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void
        {
			super.parseXML(xml, builder);

            burstInterval = builder.getElementByName(xml.@burstInterval) as Random;
            burstLength = builder.getElementByName(xml.@burstLength) as Random;
            initialDelay = builder.getElementByName(xml.@initialDelay) as Random;
            ticksPerCall = builder.getElementByName(xml.@ticksPerCall) as Random;
        }
		//------------------------------------------------------------------------------------------------
		//end of XML
    }
}