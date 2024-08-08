package cutscenes.data;

import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class LilBuddiesIntro extends ScriptedCutscene
{
    
    override function init():Void{
        addEvent(0, lilBuddiesIntro);
    }

    function lilBuddiesIntro() {
        if(PlayState.fceForLilBuddies){
            playstate.lilBuddiesStart();
        }
        else{
            playstate.startCountdown();
        }
    }

}