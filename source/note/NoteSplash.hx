package note;

import note.NoteSplashSkinBase.NoteSplashAnim;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

using StringTools;

class NoteSplash extends FlxSprite{

    public static var splashSkinClassName:String = "Default";

    public function new(x:Float, y:Float, direction:Int, ?forceSplashNumber:Null<Int>){

        super(x, y);

		var splashSkinClass = Type.resolveClass("note.noteSplashSkins." + splashSkinClassName);
		if(splashSkinClass == null){
			splashSkinClass = note.noteSplashSkins.Default;
		}
		var splashSkin:NoteSplashSkinBase = Type.createInstance(splashSkinClass, []);
        
        /*var noteColor:String = "purple";
        switch(note){
            case 1:
                noteColor = "blue";
            case 2:
                noteColor = "green";
            case 3:
                noteColor = "red";
        }*/

        /*var splashAnimNumber:Int;

        switch(splashPath){
            default:
                splashAnimNumber = FlxG.random.int(1, 2);
        }*/

        /*if(forceSplashNumber != null){
            splashAnimNumber = forceSplashNumber;
        }*/

        var splashAnimNumber:Int = FlxG.random.int(0, splashSkin.info.anims[direction].length - 1);
        if(forceSplashNumber != null){
            splashAnimNumber = forceSplashNumber;
        }

        var anim:NoteSplashAnim = splashSkin.info.anims[direction][splashAnimNumber];

        frames = Paths.getSparrowAtlas(splashSkin.info.path);
        antialiasing = splashSkin.info.antialiasing;
        animation.addByPrefix("splash", anim.prefix, FlxG.random.int(anim.framerateRange[0], anim.framerateRange[1]), false);
        animation.finishCallback = function(n){ destroy(); }
        animation.play("splash");

        alpha = splashSkin.info.alpha;

        setGraphicSize(Std.int(width * splashSkin.info.scale));
        updateHitbox();

        offset.set(anim.offset[0], anim.offset[1]);
        origin = offset;

        if(splashSkin.info.randomRotation){
            if(!splashSkin.info.limitedRotationAngles){
                angle = FlxG.random.int(0, 359);
            }
            else{
                var angles = [0, 90, 180, 270];
                angle = angles[FlxG.random.int(0, 3)];
            }
        }

    }

}