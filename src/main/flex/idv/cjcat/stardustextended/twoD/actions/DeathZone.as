package idv.cjcat.stardustextended.twoD.actions {

import idv.cjcat.stardustextended.common.actions.Action;
import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.zones.Zone;
import idv.cjcat.stardustextended.twoD.zones.ZoneCollection;

    /**
	 * Causes particles to be marked dead when they are not contained inside a specified zone.
	 * 
	 * <p>
	 * Default priority = -6;
	 * </p>
	 */
	public class DeathZone extends Action implements IZoneContainer {

		/**
		 * If a particle leave this zone (<code>Zone.contains()</code> returns false), it will be marked dead.
		 */
        protected var zoneCollection : ZoneCollection;
        public function get zones() : Vector.<Zone> { return zoneCollection.zones; }
        public function set zones(value : Vector.<Zone>) : void { zoneCollection.zones = value; }

        /**
		 * Inverts the zone region.
		 */
		public var inverted:Boolean;
		
		public function DeathZone(zone:Zone = null, inverted:Boolean = false) {
			priority = -6;

            zoneCollection = new ZoneCollection();
			this.inverted = inverted;
		}
		
		override public function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void {
			var dead:Boolean = zoneCollection.contains(particle.x, particle.y);
			if (inverted) dead = !dead;
			if (dead) particle.isDead = true;
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getRelatedObjects():Array {
			return zoneCollection.toArray();
		}
		
		override public function getXMLTagName():String {
			return "DeathZone";
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
            zoneCollection.addToStardustXML(xml);
			xml.@inverted = inverted;
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
            zoneCollection.parseFromStardustXML(xml, builder);
			if (xml.@inverted.length()) inverted = (xml.@inverted == "true");
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}