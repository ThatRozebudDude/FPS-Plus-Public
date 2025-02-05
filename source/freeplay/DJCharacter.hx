package freeplay;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

using StringTools;

@:build(modding.GlobalScriptingTypesMacro.build())
class DJCharacter extends AtlasSprite
{
	public var introFinish:Void->Void;

	var idleCount:Int = 0;
	var doRandomIdle:Bool = false;
	var bopEvery:Int = 2;
	
	var afkTimer:Float = 0;
	var nextAfkTime:Float = 5;
	var minAfkTime:Float = 9;
	var maxAfkTime:Float = 27;

	public var freeplaySkin:String = "";
	public var listSuffix:String = "-bf";

	public var capsuleSelectColor:FlxColor = 0xFFFFFFFF;
	public var capsuleDeselectColor:FlxColor = 0xFF969A9D;
	public var capsuleSelectOutlineColor:FlxColor = 0xFF6B9FBA;
	public var capsuleDeselectOutlineColor:FlxColor = 0xFF3E508C;

	public var freeplayCategories:Array<String> = [];
	public var freeplaySongs:Array<Array<Dynamic>> = [];

	var skipNextIdle:Bool = false;
	var canPlayIdleAfter:Array<String> = [];

	public var backingCard:FlxSpriteGroup = new FlxSpriteGroup();

	public function new() {
		super(0, 0, null);
		antialiasing = true;

		animationEndCallback = function(name) {
			switch(name){
				case "intro":
					introFinish();
					skipNextIdle = true;
					playAnim("idle", true);
			}
		}
	}

	public function setup():Void{
		if(idleCount > 0){ nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime); }
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);

		if(idleCount > 0){
			if(curAnim == "idle"){
				afkTimer += elapsed;
				if(afkTimer >= nextAfkTime){
					afkTimer = 0;
					nextAfkTime = nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
					doRandomIdle = true;
				}
			}
		}
	}

	public inline function setupSongList():Void{
		var songFile:Array<String> = Utils.getTextInLines(Paths.text("songList-" + listSuffix, "data/freeplay"));
		
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

	public function beat(curBeat:Int):Void{
		if(FlxG.sound.music.playing && curBeat % bopEvery == 0 && !skipNextIdle &&  ((curAnim == "idle") || (canPlayIdleAfter.contains(curAnim) && finishedAnim))){
			if(!doRandomIdle || idleCount <= 0){
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

	public function buttonPress():Void{
		if(idleCount > 0){
			afkTimer = 0;
			nextAfkTime = nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
			doRandomIdle = false;
		}
	}

	public function playIdle():Void{
		playAnim("idle", true);
	}
	public function playIntro():Void{
		playAnim("intro", true);
	}
	public function playConfirm():Void{
		playAnim("confirm", true);
	}

	public function playCheer(lostSong:Bool):Void{}

	public function toCharacterSelect():Void{
		playAnim("jump", true);
	}

	function playRandomIdle():Void{
		if(idleCount <= 0){ return; }
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