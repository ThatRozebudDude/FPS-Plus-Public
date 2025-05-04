package config;

import flixel.addons.display.FlxGridOverlay;
import shaders.ColorGradientShader;
import openfl.utils.Assets;
import title.TitleScreen;
import flixel.sound.FlxSound;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import transition.data.*;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import extensions.flixel.FlxUIStateExt;
import extensions.flixel.FlxTextExt;
import caching.*;


using StringTools;

class ConfigMenu extends FlxUIStateExt
{

	public static var USE_LAYERED_MUSIC:Bool = true;	//If you're not using a layered options theme, set this to false.
	public static var USE_MENU_MUSIC:Bool = false;		//Set this to true if you want to use the menu theme instead of a unique options song. Overrides USE_LAYERED_MUSIC.

	public static var exitTo:Class<Dynamic>;
	public static var startSong = true;
	public static var startInSubMenu:Int = -1;
	public static var savedListPos:Int = -1;
	public static var savedListOffset:Int = -1;

	public static final baseSongTrack:String = "config/nuConfiguratorBase";
	public static final layerSongTrack:String = "config/nuConfiguratorDrums";
	public static final keySongTrack:String = "config/nuConfiguratorKey";
	public static final cacheSongTrack:String = "config/nuConfiguratorCache";

	var songLayer:FlxSound;

	final fpsCapInSettings:Int = 120;

	var curSelected:Int = 0;

	var curListPosition:Int = 0;
	var curListStartOffset:Int = 0;

	var state:String = "topLevelMenu";
	var exiting:Bool = false;

	var invertedTitleColorShader = new ColorGradientShader(0xFFFFFFFF, 0xFF000000);

	final iconOffsets:Array<Float> = [-1000, -500, 0, 500, 1000];
	final iconScales:Array<Float> = [0.4, 0.7, 1, 0.7, 0.4];
	final textScales:Array<Float> = [0.3, 0.6, 1, 0.6, 0.3];
	final titleVertOffsets:Array<Float> = [-100, -50, 0, -50, -100];
	final iconAlphaValues:Array<Float> = [0, 0.6, 1, 0.6, 0];
	final optionIndexOffset:Array<Int> = [-2, -1, 0, 1, 2];

	var bg:FlxSprite;
	var optionTitle:FlxSprite;
	var icons:Array<FlxSprite> = [];
	var titles:Array<FlxSprite> = [];
	
	var descBar:FlxSprite;

	var categoryTitle:FlxSprite;
	var grid:FlxSprite;

	var optionNames:Array<FlxTextExt> = [];
	var optionValues:Array<FlxTextExt> = [];
	var descText:FlxTextExt;

	var subMenuUpArrow:FlxSprite;
	var subMenuDownArrow:FlxSprite;

	var nextCategoryIcon:FlxSprite;
	var prevCategoryIcon:FlxSprite;
	var nextCategoryArrow:FlxSprite;
	var prevCategoryArrow:FlxSprite;

	var topLevelMenuGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var subMenuGroup:FlxSpriteGroup = new FlxSpriteGroup();

	final options:Array<String> = ["gameplay", "video", "customize", "accessibility"];

	var configOptions:Array<Array<ConfigOption>> = [];

	final genericOnOff:Array<String> = ["on", "off"];

	var offsetValue:Float;
	var healthValue:Int;
	var healthDrainValue:Int;
	var comboValue:Int;
	final comboTypes:Array<String> = ["world", "hud", "off"];
	var downValue:Bool;
	var glowValue:Bool;
	var randomTapValue:Int;
	final randomTapTypes:Array<String> = ["never", "not singing", "always"];
	final allowedFramerates:Array<Int> = [60, 120, 144, 240, 999];
	var framerateValue:Int;
	var dimValue:Int;
	var noteSplashValue:Int;
	final noteSplashTypes:Array<String> = ["off", "both", "partial", "hit only", "hold only"];
	var centeredValue:Bool;
	var scrollSpeedValue:Int;
	var showComboBreaksValue:Bool;
	var showFPSValue:Bool;
	var useGPUValue:Bool;
	var extraCamMovementValue:Bool;
	var camBopAmountValue:Int;
	final camBopAmountTypes:Array<String> = ["on", "reduced", "off"];
	var showCaptionsValue:Bool;
	var showAccuracyValue:Bool;
	var showMissesValue:Int;
	final showMissesTypes:Array<String> = ["off", "on", "combo breaks"];
	var autoPauseValue:Bool;
	var flashingLightsValue:Bool;

	var pressUp:Bool = false;
	var pressDown:Bool = false;
	var pressLeft:Bool = false;
	var pressRight:Bool = false;
	var pressAccept:Bool = false;
	var pressBack:Bool = false;
	var holdUp:Bool = false;
	var holdDown:Bool = false;
	var holdLeft:Bool = false;
	var holdRight:Bool = false;

	override function create(){

		Config.setFramerate(fpsCapInSettings);

		if(exitTo == null){
			exitTo = MainMenuState;
		}

		FlxG.sound.cache(Paths.music(baseSongTrack));
		if(USE_LAYERED_MUSIC){
			FlxG.sound.cache(Paths.music(layerSongTrack));
			FlxG.sound.cache(Paths.music(keySongTrack));
			FlxG.sound.cache(Paths.music(cacheSongTrack));
		}
		

		if(startSong){
			if(!USE_MENU_MUSIC){
				FlxG.sound.playMusic(Paths.music(baseSongTrack), 1);
				if(USE_LAYERED_MUSIC){
					songLayer = FlxG.sound.play(Paths.music(layerSongTrack), 0, true);
				}
			}
			else{
				MainMenuState.playMenuMusic();
			}
		}
		else{
			if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
				songLayer = FlxG.sound.play(Paths.music(layerSongTrack), 0, true);
				songLayer.time = FlxG.sound.music.time;
			}
			startSong = true;
		}

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF5C6CA5;

