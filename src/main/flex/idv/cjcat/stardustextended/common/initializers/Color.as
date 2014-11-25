package idv.cjcat.stardustextended.common.initializers {

import idv.cjcat.stardustextended.common.math.UniformRandom;
import idv.cjcat.stardustextended.common.particles.Particle;
	import idv.cjcat.stardustextended.common.xml.XMLBuilder;
	
	public class Color extends Initializer {

		public var colorR : UniformRandom;
		public var colorG : UniformRandom;
		public var colorB : UniformRandom;

		/**
		 * Initializes a particle to the given color. Color values are in the [0-1] range where 0
		 * is the lack of the color. For example  (0,0,0) means black, (1,1,1) means white.
		 */
		public function Color()
		{
			colorR = new UniformRandom(0.5, 0.5);
			colorG = new UniformRandom(0.5, 0.5);
			colorB = new UniformRandom(0.5, 0.5);
		}
		
		override public final function initialize(particle:Particle):void {
			particle.colorR = colorR.random();
			particle.colorB = colorB.random();
			particle.colorG = colorG.random();
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		override public function getXMLTagName():String {
			return "Color";
		}

		override public function getRelatedObjects():Array {
			return [colorR, colorB, colorG];
		}

		override public function toXML():XML {
			var xml:XML = super.toXML();
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
		}
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}