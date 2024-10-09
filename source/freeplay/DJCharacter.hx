package freeplay;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

class DJCharacter extends AtlasSprite
{

    public var introFinish:Void->Void;
    public var freeplaySkin:String = "";
    public var capsuleSelectColor:FlxColor = 0xFFFFFFFF;
    public var capsuleDeselectColor:FlxColor = 0xFF969A9D;
    public var capsuleSelectOutlineColor:FlxColor = 0xFF6B9FBA;
    public var capsuleDeselectOutlineColor:FlxColor = 0xFF3E508C;

    public var freeplayCategories:Array<String> = [];
    public var freeplaySongs:Array<Array<Dynamic>> = [];

    var skipNextIdle:Bool = false;

    public var backingCard:FlxSpriteGroup = new FlxSpriteGroup();

    public function new() {
        super(0, 0, null);
        setup();
        songList();
    }

    function setup():Void{}

    function songList():Void{}

    public function beat(curBeat:Int):Void{}

    public function buttonPress():Void{}

    public function playIdle():Void{}
    public function playIntro():Void{}
    public function playConfirm():Void{}
    public function playCheer(lostSong:Bool):Void{}
    public function toCharacterSelect():Void{}

    public function backingCardStart():Void{}
    public function backingCardSelect():Void{}

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