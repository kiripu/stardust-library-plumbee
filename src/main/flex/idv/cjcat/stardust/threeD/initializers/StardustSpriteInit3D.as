﻿package idv.cjcat.stardust.threeD.initializers  {
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.twoD.display.IStardustSprite;
	
	public class StardustSpriteInit3D extends Initializer3D {
		
		public function StardustSpriteInit3D() {
			
		}
		
		/**
		 * Calls the <code>IStardustSprite.init()</code> method of a particle's target if the target implements the <code>IStardustSprite</code> interface.
		 * @see idv.cjcat.stardust.twoD.display.IStardustSprite
		 */
		override public final function initialize(particle:Particle):void {
			var target:IStardustSprite = particle.target as IStardustSprite;
			if (target) target.init(particle);
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "StardustSpriteInit3D";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}