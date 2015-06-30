package idv.cjcat.stardustextended.twoD.actions
{

import idv.cjcat.stardustextended.common.actions.Action;
import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.fields.Field;
import idv.cjcat.stardustextended.twoD.geom.MotionData2D;
import idv.cjcat.stardustextended.twoD.geom.MotionData2DPool;
	
	/**
	 * Applies accelerations to particles according to the associated gravity fields, in pixels.
	 * 
	 * <p>
	 * Default priority = -3;
	 * </p>
	 * 
	 * @see idv.cjcat.stardustextended.twoD.fields.Field
	 */
	public class Gravity extends Action implements IFieldContainer
	{

		protected var _fields : Vector.<Field>;
		
		public function Gravity() {
			priority = -3;
			_fields = new Vector.<Field>();
		}


        public function get fields() : Vector.<Field>
        {
            return _fields;
        }

        public function set fields(value : Vector.<Field>) : void
        {
            _fields = value;
        }

		/**
		 * Adds a gravity field to the simulation.
		 * @param field
		 */
		public function addField(field:Field):void {
			if (_fields.indexOf(field) < 0) _fields.push(field);
		}
		
		/**
		 * Removes a gravity field from the simulation.
		 * @param field
		 */
		public function removeField(field:Field):void {
			var index:int = _fields.indexOf(field);
			if (index >= 0) _fields.splice(index, 1);
		}
		
		/**
		 * Removes all gravity fields from the simulation.
		 */
		public function clearFields():void {
			_fields = new Vector.<Field>();
		}

		override public function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void {
            var md2D : MotionData2D;
			for (var i : int = 0; i < _fields.length; i++) {
				md2D = _fields[i].getMotionData2D(particle);
				if (md2D) {
					particle.vx += md2D.x * timeDelta;
					particle.vy += md2D.y * timeDelta;
					MotionData2DPool.recycle(md2D);
				}
			}
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getRelatedObjects():Array {
            const result:Array = [];
            for(var i : int = 0; i < _fields.length; i++) {
                result[result.length] = _fields[i];
            }
			return result;
		}
		
		override public function getXMLTagName():String {
			return "Gravity";
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
			
			if (_fields.length > 0) {
				xml.appendChild(<fields/>);
				var field:Field;
				for each (field in _fields) {
					xml.fields.appendChild(field.getXMLTag());
				}
			}
			
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
			
			clearFields();
			for each (var node:XML in xml.fields.*) {
				addField(builder.getElementByName(node.@name) as Field);
			}
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}