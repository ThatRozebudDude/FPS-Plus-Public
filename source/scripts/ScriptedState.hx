package scripts;

import transition.CustomTransition;
import transition.data.InstantTransition;

import modding.PolymodHandler;
import restricted.RestrictedUtils;

//Basically just MusicBeatState with polymodReload
class ScriptedState extends MusicBeatState
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