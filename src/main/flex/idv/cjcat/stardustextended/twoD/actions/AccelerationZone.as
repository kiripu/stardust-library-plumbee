package idv.cjcat.stardustextended.twoD.actions {
	import idv.cjcat.stardustextended.common.emitters.Emitter;
	import idv.cjcat.stardustextended.common.particles.Particle;
	import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.geom.Vec2D;
import idv.cjcat.stardustextended.twoD.geom.Vec2DPool;
import idv.cjcat.stardustextended.twoD.particles.Particle2D;
import idv.cjcat.stardustextended.twoD.zones.RectZone;
import idv.cjcat.stardustextended.twoD.zones.Zone;
	
	/**
	 * Causes particles to change acceleration specified zone.
	 * 
	 * <p>
	 * Default priority = -6;
	 * </p>
	 */
	public class AccelerationZone extends Action2D implements IZoneContainer {

        public function get zone():Zone { return _zone; }
        public function set zone(value:Zone):void {
            if (!value) value = new RectZone();
            _zone = value;
        }
		private var _zone:Zone;
		/**
		 * Inverts the zone region.
		 */
		public var inverted:Boolean;

		/**
		 * The acceleration applied in each step to particles inside the zone.
		 * Default is 1.
		 */
		public var acceleration:Number;

		public function AccelerationZone(zone:Zone = null, inverted:Boolean = false) {
			priority = -6;
			
			this.zone = zone;
			this.inverted = inverted;
			acceleration = 1;
		}
		
		override public function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void {
			var p2D : Particle2D = Particle2D(particle);
			var affected : Boolean = _zone.contains(p2D.x, p2D.y);
			if (inverted)
			{
				affected = !affected;
			}
			if (affected)
			{
				var v : Vec2D = Vec2DPool.get(p2D.vx, p2D.vy);
				const vecLength : Number = v.length;
				if (vecLength > 0) {
					var finalVal : Number = vecLength + acceleration * timeDelta;
					if (finalVal < 0) {
						finalVal = 0;
					}
					v.length = finalVal;
					p2D.vx = v.x;
					p2D.vy = v.y;
				}
				Vec2DPool.recycle(v);
			}
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getRelatedObjects():Array {
			return [_zone];
		}
		
		override public function getXMLTagName():String {
			return "AccelerationZone";
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
			xml.@zone = _zone.name;
			xml.@inverted = inverted;
			xml.@acceleration = acceleration;
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
			_zone = builder.getElementByName(xml.@zone) as Zone;
			inverted = (xml.@inverted == "true");
			acceleration = parseFloat(xml.@acceleration);
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}