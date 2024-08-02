package cutscenes.data;

import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class TankmanTemplate extends ScriptedCutscene
{

    var tankman:AtlasSprite;
    var picoSpeaker:AtlasSprite;
    var gfSpeaker:FlxSprite;

    override function init():Void{
        tankman = new AtlasSprite(74, 324, Paths.getTextureAtlas("week7/cutscene/tankmanCutscene"));
        tankman.antialiasing = true;
        tankman.addAnimationByLabel("ugh1", "Ugh 1", 24, false);
        tankman.addAnimationByLabel("ugh2", "Ugh 2", 24, false);
        tankman.addAnimationByLabel("guns", "Guns", 24, false);
        tankman.addAnimationByLabel("stress1", "Stress 1", 24, false);
        tankman.addAnimationByLabel("stress2", "Stress 2", 24, false);
        //tankman.addFullAnimation("full");

        picoSpeaker = new AtlasSprite(324, 5, Paths.getTextureAtlas("week7/cutscene/picoSpeakerCutscene"));
        picoSpeaker.antialiasing = true;
        picoSpeaker.addAnimationByLabel("fall", "Pico Fall", 24, false);
        picoSpeaker.addAnimationByLabel("idle", "Idle", 24, true);
        //picoSpeaker.addFullAnimation("full");

        gfSpeaker = new FlxSprite(-8, -372);
        gfSpeaker.frames = Paths.getSparrowAtlas("week7/cutscene/gfCutscene");
        gfSpeaker.antialiasing = true;
        gfSpeaker.animation.addByPrefix("summon", "", 24, false);

        addEvent(0, setup);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var move:Float = 1;
        if(FlxG.keys.anyPressed([SHIFT])){move = 10;}



        if(FlxG.keys.anyJustPressed([W])){
            tankman.y -= move;
            tankman.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([S])){
            tankman.y += move;
            tankman.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([A])){
            tankman.x -= move;
            tankman.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([D])){
            tankman.x += move;
            tankman.playAnim("full", true);
        }



        if(FlxG.keys.anyJustPressed([I])){
            picoSpeaker.y -= move;
            picoSpeaker.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([K])){
            picoSpeaker.y += move;
            picoSpeaker.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([J])){
            picoSpeaker.x -= move;
            picoSpeaker.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([L])){
            picoSpeaker.x += move;
            picoSpeaker.playAnim("full", true);
        }




        if(FlxG.keys.anyJustPressed([UP])){
            gfSpeaker.y -= move;
            gfSpeaker.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([DOWN])){
            gfSpeaker.y += move;
            gfSpeaker.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([LEFT])){
            gfSpeaker.x -= move;
            gfSpeaker.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([RIGHT])){
            gfSpeaker.x += move;
            gfSpeaker.animation.play("full", true);
        }



        if(FlxG.keys.anyJustPressed([ONE])){
            tankman.visible = !tankman.visible;
        }
        if(FlxG.keys.anyJustPressed([TWO])){
            picoSpeaker.visible = !picoSpeaker.visible;
        }
        if(FlxG.keys.anyJustPressed([THREE])){
            gfSpeaker.visible = !gfSpeaker.visible;
        }



        if(FlxG.keys.anyJustPressed([SPACE])){
            trace("tankman: " + tankman.getPosition());
            trace("picoSpeaker: " + picoSpeaker.getPosition());
            trace("gfSpeaker: " + gfSpeaker.getPosition());
        }
    }

    function setup() {
        addToGfLayer(picoSpeaker);
        addToGfLayer(gfSpeaker);
        addToCharacterLayer(tankman);

        playstate().camChangeZoom(0.8, 2, FlxEase.quartOut);
    }

}