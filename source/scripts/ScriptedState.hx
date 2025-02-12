package scripts;

import transition.CustomTransition;
import transition.data.InstantTransition;

import modding.PolymodHandler;
import extensions.flixel.FlxUIStateExt;

// Basically just FlxUIStateExt with polymodReload
class ScriptedState extends FlxUIStateExt
{
    public var stateName:String = "";

    override public function update(elapsed:Float){
        if (Binds.justPressed("polymodReload")){
			PolymodHandler.reload(false);
            // Its a bit "hacky" but we have to do this to create script instance in parent...(yep again)
            var newInstance = Utils.forceCall(ScriptableState, "init", [stateName]);
            Reflect.setProperty(newInstance, "stateName", stateName);
            CustomTransition.transition(new InstantTransition(), newInstance);
		}
        super.update(elapsed);
    }
}