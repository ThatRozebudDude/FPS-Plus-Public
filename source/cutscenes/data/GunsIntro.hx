package cutscenes.data;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class GunsIntro extends ScriptedCutscene
{

    var tankman:AtlasSprite;

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

        originalZoom = playstate().defaultCamZoom;

        addEvent(0, guns1);
        addEvent(4.1, guns2);
        addEvent(4.55, guns3);
        addEvent(11, guns4);
    }

    function guns1() {
        addToCharacterLayer(tankman);
        tankman.playAnim("guns", true);
        dad().visible = false;
        FlxG.sound.play(Paths.sound("week7/tankSong2"));
        bgm = FlxG.sound.play(Paths.music("week7/distorto")).fadeIn(5, 0, 0.2);
        playstate().camFocusOpponent();
        playstate().camChangeZoom(originalZoom * 1.3, 4, FlxEase.quadInOut);
        playstate().camHUD.visible = false;
    }

    function guns2() {
        playstate().camChangeZoom(originalZoom * 1.4, 0.4, FlxEase.quadOut);
        gf().playAnim("sad");
    }

    function guns3() {
        playstate().camChangeZoom(originalZoom * 1.3, 0.7, FlxEase.quadInOut);  
    }

    function guns4() {
        bgm.fadeOut((Conductor.crochet / 1000) * 5, 0);
        playstate().camChangeZoom(originalZoom, (Conductor.crochet / 1000) * 5, FlxEase.quadInOut);
        dad().visible = true;
        tankman.visible = false;
        removeFromCharacterLayer(tankman);
        playstate().camHUD.visible = true;
        focusCameraBasedOnFirstSection();
        next();
    }

}