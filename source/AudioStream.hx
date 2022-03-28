package;

import flixel.FlxG;
import openfl.media.SoundTransform;
import flixel.tweens.FlxTween;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.Assets;

/**
	Uses OpenFL audio functions instead of HaxeFlixel for better memory usage.
	Written by Smokey.
**/

class AudioStream
{
	public var sound:Sound;
	var channel:SoundChannel;
	var fadeTween:FlxTween;
	var volume:Float = 1;

	public function new()
	{
		sound = new Sound();
	}

	public function loadSound(key:String, cache:Bool = true)
	{
		if (sound != null)
			sound = Assets.getMusic(key, cache);
		else
			trace('sound is null dickhead');
	}

	public function play()
	{
		channel = sound.play();
		channel.soundTransform = new SoundTransform(FlxG.sound.volume);
	}

	public function changeVolume(vol:Float)
	{
		if (channel != null)
			channel.soundTransform = new SoundTransform(vol);

		volume = vol;
	}

	public function stop()
	{
		if (channel != null)
		{
			channel.stop();
			channel = null;
		}
		else
			trace('No sound found in the channel!');
	}
}
