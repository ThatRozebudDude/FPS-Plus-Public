package extensions.flixel.system.frondEnds;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.system.FlxAssets.FlxSoundAsset;
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

	override function changeVolume(amount:Float):Void{
		muted = false;
		volume = linearToLog(logToLinear(volume) + amount);

		// Makes sure that the volume is fully muted when it hits the lower limit and is fully set back to max when increased
		if(volume < 0.0011){ volume = 0; }
		else if(volume > 0.99){ volume = 1; }

		showSoundTray(amount > 0);
	}

}