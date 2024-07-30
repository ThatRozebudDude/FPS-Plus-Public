package extensions.flixel;

import transition.*;
import transition.data.*;

import cpp.vm.Gc;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;

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

	public function switchState(_state:FlxState){
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
