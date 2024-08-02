package cutscenes.data;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class StressIntro extends ScriptedCutscene
{

    var tankman:AtlasSprite;
    var picoSpeaker:AtlasSprite;
    var gfSummon:FlxSprite;
    var gfSpeaker:Character;

    var bgm:FlxSound;

    var originalZoom:Float;

    override function init():Void{
        tankman = new AtlasSprite(74, 324, Paths.getTextureAtlas("week7/cutscene/tankmanCutscene"));
        tankman.antialiasing = true;
        tankman.addAnimationByLabel("ugh1", "Ugh 1", 24, false);
        tankman.addAnimationByLabel("ugh2", "Ugh 2", 24, false);
        tankman.addAnimationByLabel("guns", "Guns", 24, false);
        tankman.addAnimationByLabel("stress1", "Stress 1", 24, false);
        tankman.addAnimationByLabel("stress2", "Stress 2", 24, false);

        picoSpeaker = new AtlasSprite(322, -3, Paths.getTextureAtlas("week7/cutscene/picoSpeakerCutscene"));
        picoSpeaker.antialiasing = true;
        picoSpeaker.addAnimationByLabel("fall", "Pico Fall", 24, false);
        picoSpeaker.addAnimationByLabel("idle", "Idle", 24, true);
        picoSpeaker.animationEndCallback = function(name:String) {
            if(name == "fall"){
                picoSpeaker.playAnim("idle", true);
            }
        }
        picoSpeaker.visible = false;
        picoSpeaker.scrollFactor.set(0.95, 0.95);

        gfSummon = new FlxSprite(-10, -380);
        gfSummon.frames = Paths.getSparrowAtlas("week7/cutscene/gfCutscene");
        gfSummon.antialiasing = true;
        gfSummon.animation.addByPrefix("summon", "", 24, false);
        gfSummon.visible = false;
        gfSummon.scrollFactor.set(0.95, 0.95);

        gfSpeaker = new Character(210, 74, "GfTankmen", false, true);
        gfSpeaker.scrollFactor.set(0.95, 0.95);

        originalZoom = playstate().defaultCamZoom;

        addEvent(0, stress1);
        addEvent(15.1, stress2);
        addEvent(17.3, stress3);
        addEvent(19.5, stress4);
        addEvent(20.3, stress5);
        addEvent(31.5, zoomIn);
        addEvent(32.5, zoomOut);
        addEvent(35.1, stressEnd);
    }

    function stress1() {
        addToCharacterLayer(tankman);
        tankman.playAnim("stress1", true);
        dad().visible = false;
        
        addToGfLayer(gfSpeaker);
        gfSpeaker.playAnim("idleLoop", true);
        gf().visible = false;

        addToGfLayer(picoSpeaker);
        addToGfLayer(gfSummon);

        boyfriend().canAutoAnim = false;
        boyfriend().playAnim("idleNoGf", true);

        ///FlxG.sound.play(Paths.sound("week7/stressCutscene"));
        bgm = FlxG.sound.play(Paths.sound("week7/stressCutscene"));

        playstate().camFocusOpponent();
        playstate().camChangeZoom(originalZoom * 1.15, 0);
        playstate().camHUD.visible = false;
    }

    function stress2() {
        gfSpeaker.visible = false;
        gfSummon.visible = true;
        gfSummon.animation.play("summon", true);

        playstate().camChangeZoom(originalZoom * 1.6, 2, FlxEase.quadOut);
        var pos:FlxPoint = new FlxPoint(FlxMath.lerp(playstate().getOpponentFocusPosition().x, playstate().getBfFocusPostion().x, 0.5), FlxMath.lerp(playstate().getOpponentFocusPosition().y, playstate().getBfFocusPostion().y, 0.5));
		playstate().camMove(pos.x, pos.y - 200, 2, FlxEase.quadOut, "center");
    }

    function stress3() {
        gfSummon.visible = false;
        picoSpeaker.visible = true;
        picoSpeaker.playAnim("fall");

        boyfriend().playAnim("bfCatch", true);

        playstate().camChangeZoom(0.8, 0);
    }
    
    function stress4() {
        tankman.playAnim("stress2", true);
    }

    function stress5() {
        playstate().camMove(playstate().getOpponentFocusPosition().x + 230, playstate().getOpponentFocusPosition().y - 50, 1.9, FlxEase.expoOut, "dad");
    }

    function zoomIn() {
        playstate().camFocusBF(0);
        playstate().camChangeZoom(originalZoom*1.4, 0);
        playstate().camChangeZoom((originalZoom*1.4) + 0.1, 0.5, FlxEase.elasticOut);
        boyfriend().playAnim("singUPmiss");
    }

    function zoomOut() {
        playstate().camFocusOpponent(0);
        playstate().camChangeZoom(originalZoom, 0);
        boyfriend().playAnim("idle");
    }

    function stressEnd() {
        bgm.fadeOut((Conductor.crochet / 1000) * 5, 0);

        picoSpeaker.visible = false;
        tankman.visible = false;


        gf().visible = true;
        dad().visible = true;
        boyfriend().canAutoAnim = true;
        gf().playAnim("shoot1", true);

        playstate().camHUD.visible = true;
        focusCameraBasedOnFirstSection();
        next();
    }

}