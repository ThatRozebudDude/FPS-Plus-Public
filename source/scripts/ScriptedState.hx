package scripts;

import modding.PolymodHandler;
import transition.CustomTransition;
import transition.data.InstantTransition;

//Basically just MusicBeatState with polymodReload
class ScriptedState extends MusicBeatState
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
		var r = restricted.RestrictedUtils.callStaticGeneratedMethod(ScriptableState, "scriptInit", [stateString]);
		Reflect.setProperty(r, "_stateName", stateString);
		return r;
	}
}