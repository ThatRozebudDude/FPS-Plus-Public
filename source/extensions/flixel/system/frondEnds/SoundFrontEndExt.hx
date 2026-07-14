package extensions.flixel.system.frondEnds;

import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.sound.FlxSoundGroup;
import flixel.sound.FlxSound;
import flixel.system.frontEnds.SoundFrontEnd;

class SoundFrontEndExt extends SoundFrontEnd
{

	override function load(?embeddedSound:FlxSoundAsset, volume:Float = 1.0, looped:Bool = false, ?group:FlxSoundGroup, autoDestroy:Bool = false, autoPlay:Bool = false, ?url:String, ?onComplete:() -> Void, ?onLoad:() -> Void):FlxSound{
		var sound:FlxSound = super.load(embeddedSound, volume, looped, group, autoDestroy, autoPlay, url, onComplete, onLoad);
		if(sound != null){ list.add(sound); }
		return sound;
	}
	
	override function play(embeddedSound:FlxSoundAsset, volume:Float = 1.0, looped:Bool = false, ?group:FlxSoundGroup, autoDestroy:Bool = true, ?onComplete:() -> Void):FlxSound{
		var sound:FlxSound = super.play(embeddedSound, volume, looped, group, autoDestroy, onComplete);
		if(sound != null){ list.add(sound); }
		return sound;
	}

}