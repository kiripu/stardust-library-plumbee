package idv.cjcat.stardustextended.zones {
import flash.geom.Point;

import idv.cjcat.stardustextended.math.Random;
	import idv.cjcat.stardustextended.math.UniformRandom;
	import idv.cjcat.stardustextended.xml.XMLBuilder;
	import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
	 * Rectangular zone.
	 */
	public class RectZone extends Zone {
		
		public var x:Number;
		public var y:Number;
		private var _randomX:Random;
		private var _randomY:Random;
		private var _width:Number;
		private var _height:Number;
		
		public function RectZone(x:Number = 0, y:Number = 0, width:Number = 150, height:Number = 50, randomX:Random = null, randomY:Random = null) {
			if (!randomX) randomX = new UniformRandom();
			if (!randomY) randomY = new UniformRandom();
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.randomX = randomX;
			this.randomY = randomY;
		}
		
		public function get width():Number { return _width; }
		public function set width(value:Number):void {
			_width = value;
			updateArea();
		}
		
		public function get height():Number { return _height; }
		public function set height(value:Number):void {
			_height = value;
			updateArea();
		}
		
		public function get randomX():Random { return _randomX; }
		public function set randomX(value:Random):void {
			if (!value) value = new UniformRandom();
			_randomX = value;
		}
		
		public function get randomY():Random { return _randomY; }
		public function set randomY(value:Random):void {
			if (!value) value = new UniformRandom();
			_randomY = value;
		}
		
		override protected function updateArea():void {
			area = _width * _height;
		}
		
		override public function calculateMotionData2D():MotionData2D {
			randomX.setRange(x, x + _width);
			randomY.setRange(y, y + _height);
			return new MotionData2D(randomX.random(), randomY.random());
		}
		
		override public function contains(xc:Number, yc:Number):Boolean
		{
            if (_rotation != 0)
            {
                // rotate the point backwards instead, it has the same result
                var vec : Vec2D = Vec2DPool.get(xc, yc);
                vec.rotate(-_rotation);
                xc = vec.x;
                yc = vec.y;
            }
            if ((xc < x) || (xc > (x + _width))) return false;
            else if ((yc < y) || (yc > (y + _height))) return false;
            return true;
		}

        override public function setPosition(xc : Number, yc : Number):void {
            x = xc;
            y = yc;
        }

		override public function getPosition():Point {
			position.setTo(x, y);
			return position;
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getRelatedObjects():Array {
			return [_randomX, _randomY];
		}
		
		override public function getXMLTagName():String {
			return "RectZone";
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
			
			xml.@x = x;
			xml.@y = y;
			xml.@width = width;
			xml.@height = height;
			xml.@randomX = randomX.name;
			xml.@randomY = randomY.name;
			
			return xml;
		}
		
		override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
			super.parseXML(xml, builder);
			
			if (xml.@x.length()) x = parseFloat(xml.@x);
			if (xml.@y.length()) y = parseFloat(xml.@y);
			if (xml.@width.length()) width = parseFloat(xml.@width);
			if (xml.@height.length()) height = parseFloat(xml.@height);
			if (xml.@randomX.length()) randomX = builder.getElementByName(xml.@randomX) as Random;
			if (xml.@randomY.length()) randomY = builder.getElementByName(xml.@randomY) as Random;
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}