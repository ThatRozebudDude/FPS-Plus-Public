package extensions.flixel.system.frontEnds;

import config.CacheConfig;
import config.Config;
import openfl.Assets;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.sound.FlxSoundGroup;
import flixel.system.frontEnds.SoundFrontEnd;

using StringTools;

@:allow(flixel.FlxG)
class SoundFrontEndExt extends SoundFrontEnd
{

    var currentTrackedBGM:String = "___";

    public function new() {
        super();
    }

    //Keeps track of the current track playing on FlxG.sound.music and removes it from the cache when changed.
    override public function playMusic(embeddedMusic:String, volume:Float = 1.0, looped:Bool = true, ?group:FlxSoundGroup) {
        super.playMusic(embeddedMusic, volume, looped, group);
        if((!CacheConfig.music || !embeddedMusic.startsWith("assets/songs")) && embeddedMusic != currentTrackedBGM){
            Assets.cache.clear(currentTrackedBGM);
            currentTrackedBGM = embeddedMusic;
        }
    }

}