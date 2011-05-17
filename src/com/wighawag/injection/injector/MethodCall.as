package com.wighawag.injection.injector {
	import flash.errors.IllegalOperationError;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.abc.MethodBody;
	import org.as3commons.bytecode.abc.Op;
	import org.as3commons.bytecode.abc.QualifiedName;

	public class MethodCall implements IOpcodeInjector {
		private var _findOp:Op;
		private var _getOp:Op;
		private var _pushOp:Op;
		private var _callOp:Op;

		public function MethodCall(classQName:QualifiedName, methodQName:QualifiedName, args:Array = null){
			var numArgs:uint = 0;

			_findOp = new Op(Opcode.findpropstrict, [classQName]);
			_getOp = new Op(Opcode.getproperty, [classQName]);
			if (args != null && args.length > 0){
				_pushOp = new Op(Opcode.pushstring, [args[0]]);
				numArgs = 1;
			}
			_callOp = new Op(Opcode.callproperty, [methodQName, numArgs]);

		}

		public function inject(methodBody:MethodBody, startIndex:uint = 0):uint {
			var newStartIndex:uint = startIndex;
			if (_pushOp != null){
				newStartIndex += 5;
				methodBody.opcodes.splice(startIndex, 0, _findOp, _getOp, _pushOp, _callOp, new Op(Opcode.pop));
			} else {
				newStartIndex += 4;
				methodBody.opcodes.splice(startIndex, 0, _findOp, _getOp, _callOp, new Op(Opcode.pop));
			}

			return newStartIndex;
		}

	}

}