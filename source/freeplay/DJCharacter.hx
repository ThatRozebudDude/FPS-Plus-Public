package freeplay;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

using StringTools;

@:build(modding.GlobalScriptingTypesMacro.build())
class DJCharacter extends AtlasSprite
{

    public var introFinish:Void->Void;
    public var freeplaySkin:String = "";
    public var songList:String;
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
    }

    public function setup():Void{}

    public inline function setupSongList():Void{
        var songFile:Array<String> = Utils.getTextInLines(Paths.text(songList, "data/freeplay"));

        //Create categories first
		for(line in songFile){
			line = line.trim();
			if(line.startsWith("category")){
				var categoryName = line.split("|")[1].trim();
				createCategory(categoryName);
			}
		}

        //Then add songs
        for(line in songFile){
            if(line.startsWith("song")){
				var parts:Array<String> = line.split("|");
				var name:String = parts[1].trim();
				var icon:String = parts[2].trim();
				var fullArrayString:String = parts[3].trim();

				var categoryArray:Array<String> = fullArrayString.split(",");
				for(i in 0...categoryArray.length){
					if(i == 0){ categoryArray[i] = categoryArray[i].substring(1); }
					if(i == categoryArray.length-1){ categoryArray[i] = categoryArray[i].substring(0, categoryArray[i].length-1); }
					categoryArray[i] = categoryArray[i].trim();
				}
				
				addSong(name, icon, categoryArray);
			}
        }
    }

    public function beat(curBeat:Int):Void{}

    public function buttonPress():Void{}

    public function playIdle():Void{}
    public function playIntro():Void{}
    public function playConfirm():Void{}
    public function playCheer(lostSong:Bool):Void{}
    public function toCharacterSelect():Void{}

    public function backingCardStart():Void{}
    public function backingCardSelect():Void{}

    inline function createCategory(name:String):Void{
        if(!freeplayCategories.contains(name)){
			freeplayCategories.push(name);
		}
    }

    inline function addSong(name:String, character:String, categories:Array<String>):Void{
        freeplaySongs.push([name, character, categories]);
		for(cat in categories){
			createCategory(cat);
		}
    }

}