package;

import config.Config;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

using StringTools;

class NoteHoldCover extends FlxSprite{

    public static var coverPath:String = "ui/noteHoldCovers";

    public var noteDirection:Int = -1;
    var splashAlpha = 0.7;
    var posOffset:FlxPoint = new FlxPoint();

    var referenceSprite:FlxSprite;

    public function new(_referenceSprite:FlxSprite, note:Int){

        super(0, 0);

        referenceSprite = _referenceSprite;

        noteDirection = note;
        
        var noteColor:String = "Purple";
        switch(noteDirection){
            case 1:
                noteColor = "Blue";
            case 2:
                noteColor = "Green";
            case 3:
                noteColor = "Red";
        }

        frames = Paths.getSparrowAtlas(coverPath);
        antialiasing = true;
        animation.addByPrefix("start", "holdCoverStart" + noteColor, 24, false);
        animation.addByPrefix("hold", "holdCover" + noteColor + "0", 24, true);
        animation.addByPrefix("end", "holdCoverEnd" + noteColor, 24, false);
        animation.finishCallback = callback;
        animation.play("start");
        
        visible = false;

        switch(coverPath){
            case "week6/weeb/pixelUI/noteHoldCovers-pixel":
                setGraphicSize(Std.int(width * PlayState.daPixelZoom));
                antialiasing = false;
                updateHitbox();
                offset.set(36, -16);
                splashAlpha = 0.8;
                posOffset.set(54, 60);

            default:
                offset.set(162, 155);
                posOffset.set(55, 55);

        }

    }

    override function update(elapsed:Float) {
        if(referenceSprite == null){ destroy(); }
        x = referenceSprite.x + posOffset.x;
        y = referenceSprite.y + posOffset.y;
        super.update(elapsed);
    }

    public function start() {
        visible = (Config.noteSplashType == 1 || Config.noteSplashType == 3);
        alpha = 1;
        animation.play("start");
    }

    public function end(playSplash:Bool) {
        visible = playSplash && (Config.noteSplashType == 1 || Config.noteSplashType == 3);
        alpha = splashAlpha;
        animation.getByName("end").frameRate = 24 + FlxG.random.int(0, 6);
        animation.play("end");
    }

    function callback(anim:String) {
        
        switch(anim){
            case "start":
                animation.play("hold");

            case "end":
                visible = false;
        }

    }

}