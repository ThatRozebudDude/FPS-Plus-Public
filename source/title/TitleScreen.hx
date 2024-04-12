package title;

import config.Config;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
//import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
//import polymod.Polymod;

using StringTools;

class TitleScreen extends MusicBeatState
{

	public static var titleMusic:String = "klaskiiLoop"; 
	public static var titleMusicVolume:Float = 0.9; 

	var camBackground:FlxCamera;
	var camMain:FlxCamera;

	final bgScrollSpeed = 20;

	var allowControllerPress:Bool = false;

	override public function create():Void
	{
		//Polymod.init({modRoot: "mods", dirs: ['introMod']});

		// DEBUG BULLSHIT

		Config.setFramerate(144);

		useDefaultTransIn = false;

		camBackground = new FlxCamera();
		camBackground.width *= 2;
		camBackground.x -= 640;
		camBackground.angle = -6.26;

		camMain = new FlxCamera();
		camMain.bgColor.alpha = 0;
		camMain.bgColor.alpha = 0;

		FlxG.cameras.reset();
		FlxG.cameras.add(camBackground, false);
		FlxG.cameras.add(camMain, true);
		FlxG.cameras.setDefaultDrawTarget(camMain, true);

		var bgBfTop = new FlxBackdrop(Paths.image("fpsPlus/title/backgroundBf"), X);
		bgBfTop.y = 365 - bgBfTop.height;
		bgBfTop.velocity.x = bgScrollSpeed;
		bgBfTop.antialiasing = true;
		bgBfTop.alpha = 0.5;
		bgBfTop.cameras = [camBackground];

		var bgBfBottom = new FlxBackdrop(Paths.image("fpsPlus/title/backgroundBf"), X);
		bgBfBottom.y = 355;
		bgBfBottom.velocity.x = bgScrollSpeed * -1;
		bgBfBottom.antialiasing = true;
		bgBfBottom.alpha = 0.5;
		bgBfBottom.cameras = [camBackground];

		logoBl = new FlxSprite(-175, -125);
		logoBl.frames = Paths.getSparrowAtlas("logoBumpin");
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.scale.set(0.85, 0.85);
		logoBl.angle = camBackground.angle;

		var glow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('fpsPlus/title/glow'));
		glow.antialiasing = true;

		var topBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('fpsPlus/title/barTop'));
		topBar.antialiasing = true;
		
		var bottomBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('fpsPlus/title/barBottom'));
		bottomBar.antialiasing = true;

		gfDance = new FlxSprite(462, 15);
		gfDance.frames = Paths.getSparrowAtlas("fpsPlus/title/gf");
		gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat instance 1', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat instance 1', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.animation.play("danceRight", true, false, 14);
		gfDance.antialiasing = true;

		titleText = new FlxSprite(139, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas("titleEnter");
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		/*titleText.angle = camBackground.angle;
		titleText.x += 120;
		titleText.y -= 24;*/

		add(bgBfTop);
		add(bgBfBottom);

		add(topBar);
		add(gfDance);
		add(bottomBar);
		add(glow);

		add(logoBl);
		add(titleText);

		if(FlxG.sound.music == null){
			FlxG.sound.playMusic(Paths.music(titleMusic), titleMusicVolume);
		}
		else{
			if(!FlxG.sound.music.playing){
				FlxG.sound.playMusic(Paths.music(titleMusic), titleMusicVolume);
				switch(titleMusic){
					case "klaskiiLoop":
						Conductor.changeBPM(158);
					case "freakyMenu":
						Conductor.changeBPM(102);
				}
			}
		}

		FlxG.sound.music.onComplete = function(){lastStep = 0;}
		
		camMain.flash(FlxColor.WHITE, 1);

		super.create();

	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = (!allowControllerPress ? Binds.justPressedKeyboardOnly("menuAccept") : Binds.justPressed("menuAccept"));

		if(!transitioning && Binds.justPressed("menuBack")){
			System.exit(0);
		}

		if (pressedEnter && !transitioning)
		{
			titleText.animation.play('press');

			camMain.stopFX();
			camMain.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated
				switchState(new MainMenuState());
			});
		}

		if(!allowControllerPress && Binds.justReleasedControllerOnly("menuAccept")){
			allowControllerPress = true;
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		

		//i want the option
		if(curBeat % 1 == 0){

			danceLeft = !danceLeft;

			if (danceLeft){
				gfDance.animation.play('danceRight', true);
			}
			else{
				gfDance.animation.play('danceLeft', true);
			}
		}
	}

}
