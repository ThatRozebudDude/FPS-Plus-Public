package freeplay;

import modding.PolymodHandler;
import flixel.group.FlxSpriteGroup;
import openfl.filters.ShaderFilter;
import shaders.BlueFadeShader;
import shaders.ColorGradientShader;
import haxe.Json;
import transition.data.InstantTransition;
import sys.FileSystem;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.math.FlxMath;
import Highscore.SongStats;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import config.*;
import characterSelect.CharacterSelectState;

import title.TitleScreen;
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
import caching.*;

using StringTools;

@:hscriptClass
class ScriptedFreeplayState extends FreeplayState implements polymod.hscript.HScriptedClass{}

class FreeplayState extends MusicBeatState
{

	var bg:FlxSprite;
	var flash:FlxSprite;
	var cover:FlxSprite;
	var topBar:FlxSprite;
	var freeplayText:FlxText;
	var changeCharacterText:FlxText;
	var changeTabText:FlxText;
	var highscoreSprite:FlxSprite;
	var clearPercentSprite:FlxSprite;
	var scoreDisplay:DigitDisplay;
	var percentDisplay:DigitDisplay;
	var albumTitle:FlxSprite;
	var albumTitleShader:ColorGradientShader = new ColorGradientShader();
	var albumTitleColorDummy:FlxSprite = new FlxSprite();
	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	var difficulty:FlxSprite;
	var categoryTitle:FlxBitmapText;
	var miniArrowLeft:FlxSprite;
	var miniArrowRight:FlxSprite;
	var difficultyStars:DifficultyStars;

	var album:FlxSprite;
	var albumDummy:FlxObject;
	var albumTime:Float = 0;
	var curAlbum:String = "vol1";
	final ablumPeriod:Float = 1/24;
	var smoothAlbum:Bool = false;

	var variationBox:FlxSprite;
	var variationArrowLeft:FlxSprite;
	var variationArrowRight:FlxSprite;
	var variationName:FlxBitmapText;

	var capsuleGroup:FlxTypedSpriteGroup<Capsule> = new FlxTypedSpriteGroup<Capsule>();

	var categoryNames:Array<String> = [];
	var categoryMap:Map<String, Array<Capsule>> = new Map<String, Array<Capsule>>();

	var dj:DJCharacter;
	var backCardGroup:FlxSpriteGroup = new FlxSpriteGroup();

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;
	public static var curCategory:Int = 0;
	public static var curVariation:Int = 0;

	var textCycleCount:Int = 0;
	var categoryLockOutSoItStopsBreaking:Float = 0;

	public static var djCharacter:String = "BoyfriendFreeplay";

	var allowedDifficulties:Array<Int> = [0, 1, 2];

	var prevScore:Int;
	var prevAccuracy:Int;

	public static var playStickerIntro:Bool = false;

	var transitionOver:Bool = false;
	var waitForFirstUpdateToStart:Bool = true;
	var selectingMode:String = "song";

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var camTarget:FlxPoint = new FlxPoint();
	var versionText:FlxTextExt;

	var introAnimType:IntroAnimType;

	static var controllerMode:Bool = false;

	private var camMenu:FlxCamera;
	private var camFreeplay:FlxCamera;

	var fadeShader:BlueFadeShader = new BlueFadeShader(1);
	
	public static var curCharacterStickers:Array<String>;

	static final  transitionTime:Float = 1;
	static final  staggerTime:Float = 0.1;
	static final  randomVariation:Float = 0.04;
	static final  transitionEase:flixel.tweens.EaseFunction = FlxEase.quintOut;

	static final  transitionTimeExit:Float = 0.7;
	static final  staggerTimeExit:Float = 0.07;
	static final  randomVariationExit:Float = 0.03;
	static final  transitionEaseExit:flixel.tweens.EaseFunction = FlxEase.cubeIn;

	public function new(?_introAnimType:IntroAnimType = fromSongExit, ?camFollowPos:FlxPoint = null) {
		super();
		introAnimType = _introAnimType;
		if(camFollowPos == null){
			camFollowPos = new FlxPoint();
		}
		camFollow = new FlxObject(camFollowPos.x, camFollowPos.y, 1, 1);
	}

	override function create(){

		Config.setFramerate(144);

		countSteps = false;

		persistentUpdate = persistentDraw = true;

		if(introAnimType == fromMainMenu){
			if(FlxG.sound.music.playing){
				FlxG.sound.music.volume = 0;
			}
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}

		camMenu = new FlxCamera();
		camMenu.filters = [];

		camFreeplay = new FlxCamera();
		camFreeplay.bgColor.alpha = 0;
		camFreeplay.filters = [new ShaderFilter(fadeShader.shader)];

		FlxG.cameras.reset(camMenu);
		FlxG.cameras.add(camFreeplay, true);
		FlxG.cameras.setDefaultDrawTarget(camMenu, false);

		if(introAnimType == fromMainMenu){
			customTransIn = new transition.data.InstantTransition();
		}
		else if(introAnimType == fromCharacterSelect){
			customTransIn = new transition.data.ScreenWipeIn(riseTime, riseEase);
			fadeShader.fadeVal = 0;
			FlxTween.tween(fadeShader, {fadeVal: 1}, riseTime);
		}
		else if(introAnimType == fromSongWin || introAnimType == fromSongLose){
			customTransIn = new transition.data.StickerIn();
			playStickerIntro = false;
		}

		//DJ STUFF
		if(!ScriptableDJCharacter.listScriptClasses().contains(djCharacter)){
			djCharacter = "BoyfriendFreeplay";
		}
		dj = ScriptableDJCharacter.init(djCharacter);
		dj.setup();
		dj.introFinish = djIntroFinish;
		dj.cameras = [camFreeplay];
		curCharacterStickers = dj.freeplayStickers;

		fakeMainMenuSetup();

		createSongList();

		super.create();
	} 