		optionTitle = new FlxSprite(0, 100);
		optionTitle.frames = Paths.getSparrowAtlas("menu/main/options");
		optionTitle.animation.addByPrefix('selected', "selected", 24);
		optionTitle.animation.play('selected');
		optionTitle.antialiasing = true;
		optionTitle.updateHitbox();
		optionTitle.screenCenter(X);
		optionTitle.y -= optionTitle.height/2;

		descBar = new FlxSprite(0, 720).makeGraphic(1280, 90, 0xFF000000);
		descBar.alpha = 0.5;

		topLevelMenuGroup.add(optionTitle);

		var categoryFrames = Paths.getSparrowAtlas("menu/config/categories");
		var categoryIconFrames = Paths.getSparrowAtlas("menu/config/icons");

		categoryTitle = new FlxSprite(0, 100);
		categoryTitle.frames = categoryFrames;
		for(option in options){
			categoryTitle.animation.addByPrefix(option, option, 24, true);
		}
		categoryTitle.visible = false;
		categoryTitle.antialiasing = true;

		grid = new FlxSprite(30, 225).loadGraphic(FlxGridOverlay.createGrid(1220, 60, 1220, 60 * 6, true, 0x7F000000, 0x60000000));

		descText = new FlxTextExt(320, 740, 640, "AHAHAHH!", 20);
		descText.setFormat(Paths.font("vcr"), descText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderQuality = 1;
		
		subMenuGroup.add(grid);

		subMenuUpArrow = new FlxSprite(0, grid.y - 11).loadGraphic(Paths.image("menu/config/smallArrow"));
		subMenuUpArrow.antialiasing = true;
		subMenuUpArrow.y -= subMenuUpArrow.height;
		subMenuUpArrow.screenCenter(X);

		subMenuDownArrow = new FlxSprite(0, grid.y + grid.height + 11).loadGraphic(Paths.image("menu/config/smallArrow"));
		subMenuDownArrow.antialiasing = true;
		subMenuDownArrow.flipY = true;
		subMenuDownArrow.screenCenter(X);

		subMenuGroup.add(subMenuUpArrow);
		subMenuGroup.add(subMenuDownArrow);

		nextCategoryIcon = new FlxSprite(1280 - 190, 100);
		nextCategoryIcon.frames = categoryIconFrames;
		nextCategoryIcon.antialiasing = true;
		nextCategoryIcon.scale.set(0.5, 0.5);
		for(option in options){ nextCategoryIcon.animation.addByPrefix(option, option, 24, true); }

		prevCategoryIcon = new FlxSprite(190, 100);
		prevCategoryIcon.frames = categoryIconFrames;
		prevCategoryIcon.antialiasing = true;
		prevCategoryIcon.scale.set(0.5, 0.5);
		for(option in options){ prevCategoryIcon.animation.addByPrefix(option, option, 24, true); }

		nextCategoryArrow = new FlxSprite(1280 - 50, 100).loadGraphic(Paths.image("menu/config/arrow"));
		nextCategoryArrow.antialiasing = true;
		nextCategoryArrow.x -= nextCategoryArrow.width/2;
		nextCategoryArrow.y -= nextCategoryArrow.height/2;

		prevCategoryArrow = new FlxSprite(50, 100).loadGraphic(Paths.image("menu/config/arrow"));
		prevCategoryArrow.antialiasing = true;
		prevCategoryArrow.flipX = true;
		prevCategoryArrow.x -= prevCategoryArrow.width/2;
		prevCategoryArrow.y -= prevCategoryArrow.height/2;

		subMenuGroup.add(nextCategoryIcon);
		subMenuGroup.add(prevCategoryIcon);
		subMenuGroup.add(nextCategoryArrow);
		subMenuGroup.add(prevCategoryArrow);

		for(i in 0...6){
			var configText = new FlxTextExt(grid.x + 8, grid.y + 8 + (60*i), 1220 - 16, "OPTION " + i, 50);
			configText.setFormat(Paths.font("Funkin-Bold", "otf"), configText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			configText.borderSize = 4;
			configText.borderQuality = 1;
			optionNames.push(configText);
			subMenuGroup.add(configText);
		}

		for(i in 0...6){
			var valueText = new FlxTextExt(grid.x + 8, grid.y + 8 + (60*i), 1220 - 16, "<VALUE " + i + ">", 50);
			valueText.setFormat(Paths.font("Funkin-Bold", "otf"), valueText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			valueText.borderSize = 4;
			valueText.borderQuality = 1;
			optionValues.push(valueText);
			subMenuGroup.add(valueText);
		}

		for(i in 0...optionIndexOffset.length){
			var icon = new FlxSprite();
			icon.frames = categoryIconFrames;
			for(option in options){ icon.animation.addByPrefix(option, option, 24, true); }
			icon.antialiasing = true;
			icon.screenCenter(X);
			icon.x += iconOffsets[i];
			icon.scale.set(iconScales[i], iconScales[i]);
			icons.push(icon);
			topLevelMenuGroup.add(icon);

			var title = new FlxSprite();
			title.frames = categoryFrames;
			for(option in options){ title.animation.addByPrefix(option, option, 24, true); }
			title.antialiasing = true;
			title.screenCenter(X);
			title.x += iconOffsets[i];
			title.y = 620 - title.height/2;
			title.y += titleVertOffsets[i];
			title.scale.set(textScales[i], textScales[i]);
			titles.push(title);
			topLevelMenuGroup.add(title);
		}

		subMenuGroup.alpha = 0;

		add(bg);

		add(topLevelMenuGroup);
		add(subMenuGroup);
		
		add(descBar);
		add(descText);
		add(categoryTitle);

		setupOptions();
		updateAllOptions();

		customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		changeCategory(0, false);

		if(startInSubMenu > -1){
			changeCategory(startInSubMenu, false);
			openSubMenu(false);
			curListPosition = savedListPos;
			curListStartOffset = savedListOffset; 
			textUpdate();
			startInSubMenu = -1;
			savedListPos = -1;
			savedListOffset = -1;
		}

		super.create();

	}

	override function update(elapsed:Float):Void{

		super.update(elapsed);

		pressUp = Binds.justPressed("menuUp");
		pressDown = Binds.justPressed("menuDown");
		pressLeft = Binds.justPressed("menuLeft");
		pressRight = Binds.justPressed("menuRight");
		pressAccept = Binds.justPressed("menuAccept");
		pressBack = Binds.justPressed("menuBack");
		holdUp = Binds.pressed("menuUp");
		holdDown = Binds.pressed("menuDown");
		holdLeft = Binds.pressed("menuLeft");
		holdRight = Binds.pressed("menuRight");

		if(USE_LAYERED_MUSIC){
			if (!exiting && (Math.abs(songLayer.time - (FlxG.sound.music.time)) > 20)){
				resyncLayers();
			}
		}

		if(!exiting){

			switch(state){

				case "topLevelMenu":
					if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
						songLayer.volume = 0;
					}

					if (pressBack){
						exit();
					}
					else if(pressAccept){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						openSubMenu();
					}
					else if(pressLeft){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeCategory(-1);
					}
					else if(pressRight){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeCategory(1);
					}

				case "subMenu":
					if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
						songLayer.volume = 1;
					}

					if(Binds.justPressed("menuCycleLeft")){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						curListPosition = 0;
						curListStartOffset = 0;
						changeCategory(-1, false);
						textUpdate();

						FlxTween.cancelTweensOf(categoryTitle);
						FlxTween.cancelTweensOf(categoryTitle.scale);
						categoryTitle.animation.play(options[curSelected]);
						categoryTitle.centerOrigin();
						categoryTitle.scale.set(1, 1);
						categoryTitle.x = (1280/2) - (categoryTitle.frameWidth/2);
						categoryTitle.x += -120;
						categoryTitle.y = 100 - (categoryTitle.frameHeight/2);

						FlxTween.tween(categoryTitle, {x: categoryTitle.x + 120}, 0.4, {ease: FlxEase.quintOut});
					}
					else if(Binds.justPressed("menuCycleRight")){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						curListPosition = 0;
						curListStartOffset = 0;
						changeCategory(1, false);
						textUpdate();

						FlxTween.cancelTweensOf(categoryTitle);
						FlxTween.cancelTweensOf(categoryTitle.scale);
						categoryTitle.animation.play(options[curSelected]);
						categoryTitle.centerOrigin();
						categoryTitle.scale.set(1, 1);
						categoryTitle.x = (1280/2) - (categoryTitle.frameWidth/2);
						categoryTitle.x += 120;
						categoryTitle.y = 100 - (categoryTitle.frameHeight/2);

						FlxTween.tween(categoryTitle, {x: categoryTitle.x - 120}, 0.4, {ease: FlxEase.quintOut});
					}

					/*if(holdUp && curListPosition == 0){
						subMenuUpArrow.scale.set(0.7, 0.7);
					}
					else{
						subMenuUpArrow.scale.set(1, 1);
					}

					if(holdDown && curListPosition == 5){
						subMenuDownArrow.scale.set(0.7, 0.7);
					}
					else{
						subMenuDownArrow.scale.set(1, 1);
					}*/

					if(Binds.pressed("menuCycleRight")){ nextCategoryArrow.scale.set(0.75, 0.75); }
					else{ nextCategoryArrow.scale.set(1, 1); }

					if(Binds.pressed("menuCycleLeft")){ prevCategoryArrow.scale.set(0.75, 0.75); }
					else{ prevCategoryArrow.scale.set(1, 1); }

					if(pressDown){
						if(curListStartOffset + curListPosition < configOptions[curSelected].length-1){
							if(curListPosition == 5){
								curListStartOffset++;
							}
							else{
								curListPosition++;
							}
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
					}
					else if(pressUp){
						if(curListStartOffset + curListPosition > 0){
							if(curListPosition == 0){
								curListStartOffset--;
							}
							else{
								curListPosition--;
							}
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
					}

					subMenuUpArrow.visible = !(curListStartOffset == 0);
					subMenuDownArrow.visible = !(curListStartOffset + 6 >= configOptions[curSelected].length);

					if(configOptions[curSelected][curListStartOffset + curListPosition].optionUpdate != null){
						configOptions[curSelected][curListStartOffset + curListPosition].optionUpdate();
					}

					if(state != "transitioning"){
						if(pressBack){
							FlxG.sound.play(Paths.sound('cancelMenu'));
							closeSubMenu();
						}
					}

					if(pressUp || pressDown || pressLeft || pressRight || pressAccept){
						textUpdate();
					}

			}

		}

		descText.y = descBar.y + 20;

	}

	function changeCategory(change:Int, ?doTween:Bool = true):Void{
		curSelected += change;
		if(curSelected < 0){ curSelected = options.length-1; }
		if(curSelected >= options.length){ curSelected = 0; }

		if(doTween){
			for(i in 0...titles.length){
				FlxTween.cancelTweensOf(titles[i]);
				FlxTween.cancelTweensOf(titles[i].scale);
				FlxTween.cancelTweensOf(icons[i]);
				FlxTween.cancelTweensOf(icons[i].scale);

				var iOffset = i + Utils.sign(change);
				if(iOffset < 0 || iOffset >= optionIndexOffset.length){
					titles[i].visible = false;
					icons[i].visible = false;
				}
				else{
					titles[i].visible = true;
					titles[i].animation.play(options[wrapToOptionLength(curSelected + optionIndexOffset[i])]);
					titles[i].x = 1280/2 - titles[i].frameWidth/2;
					titles[i].x += iconOffsets[iOffset];
					titles[i].y = 620 - titles[i].frameHeight/2;
					titles[i].y += titleVertOffsets[iOffset];
					titles[i].centerOrigin();
					titles[i].scale.set(textScales[iOffset], textScales[iOffset]);
					//titles[i].alpha = iconAlphaValues[iOffset];

					FlxTween.tween(titles[i], {x: (1280/2 - titles[i].frameWidth/2) + iconOffsets[i], y: (620 - titles[i].frameHeight/2) + titleVertOffsets[i]}, 0.5, {ease: FlxEase.quintOut});
					FlxTween.tween(titles[i].scale, {x: textScales[i], y: textScales[i]}, 0.5, {ease: FlxEase.quintOut});

					icons[i].visible = true;
					icons[i].animation.play(options[wrapToOptionLength(curSelected + optionIndexOffset[i])]);
					icons[i].x = 1280/2 - icons[i].frameWidth/2;
					icons[i].x += iconOffsets[iOffset];
					icons[i].y = 720/2 - icons[i].frameHeight/2;
					icons[i].scale.set(iconScales[iOffset], iconScales[iOffset]);
					//icons[i].alpha = iconAlphaValues[iOffset];

					FlxTween.tween(icons[i], {x: (1280/2 - icons[i].frameWidth/2) + iconOffsets[i]}, 0.5, {ease: FlxEase.quintOut});
					FlxTween.tween(icons[i].scale, {x: iconScales[i], y: iconScales[i]}, 0.5, {ease: FlxEase.quintOut});
				}
			}
		}
		else{
			for(i in 0...titles.length){
				FlxTween.cancelTweensOf(titles[i]);
				FlxTween.cancelTweensOf(titles[i].scale);
				FlxTween.cancelTweensOf(icons[i]);
				FlxTween.cancelTweensOf(icons[i].scale);

				titles[i].visible = true;
				titles[i].animation.play(options[wrapToOptionLength(curSelected + optionIndexOffset[i])]);
				titles[i].x = 1280/2 - titles[i].frameWidth/2;
				titles[i].x += iconOffsets[i];
				titles[i].y = 620 - titles[i].frameHeight/2;
				titles[i].y += titleVertOffsets[i];
				titles[i].centerOrigin();
				titles[i].scale.set(textScales[i], textScales[i]);
				//titles[i].alpha = iconAlphaValues[i];

				icons[i].animation.play(options[wrapToOptionLength(curSelected + optionIndexOffset[i])]);
				icons[i].x = 1280/2 - icons[i].frameWidth/2;
				icons[i].x += iconOffsets[i];
				icons[i].y = 720/2 - icons[i].frameHeight/2;
				icons[i].scale.set(iconScales[i], iconScales[i]);
				//icons[i].alpha = iconAlphaValues[i];
			}
		}

		for(i in 0...titles.length){
			if(i == 2){
				titles[i].shader = null;
				titles[i].animation.curAnim.frameRate = 24;
			}
			else{
				titles[i].shader = invertedTitleColorShader.shader;
				titles[i].animation.curAnim.frameRate = 8;
			}
		}

		nextCategoryIcon.animation.play(options[wrapToOptionLength(curSelected + 1)]);
		nextCategoryIcon.setPosition(1280 - 190, 100);
		nextCategoryIcon.x -= nextCategoryIcon.frameWidth/2;
		nextCategoryIcon.y -= nextCategoryIcon.frameHeight/2;
		nextCategoryIcon.centerOrigin();

		prevCategoryIcon.animation.play(options[wrapToOptionLength(curSelected - 1)]);
		prevCategoryIcon.setPosition(190, 100);
		prevCategoryIcon.x -= prevCategoryIcon.frameWidth/2;
		prevCategoryIcon.y -= prevCategoryIcon.frameHeight/2;
		prevCategoryIcon.centerOrigin();
	}

	inline function wrapToOptionLength(v:Int):Int{
		while(v >= options.length){ v -= options.length; }
		while(v < 0){ v += options.length; }
		return v;
	}

	function openSubMenu(?doTween:Bool = true):Void{
		state = "subMenu";
		curListPosition = 0;
		curListStartOffset = 0;
		textUpdate();

		FlxTween.cancelTweensOf(topLevelMenuGroup);
		FlxTween.cancelTweensOf(subMenuGroup);
		FlxTween.cancelTweensOf(descBar);
		FlxTween.cancelTweensOf(categoryTitle);
		FlxTween.cancelTweensOf(categoryTitle.scale);
		FlxTween.cancelTweensOf(bg);

		if(doTween){
			FlxTween.tween(topLevelMenuGroup, {alpha: 0}, 0.3, {ease: FlxEase.quintOut});
			FlxTween.tween(subMenuGroup, {alpha: 1}, 0.3, {ease: FlxEase.quintOut});
			FlxTween.tween(descBar, {y: 720 - descBar.height}, 0.5, {ease: FlxEase.quintOut});
			FlxTween.color(bg, 1.75, 0xFF4961B8, 0xFF5C6CA5, {ease: FlxEase.quintOut});

			categoryTitle.visible = true;
			titles[2].visible = false;
			categoryTitle.setPosition(titles[2].x, titles[2].y);
			categoryTitle.animation.play(options[curSelected]);
			categoryTitle.centerOrigin();
			categoryTitle.scale.set(titles[2].scale.x, titles[2].scale.y);

			FlxTween.tween(categoryTitle, {x: (1280/2) - (categoryTitle.frameWidth/2), y: 100 - (categoryTitle.frameHeight/2)}, 0.5, {ease: FlxEase.quintOut});
			FlxTween.tween(categoryTitle.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.quintOut});
		}
		else{
			topLevelMenuGroup.alpha = 0;
			subMenuGroup.alpha = 1;
			descBar.y = 720 - descBar.height;

			categoryTitle.visible = true;
			titles[2].visible = false;
			categoryTitle.animation.play(options[curSelected]);
			categoryTitle.centerOrigin();
			categoryTitle.scale.set(1, 1);
			categoryTitle.x = (1280/2) - (categoryTitle.frameWidth/2);
			categoryTitle.y = 100 - (categoryTitle.frameHeight/2);
		}
	}

	function closeSubMenu():Void{
		state = "topLevelMenu";

		FlxTween.cancelTweensOf(topLevelMenuGroup);
		FlxTween.cancelTweensOf(subMenuGroup);
		FlxTween.cancelTweensOf(descBar);

		FlxTween.tween(topLevelMenuGroup, {alpha: 1}, 0.3, {ease: FlxEase.quintOut});
		FlxTween.tween(subMenuGroup, {alpha: 0}, 0.3, {ease: FlxEase.quintOut});
		FlxTween.tween(descBar, {y: 720}, 0.5, {ease: FlxEase.quintOut});

		categoryTitle.visible = false;
		titles[2].visible = true;
	}

	function exit():Void{
		writeToConfig();
		exiting = true;
		if(!USE_MENU_MUSIC || exitTo != MainMenuState){
			FlxG.sound.music.stop();
			Assets.cache.removeSound(baseSongTrack);
		}
		if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
			songLayer.stop();
			songLayer.destroy();
			Assets.cache.removeSound(Paths.music(layerSongTrack));
			Assets.cache.removeSound(Paths.music(keySongTrack));
			Assets.cache.removeSound(Paths.music(cacheSongTrack));
		}
		FlxG.sound.play(Paths.sound('cancelMenu'));
		switchState(Type.createInstance(exitTo, []));
		exitTo = null;
		Utils.gc();
	}

