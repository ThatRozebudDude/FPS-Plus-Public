package title;

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
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
//import polymod.Polymod;

using StringTools;

class TitleScreenKickstarter extends MusicBeatState
{

	public static var titleMusic:String = "klaskiiLoop"; 

	override public function create():Void
	{
		//Polymod.init({modRoot: "mods", dirs: ['introMod']});

		// DEBUG BULLSHIT

		useDefaultTransIn = false;

		persistentUpdate = true;

		var bg = new VideoHandler();
		bg.playMP4(Paths.video("titleKickBG"), null, true);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas("logoBumpin2");
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.blend = "add";
		logoBl.updateHitbox();

		var bgGrad:FlxSprite = new FlxSprite().loadGraphic(Paths.image('titleBG'));
		bgGrad.antialiasing = true;
		bgGrad.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas("gfDanceTitle2");
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.blend = "add";
		gfDance.antialiasing = true;

		add(bg);
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas("titleEnter");
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.blend = "add";
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		if(FlxG.sound.music == null){
			FlxG.sound.playMusic(Paths.music(titleMusic), 0.75);
		}
		else{
			if(!FlxG.sound.music.playing){
				FlxG.sound.playMusic(Paths.music(titleMusic), 0.75);
				switch(titleMusic){
					case "klaskiiLoop":
						Conductor.changeBPM(158);
					case "freakyMenu":
						Conductor.changeBPM(102);
				}
			}
		}
		
		FlxG.camera.flash(FlxColor.WHITE, 1);

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

		var pressedEnter:Bool = controls.ACCEPT || controls.PAUSE;

		if(!transitioning && controls.BACK){
			System.exit(0);
		}

		if (pressedEnter && !transitioning)
		{
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated
				switchState(new MainMenuState());
			});
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight', true);
		else
			gfDance.animation.play('danceLeft', true);

		FlxG.log.add(curBeat);
	}

}
