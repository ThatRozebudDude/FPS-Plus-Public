package modding;

import config.CacheConfig;
import config.Config;
import flixel.input.gamepad.FlxGamepadInputID;
import openfl.display.BlendMode as BaseBlendMode;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.input.keyboard.FlxKey;
import Highscore.Rank;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import sys.FileSystem;
import flixel.util.FlxColor;

using StringTools;

class ScriptingUtil
{
	//FlxAxes aliases.
	public static var axisNone(get, never):Int;
	public static inline function get_axisNone()	{ return 0x00; }
	public static var axisX(get, never):Int;
	public static inline function get_axisX()		{ return 0x01; }
	public static var axisY(get, never):Int;
	public static inline function get_axisY()		{ return 0x11; }
	public static var axisXY(get, never):Int;
	public static inline function get_axisXY()		{ return 0x10; }

	public static var rankNone(get, never):Rank;
	public static inline function get_rankNone()		{ return none; }
	public static var rankLoss(get, never):Rank;
	public static inline function get_rankLoss()		{ return loss; }
	public static var rankGood(get, never):Rank;
	public static inline function get_rankGood()		{ return good; }
	public static var rankGreat(get, never):Rank;
	public static inline function get_rankGreat()		{ return great; }
	public static var rankExcellent(get, never):Rank;
	public static inline function get_rankExcellent()	{ return excellent; }
	public static var rankPerfect(get, never):Rank;
	public static inline function get_rankPerfect()		{ return perfect; }
	public static var rankGold(get, never):Rank;
	public static inline function get_rankGold()		{ return gold; }

	public static inline function makeFlxGroup():FlxTypedGroup<FlxBasic>				{ return new FlxTypedGroup<FlxBasic>(); }
	public static inline function makeFlxSpriteGroup():FlxTypedSpriteGroup<FlxSprite>	{ return new FlxTypedSpriteGroup<FlxSprite>(); }

	public static inline function keyFromString(key:String):FlxKey						{ return FlxKey.fromString(key); }

	//Things that should work but don't... kinda...
	public static inline function contains(a:String, b:String):Bool						{ return a.contains(b); }
	public static inline function startsWith(a:String, b:String):Bool					{ return a.startsWith(b); }
	public static inline function endsWith(a:String, b:String):Bool						{ return a.endsWith(b); }
	public static inline function colorFromString(c:String):FlxColor					{ return FlxColor.fromString(c); }

	public static inline function screenCenter(obj:FlxObject, ?x:Bool = true, ?y:Bool = true):Void{ 
		if (x){ obj.x = (FlxG.width - obj.width)	/ 2; }
		if (y){ obj.y = (FlxG.height - obj.height)  / 2; }	
	}

	//Stuff for getting input without using Binds. Useful for adding debug keys and stuff.
	public static inline function anyPressed(keys:Array<String>):Bool{
		var checkKeys:Array<FlxKey> = [];
		for(key in keys){ checkKeys.push(FlxKey.fromString(key)); }
		return FlxG.keys.anyPressed(checkKeys);
	}
	public static inline function anyJustPressed(keys:Array<String>):Bool{
		var checkKeys:Array<FlxKey> = [];
		for(key in keys){ checkKeys.push(FlxKey.fromString(key)); }
		return FlxG.keys.anyJustPressed(checkKeys);
	}
	public static inline function anyJustReleased(keys:Array<String>):Bool{
		var checkKeys:Array<FlxKey> = [];
		for(key in keys){ checkKeys.push(FlxKey.fromString(key)); }
		return FlxG.keys.anyJustReleased(checkKeys);
	}
	
	public static inline function anyPressedController(keys:Array<String>):Bool{
		var r:Bool = false;
		for(key in keys){
			r = FlxG.gamepads.anyPressed(FlxGamepadInputID.fromString(key));
			if(r){ break; }
		}
		return r;
	}
	public static inline function anyJustPressedController(keys:Array<String>):Bool{
		var r:Bool = false;
		for(key in keys){
			r = FlxG.gamepads.anyJustPressed(FlxGamepadInputID.fromString(key));
			if(r){ break; }
		}
		return r;
	}
	public static inline function anyJustReleasedController(keys:Array<String>):Bool{
		var r:Bool = false;
		for(key in keys){
			r = FlxG.gamepads.anyJustReleased(FlxGamepadInputID.fromString(key));
			if(r){ break; }
		}
		return r;
	}
	
	public static inline function getClass<T>(o:T):Class<T>		{ return Type.getClass(o); }
}

class BlendMode
{
	public static var ADD = BaseBlendMode.ADD;
	public static var ALPHA = BaseBlendMode.ALPHA;
	public static var DARKEN = BaseBlendMode.DARKEN;
	public static var DIFFERENCE = BaseBlendMode.DIFFERENCE;
	public static var ERASE = BaseBlendMode.ERASE;
	public static var HARDLIGHT = BaseBlendMode.HARDLIGHT;
	public static var INVERT = BaseBlendMode.INVERT;
	public static var LAYER = BaseBlendMode.LAYER;
	public static var LIGHTEN = BaseBlendMode.LIGHTEN;
	public static var MULTIPLY = BaseBlendMode.MULTIPLY;
	public static var NORMAL = BaseBlendMode.NORMAL;
	public static var OVERLAY = BaseBlendMode.OVERLAY;
	public static var SCREEN = BaseBlendMode.SCREEN;
	public static var SHADER = BaseBlendMode.SHADER;
	public static var SUBTRACT = BaseBlendMode.SUBTRACT;
}

