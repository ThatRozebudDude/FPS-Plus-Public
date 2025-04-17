package;

import caching.AudioCache;
import modding.PolymodHandler;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import sys.io.File;
import sys.FileSystem;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.utils.Assets;
import openfl.system.System;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#if yaml
import yaml.Yaml;
import yaml.Parser;
import yaml.Renderer;
import yaml.util.ObjectMap;
#end
using StringTools;
using Lambda;

class Utils
{

	public static final resultsTextCharacters = "AaBbCcDdEeFfGgHhiIJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz:1234567890.-'[]()";

	public static function getTextInLines(path:String):Array<String>{
		var daList:Array<String> = getText(path).trim().split('\n');

		for (i in 0...daList.length){
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//find actual graphic mid point (for backwards compatanility with people who don't update flixel)
	public static inline function getGraphicMidpoint(sprite:FlxSprite, ?point:FlxPoint):FlxPoint{
		#if (flixel >= "5.7.0")
		return sprite.getGraphicMidpoint(point);
		#else
		if (point == null){
			point = FlxPoint.get();
		}
		return point.set(sprite.x + sprite.frameWidth * 0.5 * sprite.scale.x, sprite.y + sprite.frameHeight * 0.5 * sprite.scale.y);
		#end
	}

	//the options menu requires the old one to work :[[[[[
	public static inline function oldGetGraphicMidpoint(sprite:FlxSprite, ?point:FlxPoint):FlxPoint{
		if (point == null){
			point = FlxPoint.get();
		}
		return point.set(sprite.x + sprite.frameWidth * 0.5, sprite.y + sprite.frameHeight * 0.5);
	}

	//Actually center offsets.
	public static inline function centerOffsets(sprite:FlxSprite, AdjustPosition:Bool = false):Void{
		sprite.offset.x = ((sprite.frameWidth * sprite.scale.x) - sprite.width) * 0.5;
		sprite.offset.y = ((sprite.frameHeight * sprite.scale.y) - sprite.height) * 0.5;
		if (AdjustPosition){
			sprite.x += sprite.offset.x;
			sprite.y += sprite.offset.y;
		}
	}

	/*
	*	Adjusts the value based on the reference FPS.
	*/
	public static inline function fpsAdjust(value:Float, ?referenceFps:Float = 60):Float{
		return value * (referenceFps * FlxG.elapsed);
	}

	/**
	* Lerp function that can be run in update and is consistent independent of the game's framerate.
	* 
	* @param	a				Source value.
	* @param	b				Target value.
	* @param	ratio			The ratio at which the values are interpolated.
	* @param	referenceFps	An optional parameter that makes the lerp act as if it was running at that framerate.
	* @param	snap			An optional parameter that determines whether to snap `a` to `b` if their difference is within `snapTolerance`.
	* @param	snapTolerance	An optional parameter that adjusts the difference needed to snap `a` to `b`.
	*/
	public static inline function fpsAdjustedLerp(a:Float, b:Float, ratio:Float, ?referenceFps:Float = 60, ?snap:Bool = false, ?snapTolerance:Float = 0.001):Float{
		var v = dampen(a, b, Math.pow(1 - ratio, referenceFps));
		return (snap && inRange(v, b, snapTolerance)) ? b : v;
	}

	/**
	* The dampening fuction used in `fpsAdjustedLerp`.
	* 
	* @param	a				Source value.
	* @param	b				Target value.
	* @param	smoothing		The proportion of `a` left after 1 second.
	*/
	public static inline function dampen(a:Float, b:Float, smoothing:Float):Float{
		return FlxMath.lerp(a, b, 1 - Math.pow(smoothing, FlxG.elapsed));
	}

	/*
	*	Lerp that calls `fpsAdjust` on the ratio.
	*	This function is exactly the correct way to do this but I'm leaving it here for backwards compatibility.
	*/
	public static inline function fpsAdjustedLerpOld(a:Float, b:Float, ratio:Float):Float{
		return FlxMath.lerp(a, b, clamp(fpsAdjust(ratio), 0, 1));
	}

	public static inline function inRange(a:Float, b:Float, tolerance:Float):Bool{
		return (a <= b + tolerance && a >= b - tolerance);
	}

	/*
	*	Left over functions. Hopefully polymod should be able to do this now.
	*/
	public static function exists(path:Dynamic):Bool{
		if(Std.isOfType(path, String)){
			return Assets.exists(path);
		}
		
		return (path != null);
	}

	public static function getText(path:String):String{
		return Assets.getText(path);
	}

	public static function clamp(v:Float, min:Float, max:Float):Float {
		if(v < min) { v = min; }
		if(v > max) { v = max; }
		return v;
	}

	public static function worldToLocal(object:FlxObject, x:Float, y:Float):FlxPoint{
		return new FlxPoint(x - object.x, y - object.y);
	}

	public static inline function sign(v:Float):Int {
		return (v > 0 ? 1 : (v < 0 ? -1 : 0));
	}

	/**
	* Creates a solid color sprite with the desired demensions by createing a 1x1 sprite and scaling it.
	*
	* @param	width		The desired width of the sprite.
	* @param	height		The desired height of the sprite.
	* @param	color		The desired color of the sprite.
	* @param	zoomAdjust	An optional parameter that the width and height are divided by. Useful if you need specific dimensions but the camera is zoomed.
	*/
	public static function makeColoredSprite(width:Float, height:Float, color:FlxColor, ?zoomAdjustment:Float = 1):FlxSprite{
		var r:FlxSprite = new FlxSprite().makeGraphic(1, 1, color);
		r.scale.set(width/zoomAdjustment, height/zoomAdjustment);
		r.updateHitbox();
		return r;
	}

	//FileSystem readDirectory but with mods folder
	public static inline function readDirectory(path:String):Array<String>{
		var files:Array<String> = null;
		if(FileSystem.exists(path)){ files = FileSystem.readDirectory(path); }
		for (mod in PolymodHandler.loadedModDirs){
			if (FileSystem.exists('mods/$mod/' + path.split("assets/")[1])){
				if(files == null){ files = []; }
				var modfile = FileSystem.readDirectory('mods/$mod/' + path.split("assets/")[1]);
				for (file in modfile){
					if (!files.contains(file)){
						files.push(file);
					}
				}
			}
		}
		return files;
	}

	//Removes duplicate items from an array. Can additionally supply extra arrays to check from.
	public static function removeDuplicates(arr:Dynamic, ?extraArrayComparisons:Array<Dynamic>):Dynamic{
		if(extraArrayComparisons == null){ extraArrayComparisons = []; }
		var duplicates:Array<Dynamic> = [];
		return arr.filter(function(element){
			if(!duplicates.contains(element)){
				var r:Bool = true;
				for(array in extraArrayComparisons){ if(array.contains(element)){ r = false; } }
				duplicates.push(element);
				return r;
			}
			return false;
		});
	}

	//Flixel 5.9.0 changed how animation callbacks are called so destroying an object in one of them will cause a null object reference. This is a fix for that.
	//Sets up an object to be destroyed after the update loop is finished being processed.
	public static inline function destroyWhenAvailable(obj:FlxObject):Void{
		FlxG.signals.postUpdate.addOnce(function(){ obj.destroy(); });
	}

	public static inline function defaultSongMetadata(_name:String):Dynamic{
		return {
			name: _name,
			artist: "",
			album: "none",
			difficulties: [0, 0, 0],
			dadBeats: [0, 2],
			bfBeats: [1, 3],
			compatableInsts: [],
			mixName: "Original",
			pauseMusic: "pause/breakfast"
		}
	}

	public static inline function keyToString(key:FlxKey):String{
		switch(key){
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case MINUS:
				return "-";
			case PLUS:
				return "=";
			case LBRACKET:
				return "[";
			case RBRACKET:
				return "]";
			case BACKSLASH:
				return "\\";
			case SCROLL_LOCK:
				return "SCROLL LOCK";
			case SEMICOLON:
				return ";";
			case QUOTE:
				return "\"";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			case SLASH:
				return "/";
			case GRAVEACCENT:
				return "`";
			case NUMPADZERO:
				return "KP 0";
			case NUMPADONE:
				return "KP 1";
			case NUMPADTWO:
				return "KP 2";
			case NUMPADTHREE:
				return "KP 3";
			case NUMPADFOUR:
				return "KP 4";
			case NUMPADFIVE:
				return "KP 5";
			case NUMPADSIX:
				return "KP 6";
			case NUMPADSEVEN:
				return "KP 7";
			case NUMPADEIGHT:
				return "KP 8";
			case NUMPADNINE:
				return "KP 9";
			case NUMPADMINUS:
				return "KP -";
			case NUMPADPLUS:
				return "KP +";
			case NUMPADPERIOD:
				return "KP .";
			case NUMPADMULTIPLY:
				return "KP *";
			case NUMPADSLASH:
				return "KP /";
			default:
				return key.toString();
		}
	}
	
	public static inline function controllerButtonToString(button:FlxGamepadInputID):String{
		switch(button){
			case LEFT_SHOULDER:
				return "LB";
			case RIGHT_SHOULDER:
				return "RB";
			case LEFT_STICK_CLICK:
				return "LS CLICK";
			case RIGHT_STICK_CLICK:
				return "RS CLICK";
			case DPAD_UP:
				return "DPAD UP";
			case DPAD_DOWN:
				return "DPAD DOWN";
			case DPAD_LEFT:
				return "DPAD LEFT";
			case DPAD_RIGHT:
				return "DPAD RIGHT";
			case LEFT_TRIGGER_BUTTON:
				return "LT";
			case RIGHT_TRIGGER_BUTTON:
				return "RT";
			case LEFT_STICK_DIGITAL_UP:
				return "LS UP";
			case LEFT_STICK_DIGITAL_RIGHT:
				return "LS RIGHT";
			case LEFT_STICK_DIGITAL_DOWN:
				return "LS DOWN";
			case LEFT_STICK_DIGITAL_LEFT:
				return "LS LEFT";
			case RIGHT_STICK_DIGITAL_UP:
				return "RS UP";
			case RIGHT_STICK_DIGITAL_RIGHT:
				return "RS RIGHT";
			case RIGHT_STICK_DIGITAL_DOWN:
				return "RS DOWN";
			case RIGHT_STICK_DIGITAL_LEFT:
				return "RS LEFT";
			default:
				return button.toString();
		}
	}

	//Runs garbage collection and compacts memory.
	public static function gc(?doCompact:Bool = true):Void{
		System.gc();
		#if cpp
		if(doCompact){ cpp.vm.Gc.compact(); }
		#end
	}
}

class OrderedMap<K, V>{

	public var keys:Array<K>;
	public var values:Array<V>;

	public function new() {
		keys = [];
		values = [];
	}

	public function set(key:K, value:V):Void{
		if(keys.contains(key)){
			var index = keys.indexOf(key);
			values[index] = value;
		}
		else{
			keys.push(key);
			values.push(value);
		}
	}

	public function get(key:K):V{
		if(keys.contains(key)){
			return values[keys.indexOf(key)];
		}
		return null;
	}

	public function remove(key:K):Void{
		if(keys.contains(key)){
			var index = keys.indexOf(key);
			keys.remove(key);
			values.remove(values[index]);
		}
	}

}