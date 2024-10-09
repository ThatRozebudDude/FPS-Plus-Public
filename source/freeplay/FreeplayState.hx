package freeplay;

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

using StringTools;

class FreeplayState extends MusicBeatState
{

	var bg:FlxSprite;
	var flash:FlxSprite;
	var cover:FlxSprite;
	var topBar:FlxSprite;
	var freeplayText:FlxText;
	var changeCharacterText:FlxText;
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

	var capsuleGroup:FlxTypedSpriteGroup<Capsule> = new FlxTypedSpriteGroup<Capsule>();

	var categoryNames:Array<String> = [];
	var categoryMap:Map<String, Array<Capsule>> = new Map<String, Array<Capsule>>();

	var dj:DJCharacter;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;
	public static var curCategory:Int = 0;

	public static var djCharacter:String = "Boyfriend";

	var allowedDifficulties:Array<Int> = [0, 1, 2];

	var prevScore:Int;
	var prevAccuracy:Int;

	public static var playStickerIntro:Bool = false;

	var transitionOver:Bool = false;
	var waitForFirstUpdateToStart:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var camTarget:FlxPoint = new FlxPoint();
	var versionText:FlxTextExt;

	var introAnimType:IntroAnimType;

	static var controllerMode:Bool = false;

	private var camMenu:FlxCamera;
	private var camCard:FlxCamera;
	private var camFreeplay:FlxCamera;

	var fadeShader:BlueFadeShader = new BlueFadeShader(1);

	static final freeplaySong:String = "freeplayRandom"; 
	static final freeplaySongBpm:Float = 145; 
	static final freeplaySongVolume:Float = 0.8; 

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

		persistentUpdate = persistentDraw = true;

		if(introAnimType == fromMainMenu){
			if(FlxG.sound.music.playing){
				FlxG.sound.music.volume = 0;
			}
			//FlxG.sound.play(Paths.sound("freeplay/recordStop"));
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}

		camMenu = new FlxCamera();

		camCard = new FlxCamera();
		camCard.bgColor.alpha = 0;
		camCard.filters = [new ShaderFilter(fadeShader.shader)];

		camFreeplay = new FlxCamera();
		camFreeplay.bgColor.alpha = 0;
		camFreeplay.filters = [new ShaderFilter(fadeShader.shader)];

		FlxG.cameras.reset(camMenu);
		FlxG.cameras.add(camCard, false);
		FlxG.cameras.add(camFreeplay, true);
		FlxG.cameras.setDefaultDrawTarget(camMenu, false);

		if(introAnimType == fromMainMenu){
			customTransIn = new transition.data.InstantTransition();
		}
		else if(introAnimType == fromCharacterSelect){
			customTransIn = new transition.data.ScreenWipeInFlipped(0.6);
			fadeShader.fadeVal = 0;
			FlxTween.tween(fadeShader, {fadeVal: 1}, 0.8);
		}
		else if(introAnimType == fromSongWin || introAnimType == fromSongLose){
			customTransIn = new transition.data.StickerIn();
			playStickerIntro = false;
		}

		//DJ STUFF
		var djClass = Type.resolveClass("freeplay.characters." + djCharacter);
		if(djClass == null){ djClass = freeplay.characters.Boyfriend; }
		dj = Type.createInstance(djClass, []);
		dj.introFinish = djIntroFinish;
		dj.cameras = [camFreeplay];

		fakeMainMenuSetup();

		for(cat in dj.freeplayCategories){
			createCategory(cat);
		}

		for(song in dj.freeplaySongs){
			addSong(song[0], song[1], song[2], song[3]);
		}

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
		if(albumTime >= ablumPeriod){
			albumTime = 0;
			album.setPosition(albumDummy.x, albumDummy.y);
			album.angle = albumDummy.angle;
		}

