package cutscenes.data;

import transition.data.InstantTransition;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class EggnogEnding extends ScriptedCutscene
{

    override function init():Void{
        addEvent(0, end);
    }

    function end() {
        var blackShit:FlxSprite = new FlxSprite(-FlxG.width * playstate.camGame.zoom,
            -FlxG.height * playstate.camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
        blackShit.scrollFactor.set();
        addToForegroundLayer(blackShit);
        playstate.camHUD.visible = false;
        FlxG.sound.play(Paths.sound('week5/Lights_Shut_off'));
        playstate.endSong();
    }

}