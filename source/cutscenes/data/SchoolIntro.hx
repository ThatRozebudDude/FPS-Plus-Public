package cutscenes.data;

import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class SchoolIntro extends ScriptedCutscene
{

    override function init():Void{
        addEvent(0, schoolIntro);
    }

    function schoolIntro() {
        playstate().schoolIntro(playstate().dialogueBox);
        if(PlayState.SONG.song.toLowerCase() == "roses"){
            FlxG.sound.play(Paths.sound('week6/ANGRY'));
        }
    }

}