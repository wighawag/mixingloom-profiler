package com.wighawag.injection.injector {
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.abc.MethodBody;
	import org.as3commons.bytecode.abc.Op;

	public class MethodCallWrapper implements IOpcodeInjector {
		private var _beginMethodCall:MethodCall;
		private var _endMethodCall:MethodCall;

		public function MethodCallWrapper(beginMethodCall:MethodCall, endMethodCall:MethodCall = null){
			_beginMethodCall = beginMethodCall;

			if (endMethodCall == null){
				_endMethodCall = _beginMethodCall;
			} else {
				_endMethodCall = endMethodCall;
			}
		}


		public function inject(methodBody:MethodBody, startIndex:uint = 0):uint {
			for each (var op:Op in methodBody.opcodes){
				startIndex++;
				if (op.opcode === Opcode.pushscope){
					break;
				}
			}

			startIndex = _beginMethodCall.inject(methodBody, startIndex);

			// add another call just before each return
			methodBody.maxStack += 1; // make sure the stack is not overflowed by allowing extra stack space
			while (startIndex < methodBody.opcodes.length){
				op = methodBody.opcodes[startIndex] as Op;
				if (op.opcode === Opcode.returnvalue || op.opcode === Opcode.returnvoid){
					startIndex = _endMethodCall.inject(methodBody, startIndex);
				}
				startIndex++;
			}
			return startIndex;
		}
	}
}