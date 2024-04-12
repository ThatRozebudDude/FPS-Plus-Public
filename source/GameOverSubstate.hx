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

	var stageSuffix:String = "";

	public function new(x:Float, y:Float, camX:Float, camY:Float, character:String)
	{
		var daStage = PlayState.curStage;
		var daBf:String = character;
		switch (daBf)
		{
			case 'BfPixelDead':
				stageSuffix = '-pixel';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Character(x, y, daBf, true);
		add(bf);

		camFollow = new FlxObject(camX, camY, 1, 1);
		add(camFollow);
		FlxTween.tween(camFollow, {x: CoolUtil.getTrueGraphicMidpoint(bf).x, y: CoolUtil.getTrueGraphicMidpoint(bf).y}, 3, {ease: FlxEase.expoOut, startDelay: 0.5});

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.follow(camFollow, LOCKON);

		if (Binds.justPressed("menuAccept") && !isEnding)
		{
			endBullshit();
		}

		if (Binds.justPressed("menuBack") && !isEnding)
		{
			FlxG.sound.music.stop();
			isEnding = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));

			if (PlayState.isStoryMode)
				PlayState.instance.switchState(new StoryMenuState());
			else
				PlayState.instance.switchState(new FreeplayState());

			FlxG.camera.fade(FlxColor.BLACK, 0.1, false);
			

			
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			switch(PlayState.SONG.player2){

				case "Tankman":
					bf.playAnim('deathLoop');
					FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), 0.2);
					FlxG.sound.play(Paths.sound('week7/jeffGameover/jeffGameover-' + FlxG.random.int(1, 25)), 1, false, null, true, function()
					{
						if (!isEnding)
							FlxG.sound.music.fadeIn(2.5, 0.2, 1);
					});

				default:
					bf.playAnim('deathLoop');
					FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}
			
		}

		if (FlxG.sound.music.playing)
		{
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
		FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
			{
				PlayState.instance.switchState(new PlayState());
			});
		});
	}
}
