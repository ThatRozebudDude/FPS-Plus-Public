package freeplay;

import sys.FileSystem;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;

class DJCharacter extends AtlasSprite
{

    public var introFinish:Void->Void;
    public var freeplaySkin:String = "";

    public function new() {
        super(0, 0, null);
        setup();
    }

    function setup():Void{}

    public function beat(curBeat:Int):Void{}

    public function buttonPress():Void{}

    public function playIntro():Void{}
    public function playConfirm():Void{}
    public function playCheer(lostSong:Bool):Void{}
    public function toCharacterSelect():Void{}

}