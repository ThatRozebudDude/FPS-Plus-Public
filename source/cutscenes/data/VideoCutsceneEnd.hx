package cutscenes.data;

import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import transition.data.InstantTransition;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class VideoCutsceneEnd extends ScriptedCutscene
{

    var video:VideoHandler;
    var videoOver:Bool = false;

    var black:FlxSprite;

    var path:String;
    var skipable:Bool;

    public function new(_path:String, ?_skipable:Bool = true) {
        path = _path;
        skipable = _skipable;
        super();
    }

    override function init():Void{

        black = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		black.scale.set(1280, 720);
		black.updateHitbox();
		black.scrollFactor.set();
		black.visible = false;
		black.cameras = [playstate.camOverlay];

        video = new VideoHandler();
		video.scrollFactor.set();
		video.antialiasing = true;
		video.visible = false;
        video.cameras = [playstate.camOverlay];

        addEvent(0, setup);
        addEvent(0.1, showBlack);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!videoOver && Binds.justPressed("menuAccept") && playstate.inVideoCutscene && skipable){
            videoOver = true;
            black.visible = true;
			tween.tween(video, {alpha: 0, volume: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				video.skip();
			}});
        }
    }

    function setup() {
        playstate.inVideoCutscene = true;

        video.visible = true;

        playstate.camGame.filters = [];
        playstate.camHUD.visible = false;

		video.playMP4(Paths.video(path), function(){
            videoOver = true;
			playstate.customTransOut = new InstantTransition();
            playstate.endSong();
		}, false);

		addGeneric(black);
		addGeneric(video);
    }

    function showBlack() {
        black.visible = true;
    }

}