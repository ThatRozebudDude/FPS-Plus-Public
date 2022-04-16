package;

import transition.*;
import transition.data.*;

import cpp.vm.Gc;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;

class UIStateExt extends FlxUIState
{
	private var useDefaultTransIn:Bool = true;
	private var useDefaultTransOut:Bool = true;

	public static var defaultTransIn:Class<Dynamic>;
	public static var defaultTransInArgs:Array<Dynamic>;
	public static var defaultTransOut:Class<Dynamic>;
	public static var defaultTransOutArgs:Array<Dynamic>;

	private var customTransIn:BasicTransition = null;
	private var customTransOut:BasicTransition = null;

    private var controls(get, never):Controls;
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if(customTransIn != null){
			CustomTransition.transition(customTransIn, null);
		}
		else if(useDefaultTransIn)
			CustomTransition.transition(Type.createInstance(defaultTransIn, defaultTransInArgs), null);
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
			FlxG.switchState(_state);
			System.gc();
			return;
		}
	}

}
