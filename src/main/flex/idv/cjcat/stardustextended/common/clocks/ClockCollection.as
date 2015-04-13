package idv.cjcat.stardustextended.common.clocks {
	
	/**
	 * This class is used internally by classes that implements the <code>ClockCollector</code> interface.
	 */
	public class ClockCollection implements ClockCollector {
		
		private var _clocks:Array;
		
		public function ClockCollection() {
			_clocks = [];
		}
		
		public final function addClock(clock:Clock):void {
			_clocks.push(clock);
		}
		
		public final function removeClock(clock:Clock):void {
			var index:int;
			while ((index = _clocks.indexOf(clock)) >= 0) {
				_clocks.splice(index, 1);
			}
		}
		
		public final function clearClocks():void {
			_clocks = [];
		}

		public function get clocks():Array {
			return _clocks;
		}
	}
}