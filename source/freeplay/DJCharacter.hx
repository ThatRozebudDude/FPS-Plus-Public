package freeplay;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

using StringTools;

@:build(modding.GlobalScriptingTypesMacro.build())
class DJCharacter extends AtlasSprite
{
    var idleCount:Int = 1;
    var doRandomIdle:Bool = false;
    public var introFinish:Void->Void;
    public var freeplaySkin:String = "";
    public var listSuffix:String;
    public var capsuleSelectColor:FlxColor = 0xFFFFFFFF;
    public var capsuleDeselectColor:FlxColor = 0xFF969A9D;
    public var capsuleSelectOutlineColor:FlxColor = 0xFF6B9FBA;
    public var capsuleDeselectOutlineColor:FlxColor = 0xFF3E508C;

    public var freeplayCategories:Array<String> = [];
    public var freeplaySongs:Array<Array<Dynamic>> = [];

    var skipNextIdle:Bool = false;
    var canPlayIdleAfter:Array<String> = ["idle1start", "cheerWin", "cheerLose"];

    public var backingCard:FlxSpriteGroup = new FlxSpriteGroup();

    public function new() {
        super(0, 0, null);
        antialiasing = true;
    }

    public function setup():Void{}

    public inline function setupSongList():Void{
        var songFile:Array<String> = Utils.getTextInLines(Paths.text("songList" + listSuffix, "data/freeplay"));

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

    public function beat(curBeat:Int):Void{
        if(FlxG.sound.music.playing && curBeat % 2 == 0 && !skipNextIdle &&  ((curAnim == "idle") || (canPlayIdleAfter.contains(curAnim) && finishedAnim))){
            if(!doRandomIdle){
                playAnim("idle", true);
            }
            else{
                playRandomIdle();
                doRandomIdle = false;
            }
        }
        else if(skipNextIdle){
            skipNextIdle = false;
        }
    }

    public function buttonPress():Void{}

    public function playIdle():Void{
        playAnim("idle", true);
    }
    public function playIntro():Void{
        playAnim("intro", true);
    }
    public function playConfirm():Void{
        playAnim("confirm", true);
    }

    public function playCheer(lostSong:Bool):Void{
        playAnim("cheerHold", true);
    }
    public function toCharacterSelect():Void{
        playAnim("jump", true);
    }

    public function playRandomIdle():Void{
        if(idleCount == 0){ return; }
        var rng = FlxG.random.int(1, idleCount);
        playAnim("idle" + rng + "start", true);
    }

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