package cutscenes.data;

import flixel.math.FlxMath;
import transition.data.InstantTransition;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class VideoCutscene extends ScriptedCutscene
{

    var video:VideoHandler;
    var videoOver:Bool = false;

    var black:FlxSprite;

    var path:String;
    var skipable:Bool;
    var doZoomOut:Bool;
    var instantlyMoveCamera:Bool;

    var prevCamFilters:Array<Null<openfl.filters.BitmapFilter>>;

    public function new(_path:String, ?_skipable:Bool = true, ?_doZoomOut:Bool = false, ?_instantlyMoveCamera:Bool = false) {
        path = _path;
        skipable = _skipable;
        doZoomOut = _doZoomOut;
        instantlyMoveCamera = _instantlyMoveCamera;
        super();
    }

    override function init():Void{

        black = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		black.scale.set(1280, 720);
		black.updateHitbox();
		black.scrollFactor.set();
		black.visible = true;

        video = new VideoHandler();
		video.scrollFactor.set();
		video.antialiasing = true;
		video.visible = true;
        video.cameras = [playstate.camOverlay];

        addEvent(0, setup);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!videoOver && Binds.justPressed("menuAccept") && playstate.inVideoCutscene && skipable){
            videoOver = true;
			tween.tween(video, {alpha: 0, volume: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				video.skip();
			}});
        }
    }

    function setup() {
        playstate.inVideoCutscene = true;
        //playstate().camGame.zoom = 1;

        prevCamFilters = playstate.camGame.filters;
        playstate.camGame.filters = [];

		video.playMP4(Paths.video(path), function(){
            videoOver = true;

            playstate.startCountdown();
            playstate.inVideoCutscene = false;
            playstate.camGame.filters = prevCamFilters;

            removeGeneric(video);
            playstate.tweenManager.tween(black, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				removeGeneric(black);
			}});

            if(doZoomOut){
                playstate.camChangeZoom(playstate.defaultCamZoom * 1.2, 0, null);
                playstate.camChangeZoom(playstate.defaultCamZoom/1.2, ((Conductor.crochet / 1000) * 5) - 0.1, FlxEase.quadOut);
            }
            if(instantlyMoveCamera){
                if(PlayState.SONG.notes[0].mustHitSection){ playstate.camFocusBF(); }
                else{ playstate.camFocusOpponent(); }
            }
		}, false);

		addGeneric(black);
		addGeneric(video);
    }

}