package scripts;

import transition.CustomTransition;
import transition.data.InstantTransition;

import modding.PolymodHandler;
import extensions.flixel.FlxUIStateExt;
import restricted.RestrictedUtils;

//Basically just FlxUIStateExt with polymodReload
class ScriptedState extends FlxUIStateExt
{
	public var _stateName:String = "";

	override public function update(elapsed:Float){
		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload(false);
			var newInstance = init(_stateName);
			customTransOut = new InstantTransition();
			switchState(newInstance);
		}
		super.update(elapsed);
	}

	public static function init(stateString:String){
		var r = RestrictedUtils.callStaticGeneratedMethod(ScriptableState, "init", [stateString]);
		Reflect.setProperty(r, "_stateName", stateString);
		return r;
	}
}