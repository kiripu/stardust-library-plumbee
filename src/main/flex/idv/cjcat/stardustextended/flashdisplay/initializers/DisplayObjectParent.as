package idv.cjcat.stardustextended.flashdisplay.initializers {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import idv.cjcat.stardustextended.common.initializers.Initializer;
import idv.cjcat.stardustextended.common.particles.Particle;
	
	/**
	 * Specifies a specific display object container to be the parent of a particle 
	 * if the particle is initialized by the <code>DisplayObjectClass</code> initializer.
	 * 
	 * <p>
	 * Default priority = -100;
	 * </p>
	 */
	public class DisplayObjectParent extends Initializer {
		
		public var container:DisplayObjectContainer;
		public function DisplayObjectParent(container:DisplayObjectContainer = null) {
			priority = -100;
			this.container = container;
		}
		
		override public function initialize(particle:Particle):void {
			if (!container) return;
			var displayObj:DisplayObject = particle.target as DisplayObject;
			if (!displayObj) return;
			container.addChild(displayObj);
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "DisplayObjectParent";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}