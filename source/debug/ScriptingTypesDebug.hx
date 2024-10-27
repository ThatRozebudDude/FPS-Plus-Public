package debug;

import modding.PolymodHandler;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class ScriptingTypesDebug extends FlxState
{

	public function new() {
		super();
	}

	override function create() {
		var obj = new EmptyClass();
		trace(Reflect.fields(obj));
		super.create();
	}
}

@:build(modding.GlobalScriptingTypesMacro.build())
class EmptyClass{
	public function new() {}
}