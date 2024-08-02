package cutscenes.data;

import flixel.math.FlxMath;
import transition.data.InstantTransition;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class TwoHotEnding extends ScriptedCutscene
{

    var video:VideoHandler;
    var videoOver:Bool = false;

    var picoSprite:Character;

    var black:FlxSprite;

    override function init():Void{
        picoSprite = new Character(boyfriend().x, boyfriend().y, "PicoCutscene", true);
        picoSprite.visible = false;

        black = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		black.scale.set(1280, 720);
		black.updateHitbox();
		black.scrollFactor.set();
		black.visible = false;

        video = new VideoHandler();
		video.scrollFactor.set();
		video.antialiasing = true;
		video.visible = false;

        addEvent(0, setup);
        addEvent(0, centerCamera);
        addEvent(1/24, neneIdleLoop);
        addEvent(1, picoGetPissed);
        addEvent(1.5, darrnellGetPissed);
        addEvent(137 * (1/24), swapToVideo);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!videoOver && Binds.justPressed("menuAccept") && playstate().inVideoCutscene){
            videoOver = true;
			playstate().tweenManager.tween(video, {alpha: 0, volume: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				video.skip();
			}});
        }
    }

    function setup() {
		video.playMP4(Paths.video("weekend1/2hotCutscene"), function(){
            videoOver = true;
			playstate().customTransOut = new InstantTransition();
            playstate().endSong();
		}, false);

		addToCharacterLayer(picoSprite);
		addGeneric(black);
		addGeneric(video);
    }

    function centerCamera() {
        var centerPos:FlxPoint = new FlxPoint(FlxMath.lerp(playstate().getOpponentFocusPosition().x, playstate().getBfFocusPostion().x, 0.5), FlxMath.lerp(playstate().getOpponentFocusPosition().y, playstate().getBfFocusPostion().y, 0.5));
        playstate().autoCam = false;
        playstate().autoCamBop = false;
        boyfriend().canAutoAnim = false;
        dad().canAutoAnim = false;
        playstate().camMove(centerPos.x, centerPos.y, 2, FlxEase.quadInOut);
        playstate().camChangeZoom(0.7, 2, FlxEase.quadInOut);
        playstate().camHUD.visible = false;
    }

    function neneIdleLoop() {
        var frame:Int = gf().curAnimFrame();
        var frameOffset:Int = 0;
        if(gf().curAnim == "danceRight"){ frameOffset = 15; }
        var finalFrame:Int = (frame + frameOffset) % 30;
        gf().canAutoAnim = false;
        gf().playAnim("idleLoop", true, false, finalFrame);
        //trace(frame);
        //trace(frameOffset);
        //trace(finalFrame);
        //trace(gf().curAnim);
    }

    function picoGetPissed(){
        boyfriend().visible = false;
        picoSprite.playAnim("pissed", true);
        picoSprite.visible = true;
    }

    function darrnellGetPissed(){
        dad().playAnim("pissed", true);
    }

    function swapToVideo() {
        playstate().inVideoCutscene = true;
        playstate().camGame.zoom = 1;
        video.visible = true;
        black.visible = true;
        playstate().camGame.filters = [];
    }

}