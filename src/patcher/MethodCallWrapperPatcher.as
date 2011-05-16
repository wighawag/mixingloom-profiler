package patcher {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import injector.IOpcodeInjector;
	import injector.MethodCall;
	import injector.MethodCallWrapper;
	import org.as3commons.bytecode.abc.enum.NamespaceKind;
	import org.as3commons.bytecode.tags.DoABCTag;

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

	public class MethodCallWrapperPatcher extends AbstractXMLPatcher {

		public function MethodCallWrapperPatcher(url:String){
			super(url);
		}

		override protected function handleXMLLoad(event:Event):void {
			var xmlData:XML = new XML((event.currentTarget as URLLoader).data as String);

			var targetClasses : Dictionary = new Dictionary;
			
			for each (var injection:XML in xmlData.*) {
				
				var methodEntryInvokerClassName:String = injection.source.entry.className;
				var methodEntryInvokerNamespace:String = methodEntryInvokerClassName.substr(0, methodEntryInvokerClassName.lastIndexOf('.'));
				methodEntryInvokerClassName = methodEntryInvokerClassName.substr(methodEntryInvokerClassName.lastIndexOf('.') + 1);

				var methodEntryInvokerMethodName:String = injection.source.entry.methodName;

				var lNamespace:LNamespace = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, methodEntryInvokerNamespace);

				var methodEntryInvokerClassQName:QualifiedName = new QualifiedName(methodEntryInvokerClassName, lNamespace);
				var methodEntryInvokerMethodQName:QualifiedName = new QualifiedName(methodEntryInvokerMethodName, LNamespace.PUBLIC);


				var methodExitInvokerClassName:String = injection.source.exit.className;
				var methodExitInvokerNamespace:String = methodExitInvokerClassName.substr(0, methodExitInvokerClassName.lastIndexOf('.'));
				methodExitInvokerClassName = methodExitInvokerClassName.substr(methodExitInvokerClassName.lastIndexOf('.') + 1);

				var methodExitInvokerMethodName:String = injection.source.exit.methodName;

				lNamespace = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, methodExitInvokerNamespace);

				var methodExitInvokerClassQName:QualifiedName = new QualifiedName(methodExitInvokerClassName, lNamespace);
				var methodExitInvokerMethodQName:QualifiedName = new QualifiedName(methodExitInvokerMethodName, LNamespace.PUBLIC);
			
				for each (var target:XML in injection.targets.*){
					var className : String = target.className;
					var methodName : String = target.methodName;
					
					if (!targetClasses[className])
					{
						targetClasses[className] = new Dictionary();
					}
					if (!targetClasses[className][methodName])
					{
						targetClasses[className][methodName] = new Vector.<IOpcodeInjector> // here only MethodCallWrapper
					}
					
					var methodCallWrapper:MethodCallWrapper = new MethodCallWrapper(
						new MethodCall(methodEntryInvokerClassQName, methodEntryInvokerMethodQName, [className + "." + methodName]),
						new MethodCall(methodExitInvokerClassQName, methodExitInvokerMethodQName, [className + "." + methodName])
					);
					
					targetClasses[className][methodName].push(methodCallWrapper);

				}
			}
			

			for each (var swfTag:SwfTag in swfContext.swfTags){
				if (swfTag.type == DoABCTag.TAG_ID){
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

					for each (var instanceInfo:InstanceInfo in abcFile.instanceInfo) {
						var targetMethods : Dictionary = targetClasses[instanceInfo.classMultiname.fullName];
						if (targetMethods){
							for each (var methodInfo:MethodInfo in instanceInfo.methodInfo){
								var methodShortName:String = methodInfo.as3commonsBytecodeName.fullName;
								methodShortName = methodShortName.substr(methodShortName.lastIndexOf('.') + 1);
								if (targetMethods[methodShortName]) {
									for each (var opcodeInjector : IOpcodeInjector in targetMethods[methodShortName])
									{
										opcodeInjector.inject(methodInfo.methodBody);
									}
								}
							}
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