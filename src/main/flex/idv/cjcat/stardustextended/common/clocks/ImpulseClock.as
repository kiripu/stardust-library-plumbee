package idv.cjcat.stardustextended.common.clocks
{

import idv.cjcat.stardustextended.common.math.Random;
import idv.cjcat.stardustextended.common.math.StardustMath;
import idv.cjcat.stardustextended.common.math.UniformRandom;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
	
	/**
	 * This clock can be used to create randomized impulses and has more parameters than ImpulseClock
	 */
	public class ImpulseClock extends Clock
    {

        /**
         * The delay in steps until the first impulse happens
         */
        public function set initialDelay(value : Random) : void {
            _initialDelay = value;
            setCurrentInitialDelay()
        }
        public function get initialDelay() : Random { return _initialDelay; }
        protected var _initialDelay : Random;

        /**
         * The length of a impulses in steps.
         */
        public function set impulseLength(value : Random) : void {
            _impulseLength = value;
            setCurrentImpulseLength();
        }
        public function get impulseLength() : Random { return _impulseLength; }
        protected var _impulseLength : Random;

        /**
         * The time between a impulses in steps.
         */
        public function set impulseInterval(value : Random) : void {
            _impulseInterval = value;
            currentImpulseInterval = 0;
        }
        public function get impulseInterval() : Random { return _impulseInterval; }
        protected var _impulseInterval : Random;

        /**
         * How many particles to create when an impulse is happening.
         * If less than one, it's the probability of an emitter to create a single particle in each step.
         */
        public var ticksPerCall : Number;

        /**
         * The time elapsed since getTicks() was first called (calling reset() resets this value).
         * This is used by the clock internally to keep track of what phase are we in currently.
         */
        protected var currentTime : Number;
        protected var currentImpulseInterval : Number;
        protected var currentImpulseLength : Number;
        protected var currentInitialDelay : Number;

		public function ImpulseClock(_impulseInterval : Random = null,
                                         _impulseLength : Random = null,
                                         _initialDelay : Random = null,
                                         _ticksPerCall : Number = 1)
		{
            impulseInterval = _impulseInterval ? _impulseInterval : new UniformRandom(20, 10);
            impulseLength = _impulseLength ? _impulseLength : new UniformRandom(20, 15);
            initialDelay = _initialDelay ? _initialDelay : new UniformRandom(0, 0);
            ticksPerCall = _ticksPerCall;
            currentTime = 0;
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
                    if (currentImpulseLength > 0)
                    {
                        ticks = StardustMath.randomFloor(ticksPerCall * time);
                    }
                    if (currentImpulseInterval <= -currentImpulseLength)
                    {
                        setCurrentImpulseLength();
                        setCurrentImpulseInterval();
                    }
                }
            }
            return ticks;
		}

        [Inline]
        private final function setCurrentImpulseLength() : void
        {
            var len : Number = _impulseLength.random();
            currentImpulseLength = len > 0 ? len : 0;
        }

        [Inline]
        private final function setCurrentImpulseInterval() : void
        {
            var val : Number = _impulseInterval.random();
            currentImpulseInterval = val > 0 ? val : 0;
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
            setCurrentImpulseLength();
            currentImpulseInterval = 0;
        }

		//XML
		//------------------------------------------------------------------------------------------------
        override public function getRelatedObjects():Array {
            return [_impulseInterval, _impulseLength, _initialDelay];
        }

        override public function getXMLTagName():String
        {
			return "ImpulseClock";
		}
		
		override public function toXML():XML
        {
			var xml : XML = super.toXML();
            xml.@ticksPerCall = ticksPerCall;
            xml.@impulseInterval = _impulseInterval.name;
            xml.@impulseLength = _impulseLength.name;
            xml.@initialDelay = _initialDelay.name;
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void
        {
			super.parseXML(xml, builder);

            if (xml.@ticksPerCall.length()) ticksPerCall = parseFloat(xml.@ticksPerCall);
            if (xml.@impulseLength.length()) impulseLength = builder.getElementByName(xml.@impulseLength) as Random;
            if (xml.@impulseInterval.length()) impulseInterval = builder.getElementByName(xml.@impulseInterval) as Random;

            if (xml.@initialDelay.length()) initialDelay = builder.getElementByName(xml.@initialDelay) as Random;

            // Legacy names, for simulations created with old versions
            if (xml.@impulseCount.length()) ticksPerCall = parseFloat(xml.@impulseCount);
            if (xml.@repeatCount.length()) impulseLength = new UniformRandom(parseInt(xml.@repeatCount), 0);
            if (xml.@burstInterval.length()) impulseInterval = new UniformRandom(parseInt(xml.@burstInterval), 0);
        }
		//------------------------------------------------------------------------------------------------
		//end of XML
    }
}