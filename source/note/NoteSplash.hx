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

    public static var skinName:String = "Default";

    static var persistentSkinName:String;
    static var persistentSkinInfo:NoteSplashSkinBase;

    public function new(x:Float, y:Float, direction:Int, ?forceSplashNumber:Null<Int>){

        super(x, y);

        if(persistentSkinName == null || persistentSkinName != skinName){
            persistentSkinName = skinName;
            persistentSkinInfo = new NoteSplashSkinBase(skinName);
        }

        //if(!ScriptableNoteSplashSkin.listScriptClasses().contains(splashSkinClassName + "SplashSkin")){ splashSkinClassName = "Default"; }
		//var splashSkin:NoteSplashSkinBase = ScriptableNoteSplashSkin.init(splashSkinClassName + "SplashSkin");
        
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

        var splashAnimNumber:Int = FlxG.random.int(0, persistentSkinInfo.info.anims[direction].length - 1);
        if(forceSplashNumber != null){
            splashAnimNumber = forceSplashNumber;
        }

        var anim:NoteSplashAnim = persistentSkinInfo.info.anims[direction][splashAnimNumber];

        frames = Paths.getSparrowAtlas(persistentSkinInfo.info.path);
        antialiasing = persistentSkinInfo.info.antialiasing;
        animation.addByPrefix("splash", anim.prefix, FlxG.random.int(anim.framerateRange[0], anim.framerateRange[1]), false);
        animation.finishCallback = function(n){ destroy(); }
        animation.play("splash");

        alpha = persistentSkinInfo.info.alpha;

        setGraphicSize(Std.int(width * persistentSkinInfo.info.scale));
        updateHitbox();

        offset.set(anim.offset[0], anim.offset[1]);
        origin = offset;

        if(persistentSkinInfo.info.randomRotation){
            if(!persistentSkinInfo.info.limitedRotationAngles){
                angle = FlxG.random.int(0, 359);
            }
            else{
                var angles = [0, 90, 180, 270];
                angle = angles[FlxG.random.int(0, 3)];
            }
        }

    }

}