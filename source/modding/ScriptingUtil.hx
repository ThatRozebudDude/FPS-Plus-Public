package modding;

import openfl.display.BlendMode;
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
    public static inline function get_axisNone()    { return 0x00; }
    public static var axisX(get, never):Int;
    public static inline function get_axisX()       { return 0x01; }
    public static var axisY(get, never):Int;
    public static inline function get_axisY()       { return 0x11; }
    public static var axisXY(get, never):Int;
    public static inline function get_axisXY()      { return 0x10; }

    public static var rankNone(get, never):Rank;
    public static inline function get_rankNone()        { return none; }
    public static var rankLoss(get, never):Rank;
    public static inline function get_rankLoss()        { return loss; }
    public static var rankGood(get, never):Rank;
    public static inline function get_rankGood()        { return good; }
    public static var rankGreat(get, never):Rank;
    public static inline function get_rankGreat()       { return great; }
    public static var rankExcellent(get, never):Rank;
    public static inline function get_rankExcellent()   { return excellent; }
    public static var rankPerfect(get, never):Rank;
    public static inline function get_rankPerfect()     { return perfect; }
    public static var rankGold(get, never):Rank;
    public static inline function get_rankGold()        { return gold; }

    public static inline function makeFlxGroup():FlxTypedGroup<FlxBasic>                { return new FlxTypedGroup<FlxBasic>(); }
    public static inline function makeFlxSpriteGroup():FlxTypedSpriteGroup<FlxSprite>   { return new FlxTypedSpriteGroup<FlxSprite>(); }

    public static inline function keyFromString(key:String):FlxKey                      { return FlxKey.fromString(key); }

    //Things that should work but don't... kinda...
    public static inline function contains(a:String, b:String):Bool                     { return a.contains(b); }
    public static inline function startsWith(a:String, b:String):Bool                   { return a.startsWith(b); }
    public static inline function endsWith(a:String, b:String):Bool                     { return a.endsWith(b); }
    public static inline function colorFromString(c:String):FlxColor                    { return FlxColor.fromString(c); }

    public static inline function screenCenter(obj:FlxObject, ?x:Bool = true, ?y:Bool = true):Void{ 
        if (x){ obj.x = (FlxG.width - obj.width)    / 2; }
		if (y){ obj.y = (FlxG.height - obj.height)  / 2; }	
    }
}

class PolyBlendMode
{
    public static var ADD = BlendMode.ADD;
    public static var ALPHA = BlendMode.ALPHA;
    public static var DARKEN = BlendMode.DARKEN;
    public static var DIFFERENCE = BlendMode.DIFFERENCE;
    public static var ERASE = BlendMode.ERASE;
    public static var HARDLIGHT = BlendMode.HARDLIGHT;
    public static var INVERT = BlendMode.INVERT;
    public static var LAYER = BlendMode.LAYER;
    public static var LIGHTEN = BlendMode.LIGHTEN;
    public static var MULTIPLY = BlendMode.MULTIPLY;
    public static var NORMAL = BlendMode.NORMAL;
    public static var OVERLAY = BlendMode.OVERLAY;
    public static var SCREEN = BlendMode.SCREEN;
    public static var SHADER = BlendMode.SHADER;
    public static var SUBTRACT = BlendMode.SUBTRACT;
}

class FlxTextBorderStyle
{
    public static var NONE = flixel.text.FlxText.FlxTextBorderStyle.NONE;
    public static var SHADOW = flixel.text.FlxText.FlxTextBorderStyle.SHADOW;
    public static var OUTLINE = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE;
    public static var OUTLINE_FAST = flixel.text.FlxText.FlxTextBorderStyle.OUTLINE_FAST;
}