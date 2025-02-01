package caching;

import openfl.Assets;
import flixel.FlxG;

class AudioCache
{

	public static var trackedSounds:Array<String> = new Array<String>();

	public static function clear():Void{
		for(sound in trackedSounds){
			Assets.cache.clear(sound);
		}
		
		trackedSounds = [];
	}

}