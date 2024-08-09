package note;

import openfl.display.BlendMode;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

using StringTools;

class NoteSplash extends FlxSprite{

    public static var splashPath:String = "ui/noteSplashes";

    public function new(x:Float, y:Float, note:Int, ?forceSplashNumber:Null<Int>){

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

        var splashAnimNumber:Int;

        switch(splashPath){
            default:
                splashAnimNumber = FlxG.random.int(1, 2);
        }

        if(forceSplashNumber != null){
            splashAnimNumber = forceSplashNumber;
        }

        frames = Paths.getSparrowAtlas(splashPath);
        antialiasing = true;
        animation.addByPrefix("splash", "note impact " + splashAnimNumber + " " + noteColor, 24 + FlxG.random.int(-3, 4), false);
        animation.finishCallback = function(n){ destroy(); }
        animation.play("splash");

        switch(splashPath){
            case "week6/weeb/pixelUI/noteSplashes-pixel":
                alpha = 0.7;

                setGraphicSize(Std.int(width * 6));
                antialiasing = false;
                updateHitbox();

                if(splashAnimNumber == 1){
                    offset.set(21, 25);
                }
                else{
                    offset.set(23, 23);
                }
                origin = offset;

                var angles = [0, 90, 180, 270];
                angle = angles[FlxG.random.int(0, 3)];

            default:
                alpha = 0.6;
                //center offsets and rotate around center
                if(splashAnimNumber == 1){
                    offset.set(126, 150);
                }
                else{
                    offset.set(138, 138);
                }
                origin = offset;

                angle = FlxG.random.int(0, 359);
                

        }

    }

}