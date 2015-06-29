package idv.cjcat.stardustextended.common.actions.triggers
{

import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.actions.IZoneContainer;
import idv.cjcat.stardustextended.twoD.zones.Zone;
import idv.cjcat.stardustextended.twoD.zones.ZoneCollection;

/**
	 * This trigger is triggered when a particle is contained in a zone.
	 */
	public class ZoneTrigger extends Trigger implements IZoneContainer
    {
		protected var zoneCollection : ZoneCollection;
		public function get zones() : Vector.<Zone> { return zoneCollection.zones; }
		public function set zones(value : Vector.<Zone>) : void { zoneCollection.zones = value; }

		public function ZoneTrigger() {
            zoneCollection = new ZoneCollection();
		}
		
		override public function testTrigger(emitter:Emitter, particle:Particle, time:Number):Boolean {
			return zoneCollection.contains(particle.x, particle.y);
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getRelatedObjects():Array {
			return zoneCollection.toArray();
		}
		
		override public function getXMLTagName():String {
			return "ZoneTrigger";
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
            zoneCollection.addToStardustXML(xml);
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
            zoneCollection.parseFromStardustXML(xml, builder);
		}
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}