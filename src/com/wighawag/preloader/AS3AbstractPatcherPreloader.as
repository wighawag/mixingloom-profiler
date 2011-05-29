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

		private var _patcherApplier:IPatcherApplier;
		private var _bytesToModify:ByteArray;

		public function AS3AbstractPatcherPreloader(){
			_patcherApplier = new PatcherApplierImpl();
		}

		override protected function applyModifications(bytes:ByteArray):void {
			// save the bytes to apply to and wait for the sub class to call applyPatchers
			_bytesToModify = bytes;
		}

		// this following method need to be called by the subclass to apply the list of patchers provided
		protected function applyPatchers(patchers:Vector.<IPatcher>):void {
			_patcherApplier.patchers = patchers;

			var parser:ByteParser = new ByteParser();
			var swfContext:SwfContext = new SwfContext();
			swfContext.originalUncompressedSwfBytes = parser.uncompressSwf(_bytesToModify);
			swfContext.swfTags = parser.getAllSwfTags(swfContext.originalUncompressedSwfBytes);

			_patcherApplier.swfContext = swfContext;
			_patcherApplier.invocationType = new InvocationType(InvocationType.FRAME2); // not sure?
			_patcherApplier.setCallBack(modificationsApplied);

			_patcherApplier.apply();
		}

	}
}