package extensions.flixel;

import transition.*;
import transition.data.*;

import scripts.ScriptableState;
import scripts.ScriptedState;
import polymod.hscript._internal.PolymodScriptClass;

import openfl.display.BitmapData;
import openfl.system.System;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
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

	override function create(){
		if(customTransIn != null){
			CustomTransition.transition(customTransIn, null);
		}
		else if(useDefaultTransIn){
			CustomTransition.transition(Type.createInstance(defaultTransIn, defaultTransInArgs), null);
		}

		//This creates a camera and a cover sprite that gets automatically added to a state that will hide anything outside the normal camera bounds.
		//Not noticable most of the time but Flixel can extend cameras out by 1 pixel when the game isn't at it's native resolution can it can create a weird pixel gap.
		//Also useful to hide stuff outside the frame on rotated cameras since those won't be clipped to the game resolution and show up when the game is maximized.
		var coverCamera:FlxCamera = new FlxCamera(((FlxG.width*2)-FlxG.width)/-2, ((FlxG.height*2)-FlxG.height)/-2, FlxG.width*2, FlxG.height*2);
		coverCamera.bgColor.alpha = 0;
		FlxG.cameras.add(coverCamera, false);

		//3x3 black image with transparent hole in the center. 
		var coverBitmap:BitmapData = new BitmapData(3, 3, true, 0xFF000000);
		coverBitmap.setPixel32(1, 1, 0x00000000);
		
		var coverSprite:FlxSprite = new FlxSprite().loadGraphic(coverBitmap);
		coverSprite.scale.set(1280, 720);
		coverSprite.x = (coverCamera.width - coverSprite.width) / 2;
		coverSprite.y = (coverCamera.height - coverSprite.height) / 2;
		coverSprite.cameras = [coverCamera];
		add(coverSprite);
		
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