	function writeToConfig():Void{
		Config.write(offsetValue, healthValue / 10.0, healthDrainValue / 10.0, comboValue, downValue, glowValue, randomTapValue, allowedFramerates[framerateValue], dimValue, noteSplashValue, centeredValue, scrollSpeedValue / 10.0, showComboBreaksValue, showFPSValue, useGPUValue, extraCamMovementValue, camBopAmountValue, showCaptionsValue, showAccuracyValue, showMissesValue, autoPauseValue, flashingLightsValue);
	}

	function updateAllOptions():Void{
		for(configOptionsList in configOptions){
			for(opt in configOptionsList){
				opt.optionUpdate();
			}
		}
	}

	function textUpdate():Void{
		for(i in 0...optionNames.length){
			textUpdateSingle(i);
		}
	}

	function textUpdateSingle(index:Int):Void{
		optionNames[index].text = "";
		optionValues[index].text = "";

		var optionPosition = curListStartOffset + index;
		if(optionPosition >= configOptions[curSelected].length){ return; }

		optionNames[index].text = configOptions[curSelected][optionPosition].name + "\n\n";
		optionValues[index].text = configOptions[curSelected][optionPosition].setting;

		if(index == curListPosition){
			optionNames[index].color = 0xFFFFFF00;
			optionValues[index].color = 0xFFFFFF00;
			descText.text = configOptions[curSelected][optionPosition].description + "\n\n";
			if(optionValues[index].text.length > 0){
				optionValues[index].text = "< " + optionValues[index].text + " >\n\n";
			}
		}
		else{
			optionNames[index].color = 0xFFFFFFFF;
			optionValues[index].color = 0xFFFFFFFF;
		}

		if(optionValues[index].text == ""){
			optionValues[index].text = "---\n\n";
		}
	}

