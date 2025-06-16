package extensions.flixel;

import transition.*;
import transition.data.*;

import scripts.ScriptableState;
import scripts.ScriptedState;
import polymod.hscript._internal.PolymodScriptClass;

import cpp.vm.Gc;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import restricted.RestrictedUtils;

using StringTools;

class FlxUIStateExt extends FlxUIState
{
	public var useDefaultTransIn:Bool = true;
	public var useDefaultTransOut:Bool = true;

	public static var defaultTransIn:Class<Dynamic>;
	public static var defaultTransInArgs:Array<Dynamic>;
	public static var defaultTransOut:Class<Dynamic>;
	public static var defaultTransOutArgs:Array<Dynamic>;

	public static var inTransition:Bool = false;

	public var customTransIn:BaseTransition = null;
	public var customTransOut:BaseTransition = null;

	override function create()
	{
		if(customTransIn != null){
			CustomTransition.transition(customTransIn, null);
		}
		else if(useDefaultTransIn){
			CustomTransition.transition(Type.createInstance(defaultTransIn, defaultTransInArgs), null);
		}
		super.create();
	}

	public function switchState(_state:FlxState, ?_allowScriptedOverrides:Bool = true):Void{
		//Scripted States
		if(_allowScriptedOverrides){
			final statePath = Type.getClassName(Type.getClass(_state));
			final stateName = statePath.split(".")[statePath.split(".").length - 1];

			//These are bit "hacky" but we have to do this to create script instance in parent...
			if(RestrictedUtils.callStaticGeneratedMethod(ScriptableState, "listScriptClasses").contains(stateName)){
				_state = ScriptedState.init(stateName);
			}
			//Extended States
			else if(PolymodScriptClass.listScriptClassesExtending(statePath).length > 0){
				var scriptClassPath = statePath.replace(stateName, "Scripted" + stateName);
				_state = RestrictedUtils.callStaticGeneratedMethod(Type.resolveClass(scriptClassPath), "init", [RestrictedUtils.callStaticGeneratedMethod(Type.resolveClass(scriptClassPath), "listScriptClasses")[0]]);
				Reflect.setProperty(_state, "_stateName", "Scripted" + stateName);
			}

		}

		//Transition stuff.
		if(customTransOut != null){
			CustomTransition.transition(customTransOut, _state);
		}
		else if(useDefaultTransOut){
			CustomTransition.transition(Type.createInstance(defaultTransOut, defaultTransOutArgs), _state);
			return;
		}
		else{
			CustomTransition.transition(new InstantTransition(), _state);
			return;
		}
	}
}
