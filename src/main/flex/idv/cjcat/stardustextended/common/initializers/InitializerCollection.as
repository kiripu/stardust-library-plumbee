package idv.cjcat.stardustextended.common.initializers {
	
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
			initializer.onPriorityChange.add(sortInitializers);
			sortInitializers();
		}
		
		public final function removeInitializer(initializer:Initializer):void {
			var index:int;
			if ((index = _initializers.indexOf(initializer)) >= 0) {
				var toRem:Initializer = Initializer(_initializers.splice(index, 1)[0]);
				toRem.onPriorityChange.remove(sortInitializers);
			}
		}
		
		public final function sortInitializers(initializer:Initializer = null):void {
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