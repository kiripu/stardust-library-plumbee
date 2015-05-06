package idv.cjcat.stardustextended.common.actions.triggers
{

	import idv.cjcat.stardustextended.common.emitters.Emitter;
	import idv.cjcat.stardustextended.common.particles.Particle;
	import idv.cjcat.stardustextended.common.xml.XMLBuilder;
	import idv.cjcat.stardustextended.twoD.deflectors.Deflector;

	public class DeflectorTrigger extends Trigger {
		
		public var deflector:Deflector;
		
		public function DeflectorTrigger(deflector:Deflector = null) {
			this.deflector = deflector;
		}
		
		override public function testTrigger(emitter:Emitter, particle:Particle, time:Number):Boolean {
			return Boolean(particle.dictionary[deflector]);
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getRelatedObjects():Array {
			return [deflector];
		}
		
		override public function getXMLTagName():String {
			return "DeflectorTrigger";
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
			if (deflector) xml.@deflector = deflector.name;
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
			
			if (xml.@deflector.length()) deflector = builder.getElementByName(xml.@deflector) as Deflector;
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}