	function setupOptions(){

		offsetValue = Config.offset;
		healthValue = Std.int(Config.healthMultiplier * 10);
		healthDrainValue = Std.int(Config.healthDrainMultiplier * 10);
		comboValue = Config.comboType;
		downValue = Config.downscroll;
		glowValue = Config.noteGlow;
		randomTapValue = Config.ghostTapType;
		dimValue = Config.bgDim;
		noteSplashValue = Config.noteSplashType;
		centeredValue = Config.centeredNotes;
		scrollSpeedValue = Std.int(Config.scrollSpeedOverride * 10);
		showComboBreaksValue = Config.showComboBreaks;
		showFPSValue = Config.showFPS;
		useGPUValue = Config.useGPU;
		extraCamMovementValue = Config.extraCamMovement;
		camBopAmountValue = Config.camBopAmount;
		showCaptionsValue = Config.showCaptions;
		showAccuracyValue = Config.showAccuracy;
		showMissesValue = Config.showMisses;
		autoPauseValue = Config.autoPause;
		flashingLightsValue = Config.flashingLights;

		framerateValue = allowedFramerates.indexOf(Config.framerate);
		if(framerateValue == -1){
			framerateValue = allowedFramerates.length - 1;
		}

		//VIDEO

		var fpsCap = new ConfigOption("FRAMERATE", #if desktop (allowedFramerates[framerateValue] == 999 ? "uncapped" : ""+allowedFramerates[framerateValue]) #else "disabled" #end, #if desktop "Uncaps the framerate during gameplay.\n(Some menus will limit framerate but gameplay will always be at the specified framerate.)" #else "Disabled on Web builds." #end);
		fpsCap.optionUpdate = function(){
			#if desktop
			if (pressRight) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				framerateValue++;
			}
			else if (pressRight || pressLeft) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				framerateValue--;
			}

			if(framerateValue < 0){
				framerateValue = allowedFramerates.length - 1;
			}
			if(framerateValue >= allowedFramerates.length){
				framerateValue = 0;
			}

			Config.setFramerate(fpsCapInSettings, allowedFramerates[framerateValue]);

			fpsCap.setting = (allowedFramerates[framerateValue] == 999 ? "uncapped" : ""+allowedFramerates[framerateValue]);
			#end
		};



