package;

import flixel.math.FlxMath;
import flixel.FlxG;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	/**
		Lerps camera, but accountsfor framerate shit?
		Right now it's simply for use to change the followLerp variable of a camera during update
		TODO LATER MAYBE:
			Actually make and modify the scroll and lerp shit in it's own function
			instead of solely relying on changing the lerp on the fly
	 */
	public static inline function fpsAdjust(value:Float, ?referenceFps:Float = 60):Float
	{
		return value * (FlxG.elapsed / (1 / referenceFps));
	}

	/*
	* just lerp that does camLerpShit for u so u dont have to do it every time
	*/
	public static inline function fpsAdjsutedLerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, fpsAdjust(ratio));
	}
}
