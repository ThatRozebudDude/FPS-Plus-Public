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
	public var listSuffix:String = "bf";

	public var capsuleSelectColor:FlxColor = 0xFFFFFFFF;
	public var capsuleDeselectColor:FlxColor = 0xFF969A9D;
	public var capsuleSelectOutlineColor:FlxColor = 0xFF6B9FBA;
	public var capsuleDeselectOutlineColor:FlxColor = 0xFF3E508C;

	var skipNextIdle:Bool = false;
	var canPlayIdleAfter:Array<String> = [];

	public var freeplaySong:String = "freeplayRandom";
	public var freeplaySongBpm:Float = 145;
	public var freeplaySongVolume:Float = 0.8;

	public var freeplayStickers:Array<String> = null;

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

}