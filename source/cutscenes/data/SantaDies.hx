package cutscenes.data;

import transition.data.InstantTransition;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class SantaDies extends ScriptedCutscene
{

    var santa:AtlasSprite;
    var parents:AtlasSprite;

    var santaVoiceline:FlxSound;

    override function init():Void{
        santa = new AtlasSprite(-452, 501, Paths.getTextureAtlas("week5/santa_speaks_assets"));
        santa.antialiasing = true;
        santa.addFullAnimation("full", 24, false);

        parents = new AtlasSprite(-517, 503, Paths.getTextureAtlas("week5/parents_shoot_assets"));
        parents.antialiasing = true;
        parents.addFullAnimation("full", 24, false);
        parents.frameCallback = function(name:String, frame:Int, totalFrame:Int) {
            if(name == "full" && frame == 271){
                FlxG.sound.play(Paths.sound("week5/santa_shot_n_falls"));
            }
        }
        parents.animationEndCallback = function(name:String) {
            if(name == "full"){
                next();
            }
        }

        addEvent(0, setup);
        addEvent(1/24, gfIdleLoop);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    function setup() {
        addToCharacterLayer(parents);
        parents.playAnim("full", true);
        dad().visible = false;

        addToForegroundLayer(santa);
        santa.playAnim("full", true);
        playstate().executeEvent("mall-toggleSantaVisible");

        playstate().autoCam = false;
        var pos = playstate().getOpponentFocusPosition();
        playstate().camMove(pos.x - 250, pos.y + 80, 1.9, FlxEase.expoOut, "santa :]");
        playstate().changeCamOffset(0, 0);
        playstate().camHUD.visible = false;

        FlxG.sound.play(Paths.sound("week5/santa_emotion"));
    }

    function gfIdleLoop() {
        var frame:Int = gf().curAnimFrame();
        var frameOffset:Int = 0;
        if(gf().curAnim == "danceRight"){ frameOffset = 16; }
        var finalFrame:Int = (frame + frameOffset) % 31;
        gf().canAutoAnim = false;
        gf().playAnim("idleLoop", true, false, finalFrame);
    }

}