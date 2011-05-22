package {
	import com.wighawag.injection.patcher.MethodCallWrapperPatcher;
	import com.wighawag.preloader.AS3AbstractPatcherPreloader;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import org.mixingloom.patcher.IPatcher;
	//import org.mixingloom.patcher.StringModifierPatcher;
	
	import com.junkbyte.console.Cc;

	// need a reference to be compiled in
	import com.wighawag.profiler.TimeProfiler;
	TimeProfiler;

	public class MixingLoomAS3Preloader extends AS3AbstractPatcherPreloader {

		public function MixingLoomAS3Preloader()
		{
			var xmlUrl : String = this.loaderInfo.parameters["xmlUrl"];
			
			var patchers : Vector.<IPatcher> = new Vector.<IPatcher>;
			patchers.push(new MethodCallWrapperPatcher(xmlUrl));
			//patchers.push(new StringModifierPatcher("a bar", "not really a bar"));
			super(patchers);
		}

		override protected function modificationsApplied(event:Event):void {
			super.modificationsApplied(event);
			setupConsole(mainStage);
		}

		private function setupConsole(displayObject:DisplayObject):void {
			Cc.config.commandLineAllowed = true // Enables full commandLine features
			Cc.config.tracing = true; // also send traces to flash's normal trace()
			Cc.config.maxLines = 2000; // change maximum log lines to 2000, default is 1000
			Cc.startOnStage(displayObject); // finally start with these config	
		}

	}

}