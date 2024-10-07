package freeplay;

import sys.FileSystem;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;

class DJCharacter extends AtlasSprite
{

    public var introFinish:Void->Void;
    public var freeplaySkin:String = "";

    public var freeplayCategories:Array<String> = [];
    public var freeplaySongs:Array<Array<Dynamic>> = [];

    public function new() {
        super(0, 0, null);
        setup();
        songList();
    }

    function setup():Void{}

    function songList():Void{}

    public function beat(curBeat:Int):Void{}

    public function buttonPress():Void{}

    public function playIntro():Void{}
    public function playConfirm():Void{}
    public function playCheer(lostSong:Bool):Void{}
    public function toCharacterSelect():Void{}

    function createCategory(name:String):Void{
        if(!freeplayCategories.contains(name)){
			freeplayCategories.push(name);
		}
    }

    function addSong(name:String, character:String, week:Int, categories:Array<String>):Void{
        freeplaySongs.push([name, character, week, categories]);
		for(cat in categories){
			createCategory(cat);
		}
    }

}