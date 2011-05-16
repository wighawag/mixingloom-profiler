package injector {
	import org.as3commons.bytecode.abc.MethodBody;

	public interface IOpcodeInjector {
		function inject(methodBody:MethodBody, startIndex:uint = 0):uint;
	}

}