package;

import openfl.display.BlendMode;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

using StringTools;

class NoteSplash extends FlxSprite{

    public static var splashPath:String = "ui/noteSplashes";

    public function new(x:Float, y:Float, note:Int){

        super(x, y);
        
        var noteColor:String = "purple";
        switch(note){
            case 1:
                noteColor = "blue";
            case 2:
                noteColor = "green";
            case 3:
                noteColor = "red";
        }

        var random:Int;

        switch(splashPath){
            default:
                random = FlxG.random.int(1, 2);
        }

        frames = Paths.getSparrowAtlas(splashPath);
        antialiasing = true;
        animation.addByPrefix("splash", "note impact " + random + " " + noteColor, 24 + FlxG.random.int(-3, 4), false);
        animation.finishCallback = function(n){ destroy(); }
        animation.play("splash");

        switch(splashPath){
            case "week6/weeb/pixelUI/noteSplashes-pixel":
                alpha = 0.7;

                setGraphicSize(Std.int(width * PlayState.daPixelZoom));
                antialiasing = false;
                updateHitbox();

                if(random == 1){
                    offset.set(20, 26);
                }
                else{
                    offset.set(24, 26);
                }
                origin = offset;

                var angles = [0, 90, 180, 270];
                angle = angles[FlxG.random.int(0, 3)];

            default:
                alpha = 0.6;
                //center offsets and rotate around center
                if(random == 1){
                    offset.set(127, 153);
                }
                else{
                    offset.set(142, 161);
                }
                origin = offset;

                angle = FlxG.random.int(0, 359);
                

        }

    }

}