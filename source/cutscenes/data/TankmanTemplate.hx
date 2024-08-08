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
    var gfSummon:FlxSprite;
    var gfSpeaker:Character;

    override function init():Void{
        tankman = new AtlasSprite(74, 324, Paths.getTextureAtlas("week7/cutscene/tankmanCutscene"));
        tankman.antialiasing = true;
        tankman.addAnimationByLabel("ugh1", "Ugh 1", 24, false);
        tankman.addAnimationByLabel("ugh2", "Ugh 2", 24, false);
        tankman.addAnimationByLabel("guns", "Guns", 24, false);
        tankman.addAnimationByLabel("stress1", "Stress 1", 24, false);
        tankman.addAnimationByLabel("stress2", "Stress 2", 24, false);
        //tankman.addFullAnimation("full");

        picoSpeaker = new AtlasSprite(322, -3, Paths.getTextureAtlas("week7/cutscene/picoSpeakerCutscene"));
        picoSpeaker.antialiasing = true;
        picoSpeaker.addAnimationByLabel("fall", "Pico Fall", 24, false);
        picoSpeaker.addAnimationByLabel("idle", "Idle", 24, true);
        picoSpeaker.scrollFactor.set(0.95, 0.95);
        //picoSpeaker.addFullAnimation("full");

        gfSummon = new FlxSprite(-10, -380);
        gfSummon.frames = Paths.getSparrowAtlas("week7/cutscene/gfCutscene");
        gfSummon.antialiasing = true;
        gfSummon.animation.addByPrefix("summon", "", 24, false);
        gfSummon.scrollFactor.set(0.95, 0.95);

        gfSpeaker = new Character(210, 74, "GfTankmen", false, true);
        gfSpeaker.scrollFactor.set(0.95, 0.95);

        addEvent(0, setup);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var move:Float = 1;
        if(FlxG.keys.anyPressed([SHIFT])){move = 10;}



        if(FlxG.keys.anyJustPressed([W])){
            tankman.y -= move;
            //tankman.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([S])){
            tankman.y += move;
            //tankman.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([A])){
            tankman.x -= move;
            //tankman.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([D])){
            tankman.x += move;
            //tankman.playAnim("full", true);
        }



        if(FlxG.keys.anyJustPressed([I])){
            picoSpeaker.y -= move;
            //picoSpeaker.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([K])){
            picoSpeaker.y += move;
            //picoSpeaker.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([J])){
            picoSpeaker.x -= move;
            //picoSpeaker.playAnim("full", true);
        }
        if(FlxG.keys.anyJustPressed([L])){
            picoSpeaker.x += move;
            //picoSpeaker.playAnim("full", true);
        }




        if(FlxG.keys.anyJustPressed([UP])){
            gfSummon.y -= move;
            //gfSummon.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([DOWN])){
            gfSummon.y += move;
            //gfSummon.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([LEFT])){
            gfSummon.x -= move;
            //gfSummon.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([RIGHT])){
            gfSummon.x += move;
            //gfSummon.animation.play("full", true);
        }



        if(FlxG.keys.anyJustPressed([T])){
            gfSpeaker.y -= move;
            //gfSpeaker.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([G])){
            gfSpeaker.y += move;
            //gfSpeaker.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([F])){
            gfSpeaker.x -= move;
            //gfSpeaker.animation.play("full", true);
        }
        if(FlxG.keys.anyJustPressed([H])){
            gfSpeaker.x += move;
            //gfSpeaker.animation.play("full", true);
        }



        if(FlxG.keys.anyJustPressed([ONE])){
            tankman.visible = !tankman.visible;
        }
        if(FlxG.keys.anyJustPressed([TWO])){
            picoSpeaker.visible = !picoSpeaker.visible;
        }
        if(FlxG.keys.anyJustPressed([THREE])){
            gfSummon.visible = !gfSummon.visible;
        }
        if(FlxG.keys.anyJustPressed([FOUR])){
            gfSpeaker.visible = !gfSpeaker.visible;
        }



        if(FlxG.keys.anyJustPressed([SPACE])){
            trace("tankman: " + tankman.getPosition());
            trace("picoSpeaker: " + picoSpeaker.getPosition());
            trace("gfSummon: " + gfSummon.getPosition());
            trace("gfSpeaker: " + gfSpeaker.getPosition());
        }
    }

    function setup() {
        addToGfLayer(picoSpeaker);
        addToGfLayer(gfSummon);
        addToGfLayer(gfSpeaker);
        addToCharacterLayer(tankman);

        playstate.camChangeZoom(0.8, 2, FlxEase.quartOut);
    }

}