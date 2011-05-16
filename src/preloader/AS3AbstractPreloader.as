package preloader {
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class AS3AbstractPreloader extends Sprite {
		protected var mainStage:Stage = null;

		public function AS3AbstractPreloader():void {
			root.addEventListener("allComplete", allCompleteHandler);
		}

		private function allCompleteHandler(event:Event):void {
			root.removeEventListener("allComplete", allCompleteHandler);

			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
			mainStage = loaderInfo.content.stage;

			applyModifications(loaderInfo.bytes);
		}

		protected function applyModifications(bytes:ByteArray):void {
			// if code injected: call modificationsApplied with the modified bytes as part of a loader.loadbytes Event (event.target.content)
			// else override to add any other stuff on the stage
		}

		protected function modificationsApplied(event:Event):void {
			while (mainStage.numChildren > 0){
				var obj:Sprite = mainStage.removeChildAt(0) as Sprite;
				obj.mouseChildren = false;
				obj.mouseEnabled = false;
				obj.visible = false;
			}

			mainStage.addChild(event.target.content)
		}
	}
}
