package com.wighawag.injection.patcher {

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	import org.mixingloom.SwfContext;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.AbstractPatcher;

	import org.as3commons.bytecode.io.AbcDeserializer;

	public class AbstractXMLPatcher extends AbstractPatcher {

		public var url:String;

		protected var swfContext:SwfContext;
		
		private var urlLoader:URLLoader

		public function AbstractXMLPatcher(url:String){
			this.url = url;
		}

		override public function apply(invocationType:InvocationType, swfContext:SwfContext):void {
			if (invocationType.type == InvocationType.FRAME2){

				this.swfContext = swfContext;

				urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				urlLoader.addEventListener(Event.COMPLETE, handleXMLLoad);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlFailed);
				
				urlLoader.load(new URLRequest(url));
			} else {
				invokeCallBack();
			}
		}
		
		protected function xmlFailed(e:IOErrorEvent):void 
		{
			urlLoader.removeEventListener(Event.COMPLETE, handleXMLLoad);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlFailed);
			invokeCallBack();
		}

		protected function handleXMLLoad(event:Event):void {
			urlLoader.removeEventListener(Event.COMPLETE, handleXMLLoad);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlFailed);
			// TO BE OVERRIDEN
			throw new SyntaxError("Abstract call, this method need to be overriden");
		}
	}
}