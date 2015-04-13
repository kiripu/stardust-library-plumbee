package idv.cjcat.stardustextended.flashdisplay {

	import idv.cjcat.stardustextended.common.xml.ClassPackage;
	import idv.cjcat.stardustextended.flashdisplay.handlers.BitmapHandler;
	import idv.cjcat.stardustextended.flashdisplay.handlers.DisplayObjectHandler;
	import idv.cjcat.stardustextended.flashdisplay.handlers.DisplayObjectSpriteSheetHandler;
	import idv.cjcat.stardustextended.flashdisplay.handlers.SingularBitmapHandler;
	import idv.cjcat.stardustextended.flashdisplay.initializers.DisplayObjectParent;
	import idv.cjcat.stardustextended.flashdisplay.initializers.PooledDisplayObjectClass;
	
	/**
	 * Packs together classes for the classic display list.
	 */
	public class FlashDisplayClassPackage extends ClassPackage {
		
		private static var _instance:FlashDisplayClassPackage;
		
		public static function getInstance():FlashDisplayClassPackage {
			if (!_instance) _instance = new FlashDisplayClassPackage();
			return _instance;
		}

		override protected final function populateClasses():void {

			//2D initializers
			classes.push(DisplayObjectParent);
			classes.push(PooledDisplayObjectClass);

			//2D particle handlers
			classes.push(BitmapHandler);
			classes.push(DisplayObjectHandler);
			classes.push(SingularBitmapHandler);
			classes.push(DisplayObjectSpriteSheetHandler);
		}
	}
}