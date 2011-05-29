package com.wighawag.injection.patcher {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import injector.MethodCall;
	import org.as3commons.bytecode.abc.enum.NamespaceKind;

	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.abc.InstanceInfo;
	import org.as3commons.bytecode.abc.LNamespace;
	import org.as3commons.bytecode.abc.MethodInfo;
	import org.as3commons.bytecode.abc.Op;
	import org.as3commons.bytecode.abc.QualifiedName;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.io.AbcSerializer;

	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.AbstractPatcher;

	import org.as3commons.bytecode.io.AbcDeserializer;

	public class SampleXMLPatcher extends AbstractPatcher {
		private var _xmlData:XML;

		public function SampleXMLPatcher(xml:XML){
			super();

			_xmlData = xml;
		}

		override public function apply(invocationType:InvocationType, swfContext:SwfContext):void {
			var swfTagName:String = xmlData.interceptor.swfTag;
			var methodEntryInvokerClassName:String = _xmlData.interceptor.methodEntryInvoker.className;
			var methodEntryInvokerMethodName:String = _xmlData.interceptor.methodEntryInvoker.methodName;

			var methodEntryInvokerNamespace:String = _xmlData.interceptor.methodEntryInvoker.namespace;
			var lNamespace:LNamespace = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, methodEntryInvokerNamespace);

			var methodEntryInvokerClassQName:QualifiedName = new QualifiedName(methodEntryInvokerClassName, lNamespace);
			var methodEntryInvokerMethodQName:QualifiedName = new QualifiedName(methodEntryInvokerMethodName, LNamespace.PUBLIC);

			for each (var swfTag:SwfTag in swfContext.swfTags){
				if (swfTag.name == swfTagName){

					// skip the flags
					swfTag.tagBody.position = 4;

					var abcStartLocation:uint = 4;
					while (swfTag.tagBody.readByte() != 0){
						abcStartLocation++;
					}
					abcStartLocation++; // skip the string byte terminator

					swfTag.tagBody.position = 0;

					var abcDeserializer:AbcDeserializer = new AbcDeserializer(swfTag.tagBody);

					var abcFile:AbcFile = abcDeserializer.deserialize(abcStartLocation);

					var methodCall:MethodCall = new MethodCall(methodEntryInvokerClassQName, methodEntryInvokerMethodQName);

					for each (var instanceInfo:InstanceInfo in abcFile.instanceInfo){

						for each (var methodInfo:MethodInfo in instanceInfo.methodInfo){

							var startIndex:uint = 0;
							for each (var op:Op in methodBody.opcodes){
								startIndex++;
								if (op.opcode === Opcode.pushscope){
									break;
								}
							}

							methodCall.inject(methodInfo.methodBody, startIndex);
						}
					}

					var abcSerializer:AbcSerializer = new AbcSerializer();
					var modifiedBytes:ByteArray = new ByteArray();
					modifiedBytes.writeBytes(swfTag.tagBody, 0, abcStartLocation);
					modifiedBytes.writeBytes(abcSerializer.serializeAbcFile(abcFile));

					swfTag.tagBody = modifiedBytes;
				}
			}

			invokeCallBack();
		}
	}
}