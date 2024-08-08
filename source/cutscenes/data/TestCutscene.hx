package cutscenes.data;

import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class TestCutscene extends ScriptedCutscene
{

    var blackScreen:FlxSprite;
    var picoDead:Character;
    var deathSound:FlxSound;

    override function init():Void{

        blackScreen = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
        blackScreen.scale.set(2560, 2560);
        blackScreen.updateHitbox();
        blackScreen.screenCenter(XY);
        blackScreen.scrollFactor.set();
        blackScreen.visible = false;
        addToMiddleLayer(blackScreen);

        picoDead = new Character(boyfriend.x, boyfriend.y, "PicoDeadExplode", true);
        picoDead.visible = false;
        addToCharacterLayer(picoDead);

        deathSound = new FlxSound().loadEmbedded(Paths.sound("gameOver/fnf_loss_sfx-pico-explode"));

        addEvent(0, camSetPos);
        addEvent(1, zoomOutAndReload);
        addEvent(2.0, shoot);
        addEvent(2.1, shoot);
        addEvent(2.2, shoot);
        addEvent(2.3, shoot);
        addEvent(2.4, shoot);
        addEvent(2.5, shoot);
        addEvent(2.6, shoot);
        addEvent(2.7, shoot);
        addEvent(2.8, die);
        addEvent(4.75, end);
    }

    function camSetPos() {
        playstate.camMove(boyfriend.x + 45, boyfriend.getMidpoint().y - 60, 0, null, "bf");
        playstate.camChangeZoom(1.2, 0, null);
    }

    function zoomOutAndReload():Void{
        playstate.camChangeZoom(0.92, 1, FlxEase.quartOut);
        boyfriend.playAnim("reload");
        FlxG.sound.play(Paths.sound("weekend1/Gun_Prep"));
    }

    function shoot() {
        //boyfriend().danceLockout = true;
        boyfriend.playAnim('shoot', true);
        FlxG.sound.play(Paths.sound("weekend1/shot" + FlxG.random.int(1, 4)));
        playstate.camShake(0.01, 1/60, 0.05, 0.01);
        //executeEvent("phillyStreets-stageDarken");
        //executeEvent("phillyStreets-canShot");
    }

    function die() {
        blackScreen.visible = true;
        picoDead.visible = true;
        picoDead.playAnim("firstDeath", true);
        deathSound.play();
        boyfriend.visible = false;
        boyfriend.playAnim("idle", true);
    }

    function end() {
        playstate.startCountdown();
        playstate.camFocusOpponent();
        playstate.camChangeZoom(0.75, 1, FlxEase.quadInOut);
        boyfriend.visible = true;
        blackScreen.visible = false;
        picoDead.visible = false;
        deathSound.stop();
    }

}