class FlxTweenType
{
	public static var PERSIST = flixel.tweens.FlxTween.FlxTweenType.PERSIST;
	public static var LOOPING = flixel.tweens.FlxTween.FlxTweenType.LOOPING;
	public static var PINGPONG = flixel.tweens.FlxTween.FlxTweenType.PINGPONG;
	public static var ONESHOT = flixel.tweens.FlxTween.FlxTweenType.ONESHOT;
	public static var BACKWARD = flixel.tweens.FlxTween.FlxTweenType.BACKWARD;
}

class FlxTextBorderStyle
{
	public static var NONE = flixel.text.FlxText.FlxTextBorderStyle.NONE;
	public static var SHADOW = flixel.text.FlxText.FlxTextBorderStyle.SHADOW;
	public static var OUTLINE = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE;
	public static var OUTLINE_FAST = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE_FAST;
}

class NativeJson
{
	public static inline function parse(text:String):Dynamic{
		return haxe.Json.parse(text);
	}

	public static inline function stringify(value:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String):String{
		return haxe.Json.stringify(value, replacer, space);
	}
}

class ScriptConfig
{
	public static var offset(get, never):Float;
	public static var healthMultiplier(get, never):Float;
	public static var healthDrainMultiplier(get, never):Float;
	public static var comboType(get, never):Int;
	public static var downscroll(get, never):Bool;
	public static var noteGlow(get, never):Bool;
	public static var ghostTapType(get, never):Int;
	public static var framerate(get, never):Int;
	public static var bgDim(get, never):Int;
	public static var noteSplashType(get, never):Int;
	public static var centeredNotes(get, never):Bool;
	public static var scrollSpeedOverride(get, never):Float;
	public static var showComboBreaks(get, never):Bool;
	public static var showFPS(get, never):Bool;
	public static var useGPU(get, never):Bool;
	public static var extraCamMovement(get, never):Bool;
	public static var camBopAmount(get, never):Int;
	public static var showCaptions(get, never):Bool;
	public static var showAccuracy(get, never):Bool;
	public static var showMisses(get, never):Int;
	public static var autoPause(get, never):Bool;
	public static var flashingLights(get, never):Bool;
	
	public static function get_offset():Float { return Config.offset; }
	public static function get_healthMultiplier():Float { return Config.healthMultiplier; }
	public static function get_healthDrainMultiplier():Float { return Config.healthDrainMultiplier; }
	public static function get_comboType():Int { return Config.comboType; }
	public static function get_downscroll():Bool { return Config.downscroll; }
	public static function get_noteGlow():Bool { return Config.noteGlow; }
	public static function get_ghostTapType():Int { return Config.ghostTapType; }
	public static function get_framerate():Int { return Config.framerate; }
	public static function get_bgDim():Int { return Config.bgDim; }
	public static function get_noteSplashType():Int { return Config.noteSplashType; }
	public static function get_centeredNotes():Bool { return Config.centeredNotes; }
	public static function get_scrollSpeedOverride():Float { return Config.scrollSpeedOverride; }
	public static function get_showComboBreaks():Bool { return Config.showComboBreaks; }
	public static function get_showFPS():Bool { return Config.showFPS; }
	public static function get_useGPU():Bool { return Config.useGPU; }
	public static function get_extraCamMovement():Bool { return Config.extraCamMovement; }
	public static function get_camBopAmount():Int { return Config.camBopAmount; }
	public static function get_showCaptions():Bool { return Config.showCaptions; }
	public static function get_showAccuracy():Bool { return Config.showAccuracy; }
	public static function get_showMisses():Int { return Config.showMisses; }
	public static function get_autoPause():Bool { return Config.autoPause; }
	public static function get_flashingLights():Bool { return Config.flashingLights; }

	public static function setFramerate(cap:Int, ?useValueInsteadOfSave:Int = -1):Void { Config.setFramerate(cap, useValueInsteadOfSave); }
}

class ScriptModConfig
{
	public static function get(uid:String, name:String):Dynamic{
		return ModConfig.get(uid, name);
	}
}

class ScriptBinds
{
	public static function pressed(input:String):Bool { return Binds.pressed(input); }
	public static function justPressed(input:String):Bool { return Binds.justPressed(input); }
	public static function justReleased(input:String):Bool { return Binds.justReleased(input); }
	public static function pressedKeyboardOnly(input:String):Bool { return Binds.pressedKeyboardOnly(input); }
	public static function justPressedKeyboardOnly(input:String):Bool { return Binds.justPressedKeyboardOnly(input); }
	public static function justReleasedKeyboardOnly(input:String):Bool { return Binds.justReleasedKeyboardOnly(input); }
	public static function pressedControllerOnly(input:String):Bool { return Binds.pressedControllerOnly(input); }
	public static function justPressedControllerOnly(input:String):Bool { return Binds.justPressedControllerOnly(input); }
	public static function justReleasedControllerOnly(input:String):Bool { return Binds.justReleasedControllerOnly(input); }
}

class ScriptCacheConfig
{
	public static var music(get, never):Null<Bool>;
	public static var characters(get, never):Null<Bool>;
	public static var graphics(get, never):Null<Bool>;

	public static inline function get_music() { return CacheConfig.music; }
	public static inline function get_characters() { return CacheConfig.characters; }
	public static inline function get_graphics() { return CacheConfig.graphics; }
}