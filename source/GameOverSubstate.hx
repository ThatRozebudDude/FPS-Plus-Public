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
	var bf:Character;
	var camFollow:FlxObject;

	var suffix:String = "";

	public function new(x:Float, y:Float, camX:Float, camY:Float, character:String){

		var daBf:String = character;
		switch (daBf){
			case 'BfPixelDead':
				suffix = '-pixel';
			case 'PicoBlazin':
				suffix = '-pico';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Character(x, y, daBf, true);
		add(bf);

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

		bf.playAnim('firstDeath', true);

		FlxTween.tween(camFollow, {x: Utils.getGraphicMidpoint(bf).x + bf.deathOffset.x, y: Utils.getGraphicMidpoint(bf).y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut, startDelay: 0.5});
		//FlxTween.tween(camFollow, {x: bf.getMidpoint().x + bf.deathOffset.x, y: bf.getMidpoint().y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut, startDelay: 0.5});

		switch(suffix){
			case "-pico":
				switch(PlayState.SONG.song.toLowerCase()){
					case "blazin":
						FlxG.sound.play(Paths.sound("gameOver/fnf_loss_sfx-pico-gutpunch"));
					default:
						FlxG.sound.play(Paths.sound("gameOver/fnf_loss_sfx" + suffix));
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

		if (bf.curAnim == 'firstDeath' && bf.curAnimFinished()){
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
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
			{
				PlayState.instance.switchState(new PlayState());
			});
		});
	}
}