	override function update(elapsed:Float){

		if(waitForFirstUpdateToStart){
			createFreeplayStuff();
			waitForFirstUpdateToStart = false;
		}

		if(FlxG.sound.music.playing){
			Conductor.songPosition = FlxG.sound.music.time;
		}

		albumTime += elapsed;
		if(albumTime >= ablumPeriod || smoothAlbum){
			albumTime = 0;
			album.setPosition(albumDummy.x, albumDummy.y);
			album.angle = albumDummy.angle;
		}

		if(transitionOver){
			switch(selectingMode){
				case "song":
					if(Binds.justPressed("menuUp")){
						changeSelected(-1);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					else if(Binds.justPressed("menuDown")){
						changeSelected(1);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
		
					if(Binds.justPressed("menuLeft")){
						changeDifficulty(-1);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					else if(Binds.justPressed("menuRight")){
						changeDifficulty(1);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
		
					if(categoryLockOutSoItStopsBreaking > 0.25){
						if(Binds.justPressed("menuCycleLeft")){
							changeCategory(-1);
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if(Binds.justPressed("menuCycleRight")){
							changeCategory(1);
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
					}
					else{
						categoryLockOutSoItStopsBreaking += elapsed;
					}
					
		
					if(Binds.justPressed("menuAccept")){
						if(categoryMap[categoryNames[curCategory]][curSelected].variations.length > 1){
							openVariationPopup();
						}
						else{
							songAccept();
						}
					}
			
					for(i in 0...categoryMap[categoryNames[curCategory]].length){
						updateCapsulePosition(i);
					}
			
					if(Binds.pressed("menuLeft")){ arrowLeft.scale.set(0.8, 0.8); }
					else{ arrowLeft.scale.set(1, 1); }
			
					if(Binds.pressed("menuRight")){ arrowRight.scale.set(0.8, 0.8); }
					else{ arrowRight.scale.set(1, 1); }
		
					if(Binds.pressed("menuCycleLeft")){ miniArrowLeft.scale.set(0.6, 0.6); }
					else{ miniArrowLeft.scale.set(1, 1); }
			
					if(Binds.pressed("menuCycleRight")){ miniArrowRight.scale.set(0.6, 0.6); }
					else{ miniArrowRight.scale.set(1, 1); }
			
					if(Binds.justPressed("menuBack")){
						transitionOver = false;
						FlxG.sound.play(Paths.sound('cancelMenu'));
						FlxG.sound.music.fadeOut(0.5, 0, function(t) {
							FlxG.sound.music.stop();
						});
						exitAnimation();
						customTransOut = new InstantTransition();
						MainMenuState.fromFreeplay = true;
						ImageCache.keepCache = true;
						new FlxTimer().start(transitionTimeExit + (staggerTimeExit*4), function(t) {
							switchState(new MainMenuState());
						});
					}
		
					if(Binds.justPressed("menuChangeCharacter")){
						transitionOver = false;
						dj.toCharacterSelect();
						customTransOut = new transition.data.ScreenWipeOutFlipped(dropTime, dropEase);
		
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.sound.music.pitch = 1;
						FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4, {ease: FlxEase.quadOut, onComplete: function(t){
							FlxG.sound.music.fadeOut(0.05);
						}});
		
						new FlxTimer().start(0.25, function(t) {
							toCharSelectAnimation();
							curSelected = 0;
							curCategory = 0;
		
							new FlxTimer().start(0.1, function(t) {
								fadeShader.fadeVal = 1;
								FlxTween.tween(fadeShader, {fadeVal: 0}, dropTime);
								switchState(new CharacterSelectState());
							});
						});
					}
		
					
				case "variation":
					if(Binds.justPressed("menuLeft")){
						changeVariation(-1);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					else if(Binds.justPressed("menuRight")){
						changeVariation(1);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}

					if(Binds.justPressed("menuAccept")){
						PlayState.overrideInsturmental = categoryMap[categoryNames[curCategory]][curSelected].variations[curVariation];
						closeVariationPopup();
						songAccept();
					}
					else if(Binds.justPressed("menuBack")){
						closeVariationPopup();
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}

					if(Binds.pressed("menuLeft")){ variationArrowLeft.scale.set(1.6, 1.6); }
					else{ variationArrowLeft.scale.set(2, 2); }
			
					if(Binds.pressed("menuRight")){ variationArrowRight.scale.set(1.6, 1.6); }
					else{ variationArrowRight.scale.set(2, 2); }
			}
		}

		//big if
		if(Binds.justPressed("menuUp")||Binds.justPressed("menuDown")||Binds.justPressed("menuLeft")||Binds.justPressed("menuRight")||Binds.justPressed("menuCycleLeft")||Binds.justPressed("menuCycleRight")){
			pressedAnything();
		}

		//update change character text
		if(FlxG.keys.anyPressed([ANY]) && controllerMode){
			updateChangeCharacterText(false);
			controllerMode = false;
		}
		else if(FlxG.gamepads.anyJustPressed(ANY) && !controllerMode){
			updateChangeCharacterText(true);
			controllerMode = true;
		}
		
		camFollow.x = Utils.fpsAdjustedLerp(camFollow.x, camTarget.x, MainMenuState.lerpSpeed, 144);
		camFollow.y = Utils.fpsAdjustedLerp(camFollow.y, camTarget.y, MainMenuState.lerpSpeed, 144);

		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload();
		}

		super.update(elapsed);

	}

	override function beatHit() {
		dj.beat(curBeat);
		super.beatHit();
	}

	function pressedAnything():Void{
		dj.buttonPress();
	}



	function createFreeplayStuff():Void{
		
		bg = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/leftSlide'));
		bg.color = 0xFFFFCCCC;
		bg.antialiasing = true;

		flash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		flash.scale.set(1280, 720);
		flash.updateHitbox();
		flash.alpha = 0;
		flash.visible = false;

		cover = new FlxSprite(1280).loadGraphic(getImagePathWithSkin('menu/freeplay/covers/dad'));
		cover.x -= cover.width;
		cover.antialiasing = true;

		topBar = new FlxSprite(0, -120).makeGraphic(1, 1, 0xFF000000);
		topBar.scale.set(1280, (topBar.y * Utils.sign(topBar.y)) + 64);
		topBar.updateHitbox();

		freeplayText = new FlxTextExt(16, 16, 0, "FREEPLAY", 32);
		freeplayText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE);

		changeCharacterText = new FlxTextExt(16, 16, 0, "[BUTTON] to Change Character", 32);
		changeCharacterText.setFormat(Paths.font("vcr"), 32, 0xFF7F7F7F);
		changeCharacterText.screenCenter(X);
		changeCharacterText.visible = false;

		changeTabText = new FlxTextExt(16, 16, 0, "[BUTTON] & [BUTTON] to Change Tabs", 32);
		changeTabText.setFormat(Paths.font("vcr"), 32, 0xFF7F7F7F);
		changeTabText.screenCenter(X);
		changeTabText.visible = false;

		updateChangeCharacterText(controllerMode);

		highscoreSprite = new FlxSprite(860, 70);
		highscoreSprite.frames = getSparrowPathWithSkin("menu/freeplay/highscore");
		highscoreSprite.animation.addByPrefix("loop", "", 24, true);
		highscoreSprite.animation.play("loop");
		highscoreSprite.antialiasing = true;

		clearPercentSprite = new FlxSprite(1165, 65).loadGraphic(getImagePathWithSkin('menu/freeplay/clearBox'));
		clearPercentSprite.antialiasing = true;

		scoreDisplay = new DigitDisplay(915, 120, getImageStringWithSkin("menu/freeplay/digital_numbers"), 7, 0.4, -25);
		scoreDisplay.setDigitOffset("1", 20);
		scoreDisplay.ease = FlxEase.cubeOut;

		percentDisplay = new DigitDisplay(1154, 87, getImageStringWithSkin("menu/freeplay/clearText"), 3, 1, 3, 0, true);
		percentDisplay.setDigitOffset("1", -8);
		percentDisplay.ease = FlxEase.quadOut;

		albumDummy = new FlxObject(950, 285, 1, 1);
		albumDummy.angle = 10;
		album = new FlxSprite(albumDummy.x, albumDummy.y).loadGraphic(Paths.image("menu/freeplay/album/vol1/album"));
		album.antialiasing = true;
		album.angle = albumDummy.angle;
		
		albumTitle = new FlxSprite(album.x - 5, album.y + 205).loadGraphic(Paths.image("menu/freeplay/album/vol1/title"));
		albumTitle.antialiasing = true;
		albumTitle.shader = albumTitleShader.shader;

		arrowLeft = new FlxSprite(20, 70);
		arrowLeft.frames = getSparrowPathWithSkin("menu/freeplay/freeplaySelector");
		arrowLeft.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
		arrowLeft.animation.play("loop");
		arrowLeft.antialiasing = true;

		arrowRight = new FlxSprite(325, 70);
		arrowRight.frames = getSparrowPathWithSkin("menu/freeplay/freeplaySelector");
		arrowRight.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
		arrowRight.animation.play("loop");
		arrowRight.flipX = true;
		arrowRight.antialiasing = true;

		difficulty = new FlxSprite(197, 115).loadGraphic(getImagePathWithSkin("menu/freeplay/diff/" + diffNumberToDiffName(curDifficulty)));
		difficulty.offset.set(difficulty.width/2, difficulty.height/2);
		difficulty.antialiasing = true;

		categoryTitle = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/resultFont"), Utils.resultsTextCharacters, FlxPoint.get(49, 62)));
		categoryTitle.text = categoryNames[curCategory];
		categoryTitle.letterSpacing = -15;
		categoryTitle.screenCenter(X);
		categoryTitle.y = 85;
		categoryTitle.antialiasing = true;

		miniArrowLeft = new FlxSprite(categoryTitle.x, categoryTitle.y + categoryTitle.height/2).loadGraphic(getImagePathWithSkin("menu/freeplay/miniArrow"));
		miniArrowLeft.x -= miniArrowLeft.width;
		miniArrowLeft.y -= miniArrowLeft.height/2;
		miniArrowLeft.y -= 7;
		miniArrowLeft.x -= 20;
		miniArrowLeft.flipX = true;
		miniArrowLeft.antialiasing = true;

		miniArrowRight = new FlxSprite(categoryTitle.x + categoryTitle.width, categoryTitle.y + categoryTitle.height/2).loadGraphic(getImagePathWithSkin("menu/freeplay/miniArrow"));
		miniArrowRight.y -= miniArrowRight.height/2;
		miniArrowRight.x += 20;
		miniArrowRight.y -= 7;
		miniArrowRight.antialiasing = true;

		difficultyStars = new DifficultyStars(953, 237);

		variationBox = new FlxSprite().makeGraphic(480, 150, 0xFF000000);
		variationBox.antialiasing = true;
		variationBox.screenCenter();
		variationBox.visible = false;

		variationArrowLeft = new FlxSprite(variationBox.x, variationBox.y + variationBox.height/2).loadGraphic(getImagePathWithSkin("menu/freeplay/miniArrow"));
		variationArrowLeft.scale.set(2, 2);
		variationArrowLeft.updateHitbox();
		variationArrowLeft.y -= variationArrowLeft.height/2;
		variationArrowLeft.x += 15;
		variationArrowLeft.flipX = true;
		variationArrowLeft.antialiasing = true;
		variationArrowLeft.blend = ADD;
		variationArrowLeft.visible = false;

		variationArrowRight = new FlxSprite(variationBox.x + variationBox.width, variationBox.y + variationBox.height/2).loadGraphic(getImagePathWithSkin("menu/freeplay/miniArrow"));
		variationArrowRight.scale.set(2, 2);
		variationArrowRight.updateHitbox();
		variationArrowRight.y -= variationArrowRight.height/2;
		variationArrowRight.x -= variationArrowRight.width;
		variationArrowRight.x -= 15;
		variationArrowRight.antialiasing = true;
		variationArrowRight.blend = ADD;
		variationArrowRight.visible = false;

		variationName = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/resultFont"), Utils.resultsTextCharacters, FlxPoint.get(49, 62)));
		variationName.text = "Original";
		variationName.letterSpacing = -15;
		variationName.antialiasing = true;
		variationName.blend = ADD;
		variationName.setPosition(variationBox.getMidpoint().x, variationBox.getMidpoint().y - 23);
		variationName.x -= variationName.width/2;
		variationName.visible = false;

		switch(introAnimType){
			case fromMainMenu | fromCharacterSelect:
				dj.playIntro();
			case fromSongWin:
				dj.playCheer(false);
			case fromSongLose:
				dj.playCheer(true);
			default:
				dj.playIdle();
		}

		//ADDING STUFF
		add(bg);
		
		add(backCardGroup);

		add(flash);

		add(dj);

		add(cover);

		add(highscoreSprite);
		add(clearPercentSprite);
		add(scoreDisplay);
		add(percentDisplay);

		add(album);
		add(albumTitle);
		add(difficultyStars);

		add(capsuleGroup);

		add(arrowLeft);
		add(arrowRight);
		add(difficulty);

		add(miniArrowLeft);
		add(miniArrowRight);
		add(categoryTitle);
		
		add(topBar);
		add(freeplayText);
		add(changeCharacterText);
		add(changeTabText);

		addCapsules();

		add(variationBox);
		add(variationName);
		add(variationArrowLeft);
		add(variationArrowRight);

		calcAvailableDifficulties();
		updateScore();
		updateAlbum(false);
		updateSongDifficulty();

		if(introAnimType == fromMainMenu){
			enterAnimation();
		}
		else if(introAnimType == fromCharacterSelect){
			fromCharSelectAnimation();
		}
		else{
			djIntroFinish();
		}

	}

	function fakeMainMenuSetup():Void{
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.cameras = [camMenu];
		add(bg);

		add(camFollow);

		camMenu.follow(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');

		for (i in 0...MainMenuState.optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = Paths.getSparrowAtlas("menu/main/" + MainMenuState.optionShit[i]);
			
			menuItem.animation.addByPrefix('idle', "idle", 24);
			menuItem.animation.addByPrefix('selected', "selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.cameras = [camMenu];
		}

		versionText = new FlxTextExt(5, FlxG.height - 21, 0, "FPS Plus: v" + MainMenuState.VERSION + " | Mod API: v" + PolymodHandler.API_VERSION_STRING, 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.cameras = [camMenu];
		add(versionText);

		if(MainMenuState.SHOW_BUILD_INFO){
			versionText.text = "FPS Plus: v" + MainMenuState.VERSION + " " + MainMenuState.NONFINAL_TAG + " | Mod API: v" + PolymodHandler.API_VERSION_STRING;

			var buildInfoText = new FlxTextExt(1280 - 5, FlxG.height - 37, 0, "Build Date: " + MainMenuState.buildDate + "\n" + GitCommit.getGitBranch() +  " (" + GitCommit.getGitCommitHash() + ")", 16);
			buildInfoText.scrollFactor.set();
			buildInfoText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			buildInfoText.x -= buildInfoText.width;
			buildInfoText.cameras = [camMenu];
			add(buildInfoText);
		}

		menuItems.forEach(function(spr:FlxSprite){
			spr.animation.play('idle');
	
			if (spr.ID == 1){
				spr.animation.play('selected');
				camTarget.set(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				if(introAnimType != fromMainMenu){
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				}
			}
	
			spr.updateHitbox();
			spr.screenCenter(X);
		});
	}

	function djIntroFinish():Void{
		if(transitionOver){ return; }

		transitionOver = true;
		startFreeplaySong();

		//bg.visible = false;
		changeCharacterText.visible = true;
		changeCharacterText.alpha = 0;
		FlxTween.tween(changeCharacterText, {alpha: 1}, 2, {ease: FlxEase.sineInOut, type: PINGPONG, onComplete: function(t){
			progressTextCycle();
		}});
		
		changeTabText.alpha = 0;
		FlxTween.tween(changeTabText, {alpha: 1}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});

		backCardGroup.add(dj.backingCard);

		dj.backingCardStart();

		camFollow.x = camTarget.x;
		camFollow.y = camTarget.y;
	}
	
	function startFreeplaySong():Void{
		FlxG.sound.playMusic(Paths.music(dj.freeplaySong), dj.freeplaySongVolume);
		Conductor.changeBPM(dj.freeplaySongBpm);
		Conductor.songPosition = 0;
		countSteps = true;
	}

	function addSong(_song:String, _icon:String, ?categories:Array<String>):Void{

		var meta = Utils.defaultSongMetadata(_song.replace("-", " "));

		if(Utils.exists("assets/data/songs/" + _song.toLowerCase() + "/meta.json")){
			var jsonMeta = Json.parse(Utils.getText("assets/data/songs/" + _song.toLowerCase() + "/meta.json"));
			if(jsonMeta.name != null)				{ meta.name = jsonMeta.name; }
			if(jsonMeta.artist != null)				{ meta.artist = jsonMeta.artist; }
			if(jsonMeta.album != null)				{ meta.album = jsonMeta.album; }
			if(jsonMeta.difficulties != null)		{ meta.difficulties = jsonMeta.difficulties; }
			if(jsonMeta.dadBeats != null)			{ meta.dadBeats = jsonMeta.dadBeats; }
			if(jsonMeta.bfBeats != null)			{ meta.bfBeats = jsonMeta.bfBeats; }
			if(jsonMeta.compatableInsts != null)	{ meta.compatableInsts = jsonMeta.compatableInsts; }
			if(jsonMeta.mixName != null)			{ meta.mixName = jsonMeta.mixName; }
		}

		if(categories == null){ categories = ["All"]; }
		var capsule:Capsule = new Capsule(_song, meta.name, _icon, meta.album, meta.difficulties, meta.compatableInsts, [dj.freeplaySkin, dj.capsuleSelectColor, dj.capsuleDeselectColor, dj.capsuleSelectOutlineColor, dj.capsuleDeselectOutlineColor]);
		for(cat in categories){
			createCategory(cat);
			categoryMap[cat].push(capsule);
		}
	}

	function createCategory(name:String):Void{
		if(!categoryMap.exists(name)){
			categoryNames.push(name);
			categoryMap.set(name, []);
		}
	}

	function addCapsules():Void{
		for(capsule in capsuleGroup){
			FlxTween.cancelTweensOf(capsule);
		}
		capsuleGroup.clear();
		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			updateCapsulePosition(i);
			categoryMap[categoryNames[curCategory]][i].snapToTargetPos();
			categoryMap[categoryNames[curCategory]][i].showRank(curDifficulty);
			capsuleGroup.add(categoryMap[categoryNames[curCategory]][i]);
		}
	}

	function updateCapsulePosition(index:Int):Void{
		categoryMap[categoryNames[curCategory]][index].targetPos.x = categoryMap[categoryNames[curCategory]][index].intendedX(index - curSelected);
		categoryMap[categoryNames[curCategory]][index].targetPos.y = categoryMap[categoryNames[curCategory]][index].intendedY(index - curSelected);
	}

	function changeSelected(change:Int):Void{
		curSelected += change;
		if(curSelected < 0){
			curSelected = categoryMap[categoryNames[curCategory]].length-1;
			for(i in 0...categoryMap[categoryNames[curCategory]].length){
				FlxTween.cancelTweensOf(categoryMap[categoryNames[curCategory]][i]);
				categoryMap[categoryNames[curCategory]][i].xPositionOffset = 0;
			}
		}
		else if(curSelected >= categoryMap[categoryNames[curCategory]].length){
			curSelected = 0;
		}

		calcAvailableDifficulties();
		updateScore();
		updateAlbum();
		updateSongDifficulty();
	}

	function changeDifficulty(change:Int, ?doTween:Bool = true):Void{
		curDifficulty += change;
		if(curDifficulty < 0){
			curDifficulty = 2;
		}
		else if(curDifficulty > 2){
			curDifficulty = 0;
		}

		if(!allowedDifficulties.contains(curDifficulty)){
			changeDifficulty(Utils.sign(change));
			return;
		}

		updateDifficultyGraphic();
		updateSongDifficulty();

		if(doTween){
			FlxTween.cancelTweensOf(difficulty);
			difficulty.y = 115 - 15;
			FlxTween.tween(difficulty, {y: difficulty.y + 15}, 0.1, {ease: FlxEase.cubeOut});
		}

		for(capsule in capsuleGroup){
			capsule.showRank(curDifficulty);
			//capsule.deslect();
		}

		updateScore();
	}

	function changeVariation(change:Int):Void{
		curVariation += change;
		if(curVariation < 0){
			curVariation = categoryMap[categoryNames[curCategory]][curSelected].variations.length - 1;
		}
		else if(curVariation >= categoryMap[categoryNames[curCategory]][curSelected].variations.length){
			curVariation = 0;
		}

		var varMeta = Json.parse(Utils.getText("assets/data/songs/" + categoryMap[categoryNames[curCategory]][curSelected].variations[curVariation].toLowerCase() + "/meta.json"));
		if(varMeta.mixName != null){
			variationName.text = varMeta.mixName;
		}
		else{
			variationName.text = "Unnamed Mix";
		}

		variationName.setPosition(variationBox.getMidpoint().x, variationBox.getMidpoint().y - 23);
		variationName.x -= variationName.width/2;
	}

	function updateDifficultyGraphic():Void{
		var prefix = "";
		if(categoryMap[categoryNames[curCategory]][curSelected].song.endsWith("-Erect")){
			prefix = "erect/";
		}

		if(!Utils.exists(Paths.image("menu/freeplay/diff/" + prefix + diffNumberToDiffName(curDifficulty), true))){
			prefix = "";
		}

		if(Utils.exists(Paths.xml("menu/freeplay/diff/" + prefix + diffNumberToDiffName(curDifficulty)))){
			difficulty.frames = Paths.getSparrowAtlas("menu/freeplay/diff/" + prefix + diffNumberToDiffName(curDifficulty));
			difficulty.animation.addByPrefix("idle", "", 24, true);
			difficulty.animation.play("idle");
		}
		else{
			difficulty.loadGraphic(Paths.image("menu/freeplay/diff/" + prefix + diffNumberToDiffName(curDifficulty)));
		}

		difficulty.offset.set(difficulty.width/2, difficulty.height/2);
	}


	function changeCategory(change:Int):Void{
		curCategory += change;
		if(curCategory < 0){
			curCategory = categoryNames.length-1;
		}
		else if(curCategory >= categoryNames.length){
			curCategory = 0;
		}

		categoryTitle.text = categoryNames[curCategory];
		categoryTitle.screenCenter(X);

		FlxTween.completeTweensOf(categoryTitle);
		categoryTitle.y -= 15;
		FlxTween.tween(categoryTitle, {y: categoryTitle.y + 15}, 0.1, {ease: FlxEase.cubeOut});

		miniArrowLeft.x = categoryTitle.x;
		miniArrowLeft.x -= miniArrowLeft.width;
		miniArrowLeft.x -= 20;

		miniArrowRight.x = categoryTitle.x + categoryTitle.width;
		miniArrowLeft.x += 20;

		curSelected = 0;

		calcAvailableDifficulties();
		updateScore();
		updateAlbum();
		addCapsules();
		updateSongDifficulty();
		tweenCapsulesOnScreen(transitionTime/2, 0, staggerTime);
	}

	function updateScore():Void{
		var score:SongStats = categoryMap[categoryNames[curCategory]][curSelected].highscoreData[curDifficulty];

		if(prevScore != score.score){
			scoreDisplay.tweenNumber(score.score, 0.8);
			prevScore = score.score;
		}
		
		if(prevAccuracy != Math.floor(score.accuracy)){
			percentDisplay.tweenNumber(Math.floor(score.accuracy), 0.8);
			prevAccuracy = Math.floor(score.accuracy);
		}

		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			categoryMap[categoryNames[curCategory]][i].deslect();
			if(i == curSelected){
				categoryMap[categoryNames[curCategory]][i].select();
			}
		}
	}

	function updateAlbum(?doTween:Bool = true):Void{
		var newAlbum:String = categoryMap[categoryNames[curCategory]][curSelected].album;
		if(newAlbum != curAlbum){
			curAlbum = newAlbum;

			if(newAlbum == "none"){
				albumTitle.visible = false;
				newAlbum = "vol1";
			}
			else{ albumTitle.visible = true; }

			album.loadGraphic(Paths.image("menu/freeplay/album/" + newAlbum + "/album"));
			albumTitle.loadGraphic(Paths.image("menu/freeplay/album/" + newAlbum + "/title"));

			if(doTween){
				FlxTween.completeTweensOf(albumDummy);
				FlxTween.completeTweensOf(albumTitle);
				FlxTween.completeTweensOf(albumTitleColorDummy);
				albumDummy.y -= 15;
				albumTitle.y -= 20;
				FlxTween.tween(albumTitle, {y: albumTitle.y + 20}, 0.2, {ease: FlxEase.cubeOut});
				FlxTween.tween(albumDummy, {y: albumDummy.y + 15}, 0.1, {ease: FlxEase.cubeOut, onUpdate: function(t) {
					albumTime = ablumPeriod;
				}});
				FlxTween.color(albumTitleColorDummy, 0.2, 0xFF4B97F3, 0xFF000000, {ease: FlxEase.quadIn, onUpdate: function(t){
					albumTitleShader.blackColor = albumTitleColorDummy.color;
				}});
			}

			albumTitle.offset.x = (albumTitle.width - 234)/2;
		}
	}

	function updateSongDifficulty():Void{
		difficultyStars.setNumber(categoryMap[categoryNames[curCategory]][curSelected].difficulties[curDifficulty]);
	}

	function updateChangeCharacterText(controller:Bool = false):Void{
		if(!controller){
			if(Binds.binds.get("menuChangeCharacter").binds.length > 0){
				var key = Binds.binds.get("menuChangeCharacter").binds[0];
				changeCharacterText.text = "[" + Utils.keyToString(key) + "] to Change Character";
			}
			else{
				changeCharacterText.text = "Change Character not bound!";
			}
			changeCharacterText.screenCenter(X);
			
			if(Binds.binds.get("menuCycleLeft").binds.length > 0 && Binds.binds.get("menuCycleRight").binds.length > 0){
				var keyLeft = Binds.binds.get("menuCycleLeft").binds[0];
				var keyRight = Binds.binds.get("menuCycleRight").binds[0];
				changeTabText.text = "[" + Utils.keyToString(keyLeft) + "] & [" + Utils.keyToString(keyRight) + "] to Change Tabs";
			}
			else{
				changeTabText.text = "Cycle Left or Cycle Right not bound!";
			}
			changeTabText.screenCenter(X);
		}
		else{
			if(Binds.binds.get("menuChangeCharacter").controllerBinds.length > 0){
				var key = Binds.binds.get("menuChangeCharacter").controllerBinds[0];
				changeCharacterText.text = "[" + Utils.controllerButtonToString(key) + "] to Change Character";
			}
			else{
				changeCharacterText.text = "Change Character not bound!";
			}
			changeCharacterText.screenCenter(X);

			if(Binds.binds.get("menuCycleLeft").controllerBinds.length > 0 && Binds.binds.get("menuCycleRight").controllerBinds.length > 0){
				var keyLeft = Binds.binds.get("menuCycleLeft").controllerBinds[0];
				var keyRight = Binds.binds.get("menuCycleRight").controllerBinds[0];
				changeTabText.text = "[" + Utils.controllerButtonToString(keyLeft) + "] & [" + Utils.controllerButtonToString(keyRight) + "] to Change Tabs";
			}
			else{
				changeTabText.text = "Cycle Left or Cycle Right not bound!";
			}
			changeTabText.screenCenter(X);
		}
	}

	function progressTextCycle(){
		textCycleCount = (textCycleCount + 1) % 4;
		switch(textCycleCount){
			case 0 | 1:
				changeCharacterText.visible = true;
				changeTabText.visible = false;
			case 2 | 3:
				changeCharacterText.visible = false;
				changeTabText.visible = true;
		}
	}

	function calcAvailableDifficulties():Void{
		allowedDifficulties = [];
		var filesInDir = Utils.readDirectory("assets/data/songs/" + categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + "/");

		if(filesInDir.contains(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + "-easy.json")){ allowedDifficulties.push(0); }
		if(filesInDir.contains(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + ".json")){ allowedDifficulties.push(1); }
		if(filesInDir.contains(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + "-hard.json")){ allowedDifficulties.push(2); }

		if(!allowedDifficulties.contains(curDifficulty)){
			curDifficulty = 0;
			changeDifficulty(allowedDifficulties[0], false);
		}

		updateDifficultyGraphic();
	}

	function diffNumberToDiffName(diff:Int):String{
		switch(diff){
			case 0:
				return "easy";
			case 1:
				return "normal";
			case 2:
				return "hard";
		}
		return "normal";
	}

	function startSong():Void{
		var formattedSong:String = Highscore.formatSong(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase(), curDifficulty);
		PlayState.SONG = Song.loadFromJson(formattedSong, categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase());
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.loadEvents = true;
		PlayState.returnLocation = "freeplay";
		new FlxTimer().start(1.5, function(t){
			switchState(new PlayState());
			FlxG.sound.music.fadeOut(0.5);
		});
	}

	function songAccept():Void{
		transitionOver = false;
		dj.backingCardSelect();
		FlxG.sound.play(Paths.sound('confirmMenu'));
		dj.playConfirm();
		categoryMap[categoryNames[curCategory]][curSelected].confirm();
		startSong();
	}

	function openVariationPopup():Void{
		selectingMode = "variation";
		variationBox.visible = true;
		variationArrowLeft.visible = true;
		variationArrowRight.visible = true;
		variationName.visible = true;

		FlxTween.cancelTweensOf(variationBox);
		FlxTween.cancelTweensOf(variationBox.scale);
		FlxTween.cancelTweensOf(variationArrowLeft);
		FlxTween.cancelTweensOf(variationArrowRight);
		FlxTween.cancelTweensOf(variationName);

		variationBox.alpha = 0.6;
		variationBox.scale.set(1.05, 0.9);
		variationArrowLeft.alpha = 0.6;
		variationArrowRight.alpha = 0.6;
		variationName.alpha = 0.6;
		
		FlxTween.tween(variationBox, {alpha: 1}, 0.4, {ease: FlxEase.expoOut});
		FlxTween.tween(variationBox.scale, {x: 1, y: 1}, 0.6, {ease: FlxEase.elasticOut});
		FlxTween.tween(variationArrowLeft, {alpha: 1}, 0.4, {ease: FlxEase.expoOut});
		FlxTween.tween(variationArrowRight, {alpha: 1}, 0.4, {ease: FlxEase.expoOut});
		FlxTween.tween(variationName, {alpha: 1}, 0.4, {ease: FlxEase.expoOut});

		curVariation = 0;
		changeVariation(0);
		
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function closeVariationPopup():Void{
		selectingMode = "song";

		FlxTween.cancelTweensOf(variationBox);
		//FlxTween.cancelTweensOf(variationBox.scale);
		FlxTween.cancelTweensOf(variationArrowLeft);
		FlxTween.cancelTweensOf(variationArrowRight);
		FlxTween.cancelTweensOf(variationName);
		
		FlxTween.tween(variationBox, {alpha: 0.4}, 2/24, {ease: FlxEase.quadOut});
		//FlxTween.tween(variationBox.scale, {x: 1, y: 1}, 0.6, {ease: FlxEase.elasticOut});
		FlxTween.tween(variationArrowLeft, {alpha: 0.4}, 2/24, {ease: FlxEase.expoOut});
		FlxTween.tween(variationArrowRight, {alpha: 0.4}, 2/24, {ease: FlxEase.expoOut});
		FlxTween.tween(variationName, {alpha: 0.4}, 2/24, {ease: FlxEase.expoOut, onComplete: function(t){
			variationBox.visible = false;
			variationArrowLeft.visible = false;
			variationArrowRight.visible = false;
			variationName.visible = false;
		}});
	}

	function tweenCapsulesOnScreen(_transitionTime:Float, _randomVariation:Float, _staggerTime:Float, ?_distance:Float = 1200):Void{
		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			FlxTween.cancelTweensOf(categoryMap[categoryNames[curCategory]][i]);
			categoryMap[categoryNames[curCategory]][i].xPositionOffset = _distance;
			categoryMap[categoryNames[curCategory]][i].snapToTargetPos();
			FlxTween.tween(categoryMap[categoryNames[curCategory]][i], {xPositionOffset: 0}, _transitionTime + FlxG.random.float(-_randomVariation, _randomVariation), {ease: transitionEase, startDelay: Math.max((_staggerTime/4) * (i+1-curSelected), 0) });
		}
	}

	function tweenCapsulesOffScreen(_transitionTime:Float, _randomVariation:Float, _staggerTime:Float, ?_distance:Float = 1800):Void{
		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			FlxTween.cancelTweensOf(categoryMap[categoryNames[curCategory]][i]);
			FlxTween.tween(categoryMap[categoryNames[curCategory]][i], {xPositionOffset: _distance}, _transitionTime + FlxG.random.float(-_randomVariation, _randomVariation), {ease: transitionEaseExit, startDelay: Math.max((_staggerTime/4) * (i+1-curSelected), 0) });
		}
	}

	function enterAnimation():Void{
		bg.x -= 1280;
		cover.x += 1280;
		topBar.y -= 720;
		freeplayText.y -= 720;
		highscoreSprite.x += 1280;
		clearPercentSprite.x += 1280;
		scoreDisplay.x += 1280;
		percentDisplay.x += 1280;
		albumTitle.x += 1280;
		arrowLeft.y -= 720;
		arrowRight.y -= 720;
		difficulty.y -= 720;
		categoryTitle.y -= 720;
		miniArrowRight.y -= 720;
		miniArrowLeft.y -= 720;

		var albumPos = albumDummy.x;
		albumDummy.x = 1280;
		albumDummy.angle = 70;
		album.x = albumDummy.x;
		album.angle = albumDummy.angle;

		FlxTween.tween(bg, {x: bg.x+1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
		FlxTween.tween(cover, {x: cover.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
		FlxTween.tween(topBar, {y: topBar.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
		FlxTween.tween(freeplayText, {y: freeplayText.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
		FlxTween.tween(highscoreSprite, {x: highscoreSprite.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
		FlxTween.tween(clearPercentSprite, {x: clearPercentSprite.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
		FlxTween.tween(scoreDisplay, {x: scoreDisplay.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*3});
		FlxTween.tween(percentDisplay, {x: percentDisplay.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
		FlxTween.tween(albumDummy, {x: albumPos, angle: 10}, transitionTime/1.1 + FlxG.random.float(-randomVariation, randomVariation), {ease: albumElasticOut});
		FlxTween.tween(albumTitle, {x: albumTitle.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
		FlxTween.tween(arrowLeft, {y: arrowLeft.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
		FlxTween.tween(arrowRight, {y: arrowRight.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
		FlxTween.tween(difficulty, {y: difficulty.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
		FlxTween.tween(categoryTitle, {y: categoryTitle.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
		FlxTween.tween(miniArrowLeft, {y: miniArrowLeft.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
		FlxTween.tween(miniArrowRight, {y: miniArrowRight.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});

		difficultyStars.tweenIn(transitionTime, 0, transitionEase, staggerTime*2);
		tweenCapsulesOnScreen(transitionTime, 0, staggerTime);
	}

	function exitAnimation():Void{
		//bg.visible = true;
		backCardGroup.remove(dj.backingCard);

		FlxTween.tween(bg, {x: bg.x-1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(cover, {x: cover.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(dj, {x: dj.x-1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(topBar, {y: topBar.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(freeplayText, {y: freeplayText.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(changeCharacterText, {y: changeCharacterText.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(changeTabText, {y: changeTabText.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(highscoreSprite, {x: highscoreSprite.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*2});
		FlxTween.tween(clearPercentSprite, {x: clearPercentSprite.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(scoreDisplay, {x: scoreDisplay.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*0});
		FlxTween.tween(percentDisplay, {x: percentDisplay.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(albumDummy, {x: 1380, angle: 70}, transitionTimeExit/1.1 + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: albumElasticOut, startDelay: staggerTimeExit*3});
		FlxTween.tween(albumTitle, {x: albumTitle.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*2});
		FlxTween.tween(arrowLeft, {y: arrowLeft.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(arrowRight, {y: arrowRight.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(difficulty, {y: difficulty.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*2});
		FlxTween.tween(categoryTitle, {y: categoryTitle.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*2});
		FlxTween.tween(miniArrowLeft, {y: miniArrowLeft.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(miniArrowRight, {y: miniArrowRight.y-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		
		difficultyStars.tweenOut(transitionTimeExit, 0, transitionEaseExit, staggerTimeExit);
		tweenCapsulesOffScreen(transitionTimeExit, 0, staggerTimeExit);

		FlxTween.completeTweensOf(flash);
		flash.alpha = 1;
		flash.visible = true;
		FlxTween.tween(flash, {alpha: 0}, 0.5, {startDelay: 0.1});
	}

	final dropTime:Float = 0.8;
	final dropEase:Null<EaseFunction> = FlxEase.backIn;
	function toCharSelectAnimation():Void{
		smoothAlbum = true;

		for(cap in capsuleGroup){ cap.doLerp = false; }
		
		FlxTween.tween(dj, {y: dj.y-175}, dropTime, {ease: dropEase, startDelay: 0.1});
		//FlxTween.tween(dj.backingCard, {y: dj.backingCard.y-100}, dropTime, {ease: dropEase, startDelay: 0.1});
		//FlxTween.tween(cover, {y: cover.y-100}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(difficulty, {y: difficulty.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(arrowLeft, {y: arrowLeft.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(arrowRight, {y: arrowRight.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(topBar, {y: topBar.y-300}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(freeplayText, {y: freeplayText.y-300}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(changeCharacterText, {y: changeCharacterText.y-300}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(changeTabText, {y: changeTabText.y-300}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(categoryTitle, {y: categoryTitle.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(miniArrowLeft, {y: miniArrowLeft.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(miniArrowRight, {y: miniArrowRight.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(highscoreSprite, {y: highscoreSprite.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(clearPercentSprite, {y: clearPercentSprite.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(scoreDisplay, {y: scoreDisplay.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(percentDisplay, {y: percentDisplay.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(albumDummy, {y: albumDummy.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(albumTitle, {y: albumTitle.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(difficultyStars, {y: difficultyStars.y-270}, dropTime, {ease: dropEase, startDelay: 0.1});
		FlxTween.tween(capsuleGroup, {y: capsuleGroup.y-250}, dropTime, {ease: dropEase, startDelay: 0.1});
	}

	final riseTime:Float = 0.8;
	final riseEase:Null<EaseFunction> = FlxEase.expoOut;
	function fromCharSelectAnimation():Void{
		smoothAlbum = true;

		for(cap in capsuleGroup){ cap.doLerp = false; }

		dj.y -= 175;
		//dj.backingCard.y -= 100;
		//cover.y -= 100;
		difficulty.y -= 270;
		arrowLeft.y -= 270;
		arrowRight.y -= 270;
		topBar.y -= 300;
		freeplayText.y -= 300;
		changeCharacterText.y -= 300;
		changeTabText.y -= 300;
		categoryTitle.y -= 270;
		miniArrowLeft.y -= 270;
		miniArrowRight.y -= 270;
		highscoreSprite.y -= 270;
		clearPercentSprite.y -= 270;
		scoreDisplay.y -= 270;
		percentDisplay.y -= 270;
		albumDummy.y -= 270;
		albumTitle.y -= 270;
		difficultyStars.y -= 270;
		capsuleGroup.y -= 250;
		
		FlxTween.tween(dj, {y: dj.y+175}, riseTime, {ease: riseEase, startDelay: 0.1});
		//FlxTween.tween(dj.backingCard, {y: dj.backingCard.y+100}, riseTime, {ease: riseEase, startDelay: 0.1});
		//FlxTween.tween(cover, {y: cover.y+100}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(difficulty, {y: difficulty.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(arrowLeft, {y: arrowLeft.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(arrowRight, {y: arrowRight.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(topBar, {y: topBar.y+300}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(freeplayText, {y: freeplayText.y+300}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(changeCharacterText, {y: changeCharacterText.y+300}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(changeTabText, {y: changeTabText.y+300}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(categoryTitle, {y: categoryTitle.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(miniArrowLeft, {y: miniArrowLeft.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(miniArrowRight, {y: miniArrowRight.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(highscoreSprite, {y: highscoreSprite.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(clearPercentSprite, {y: clearPercentSprite.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(scoreDisplay, {y: scoreDisplay.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(percentDisplay, {y: percentDisplay.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(albumDummy, {y: albumDummy.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(albumTitle, {y: albumTitle.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(difficultyStars, {y: difficultyStars.y+270}, riseTime, {ease: riseEase, startDelay: 0.1});
		FlxTween.tween(capsuleGroup, {y: capsuleGroup.y+250}, riseTime, {ease: riseEase, startDelay: 0.1, onComplete: function(t){
			for(cap in capsuleGroup){ cap.doLerp = true; }
			smoothAlbum = false;
		}});
	}

	inline function albumElasticOut(t:Float):Float{
		var ELASTIC_AMPLITUDE:Float = 1;
		var ELASTIC_PERIOD:Float = 0.6;
		return (ELASTIC_AMPLITUDE * Math.pow(2, -10 * t) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD) + 1);
	}

	inline function getImageStringWithSkin(path:String):Dynamic{
		var image:String = path;
		if(path.contains("menu/freeplay/")){
			image = image.split("menu/freeplay/")[1];
		}
		if(Utils.exists(Paths.image("menu/freeplay/skins/" + dj.freeplaySkin + "/" + image, true))){
			path = "menu/freeplay/skins/" + dj.freeplaySkin + "/" + image;
		}
		return path;
	}

	inline function getImagePathWithSkin(path:String):Dynamic{
		var image:String = path;
		if(path.contains("menu/freeplay/")){
			image = image.split("menu/freeplay/")[1];
		}
		if(Utils.exists(Paths.image("menu/freeplay/skins/" + dj.freeplaySkin + "/" + image, true))){
			path = "menu/freeplay/skins/" + dj.freeplaySkin + "/" + image;
		}
		return Paths.image(path, true);
	}

	inline function getSparrowPathWithSkin(path:String):flixel.graphics.frames.FlxAtlasFrames{
		var image:String = path;
		if(path.contains("menu/freeplay/")){
			image = image.split("menu/freeplay/")[1];
		}
		if(Utils.exists(Paths.image("menu/freeplay/skins/" + dj.freeplaySkin + "/" + image, true))){
			path = "menu/freeplay/skins/" + dj.freeplaySkin + "/" + image;
		}
		return Paths.getSparrowAtlas(path);
	}

	function createSongList():Void{

		var freeplayCategories:Array<String> = [];
		var freeplaySongs:Array<Array<Dynamic>> = [];

		//Load freeplay song list from json.
		if(Utils.exists(Paths.json("songList-" + dj.listSuffix, "data/freeplay"))){
			var json = Json.parse(Utils.getText(Paths.json("songList-" + dj.listSuffix, "data/freeplay")));

			if(json.categories != null){
				for(i in 0...json.categories.length){
					if(!freeplayCategories.contains(json.categories[i])){
						freeplayCategories.push(json.categories[i]);
					}
				}
			}

			for(i in 0...json.songs.length){
				if(json.songs[i].insert == null){
					freeplaySongs.push([json.songs[i].song, json.songs[i].icon, json.songs[i].categories]);
					for(j in 0...json.songs[i].categories.length){
						if(!freeplayCategories.contains(json.songs[j].categories[j])){
							freeplayCategories.push(json.songs[j].categories[j]);
						}
					}
				}
				else{
					var index:Int = freeplaySongs.length;
					for(j in 0...freeplaySongs.length){
						if(freeplaySongs[j][0] == json.songs[i].insert.value){
							index = j + (json.songs[i].insert.type == "after" ? 1 : 0);
							break;
						}
					}
					freeplaySongs.insert(index, [json.songs[i].song, json.songs[i].icon, json.songs[i].categories]);
					for(j in 0...json.songs[i].categories.length){
						if(!freeplayCategories.contains(json.songs[j].categories[j])){
							freeplayCategories.push(json.songs[j].categories[j]);
						}
					}
				}
			}
		}

		//Support deprecated format because I am very benevolent.
		if(Utils.exists(Paths.text("songList-" + dj.listSuffix, "data/freeplay"))){
			var deprecatedText:Array<String> = Utils.getTextInLines(Paths.text("songList-" + dj.listSuffix, "data/freeplay"));

			//Create categories first
			for(line in deprecatedText){
				line = line.trim();
				if(line.startsWith("category")){
					var categoryName = line.split("|")[1].trim();
					if(!freeplayCategories.contains(categoryName)){
						freeplayCategories.push(categoryName);
					}
				}
			}

			//Then add songs
			for(line in deprecatedText){
				if(line.startsWith("song")){
					var parts:Array<String> = line.split("|");
					var name:String = parts[1].trim();
					var icon:String = parts[2].trim();
					var fullArrayString:String = parts[3].trim();

					var categoryArray:Array<String> = fullArrayString.split(",");
					for(i in 0...categoryArray.length){
						if(i == 0){ categoryArray[i] = categoryArray[i].substring(1); }
						if(i == categoryArray.length-1){ categoryArray[i] = categoryArray[i].substring(0, categoryArray[i].length-1); }
						categoryArray[i] = categoryArray[i].trim();
					}
					
					freeplaySongs.push([name, icon, categoryArray]);
					for(cat in categoryArray){
						if(!freeplayCategories.contains(cat)){
							freeplayCategories.push(cat);
						}
					}
				}
			}
		}

		for(cat in freeplayCategories){
			createCategory(cat);
		}

		for(song in freeplaySongs){
			addSong(song[0], song[1], song[2]);
		}
		
	}
}

enum IntroAnimType {
	fromMainMenu;
	fromCharacterSelect;
	fromSongExit;
	fromSongWin;
	fromSongLose;
}