package scripts;

import transition.CustomTransition;
import transition.data.InstantTransition;

import modding.PolymodHandler;
import extensions.flixel.FlxUIStateExt;
import restricted.RestrictedUtils;

//Basically just FlxUIStateExt with polymodReload
class ScriptedState extends FlxUIStateExt
{
	public var stateName:String = "";

	override public function update(elapsed:Float){
		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload(false);
			var newInstance = RestrictedUtils.callStaticGeneratedMethod(ScriptableState, "init", [stateName]);
			Reflect.setProperty(newInstance, "stateName", stateName);
			customTransOut = new InstantTransition();
			switchState(newInstance);
		}
		super.update(elapsed);
	}
}