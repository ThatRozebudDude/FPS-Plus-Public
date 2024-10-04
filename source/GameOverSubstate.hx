package;

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

class GameOverSubstate extends MusicBeatSubstate
{
	public var bf:Character;
	public var camFollow:FlxObject;

	var cameraPanDelayTimer:FlxTimer;

	var bfX:Float; 
	var bfY:Float;
	var bfChar:String;

	public var camGameOver:FlxCamera;

	public static var instance:GameOverSubstate;

	public function new(_x:Float, _y:Float, camX:Float, camY:Float, camZoom:Float, character:String){
		super();

		instance = this;

		camGameOver = new FlxCamera();
		camGameOver.zoom = camZoom;
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
		bf.playAnim('firstDeath', true);

		cameraPanDelayTimer = new FlxTimer().start(bf.deathDelay, function(t) {
			FlxTween.tween(camFollow, {x: bf.getGraphicMidpoint().x + bf.deathOffset.x, y: bf.getGraphicMidpoint().y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut});
		});

		if(bf.deathSound != null){
			FlxG.sound.play(Paths.sound(bf.deathSound));
		}
		
		PlayState.instance.stage.gameOverStart();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if (Binds.justPressed("menuAccept") && !isEnding){
			endBullshit();
		}

		if (Binds.justPressed("menuBack") && !isEnding){
			FlxG.sound.music.stop();
			isEnding = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));

			PlayState.instance.returnToMenu();

			camGameOver.fade(FlxColor.BLACK, 0.1, false);	
		}

		if (bf.curAnim == 'firstDeath' && bf.curAnimFinished() && !isEnding){
			bf.playAnim('deathLoop');

			if(bf.deathSong != null){
				FlxG.sound.playMusic(Paths.music(bf.deathSong));
			}

			PlayState.instance.stage.gameOverLoop();
		}

		if (FlxG.sound.music.playing){
			Conductor.songPosition = FlxG.sound.music.time;
		}

		/*if(FlxG.keys.anyJustPressed([BACKSLASH])){
			camGameOver.bgColor.alpha = 127;
			cameraPanDelayTimer.destroy();
		}*/
	}

	override function beatHit(){
		super.beatHit();
	}

	var isEnding:Bool = false;

	function endBullshit():Void{
		isEnding = true;
		bf.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
		if(bf.deathSongEnd != null){
			FlxG.sound.play(Paths.music(bf.deathSongEnd));
		}
		PlayState.instance.stage.gameOverEnd();
		new FlxTimer().start(0.4, function(tmr:FlxTimer){
			camGameOver.fade(FlxColor.BLACK, 1.2, false, function(){
				PlayState.instance.switchState(new PlayState());
				PlayState.replayStartCutscene = false;
			});
		});
	}
}
