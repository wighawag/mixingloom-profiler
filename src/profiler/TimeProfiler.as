package profiler {
	import com.junkbyte.console.Cc;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class TimeProfiler {
		private static var _times:Dictionary = new Dictionary();
		private static var _iterations:Dictionary = new Dictionary();
		private static var _totals:Dictionary = new Dictionary();
		private static var _recursiveCounter:Dictionary = new Dictionary();

		private static function count(type : String):Number {		
			var time : Number = getTimer() - _times[type];
			
			if (!_iterations[type]) _iterations[type] = 0;
			_iterations[type] ++;
			
			if (!_totals[type]) _totals[type] = 0;
			_totals[type] += time;
			
			return time;
		}
		
		// cannot deal with recursive call if the type is the function name
		public static function tick(type:String):void {
			if (_times[type]) {
				var time : Number = count(type);
				Cc.debugch("Profiler - time", "tick", type, time, "iteration : ", _iterations[type], "total : ", _totals[type]);
				delete _times[type];
			} else {
				_times[type] = getTimer();
			}
		}

		
		// finish need to be preceded by start
		// deal with recursive function (take in account only the first call) but make recursive call even slower than they already are
		
		public static function start(type:String):void {
			if (!_times[type]){
				_times[type] = getTimer();
				_recursiveCounter[type] = 0;
			} else {
				_recursiveCounter[type]++;
			}
		}

		public static function finish(type:String):void {

			if (_times[type] && _recursiveCounter[type] == 0) {
				var time : Number = count(type);
				Cc.debugch("Profiler - time", type, time, "iteration : ", _iterations[type], "total : ", _totals[type]);
				delete _times[type];
				delete _recursiveCounter[type];
			} else {
				if (_times[type]){
					_recursiveCounter[type]--;
				} else {
					Cc.errorch("Profiler - time", "finish need to preceded by start");
				}
			}
		}
	}
}