		var bgDim = new ConfigOption("BACKGROUND DIM", (dimValue * 10) + "%", "Adjusts how dark the background is.\nIt is recommended that you use the HUD combo display with a high background dim.");
		bgDim.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				dimValue += 1;
			}
				
			if (pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				dimValue -= 1;
			}
				
			if (dimValue > 10)
				dimValue = 0;
			if (dimValue < 0)
				dimValue = 10;

			bgDim.setting = (dimValue * 10) + "%";
		}



		var noteSplash = new ConfigOption("NOTE SPLASH", noteSplashTypes[noteSplashValue], "temp :]");
		noteSplash.extraData[0] = "All note splashes are disabled.";
		noteSplash.extraData[1] = "Both note splashes and hold covers are enabled.";
		noteSplash.extraData[2] = "Both note splashes and hold covers are enabled, but there is no hold release splash.";
		noteSplash.extraData[3] = "Only note splashes are enabled, not hold covers.";
		noteSplash.extraData[4] = "Only hold covers are enabled, not note splashes.";
		noteSplash.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				noteSplashValue += 1;
			}
				
			if (pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				noteSplashValue -= 1;
			}
				
			if (noteSplashValue >= noteSplashTypes.length)
				noteSplashValue = 0;
			if (noteSplashValue < 0)
				noteSplashValue = noteSplashTypes.length - 1;

			noteSplash.setting = noteSplashTypes[noteSplashValue];
			noteSplash.description = noteSplash.extraData[noteSplashValue];
		}



		var noteGlow = new ConfigOption("NOTE GLOW", genericOnOff[glowValue?0:1], "Makes note arrows glow if they are able to be hit.");
		noteGlow.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				glowValue = !glowValue;
			}
			noteGlow.setting = genericOnOff[glowValue?0:1];
		}



		var extraCamStuff = new ConfigOption("DYNAMIC CAMERA", genericOnOff[extraCamMovementValue?0:1] , "Moves the camera in the direction of hit notes.");
		extraCamStuff.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				extraCamMovementValue = !extraCamMovementValue;
			}
			extraCamStuff.setting = genericOnOff[extraCamMovementValue?0:1];
		};



		var camBopStuff = new ConfigOption("CAMERA BOP", camBopAmountTypes[camBopAmountValue] , "Adjust how much the camera zooms on beat.");
		camBopStuff.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				camBopAmountValue += 1;
			}
				
			if (pressLeft)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				camBopAmountValue -= 1;
			}
				
			if (camBopAmountValue > 2)
				camBopAmountValue = 0;
			if (camBopAmountValue < 0)
				camBopAmountValue = 2;

			camBopStuff.setting = camBopAmountTypes[camBopAmountValue];
		};



		var captionsStuff = new ConfigOption("CAPTIONS", genericOnOff[showCaptionsValue?0:1] , "Enables captions for songs that have them.");
		captionsStuff.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showCaptionsValue = !showCaptionsValue;
			}
			captionsStuff.setting = genericOnOff[showCaptionsValue?0:1];
		};



		//INPUT



		var noteOffset = new ConfigOption("NOTE OFFSET", ""+offsetValue, "Adjust note timings.\nPress \"ENTER\" to start the offset calibration." + (Config.ee1?"\nHold \"SHIFT\" to force the pixel calibration.\nHold \"CTRL\" to force the normal calibration.":""));
		noteOffset.extraData[0] = 0;
		noteOffset.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				offsetValue += 1;
			}
				
			if (pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				offsetValue -= 1;
			}
				
			if (holdRight){
				noteOffset.extraData[0]++;
					
				if(noteOffset.extraData[0] > 64) {
					offsetValue += 1;
					textUpdateSingle(curListPosition);
				}
			}
				
			if (holdLeft){
				noteOffset.extraData[0]++;
					
				if(noteOffset.extraData[0] > 64) {
					offsetValue -= 1;
					textUpdateSingle(curListPosition);
				}
			}
				
			if(!holdRight && !holdLeft && noteOffset.extraData[0] != 0){
				noteOffset.extraData[0] = 0;
				textUpdateSingle(curListPosition);
			}

			if(FlxG.keys.justPressed.ENTER){
				state = "transitioning";
				saveMenuPosition();
				FlxG.sound.music.fadeOut(0.3);
				writeToConfig();
				AutoOffsetState.forceEasterEgg = FlxG.keys.pressed.SHIFT ? 1 : (FlxG.keys.pressed.CONTROL ? -1 : 0);
				if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
					songLayer.fadeOut(0.3);
				}
				switchState(new AutoOffsetState());
			}

			noteOffset.setting = ""+offsetValue;
		};



		var downscroll = new ConfigOption("DOWNSCROLL", genericOnOff[downValue?0:1], "Makes notes approach from the top instead the bottom.");
		downscroll.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				downValue = !downValue;
			}
			downscroll.setting = genericOnOff[downValue?0:1];
		}



		var centeredNotes = new ConfigOption("CENTERED STRUM LINE", genericOnOff[centeredValue?0:1], "Makes the strum line centered instead of to the side.");
		centeredNotes.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				centeredValue = !centeredValue;
			}
			centeredNotes.setting = genericOnOff[centeredValue?0:1];
		}



		var ghostTap = new ConfigOption("ALLOW GHOST TAPPING", randomTapTypes[randomTapValue], "");
		ghostTap.extraData[0] = "Any key press that isn't for a valid note will cause you to miss.";
		ghostTap.extraData[1] = "You can only  miss while you need to sing.";
		ghostTap.extraData[2] = "You cannot miss unless you do not hit a note.";
		ghostTap.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				randomTapValue += 1;
			}
				
			if (pressLeft)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				randomTapValue -= 1;
			}
				
			if (randomTapValue > 2)
				randomTapValue = 0;
			if (randomTapValue < 0)
				randomTapValue = 2;

			ghostTap.setting = randomTapTypes[randomTapValue];
			ghostTap.description = ghostTap.extraData[randomTapValue];
		}



		var keyBinds = new ConfigOption("[EDIT CONTROLS]", "", "Press ENTER to change key binds.");
		keyBinds.optionUpdate = function(){
			if (pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				state = "transitioning";
				saveMenuPosition();
				writeToConfig();
				if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
					songLayer.fadeOut(0.3);
				}
				if(Binds.justPressedControllerOnly("menuAccept")){
					switchState(new KeyBindMenu(true));
				}
				else{
					switchState(new KeyBindMenu(false));
				}
			}
		}

		var showFPS = new ConfigOption("SHOW FPS", genericOnOff[showFPSValue?0:1], "Show or hide the game's framerate.");
		showFPS.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showFPSValue = !showFPSValue;
				Main.fpsDisplay.visible = showFPSValue;
			}
			showFPS.setting = genericOnOff[showFPSValue?0:1];
		}

		var useGPU = new ConfigOption("GPU LOADING", genericOnOff[useGPUValue?0:1], "Load graphics on the GPU if possible. Reduces memory usage but might not work well on lower end machines.");
		useGPU.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				useGPUValue = !useGPUValue;
			}
			useGPU.setting = genericOnOff[useGPUValue?0:1];
		}


		//MISC



		/*var accuracyDisplay = new ConfigOption("ACCURACY DISPLAY", accuracyType, "What type of accuracy calculation you want to use. Simple is just notes hit / total notes. Complex also factors in how early or late a note was.");
		accuracyDisplay.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				accuracyTypeInt += 1;
			}
				
			if (pressLeft)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				accuracyTypeInt -= 1;
			}
				
			if (accuracyTypeInt > 2)
				accuracyTypeInt = 0;
			if (accuracyTypeInt < 0)
				accuracyTypeInt = 2;
					
			accuracyType = accuracyTypes[accuracyTypeInt];
			
			accuracyDisplay.setting = accuracyType;
		};*/



		var showAccuracyDisplay = new ConfigOption("SHOW ACCURACY", genericOnOff[showAccuracyValue?0:1], "Shows the accuracy on the in-game HUD.");
		showAccuracyDisplay.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showAccuracyValue = !showAccuracyValue;
			}
			showAccuracyDisplay.setting = genericOnOff[showAccuracyValue?0:1];
		}



		var comboDisplay = new ConfigOption("COMBO DISPLAY", comboTypes[comboValue], "");
		comboDisplay.extraData[0] = "Ratings and combo count are a part of the world and move around with the camera.";
		comboDisplay.extraData[1] = "Ratings and combo count are a part of the hud and stay in a static position.";
		comboDisplay.extraData[2] = "Ratings and combo count are hidden.";
		comboDisplay.optionUpdate = function(){
			if (pressRight)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				comboValue += 1;
			}
				
			if (pressLeft)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				comboValue -= 1;
			}
				
			if (comboValue >= comboTypes.length)
				comboValue = 0;
			if (comboValue < 0)
				comboValue = comboTypes.length - 1;
			
			comboDisplay.setting = comboTypes[comboValue];
			comboDisplay.description = comboDisplay.extraData[comboValue];
		};



		var hpGain = new ConfigOption("HP GAIN MULTIPLIER", ""+(healthValue / 10.0), "Modifies how much Health you gain when hitting a note.");
		hpGain.extraData[0] = 0;
		hpGain.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				healthValue += 1;
			}
				
			if (pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				healthValue -= 1;
			}
				
			if (healthValue > 100)
				healthValue = 0;
			if (healthValue < 0)
				healthValue = 100;
					
			if (holdRight){
				hpGain.extraData[0]++;
				
				if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
					healthValue += 1;
					textUpdateSingle(curListPosition);
				}
			}
			
			if (holdLeft){
				hpGain.extraData[0]++;
				
				if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
					healthValue -= 1;
					textUpdateSingle(curListPosition);
				}
			}
			
			if(!holdRight && !holdLeft){
				hpGain.extraData[0] = 0;
				textUpdateSingle(curListPosition);
			}
			
			hpGain.setting = ""+(healthValue / 10.0);
		};



		var hpDrain = new ConfigOption("HP LOSS MULTIPLIER", ""+(healthDrainValue / 10.0), "Modifies how much Health you lose when missing a note.");
		hpDrain.extraData[0] = 0;
		hpDrain.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				healthDrainValue += 1;
			}
				
			if (pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				healthDrainValue -= 1;
			}
				
			if (healthDrainValue > 100)
				healthDrainValue = 0;
			if (healthDrainValue < 0)
				healthDrainValue = 100;
					
			if (holdRight){
				hpGain.extraData[0]++;
				
				if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
					healthDrainValue += 1;
					textUpdateSingle(curListPosition);
				}
			}
			
			if (holdLeft){
				hpGain.extraData[0]++;
				
				if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
					healthDrainValue -= 1;
					textUpdateSingle(curListPosition);
				}
			}
			
			if(!holdRight && !holdLeft){
				hpGain.extraData[0] = 0;
				textUpdateSingle(curListPosition);
			}
			
			hpDrain.setting = ""+(healthDrainValue / 10.0);
		};



		var cacheSettings = new ConfigOption("[CACHE SETTINGS]", "", "Press ENTER to change what assets the game keeps cached.");
		cacheSettings.optionUpdate = function(){
			if (pressAccept) {
				#if desktop
				FlxG.sound.play(Paths.sound('scrollMenu'));
				state = "transitioning";
				saveMenuPosition();
				writeToConfig();
				if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
					songLayer.fadeOut(0.3);
				}
				switchState(new CacheSettings());
				CacheSettings.returnLoc = new ConfigMenu();
				#end
			}
		}



		var scrollSpeed = new ConfigOption("STATIC SCROLL SPEED", (scrollSpeedValue > 0 ? "" + (scrollSpeedValue / 10.0) : ""), "");
		scrollSpeed.extraData[0] = 0;
		scrollSpeed.extraData[1] = "Press ENTER to enable.\nSets the song scroll speed to the set value instead of the song's default.";
		scrollSpeed.extraData[2] = "Press ENTER to disable.\nSets the song scroll speed to the set value instead of the song's default.";
		scrollSpeed.optionUpdate = function(){

			if(scrollSpeedValue != -10){
				if (pressRight){
					FlxG.sound.play(Paths.sound('scrollMenu'));
					scrollSpeedValue += 1;
				}
					
				if (pressLeft){
					FlxG.sound.play(Paths.sound('scrollMenu'));
					scrollSpeedValue -= 1;
				}
					
				if (scrollSpeedValue > 50)
					scrollSpeedValue = 10;
				if (scrollSpeedValue < 10)
					scrollSpeedValue = 50;
						
				if (holdRight){
					scrollSpeed.extraData[0]++;
					
					if(scrollSpeed.extraData[0] > 64 && scrollSpeed.extraData[0] % 10 == 0) {
						scrollSpeedValue += 1;
						textUpdateSingle(curListPosition);
					}
				}
				
				if (holdLeft){
					scrollSpeed.extraData[0]++;
					
					if(scrollSpeed.extraData[0] > 64 && scrollSpeed.extraData[0] % 10 == 0) {
						scrollSpeedValue -= 1;
						textUpdateSingle(curListPosition);
					}
				}
				
				if(!holdRight && !holdLeft){
					scrollSpeed.extraData[0] = 0;
					textUpdateSingle(curListPosition);
				}

				if(pressAccept){
					FlxG.sound.play(Paths.sound('scrollMenu'));
					scrollSpeedValue = -10;
				}
			}
			else{
				if(pressAccept){
					FlxG.sound.play(Paths.sound('scrollMenu'));
					scrollSpeedValue = 10;
				}
			}

			scrollSpeed.description = scrollSpeedValue > 0 ? scrollSpeed.extraData[2] : scrollSpeed.extraData[1];
			scrollSpeed.setting = (scrollSpeedValue > 0 ? "" + (scrollSpeedValue / 10.0) : "");
		};



		/*var showComboBreaks = new ConfigOption("SHOW COMBO BREAKS", genericOnOff[showComboBreaksValue?0:1], "Show combo breaks instead of misses.\nMisses only happen when you actually miss a note.\nCombo breaks can happen in other instances like dropping hold notes.");
		showComboBreaks.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showComboBreaksValue = !showComboBreaksValue;
			}
			showComboBreaks.setting = genericOnOff[showComboBreaksValue?0:1];
		}*/



		var showMissesSetting = new ConfigOption("SHOW MISSES", showMissesTypes[showMissesValue], "TEMP");
		showMissesSetting.extraData[0] = "Misses are not shown on the in-game HUD.";
		showMissesSetting.extraData[1] = "Misses are shown on the in-game HUD.";
		showMissesSetting.extraData[2] = "Combo breaks are shown on the in-game HUD.";
		showMissesSetting.optionUpdate = function(){
			if (pressRight){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showMissesValue += 1;
			}
				
			if (pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showMissesValue -= 1;
			}
				
			if (showMissesValue > 2)
				showMissesValue = 0;
			if (showMissesValue < 0)
				showMissesValue = 2;
			
			showMissesSetting.setting = showMissesTypes[showMissesValue];
			showMissesSetting.description = showMissesSetting.extraData[showMissesValue];
		};

		var autoPauseSettings = new ConfigOption("PAUSE WHEN UNFOCUSED", genericOnOff[autoPauseValue?0:1], "Pauses the game when the application is unfocused or minimized.");
		autoPauseSettings.optionUpdate = function(){
			if (pressRight || pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				autoPauseValue = !autoPauseValue;
				FlxG.autoPause = autoPauseValue;
			}

			autoPauseSettings.setting = genericOnOff[autoPauseValue?0:1];
		};

		var flashingLightsSettings = new ConfigOption("FLASHING EFFECTS", genericOnOff[flashingLightsValue?0:1], "Determines whether certain bright or flashing effects that could cause eye strain will play.");
		flashingLightsSettings.optionUpdate = function(){
			if (pressRight || pressLeft){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				flashingLightsValue = !flashingLightsValue;
			}

			flashingLightsSettings.setting = genericOnOff[flashingLightsValue?0:1];
		};


		configOptions = [
							[keyBinds, ghostTap, noteOffset, scrollSpeed],
							[fpsCap, bgDim, useGPU, showFPS],
							[downscroll, centeredNotes, noteSplash, noteGlow, showMissesSetting, showAccuracyDisplay, comboDisplay, cacheSettings],
							[extraCamStuff, camBopStuff, captionsStuff, flashingLightsSettings, autoPauseSettings, hpGain, hpDrain]
						];

	}

	function resyncLayers():Void {
		songLayer.pause();
		FlxG.sound.music.play();
		songLayer.time = FlxG.sound.music.time;
		songLayer.play();
	}

	function saveMenuPosition():Void{
		startInSubMenu = curSelected;
		savedListPos = curListPosition;
		savedListOffset = curListStartOffset;
	}

}