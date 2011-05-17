package com.wighawag.preloader {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import org.mixingloom.byteCode.ByteParser;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.IPatcher;
	import org.mixingloom.preloader.watcher.IPatcherApplier;
	import org.mixingloom.preloader.watcher.PatcherApplierImpl;
	import org.mixingloom.SwfContext;

	public class AS3AbstractPatcherPreloader extends AS3AbstractPreloader {

		private var _patcherApplier : IPatcherApplier;

		public function AS3AbstractPatcherPreloader(patchers : Vector.<IPatcher>){
			_patcherApplier = new PatcherApplierImpl();
			_patcherApplier.patchers = patchers;
		}

		override protected function applyModifications(bytes:ByteArray):void {
			var parser:ByteParser = new ByteParser();
			var swfContext : SwfContext = new SwfContext();
			swfContext.originalUncompressedSwfBytes = parser.uncompressSwf(bytes);
			swfContext.swfTags = parser.getAllSwfTags(swfContext.originalUncompressedSwfBytes);

			_patcherApplier.swfContext = swfContext;
			_patcherApplier.invocationType = new InvocationType(InvocationType.FRAME2); // not sure?
			_patcherApplier.setCallBack(modificationsApplied);
			
			_patcherApplier.apply();
		}

	}
}