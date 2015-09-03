package idv.cjcat.stardustextended.initializers {
import idv.cjcat.stardustextended.events.StardustInitializerEvent;

/**
	 * This class is used internally by classes that implements the <code>InitializerCollector</code> interface.
	 */
	public class InitializerCollection implements InitializerCollector {

		private var _initializers:Array;
		
		public function InitializerCollection() {
			_initializers = [];
		}
		
		public final function addInitializer(initializer:Initializer):void {
			if (_initializers.indexOf(initializer) >= 0) return;
			_initializers.push(initializer);
			initializer.addEventListener(StardustInitializerEvent.PRIORITY_CHANGE, sortInitializers);
			sortInitializers();
		}
		
		public final function removeInitializer(initializer:Initializer):void {
			var index:int;
			if ((index = _initializers.indexOf(initializer)) >= 0) {
				var toRem:Initializer = Initializer(_initializers.splice(index, 1)[0]);
				initializer.removeEventListener(StardustInitializerEvent.PRIORITY_CHANGE, sortInitializers);
			}
		}
		
		public final function sortInitializers(evt : * = null):void {
			_initializers.sortOn("priority", Array.NUMERIC | Array.DESCENDING);
		}
		
		public final function clearInitializers():void {
			for each (var initializer:Initializer in _initializers) removeInitializer(initializer);
		}

		public function get initializers():Array {
			return _initializers;
		}
	}
}