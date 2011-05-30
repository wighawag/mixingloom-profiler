package {
	import com.wighawag.injection.patcher.MethodCallWrapperPatcher;
	import com.wighawag.preloader.AS3AbstractPatcherPreloader;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.mixingloom.patcher.IPatcher;
	//import org.mixingloom.patcher.StringModifierPatcher;

	import com.junkbyte.console.Cc;

	// need a reference to be compiled in
	import com.wighawag.profiler.TimeProfiler;
	TimeProfiler;

	public class MixingLoomAS3Preloader extends AS3AbstractPatcherPreloader {

		private var _urlLoader:URLLoader
		private var _xmlUrl:String;

		public function MixingLoomAS3Preloader(){
			super();
			_xmlUrl = this.loaderInfo.parameters["xmlUrl"];
		}

		override protected function applyModifications(bytes:ByteArray):void {
			super.applyModifications(bytes);

			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.addEventListener(Event.COMPLETE, handleXMLLoad);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlFailed);

			_urlLoader.load(new URLRequest(_xmlUrl));

		}

		private function xmlFailed(event:IOErrorEvent):void {
			_urlLoader.removeEventListener(Event.COMPLETE, handleXMLLoad);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlFailed);

			// continue without the modif
			setupConsole(mainStage);
			// and show the error
			Cc.errorch("XML", "Xml file could not load , verify if the path specified in mm.config is correct", event.text);
		}

		private function handleXMLLoad(event:Event):void {
			_urlLoader.removeEventListener(Event.COMPLETE, handleXMLLoad);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlFailed);

			var xmlData:XML = new XML((event.currentTarget as URLLoader).data as String);

			var patchers:Vector.<IPatcher> = new Vector.<IPatcher>;
			patchers.push(new MethodCallWrapperPatcher(xmlData));
			//patchers.push(new StringModifierPatcher("a bar", "not really a bar"));

			applyPatchers(patchers);
		}


		override protected function modificationsApplied(event:Event):void {
			super.modificationsApplied(event);
			setupConsole(mainStage);
		}

		private function setupConsole(displayObject:DisplayObject):void {
			Cc.config.commandLineAllowed = true // Enables full commandLine features
			Cc.config.tracing = true; // also send traces to flash's normal trace()
			Cc.config.maxLines = 2000; // change maximum log lines to 2000, default is 1000#
			Cc.config.style.backgroundAlpha = 0.8;
			Cc.startOnStage(displayObject); // finally start with these config	
		}

	}

}