package;

import flixel.sound.FlxSound;
import flixel.FlxCamera;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubState extends MusicBeatSubState
{
	public var bf:Character;
	public var camFollow:FlxObject;

	var cameraPanDelayTimer:FlxTimer;

	var bfX:Float; 
	var bfY:Float;
	var bfChar:String;

	public var camGameOver:FlxCamera;

	public static var instance:GameOverSubState;

	public function new(_x:Float, _y:Float, camX:Float, camY:Float, camZoom:Float, character:String){
		super();

		instance = this;

		camGameOver = new FlxCamera();
		camGameOver.zoom = camZoom;
		camGameOver.filters = [];
		FlxG.cameras.add(camGameOver, false);
		cameras = [camGameOver];

		bfChar = character;

		bfX = _x;
		bfY = _y;

		Conductor.songPosition = 0;

		camFollow = new FlxObject(camX, camY, 1, 1);
		add(camFollow);

		camGameOver.follow(camFollow, LOCKON);
	}

	override function create() {
		super.create();

		bf = new Character(bfX, bfY, bfChar, true);
		if(bf.characterInfo.info.functions.deathCreate != null){
			bf.characterInfo.info.functions.deathCreate(bf);
		}
		add(bf);
		if(bf.characterInfo.info.functions.deathAdd != null){
			bf.characterInfo.info.functions.deathAdd(bf);
		}
		bf.repositionDeath();
		bf.playAnim("firstDeath", true);

		cameraPanDelayTimer = new FlxTimer().start(bf.deathDelay, function(t) {
			FlxTween.tween(camFollow, {x: bf.getMidpoint().x + bf.deathOffset.x, y: bf.getMidpoint().y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut});
		});

		if(bf.deathSound != null){
			FlxG.sound.play(Paths.sound(bf.deathSound));
		}
		
		for(script in PlayState.instance.scripts){ script.gameOverStart(); }
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(Binds.justPressed("menuAccept") && !isEnding){
			endBullshit();
		}

		if (Binds.justPressed("menuBack") && !isEnding){
			FlxG.sound.music.stop();
			isEnding = true;
			FlxG.sound.play(Paths.sound("cancelMenu"));

			PlayState.instance.returnToMenu();

			camGameOver.fade(FlxColor.BLACK, 0.1, false);	
		}

		if (bf.curAnim == "firstDeath" && bf.curAnimFinished() && !isEnding){
			bf.playAnim("deathLoop");

			if(bf.deathSong != null){
				FlxG.sound.playMusic(Paths.music(bf.deathSong));
			}

			for(script in PlayState.instance.scripts){ script.gameOverLoop(); }
		}

		if (FlxG.sound.music.playing){
			Conductor.songPosition = FlxG.sound.music.time;
		}

		for(script in PlayState.instance.scripts){ script.gameOverUpdate(elapsed); }
	}

	override function beatHit(){
		super.beatHit();
	}

	var isEnding:Bool = false;

	function endBullshit():Void{
		var songEnd:FlxSound;

		isEnding = true;
		bf.playAnim("deathConfirm", true);
		FlxG.sound.music.stop();
		if(bf.deathSongEnd != null){
			songEnd = FlxG.sound.play(Paths.music(bf.deathSongEnd));
		}
		if(PlayState.instance.instSong != null){
			PlayState.overrideInsturmental = PlayState.instance.instSong;
		}
		for(script in PlayState.instance.scripts){ script.gameOverEnd(); }
		new FlxTimer().start(0.6, function(tmr:FlxTimer){
			camGameOver.fade(FlxColor.BLACK, 1, false, function(){
				PlayState.replayStartCutscene = false;
				PlayState.instance.switchState(new PlayState());
				if(songEnd != null && songEnd.playing){ songEnd.fadeOut(0.5); }
			});
		});
	}
}
