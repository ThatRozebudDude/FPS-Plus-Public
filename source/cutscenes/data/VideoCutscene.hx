package cutscenes.data;

import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class VideoCutscene extends ScriptedCutscene
{
    
    var videoPath:String;
    var doZoom:Bool;

    public function new(_path:String, _doZoom:Bool) {
        videoPath = _path;
        doZoom = _doZoom;
        super();
    }

    override function init():Void{
        trace(videoPath);
        trace(doZoom);
        addEvent(0, videoIntro);
    }

    function videoIntro() {
        playstate().videoCutscene(Paths.video(videoPath), function(){
            playstate().camMove(playstate().camFollow.x, playstate().camFollow.y + 100, 0, null);
            if(PlayState.SONG.notes[0].mustHitSection){ playstate().camFocusBF(); }
            else{ playstate().camFocusOpponent(); }
            if(doZoom){
                playstate().camChangeZoom(playstate().defaultCamZoom * 1.2, 0, null);
                playstate().camChangeZoom(playstate().defaultCamZoom/1.2, ((Conductor.crochet / 1000) * 5) - 0.1, FlxEase.quadOut);
            }
            else{
                playstate().camChangeZoom(playstate().defaultCamZoom, 0, null);
            }
        });
    }

}