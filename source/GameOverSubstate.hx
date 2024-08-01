package;

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

	var bfX:Float; 
	var bfY:Float;
	var bfChar:String;

	var suffix:String = "";

	public function new(_x:Float, _y:Float, camX:Float, camY:Float, character:String){

		super();

		bfChar = character;
		switch (bfChar){
			case "BfPixelDead":
				suffix = '-pixel';
			case "PicoDead" | "PicoDeadExplode" | "PicoBlazin":
				suffix = '-pico';
		}

		bfX = _x;
		bfY = _y;

		Conductor.songPosition = 0;

		camFollow = new FlxObject(camX, camY, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON);

		//Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		//FlxG.camera.scroll.set();
		//FlxG.camera.target = null;

	}

	override function create() {
		super.create();

		bf = new Character(bfX, bfY, bfChar, true);
		add(bf);
		bf.playAnim('firstDeath', true);

		FlxTween.tween(camFollow, {x: Utils.getGraphicMidpoint(bf).x + bf.deathOffset.x, y: Utils.getGraphicMidpoint(bf).y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut, startDelay: bf.deathDelay});
		//FlxTween.tween(camFollow, {x: bf.getMidpoint().x + bf.deathOffset.x, y: bf.getMidpoint().y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut, startDelay: 0.5});

		switch(suffix){
			case "-pico":
				switch(PlayState.SONG.song.toLowerCase()){
					case "blazin":
						FlxG.sound.play(Paths.sound("gameOver/fnf_loss_sfx-pico-gutpunch"));
					default:
						if(bf.charClass == "PicoDeadExplode"){ FlxG.sound.play(Paths.sound("gameOver/fnf_loss_sfx-pico-explode")); }
						else{ FlxG.sound.play(Paths.sound("gameOver/fnf_loss_sfx" + suffix)); }
				}
			default:
				FlxG.sound.play(Paths.sound("gameOver/fnf_loss_sfx" + suffix));
		}
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

			FlxG.camera.fade(FlxColor.BLACK, 0.1, false);	
		}

		if (bf.curAnim == 'firstDeath' && bf.curAnimFinished() && !isEnding){
			switch(PlayState.SONG.player2){
				case "Tankman":
					bf.playAnim('deathLoop');
					FlxG.sound.playMusic(Paths.music('gameOver/gameOver' + suffix), 0.2);
					FlxG.sound.play(Paths.sound('week7/jeffGameover/jeffGameover-' + FlxG.random.int(1, 25)), 1, false, null, true, function()
					{
						if (!isEnding)
							FlxG.sound.music.fadeIn(2.5, 0.2, 1);
					});

				default:
					bf.playAnim('deathLoop');
					FlxG.sound.playMusic(Paths.music('gameOver/gameOver' + suffix));
			}
			
		}

		if (FlxG.sound.music.playing){
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit(){
		super.beatHit();
	}

	var isEnding:Bool = false;

	function endBullshit():Void{
		isEnding = true;
		bf.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music('gameOver/gameOverEnd' + suffix));
		new FlxTimer().start(0.4, function(tmr:FlxTimer){
			FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function(){
				PlayState.instance.switchState(new PlayState());
				PlayState.replayStartCutscene = false;
			});
		});
	}
}
