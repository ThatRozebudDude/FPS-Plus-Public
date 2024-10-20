package events.data;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class MusicEvents extends Events
{

    override function defineEvents() {
        addEvent("muteInst", muteInst, MUTE_INST_DESC);
        addEvent("playInst", playInst, PLAY_INST_DESC);

        addEvent("muteVocals", muteVocals, MUTE_VOCALS_DESC);
        addEvent("playVocals", playVocals, PLAY_VOCALS_DESC);

        addEvent("toggleVocalVolumeLock", toggleVocalVolumeLock, TOGGLE_VOCAL_VOLUME_LOCK_DESC);
    }

    function muteInst(tag:String):Void{
		FlxG.sound.music.volume = 0;
    }

    function playInst(tag:String):Void{
		FlxG.sound.music.volume = 1;
    }

    function muteVocals(tag:String):Void{
        var args = Events.getArgs(tag, ["all"]);
        if(playstate.vocalType == splitVocalTrack){
            switch(args[0]){
                case "bf" | "boyfriend" |"player":
                    playstate.vocals.volume = 0;
                case "dad" | "opponent":
                    playstate.vocalsOther.volume = 0;
                default:
                    playstate.vocals.volume = 0;
                    playstate.vocalsOther.volume = 0;
            }
        }
        else{
            playstate.vocals.volume = 0;
        }
    }

    function playVocals(tag:String):Void{
        var args = Events.getArgs(tag, ["all"]);
        if(playstate.vocalType == splitVocalTrack){
            switch(args[0]){
                case "bf" | "boyfreind" |"player":
                    playstate.vocals.volume = 1;
                case "dad" | "opponent":
                    playstate.vocalsOther.volume = 1;
                default:
                    playstate.vocals.volume = 1;
                    playstate.vocalsOther.volume = 1;
            }
        }
        else{
            playstate.vocals.volume = 1;
        }
    }

    function toggleVocalVolumeLock(tag:String):Void{
        playstate.canChangeVocalVolume = !playstate.canChangeVocalVolume;
    }



    //Event descriptions. Not required but it helps with charting.
    static inline final MUTE_INST_DESC:String = "Mutes the instrumental.";
    static inline final PLAY_INST_DESC:String = "Plays the instrumental.";
    static inline final PLAY_VOCALS_DESC:String = "Plays the instrumental.\n\nArgs:\n    String: Voice track (\"bf\", \"dad\", or \"all\")";
    static inline final MUTE_VOCALS_DESC:String = "Plays the instrumental.\n\nArgs:\n    String: Voice track (\"bf\", \"dad\", or \"all\")";
    static inline final TOGGLE_VOCAL_VOLUME_LOCK_DESC:String = "Toggles whether hitting/missing notes will toggle the volume on the vocal tracks.";
}