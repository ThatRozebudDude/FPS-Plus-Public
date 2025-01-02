package modding;

import polymod.Polymod;

/*
	Create an abstract alias for it until it is implemented in Polymod itself.
	also assists with updating to new scripting API.
*/

using StringTools;

class ScriptingCompat
{
	public static function implement():Void
	{
		// Abstracts
		Polymod.addImportAlias("flash.display.BlendMode", BlendMode);
		Polymod.addImportAlias("openfl.display.BlendMode", BlendMode);

		Polymod.addImportAlias("flixel.text.FlxText.FlxTextBorderStyle", FlxTextBorderStyle);
		Polymod.addDefaultImport(FlxTextBorderStyle);

		Polymod.addImportAlias("flixel.util.FlxColor", FlxColor);

		Polymod.addImportAlias("StringTools", StringToolsScript);
		Polymod.addDefaultImport(StringToolsScript, "StringTools");
	}
}
// Old Script Classes For Just Showing Deprecated Error

class CharacterInfoBase
{
	override public function new(){
		trace("CharacterInfoBase is deprecated, use CharacterInfo");
	}
}
class BaseStage
{
	public function new(){
		trace("BaseStage is deprecated, use Stages");
	}
}

class ScriptedCutscene
{
	public function new(args:Array<Dynamic>){
		trace("ScriptedCutscene is deprecated, use Cutscene");
	}
}

// Alias for Abstracts
class BlendMode
{
	public static final ADD = openfl.display.BlendMode.ADD;
	public static final ALPHA = openfl.display.BlendMode.ALPHA;
	public static final DARKEN = openfl.display.BlendMode.DARKEN;
	public static final DIFFERENCE = openfl.display.BlendMode.DIFFERENCE;
	public static final ERASE = openfl.display.BlendMode.ERASE;
	public static final HARDLIGHT = openfl.display.BlendMode.HARDLIGHT;
	public static final INVERT = openfl.display.BlendMode.INVERT;
	public static final LAYER = openfl.display.BlendMode.LAYER;
	public static final LIGHTEN = openfl.display.BlendMode.LIGHTEN;
	public static final MULTIPLY = openfl.display.BlendMode.MULTIPLY;
	public static final NORMAL = openfl.display.BlendMode.NORMAL;
	public static final OVERLAY = openfl.display.BlendMode.OVERLAY;
	public static final SCREEN = openfl.display.BlendMode.SCREEN;
	public static final SHADER = openfl.display.BlendMode.SHADER;
	public static final SUBTRACT = openfl.display.BlendMode.SUBTRACT;
}

class FlxTextBorderStyle
{
	public static final NONE = flixel.text.FlxText.FlxTextBorderStyle.NONE;
	public static final SHADOW = flixel.text.FlxText.FlxTextBorderStyle.SHADOW;
	public static final OUTLINE = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE;
	public static final OUTLINE_FAST = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE_FAST;
}

class FlxColor
{
	public static final TRANSPARENT = 0x00000000;
	public static final WHITE = 0xFFFFFFFF;
	public static final GRAY = 0xFF808080;
	public static final BLACK = 0xFF000000;

	public static final GREEN = 0xFF008000;
	public static final LIME = 0xFF00FF00;
	public static final YELLOW = 0xFFFFFF00;
	public static final ORANGE = 0xFFFFA500;
	public static final RED = 0xFFFF0000;
	public static final PURPLE = 0xFF800080;
	public static final BLUE = 0xFF0000FF;
	public static final BROWN = 0xFF8B4513;
	public static final PINK = 0xFFFFC0CB;
	public static final MAGENTA = 0xFFFF00FF;
	public static final CYAN = 0xFF00FFFF;

	public static function fromCMYK(c:Float, m:Float, y:Float, b:Float, a:Float = 1):Int
		return flixel.util.FlxColor.fromCMYK(c, m, y, b, a);

	public static function fromHSB(h:Float, s:Float, b:Float, a:Float = 1):Int
		return flixel.util.FlxColor.fromHSB(h, s, b, a);

	public static function fromInt(num:Int):Int
		return flixel.util.FlxColor.fromInt(num);

	public static function fromRGBFloat(r:Float, g:Float, b:Float, a:Float = 1):Int
		return flixel.util.FlxColor.fromRGBFloat(r, g, b, a);

	public static function fromRGB(r:Int, g:Int, b:Int, a:Int = 255):Int
		return flixel.util.FlxColor.fromRGB(r, g, b, a);

	public static function getHSBColorWheel(a:Int = 255):Array<Int>
		return flixel.util.FlxColor.getHSBColorWheel(a);

	public static function gradient(color1:flixel.util.FlxColor, color2:flixel.util.FlxColor, steps:Int, ?ease:Float->Float):Array<Int>
		return flixel.util.FlxColor.gradient(color1, color2, steps, ease);

	public static function interpolate(color1:flixel.util.FlxColor, color2:flixel.util.FlxColor, factor:Float = 0.5):Int
		return flixel.util.FlxColor.interpolate(color1, color2, factor);

	public static function fromString(string:String):Int
		return flixel.util.FlxColor.fromString(string);
}

class StringToolsScript
{
	public static function contains(s:String, value:String):Bool
		return s.contains(value);

	public static function endsWith(s:String, end:String):Bool
		return s.endsWith(end);

	public static function fastCodeAt(s:String, index:Int):Int
		return s.fastCodeAt(index);

	public static function hex(n:Int, ?digits:Int):String
		return hex(n, digits);

	public static function htmlEscape(s:String, ?quotes:Bool):String
		return s.htmlEscape(quotes);

	public static function htmlUnescape(s:String):String
		return s.htmlUnescape();

	public static function isEof(c:Int):Bool
		return isEof(c);

	public static function isSpace(s:String, pos:Int):Bool
		return s.isSpace(pos);

	public static function ltrim(s:String):String
		return s.ltrim();

	public static function replace(s:String, sub:String, by:String):String
		return s.replace(sub, by);

	public static function startsWith(s:String, start:String):Bool
		return s.startsWith(start);
}