package caching;

import openfl.Assets;
import flixel.FlxG;
import flixel.sound.FlxSoundGroup;

using StringTools;

class AudioCache
{

	public static var trackedSounds:Array<String> = new Array<String>();
	public static var trackedMusic:Array<String> = new Array<String>();
	//public static var currentTrackedBGM:String = "";

	public static function clear():Void{
		for(sound in trackedSounds){
			Assets.cache.clear(sound);
		}
		for(music in trackedMusic){
			Assets.cache.clear(music);
		}
		trackedSounds = [];
		trackedMusic = [];
	}

	//Keeps track of the current track playing on FlxG.sound.music and removes it from the cache when changed.
	/*public static function playMusic(path:String, volume:Float = 1.0, looped:Bool = true, ?group:FlxSoundGroup) {
		FlxG.sound.playMusic(path, volume, looped, group);
		if((!path.startsWith("assets/songs")) && path != currentTrackedBGM){
			Assets.cache.clear(currentTrackedBGM);
			trackedMusic.remove(currentTrackedBGM);
			currentTrackedBGM = path;
		}
	}*/

}