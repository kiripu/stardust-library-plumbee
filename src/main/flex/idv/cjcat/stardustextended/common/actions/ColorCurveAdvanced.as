package idv.cjcat.stardustextended.common.actions
{

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.geom.Matrix;

	import idv.cjcat.stardustextended.common.emitters.Emitter;
    import idv.cjcat.stardustextended.common.particles.Particle;
	import idv.cjcat.stardustextended.common.utils.ColorUtil;

	/**
	 * Alters a particle's color during its lifetime based on a gradient.
	 */
	public class ColorCurveAdvanced extends Action
	{
		public var numSteps : uint = 500;

		public function ColorCurveAdvanced() : void
		{
			super();
			// test values
			//var colors : Array = [0x0000FF, 0xFF0000, 0x00FF00, 0xff00ff];
			//var gradients : Array = [0, 87, 102, 255];
			//setGradient(colors, gradients);
		}

		private var colorRs : Vector.<Number> = new Vector.<Number>();
		private var colorBs : Vector.<Number> = new Vector.<Number>();
		private var colorGs : Vector.<Number> = new Vector.<Number>();
		/**
		 * Sets the gradient values. Both vectors must be the same length, and must have less than 16 values.
		 * @param colors Array of uint colors HEX RGB colors
		 * @param ratios Array of uint ratios ordered, in increasing order. First value should be 0, last 255.
		 */
		public final function setGradient(colors : Array, ratios : Array):void
		{
			colorRs = new Vector.<Number>();
			colorBs = new Vector.<Number>();
			colorGs = new Vector.<Number>();

			var mat : Matrix = new Matrix();
			var alphas : Array = [];
			for (var k : int = 0; k < colors.length; k++)
			{
				alphas.push(1);
			}
			mat.createGradientBox(numSteps, 1);
			var sprite : Sprite = new Sprite();
			sprite.graphics.lineStyle();
			sprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mat);
			sprite.graphics.drawRect(0, 0, numSteps, 1);
			sprite.graphics.endFill();
			var bd : BitmapData = new BitmapData(numSteps, 1);
			bd.draw(sprite);
			for (var i : int = numSteps -1; i > -1; i--)
			{
				var color : uint = bd.getPixel(i, 0);
				colorRs.push(ColorUtil.extractRed(color));
				colorBs.push(ColorUtil.extractBlue(color));
				colorGs.push(ColorUtil.extractGreen(color));
			}
		}

		override public final function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number):void
		{
			var ratio : uint = (numSteps-1) * particle.life / particle.initLife;
            particle.colorR = colorRs[ratio];
			particle.colorB = colorBs[ratio];
            particle.colorG = colorGs[ratio];
		}

		//XML
		//------------------------------------------------------------------------------------------------
		override public function getXMLTagName():String
		{
			return "ColorCurveAdvanced";
		}
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}