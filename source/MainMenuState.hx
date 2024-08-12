package;

import flixel.util.FlxTimer;
import flixel.system.debug.console.ConsoleUtil;
import flixel.math.FlxPoint;
import config.*;
import transition.data.*;
import title.TitleScreen;
import freeplay.FreeplayState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.text.FlxText;
import extensions.flixel.FlxTextExt;

using StringTools;

class MainMenuState extends MusicBeatState
{
	
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	
	public static var optionShit:Array<String> = ['storymode', 'freeplay', 'donate', "options"];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camTarget:FlxPoint = new FlxPoint();
	var instantCamFollow:Bool = false;

	var versionText:FlxTextExt;
	var keyWarning:FlxTextExt;
	var canCancelWarning:Bool = true;

	public static var fromFreeplay:Bool = false;

	public static final lerpSpeed:Float = 0.01;
	final warningDelay:Float = 10;

	public static final version:String = "v5.0.3 (Non-Release Build)";

	override function create()
	{

		Config.setFramerate(144);

		if (!FlxG.sound.music.playing)
		{	
			FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), TitleScreen.titleMusicVolume);
		}

		persistentUpdate = persistentDraw = true;

		if(fromFreeplay){
			fromFreeplay = false;
			customTransIn = new InstantTransition();
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
	
		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuBGMagenta'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.18));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = Paths.getSparrowAtlas("menu/main/" + optionShit[i]);
			
			menuItem.animation.addByPrefix('idle', "idle", 24);
			menuItem.animation.addByPrefix('selected', "selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow);

		versionText = new FlxTextExt(5, FlxG.height - 21, 0, "FPS Plus: " + version, 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		keyWarning = new FlxTextExt(5, FlxG.height - 21 + 16, 0, "If your controls aren't working, try pressing CTRL + BACKSPACE to reset them.", 16);
		keyWarning.scrollFactor.set();
		keyWarning.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyWarning.alpha = 0;
		add(keyWarning);

		FlxTween.tween(versionText, {y: versionText.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: warningDelay});
		FlxTween.tween(keyWarning, {alpha: 1, y: keyWarning.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: warningDelay});

		new FlxTimer().start(warningDelay, function(t){
			canCancelWarning = false;
		});

		// NG.core.calls.event.logEvent('swag').send();

		instantCamFollow = true;

		changeItem();
		
		//Offset Stuff
		Config.reload();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float){

		if(canCancelWarning && (Binds.justPressed("menuUp") || Binds.justPressed("menuDown")) || Binds.justPressed("menuAccept")){
			canCancelWarning = false;
			FlxTween.cancelTweensOf(versionText);
			FlxTween.cancelTweensOf(keyWarning);
		}
	
		if (!selectedSomethin){
			if (Binds.justPressed("menuUp")){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
			else if (Binds.justPressed("menuDown")){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (FlxG.keys.justPressed.BACKSPACE && FlxG.keys.pressed.CONTROL){
				Binds.resetToDefaultControls();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			else if (Binds.justPressed("menuBack") && !FlxG.keys.pressed.CONTROL){
				switchState(new TitleScreen());
			}

			if (Binds.justPressed("menuAccept")){
			
				if (optionShit[curSelected] == 'donate'){
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}

				else if(optionShit[curSelected] == 'freeplay'){
					selectedSomethin = true;
					customTransOut = new InstantTransition();
					FreeplayState.curSelected = 0;
					FreeplayState.curCategory = 0;
					switchState(new FreeplayState(true, camFollow.getPosition()));
				}
				
				else{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					var daChoice:String = optionShit[curSelected];
					
					switch (daChoice){
						case 'freeplay':
							if(CacheConfig.music){
								FlxG.sound.music.stop();
							}
						case 'options':
							if(!ConfigMenu.USE_MENU_MUSIC){
								FlxG.sound.music.stop();
							}
							else{
								ConfigMenu.startSong = false;
							}
					}

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite){
						if (curSelected != spr.ID){
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween){
									spr.kill();
								}
							});
						}
						else{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker){
								spr.visible = true;

								switch (daChoice)
								{
									case 'storymode':
										StoryMenuState.curWeek = 0;
										switchState(new StoryMenuState());
										trace("Story Menu Selected");
									/*case 'freeplay':
										FreeplayState.startingSelection = 0;
										FreeplayState.fromMainMenu = true;
										switchState(new FreeplayState());
										trace("Freeplay Menu Selected");*/
									case 'options':
										switchState(new ConfigMenu());
										trace("options time");
								}
							});
						}
					});
				}
			}
		}

		if(!instantCamFollow){
			camFollow.x = Utils.fpsAdjsutedLerp(camFollow.x, camTarget.x, lerpSpeed);
			camFollow.y = Utils.fpsAdjsutedLerp(camFollow.y, camTarget.y, lerpSpeed);
		}
		else{
			camFollow.x = camTarget.x;
			camFollow.y = camTarget.y;
			instantCamFollow = false;
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0){
		curSelected += huh;

		if (curSelected >= menuItems.length){
			curSelected = 0;
		}
 		if (curSelected < 0){
			curSelected = menuItems.length - 1;
		}

		menuItems.forEach(function(spr:FlxSprite){
			spr.animation.play('idle');

			if (spr.ID == curSelected){
				spr.animation.play('selected');
				camTarget.set(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
