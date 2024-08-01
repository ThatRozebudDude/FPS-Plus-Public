package cutscenes.data;

import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class DarnellIntro extends ScriptedCutscene
{

    var picoIntro:Character;
    final beatTime = Conductor.getBeatTimeFromBpm(168);

    var picoPos:FlxPoint;
	var nenePos:FlxPoint;
	var darnellPos:FlxPoint;

    var originalZoom:Float;

    override function init():Void{
        picoPos = playstate().getBfFocusPostion();
	    nenePos = playstate().getGfFocusPosition();
	    darnellPos = playstate().getOpponentFocusPosition();

        originalZoom = playstate().defaultCamZoom;

        picoIntro = new Character(boyfriend().x, boyfriend().y, "PicoCutscene", true);
        picoIntro.characterInfo.info.functions.animationEnd = function(character:Character, anim:String) {
            if(anim == "shoot"){
                boyfriend().visible = true;
                boyfriend().dance();
                picoIntro.visible = false;
                removeFromCharacterLayer(picoIntro);
            }
        }
        //addToCharacterLayer(picoIntro);

        addEvent(0, first);
        addEvent(2, zoomOut);
        addEvent(beatTime * 12, darnellLight);
        addEvent(beatTime * 15, picoReload);
        addEvent(beatTime * 16, darnellKickUp);
        addEvent(beatTime * 17.5, darnellKickForward);
        addEvent(beatTime * 18, picoShoot);
        addEvent(beatTime * 19, darnellIdle);
        addEvent(beatTime * 20, darnellLaugh);
        addEvent(beatTime * 20.5, neneLaugh);
        addEvent(9, startSong);
    }

    /*override function update(elapsed:Float) {
        super.update(elapsed);
        if(FlxG.keys.anyJustPressed([TWO])){
            playstate().switchState(new debug.AnimationDebug("PicoCutscene", "PicoAll"));
        }
    }*/

    function first() {
        FlxG.sound.play(Paths.music("weekend1/darnellCanCutscene"));

        playstate().camHUD.visible = false;
        playstate().camGame.fade(0xFF000000, 2, true);

        addToCharacterLayer(picoIntro);

        picoIntro.playAnim("pissed", true);
        dad().playAnim("idleLoop", true);
        gf().playAnim("idleLoop", true);

        picoIntro.playAnim("pissed", true, false, 24);
        boyfriend().visible = false;

        playstate().camMove(picoPos.x + 250, picoPos.y, 0, null);
        playstate().camChangeZoom(1.3, 0, null);
    }

    function startSong() {
        playstate().startCountdown();
        playstate().camHUD.visible = true;
        playstate().camChangeZoom(originalZoom, 2, FlxEase.sineInOut);
        playstate().camMove(darnellPos.x, darnellPos.y, 2, FlxEase.sineInOut, "dad");
    }

    function zoomOut() {
        playstate().camMove(darnellPos.x + 180, darnellPos.y, 2.5, FlxEase.quadInOut);
        playstate().camChangeZoom(0.68, 2.5, FlxEase.quadInOut);
    }

    function darnellLight() {
        dad().playAnim('lightCan', true);
        FlxG.sound.play(Paths.sound("weekend1/Darnell_Lighter"));
    }

    function picoReload() {
        picoIntro.playAnim('reload', true);
        FlxG.sound.play(Paths.sound("weekend1/Gun_Prep"));
    }

    function darnellKickUp() {
        dad().playAnim('kickUp', true);
        FlxG.sound.play(Paths.sound("weekend1/Kick_Can_UP"));
        playstate().executeEvent("phillyStreets-canKickSlow");
    }

    function darnellKickForward() {
        dad().playAnim('kneeForward', true);
        FlxG.sound.play(Paths.sound("weekend1/Kick_Can_FORWARD"));
        playstate().executeEvent("phillyStreets-canKickForward");
    }

    function picoShoot() {
        picoIntro.playAnim('shoot', true);
        FlxG.sound.play(Paths.sound("weekend1/shot" + FlxG.random.int(1, 4)));
        playstate().executeEvent("phillyStreets-stageDarken");
		playstate().executeEvent("phillyStreets-canShot");
        playstate().camMove(darnellPos.x + 100, darnellPos.y, 1, FlxEase.quadInOut, "dad");
    }

    function darnellIdle() {
        dad().playAnim('idle', true);
    }

    function darnellLaugh() {
        dad().playAnim('laughCutscene', true);
        FlxG.sound.play(Paths.sound("weekend1/cutscene/darnell_laugh"));
    }

    function neneLaugh() {
        gf().playAnim('laughCutscene', true);
        FlxG.sound.play(Paths.sound("weekend1/cutscene/nene_laugh"));
    }

}