		if(transitionOver){
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

			if(Binds.justPressed("menuCycleLeft")){
				changeCategory(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if(Binds.justPressed("menuCycleRight")){
				changeCategory(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(Binds.justPressed("menuAccept")){
				transitionOver = false;
				dj.backingCardSelect();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				dj.playConfirm();
				categoryMap[categoryNames[curCategory]][curSelected].confirm();
				startSong();
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
				new FlxTimer().start(transitionTimeExit + (staggerTimeExit*4), function(t) {
					switchState(new MainMenuState());
				});
			}

			if(Binds.justPressed("menuChangeCharacter")){
				transitionOver = false;
				if(djCharacter == "Boyfriend"){
					djCharacter = "Pico";
				}
				else{
					djCharacter = "Boyfriend";
				}
				dj.toCharacterSelect();
				customTransOut = new transition.data.ScreenWipeOutFlipped(0.6);

				new FlxTimer().start(0.6, function(t) {
					fadeShader.fadeVal = 1;
					FlxTween.tween(fadeShader, {fadeVal: 0}, 0.8);
				});

				new FlxTimer().start(1, function(t) {
					switchState(new FreeplayState(fromCharacterSelect));
					FlxG.sound.music.fadeOut(0.5);
					curSelected = 0;
					curCategory = 0;
				});
			}

			//big if
			if(Binds.justPressed("menuUp")||Binds.justPressed("menuDown")||Binds.justPressed("menuLeft")||Binds.justPressed("menuRight")||Binds.justPressed("menuCycleLeft")||Binds.justPressed("menuCycleRight")){
				pressedAnything();
			}
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
		
		camFollow.x = Utils.fpsAdjsutedLerp(camFollow.x, camTarget.x, MainMenuState.lerpSpeed);
		camFollow.y = Utils.fpsAdjsutedLerp(camFollow.y, camTarget.y, MainMenuState.lerpSpeed);

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
		
		bg = new FlxSprite().loadGraphic(getImagePathWithSkin('menu/freeplay/pinkBg'));
		bg.antialiasing = true;

		flash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		flash.scale.set(1280, 720);
		flash.updateHitbox();
		flash.alpha = 0;
		flash.visible = false;

		cover = new FlxSprite(1280).loadGraphic(getImagePathWithSkin('menu/freeplay/covers/dad'));
		cover.x -= cover.width;
		cover.antialiasing = true;

		topBar = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		topBar.scale.set(1280, 64);
		topBar.updateHitbox();

		freeplayText = new FlxTextExt(16, 16, 0, "FREEPLAY", 32);
		freeplayText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE);

		changeCharacterText = new FlxTextExt(16, 16, 0, "[BUTTON] to Change Character", 32);
		changeCharacterText.setFormat(Paths.font("vcr"), 32, 0xFF7F7F7F);
		changeCharacterText.screenCenter(X);
		changeCharacterText.visible = false;
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
		add(flash);
		add(cover);

		add(dj);

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

		addCapsules();

		calcAvailableDifficulties();
		updateScore();
		updateAlbum(false);
		updateSongDifficulty();

		if(introAnimType == fromMainMenu){
			bg.x -= 1280;
			flash.visible = true;
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

			FlxTween.tween(bg, {x: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(cover, {x: cover.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(topBar, {y: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(freeplayText, {y: 16}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
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
			tweenCapsulesOnScreen(transitionTime, randomVariation, staggerTime);
		}
		else if(introAnimType != fromCharacterSelect){
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

		versionText = new FlxTextExt(5, FlxG.height - 21, 0, "FPS Plus: " + MainMenuState.version, 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.cameras = [camMenu];
		add(versionText);

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

		bg.visible = false;
		changeCharacterText.visible = true;
		changeCharacterText.alpha = 0;
		FlxTween.tween(changeCharacterText, {alpha: 1}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});

		dj.backingCard.cameras = [camCard];
		add(dj.backingCard);

		dj.backingCardStart();

		camFollow.x = camTarget.x;
		camFollow.y = camTarget.y;
	}
	
	function startFreeplaySong():Void{
		FlxG.sound.playMusic(Paths.music(freeplaySong), freeplaySongVolume);
		Conductor.changeBPM(freeplaySongBpm);
		FlxG.sound.music.onComplete = function(){ 
			lastStep = -Conductor.stepCrochet;
		}
		lastBeat = 0;
		lastStep = 0;
		totalBeats = 0;
		totalSteps = 0;
		curStep = 0;
		curBeat = 0;
	}

	function addSong(_song:String, _icon:String, _week:Int, ?categories:Array<String>):Void{

		var meta = {
			name: _song.replace("-", ""),
			artist: "",
			album: "vol1",
			difficulties: [0, 0, 0]
		}
		if(Utils.exists("assets/data/" + _song.toLowerCase() + "/meta.json")){
			meta = Json.parse(Utils.getText("assets/data/" + _song.toLowerCase() + "/meta.json"));
		}

		if(categories == null){ categories = ["All"]; }
		var capsule:Capsule = new Capsule(_song, meta.name, _icon, _week, meta.album, meta.difficulties, [dj.freeplaySkin, dj.capsuleSelectColor, dj.capsuleDeselectColor]);
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
		capsuleGroup.clear();
		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			updateCapsulePosition(i);
			categoryMap[categoryNames[curCategory]][i].snapToTargetPos();
			categoryMap[categoryNames[curCategory]][i].showRank(curDifficulty);
			//categoryMap[categoryNames[curCategory]][i].deslect();
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
		}
		else if(curSelected >= categoryMap[categoryNames[curCategory]].length){
			curSelected = 0;
		}

		calcAvailableDifficulties();
		updateScore();
		updateAlbum();
		updateSongDifficulty();
	}

	function changeDifficulty(change:Int):Void{
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

		FlxTween.completeTweensOf(difficulty);
		difficulty.y -= 15;
		FlxTween.tween(difficulty, {y: difficulty.y + 15}, 0.1, {ease: FlxEase.cubeOut});

		for(capsule in capsuleGroup){
			capsule.showRank(curDifficulty);
			//capsule.deslect();
		}

		updateScore();
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
		tweenCapsulesOnScreen(transitionTime/2, randomVariation/2, staggerTime, 400);
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
			album.loadGraphic(Paths.image("menu/freeplay/album/" + curAlbum + "/album"));
			albumTitle.loadGraphic(Paths.image("menu/freeplay/album/" + curAlbum + "/title"));

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
				
				albumTitle.offset.x = (albumTitle.width - 234)/2;
			}
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
		}
	}

	function calcAvailableDifficulties():Void{
		allowedDifficulties = [];
		var filesInDir = FileSystem.readDirectory("assets/data/" + categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + "/");

		if(filesInDir.contains(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + "-easy.json")){ allowedDifficulties.push(0); }
		if(filesInDir.contains(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + ".json")){ allowedDifficulties.push(1); }
		if(filesInDir.contains(categoryMap[categoryNames[curCategory]][curSelected].song.toLowerCase() + "-hard.json")){ allowedDifficulties.push(2); }

		if(!allowedDifficulties.contains(curDifficulty)){
			curDifficulty = 0;
			changeDifficulty(allowedDifficulties[0]);
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
		PlayState.storyWeek = categoryMap[categoryNames[curCategory]][curSelected].week;
		new FlxTimer().start(1.5, function(t){
			switchState(new PlayState());
			FlxG.sound.music.fadeOut(0.5);
		});
	}

	function tweenCapsulesOnScreen(_transitionTime:Float, _randomVariation:Float, _staggerTime:Float, ?_distance:Float = 1000):Void{
		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			FlxTween.cancelTweensOf(categoryMap[categoryNames[curCategory]][i]);
			categoryMap[categoryNames[curCategory]][i].xPositionOffset = _distance;
			categoryMap[categoryNames[curCategory]][i].snapToTargetPos();
			FlxTween.tween(categoryMap[categoryNames[curCategory]][i], {xPositionOffset: 0}, _transitionTime + FlxG.random.float(-_randomVariation, _randomVariation), {ease: transitionEase, startDelay: Utils.clamp((_staggerTime/4) * (i+1-curSelected), 0, 100) });
		}
	}

	function tweenCapsulesOffScreen(_transitionTime:Float, _randomVariation:Float, _staggerTime:Float, ?_distance:Float = 1000):Void{
		for(i in 0...categoryMap[categoryNames[curCategory]].length){
			FlxTween.cancelTweensOf(categoryMap[categoryNames[curCategory]][i]);
			FlxTween.tween(categoryMap[categoryNames[curCategory]][i], {xPositionOffset: _distance}, _transitionTime + FlxG.random.float(-_randomVariation, _randomVariation), {ease: transitionEaseExit, startDelay: Utils.clamp((_staggerTime/4) * (i+1-curSelected), 0, 100) });
		}
	}

	function exitAnimation():Void{
		bg.visible = true;
		remove(dj.backingCard);

		FlxTween.tween(bg, {x: bg.x-1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(cover, {x: cover.x+1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(dj, {x: dj.x-1280}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*1});
		FlxTween.tween(topBar, {y: -720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(freeplayText, {y: 16-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
		FlxTween.tween(changeCharacterText, {y: 16-720}, transitionTimeExit + FlxG.random.float(-randomVariationExit, randomVariationExit), {ease: transitionEaseExit, startDelay: staggerTimeExit*3});
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
		tweenCapsulesOffScreen(transitionTimeExit, randomVariationExit, staggerTimeExit);

		FlxTween.completeTweensOf(flash);
		flash.alpha = 1;
		flash.visible = true;
		FlxTween.tween(flash, {alpha: 0}, 0.5, {startDelay: 0.1});
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
		return Paths.image(path);
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
}

enum IntroAnimType {
	fromMainMenu;
	fromCharacterSelect;
	fromSongExit;
	fromSongWin;
	fromSongLose;
}