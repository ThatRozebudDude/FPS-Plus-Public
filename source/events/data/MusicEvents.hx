package events.data;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class MusicEvents extends Events
{

    override function defineEvents() {
        addEvent("muteInst", muteInst);
        addEvent("playInst", playInst);

        addEvent("muteVocals", muteVocals);
        addEvent("playVocals", playVocals);
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
                case "bf" | "boyfreind" |"player":
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

}