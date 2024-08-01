package cutscenes.data;

import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class DarnellVideo extends ScriptedCutscene
{

    var black:FlxSprite;

    var video:VideoHandler;
    var ingameCutscene:DarnellIntro;
    var videoOver:Bool = false;

    override function init():Void{
        ingameCutscene = new DarnellIntro();
        addGeneric(ingameCutscene);

        black = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		black.scale.set(1280, 720);
		black.updateHitbox();
		black.scrollFactor.set();

        addEvent(0, first);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!videoOver && Binds.justPressed("menuAccept")){
            videoOver = true;
			playstate().tweenManager.tween(video, {alpha: 0, volume: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				video.skip();
			}});
        }
    }

    function first() {
        playstate().inVideoCutscene = true;
        playstate().camGame.zoom = 1;

        video = new VideoHandler();
		video.scrollFactor.set();
		video.antialiasing = true;

		video.playMP4(Paths.video("weekend1/darnellCutscene"), function(){
			playstate().inVideoCutscene = false;
			removeGeneric(black);
			removeGeneric(video);
			ingameCutscene.start();
            videoOver = true;
		}, false);

        addGeneric(black);
		addGeneric(video);
    }

}