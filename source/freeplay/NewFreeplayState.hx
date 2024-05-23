package freeplay;

import flixel.math.FlxMath;
import Highscore.SongStats;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.display.FlxBackdrop;
import freeplay.ScrollingText.ScrollingTextInfo;
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

class NewFreeplayState extends MusicBeatState
{

	var bg:FlxSprite;
	var flash:FlxSprite;
	var cover:FlxSprite;
	var topBar:FlxSprite;
	var freeplayText:FlxText;
	var highscoreSprite:FlxSprite;
	var clearPercentSprite:FlxSprite;
	var scoreDisplay:DigitDisplay;
	var percentDisplay:DigitDisplay;
	var albumTitle:FlxSprite;
	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	var difficulty:FlxSprite;

	var album:FlxSprite;
	var albumDummy:FlxObject;
	var albumTime:Float = 0;
	var curAlbum:String = "vol1";
	final ablumPeriod:Float = 1/24;

	var capsules:Array<Capsule> = [];

	var scrollingText:FlxTypedSpriteGroup<FlxBackdrop> = new FlxTypedSpriteGroup<FlxBackdrop>();

	var dj:FlxSprite;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var prevScore:Int;
	var prevAccuracy:Int;

	public static var playStickerIntro:Bool = false;

	var transitionOver:Bool = false;
	var waitForFirstUpdateToStart:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var camTarget:FlxPoint = new FlxPoint();
	var versionText:FlxTextExt;

	var transitionFromMenu:Bool;

	private var camMenu:FlxCamera;
	private var camFreeplay:FlxCamera;

	var scrollingTextStuff:Array<ScrollingTextInfo> = [];

	static final freeplaySong:String = "freeplayRandom"; 
	static final freeplaySongBpm:Float = 145; 
	static final freeplaySongVolume:Float = 0.9; 

	public function new(?_transitionFromMenu:Bool = false, ?camFollowPos:FlxPoint = null) {
		super();
		transitionFromMenu = _transitionFromMenu;
		if(camFollowPos == null){
			camFollowPos = new FlxPoint();
		}
		camFollow = new FlxObject(camFollowPos.x, camFollowPos.y, 1, 1);
	}

	override function create(){

		Config.setFramerate(144);

		persistentUpdate = persistentDraw = true;

		if(transitionFromMenu){
			if(FlxG.sound.music.playing){
				FlxG.sound.music.volume = 0;
			}
			//FlxG.sound.play(Paths.sound("freeplay/recordStop"));
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}

		camMenu = new FlxCamera();

		camFreeplay = new FlxCamera();
		camFreeplay.bgColor.alpha = 0;

		FlxG.cameras.reset(camMenu);
		FlxG.cameras.add(camFreeplay, true);
		FlxG.cameras.setDefaultDrawTarget(camMenu, false);

		if(transitionFromMenu){
			customTransIn = new transition.data.InstantTransition();
		}
		else if(playStickerIntro){
			customTransIn = new transition.data.StickerIn();
			playStickerIntro = false;
		}

		fakeMainMenuSetup();

		setUpScrollingText();

		addSong("Tutorial", "Tutorial", "gf", 0);

		addSong("Bopeebo", "Bopeebo", "dad", 1);
		addSong("Fresh", "Fresh", "dad", 1);
		addSong("Dadbattle", "Dad Battle", "dad", 1);

		addSong("Spookeez", "Spookeez", "spooky", 2);
		addSong("South", "South", "spooky", 2);
		addSong("Monster", "Monster", "monster", 2);

		addSong("Pico", "Pico", "pico", 3);
		addSong("Philly", "Philly Nice", "pico", 3);
		addSong("Blammed", "Blammed", "pico", 3);

		addSong("Satin-Panties", "Satin Panties", "mom", 4);
		addSong("High", "High", "mom", 4);
		addSong("Milf", "M.I.L.F.", "mom", 4);

		addSong("Cocoa", "Cocoa", "parents-christmas", 5);
		addSong("Eggnog", "Eggnog", "parents-christmas", 5);
		addSong("Winter-Horrorland", "Winter Horrorland", "monster", 5);

		addSong("Senpai", "Senpai", "senpai", 6, "vol2");
		addSong("Roses", "Roses", "senpai", 6, "vol2");
		addSong("Thorns", "Thorns", "spirit", 6, "vol2");

		addSong("Ugh", "Ugh", "tankman", 7, "vol2");
		addSong("Guns", "Guns", "tankman", 7, "vol2");
		addSong("Stress", "Stress", "tankman", 7, "vol2");

		super.create();
	}



	override function update(elapsed:Float){

		if(waitForFirstUpdateToStart){
			createFreeplayStuff();
			waitForFirstUpdateToStart = false;
		}

		if(transitionOver){
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

			if(Binds.justPressed("menuAccept")){
				transitionOver = false;
				setUpScrollingTextAccept();
				addScrollingText();
				flash.alpha = 1;
				flash.visible = true;
				FlxTween.tween(flash, {alpha: 0}, 1, {startDelay: 0.1});
				FlxG.sound.play(Paths.sound('confirmMenu'));
				dj.animation.play("confirm", true);
				startSong();
			}
	
			for(i in 0...capsules.length){
				updateCapsulePosition(i);
			}
	
			if(Binds.pressed("menuLeft")){ arrowLeft.scale.set(0.8, 0.8); }
			else{ arrowLeft.scale.set(1, 1); }
	
			if(Binds.pressed("menuRight")){ arrowRight.scale.set(0.8, 0.8); }
			else{ arrowRight.scale.set(1, 1); }
	
			if(Binds.justPressed("menuBack")){
				switchState(new MainMenuState());
			}
		}
		
		camFollow.x = Utils.fpsAdjsutedLerp(camFollow.x, camTarget.x, MainMenuState.lerpSpeed);
		camFollow.y = Utils.fpsAdjsutedLerp(camFollow.y, camTarget.y, MainMenuState.lerpSpeed);

		super.update(elapsed);

	}



	override function beatHit() {
		if(transitionOver && curBeat % 2 == 0 && dj.animation.curAnim.name == "idle"){
			dj.animation.play("idle", true);
		}

		super.beatHit();
	}



	function createFreeplayStuff():Void{
		
		bg = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/bg'));
		bg.antialiasing = true;

		addScrollingText();
		scrollingText.visible = false;

		flash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		flash.scale.set(1280, 720);
		flash.updateHitbox();
		flash.alpha = 0;
		flash.visible = false;

		cover = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/sideCover'));
		cover.antialiasing = true;

		topBar = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		topBar.scale.set(1280, 64);
		topBar.updateHitbox();

		freeplayText = new FlxText(16, 16, 0, "FREEPLAY", 32);
		freeplayText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE);

		highscoreSprite = new FlxSprite(860, 70);
		highscoreSprite.frames = Paths.getSparrowAtlas("menu/freeplay/highscore");
		highscoreSprite.animation.addByPrefix("loop", "", 24, true);
		highscoreSprite.animation.play("loop");

		clearPercentSprite = new FlxSprite(1165, 65).loadGraphic(Paths.image('menu/freeplay/clearBox'));
		clearPercentSprite.antialiasing = true;

		scoreDisplay = new DigitDisplay(915, 120, "digital_numbers", 7, 0.4, -25);
		scoreDisplay.setDigitOffset(1, 20);
		scoreDisplay.ease = FlxEase.cubeOut;

		percentDisplay = new DigitDisplay(1154, 87, "menu/freeplay/clearText", 3, 1, 3, 0, true);
		percentDisplay.setDigitOffset(1, -8);
		percentDisplay.ease = FlxEase.quadOut;

		albumDummy = new FlxObject(950, 285, 1, 1);
		albumDummy.angle = 10;
		album = new FlxSprite(albumDummy.x, albumDummy.y).loadGraphic(Paths.image("menu/freeplay/album/vol1/album"));
		album.antialiasing = true;
		album.angle = albumDummy.angle;
		
		albumTitle = new FlxSprite(album.x - 5, album.y + 205).loadGraphic(Paths.image("menu/freeplay/album/vol1/title"));
		albumTitle.antialiasing = true;

		arrowLeft = new FlxSprite(20, 70);
		arrowLeft.frames = Paths.getSparrowAtlas("menu/freeplay/freeplaySelector");
		arrowLeft.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
		arrowLeft.animation.play("loop");
		arrowLeft.antialiasing = true;

		arrowRight = new FlxSprite(325, 70);
		arrowRight.frames = Paths.getSparrowAtlas("menu/freeplay/freeplaySelector");
		arrowRight.animation.addByPrefix("loop", "arrow pointer loop", 24, true);
		arrowRight.animation.play("loop");
		arrowRight.flipX = true;
		arrowRight.antialiasing = true;

		difficulty = new FlxSprite(197, 115).loadGraphic(Paths.image("menu/freeplay/diff/" + diffNumberToDiffName(curDifficulty)));
		difficulty.offset.set(difficulty.width/2, difficulty.height/2);
		difficulty.antialiasing = true;

		//DJ STUFF
		dj = new FlxSprite(-9, 290);
		dj.cameras = [camFreeplay];
		dj.frames = Paths.getSparrowAtlas("menu/freeplay/dj/bf");
		dj.antialiasing = true;

		dj.animation.addByPrefix("idle", "Boyfriend DJ0", 24, false, false, false);
		dj.animation.addByPrefix("intro", "boyfriend dj intro", 24, false, false, false);
        dj.animation.addByPrefix("confirm", "Boyfriend DJ confirm", 24, false, false, false);
		
		dj.animation.callback = function(name, frameNumber, frameIndex) {
			switch(name){
				case "idle":
					dj.offset.set(0, 0);
				case "intro":
					dj.offset.set(5, 427);
				case "confirm":
					dj.offset.set(43, -24);
			}
		}

		dj.animation.finishCallback = function(name) {
			switch(name){
				case "idle":
					dj.animation.play("idle", true, false, dj.animation.curAnim.numFrames - 4);
				case "intro":
					if(transitionFromMenu && !transitionOver){
						djIntroFinish();
						dj.animation.play("idle", true);
					}
			}
		}

		if(transitionFromMenu){
			dj.animation.play("intro", true);
		}
		else {
			dj.animation.play("idle", true);
		}

		//ADDING STUFF
		add(bg);
		add(scrollingText);
		add(flash);
		add(cover);

		add(dj);

		add(highscoreSprite);
		add(clearPercentSprite);
		add(scoreDisplay);
		add(percentDisplay);
		add(album);
		add(albumTitle);

		addCapsules();

		add(arrowLeft);
		add(arrowRight);
		add(difficulty);
		
		add(topBar);
		add(freeplayText);

		updateScore();
		updateAlbum();

		if(transitionFromMenu){
			var transitionTime:Float = 1;
			var staggerTime:Float = 0.1;
			var randomVariation:Float = 0.04;
			var transitionEase:flixel.tweens.EaseFunction = FlxEase.quintOut;
			
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

			var albumPos = albumDummy.x;
			albumDummy.x = 1280;
			albumDummy.angle = 70;
			album.x = albumDummy.x;
			album.angle = albumDummy.angle;

			FlxTween.tween(bg, {x: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(cover, {x: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(topBar, {y: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(freeplayText, {y: 16}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(highscoreSprite, {x: highscoreSprite.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
			FlxTween.tween(clearPercentSprite, {x: clearPercentSprite.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
			FlxTween.tween(scoreDisplay, {x: scoreDisplay.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*3});
			FlxTween.tween(percentDisplay, {x: percentDisplay.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});
			FlxTween.tween(albumDummy, {x: albumPos, angle: 10}, transitionTime/1.1 + FlxG.random.float(-randomVariation, randomVariation), {ease: albumElasticOut});
			FlxTween.tween(albumTitle, {x: albumTitle.x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase});
			FlxTween.tween(arrowLeft, {y: arrowLeft.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
			FlxTween.tween(arrowRight, {y: arrowRight.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime});
			FlxTween.tween(difficulty, {y: difficulty.y+720}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: staggerTime*2});

			for(i in 0...capsules.length){
				capsules[i].xPositionOffset = 1000;
				FlxTween.tween(capsules[i], {xPositionOffset: 0}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: Utils.clamp((staggerTime/4) * (i+1-curSelected), 0, 100) });
			}

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
			menuItem.frames = tex;
			
			menuItem.animation.addByPrefix('idle', MainMenuState.optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', MainMenuState.optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.cameras = [camMenu];
		}

		versionText = new FlxTextExt(5, FlxG.height - 21, 0, "FPS Plus: v4.1.0", 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.cameras = [camMenu];
		add(versionText);

		menuItems.forEach(function(spr:FlxSprite){
			spr.animation.play('idle');
	
			if (spr.ID == 1){
				spr.animation.play('selected');
				camTarget.set(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				if(!transitionFromMenu){
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				}
			}
	
			spr.updateHitbox();
			spr.screenCenter(X);
		});
	}

	function djIntroFinish():Void{
		transitionOver = true;
		startFreeplaySong();

		flash.alpha = 1;
		scrollingText.visible = true;
		FlxTween.tween(flash, {alpha: 0}, 1, {startDelay: 0.1});
	}
	
	function startFreeplaySong():Void{
		FlxG.sound.playMusic(Paths.music(freeplaySong), freeplaySongVolume);
		Conductor.changeBPM(freeplaySongBpm);
		FlxG.sound.music.onComplete = function(){lastStep = 0;}
		lastBeat = 0;
		lastStep = 0;
		totalBeats = 0;
		totalSteps = 0;
		curStep = 0;
		curBeat = 0;
	}

	//INITIAL TEXT
	function setUpScrollingText():Void{
		scrollingTextStuff = [];

		scrollingTextStuff.push({
			text: "HOT BLOODED IN MORE WAYS THAN ONE ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFF383,
			position: new FlxPoint(0, 168),
			velocity: 6.8
		});

		scrollingTextStuff.push({
			text: "BOYFRIEND ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFF9963,
			position: new FlxPoint(0, 220),
			velocity: -3.8
		});

		scrollingTextStuff.push({
			text: "PROTECT YO NUTS ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFFFFF,
			position: new FlxPoint(0, 285),
			velocity: 3.5
		});

		scrollingTextStuff.push({
			text: "BOYFRIEND ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFF9963,
			position: new FlxPoint(0, 335),
			velocity: -3.8
		});

		scrollingTextStuff.push({
			text: "HOT BLOODED IN MORE WAYS THAN ONE ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFF383,
			position: new FlxPoint(0, 397),
			velocity: 6.8
		});

		scrollingTextStuff.push({
			text: "BOYFRIEND ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFEA400,
			position: new FlxPoint(0, 455),
			velocity: -3.8
		});
	}

	//CHANGED TEXT
	function setUpScrollingTextAccept():Void{
		scrollingTextStuff = [];

		scrollingTextStuff.push({
			text: "DON'T FUCK THIS ONE UP ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFF383,
			position: new FlxPoint(0, 168),
			velocity: 6.8
		});

		scrollingTextStuff.push({
			text: "LET'S GO ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFF9963,
			position: new FlxPoint(0, 220),
			velocity: -3.8
		});

		scrollingTextStuff.push({
			text: "YOU GOT THIS ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFFFFF,
			position: new FlxPoint(0, 285),
			velocity: 3.5
		});

		scrollingTextStuff.push({
			text: "LET'S GO ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFF9963,
			position: new FlxPoint(0, 335),
			velocity: -3.8
		});

		scrollingTextStuff.push({
			text: "DON'T FUCK THIS ONE UP ",
			font: Paths.font("5by7"),
			size: 43,
			color: 0xFFFFF383,
			position: new FlxPoint(0, 397),
			velocity: 6.8
		});

		scrollingTextStuff.push({
			text: "LET'S GO ",
			font: Paths.font("5by7"),
			size: 60,
			color: 0xFFFEA400,
			position: new FlxPoint(0, 455),
			velocity: -3.8
		});
	}

	function addScrollingText():Void{

		scrollingText.forEachExists(function(text){ text.destroy(); });
		scrollingText.clear();

		for(x in scrollingTextStuff){
			var tempText = new FlxText(0, 0, 0, x.text);
			tempText.setFormat(x.font, x.size, x.color);

			var scrolling:FlxBackdrop = ScrollingText.createScrollingText(x.position.x, x.position.y, tempText);
			scrolling.velocity.x = x.velocity * 60;
			
			scrollingText.add(scrolling);
		}
		
	}

	function addSong(_song:String, _displayName:String, _icon:String, _week:Int, ?_album:String = "vol1"):Void{
		var capsule:Capsule = new Capsule(_song, _displayName, _icon, _week, _album);
		capsules.push(capsule);
	}

	function addCapsules():Void{
		for(i in 0...capsules.length){
			updateCapsulePosition(i);
			capsules[i].snapToTargetPos();
			add(capsules[i]);
		}
	}

	function updateCapsulePosition(index:Int):Void{
		capsules[index].targetPos.x = capsules[index].intendedX(index - curSelected);
		capsules[index].targetPos.y = capsules[index].intendedY(index - curSelected);
	}

	function changeSelected(change:Int):Void{
		curSelected += change;
		if(curSelected < 0){
			curSelected = capsules.length-1;
		}
		else if(curSelected >= capsules.length){
			curSelected = 0;
		}

		updateScore();
		updateAlbum();
	}

	function changeDifficulty(change:Int):Void{
		curDifficulty += change;
		if(curDifficulty < 0){
			curDifficulty = 2;
		}
		else if(curDifficulty > 2){
			curDifficulty = 0;
		}

		difficulty.loadGraphic(Paths.image("menu/freeplay/diff/" + diffNumberToDiffName(curDifficulty)));
		difficulty.offset.set(difficulty.width/2, difficulty.height/2);

		updateScore();
	}

	function updateScore():Void{
		var score:SongStats = Highscore.getScore(capsules[curSelected].song, curDifficulty);

		if(prevScore != score.score){
			scoreDisplay.tweenNumber(score.score, 0.8);
			prevScore = score.score;
		}
		
		if(prevAccuracy != Math.floor(score.accuracy)){
			percentDisplay.tweenNumber(Math.floor(score.accuracy), 0.8);
			prevAccuracy = Math.floor(score.accuracy);
		}

		for(i in 0...capsules.length){
			capsules[i].deslect();
			if(i == curSelected){
				capsules[i].select();
			}
		}
	}

	function updateAlbum():Void{
		var newAlbum:String = capsules[curSelected].album;
		if(newAlbum != curAlbum){
			curAlbum = newAlbum;
			album.loadGraphic(Paths.image("menu/freeplay/album/" + curAlbum + "/album"));
			albumTitle.loadGraphic(Paths.image("menu/freeplay/album/" + curAlbum + "/title"));
		}
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
		var formattedSong:String = Highscore.formatSong(capsules[curSelected].song.toLowerCase(), curDifficulty);
		PlayState.SONG = Song.loadFromJson(formattedSong, capsules[curSelected].song.toLowerCase());
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.loadEvents = true;
		PlayState.returnLocation = "freeplay";
		PlayState.storyWeek = capsules[curSelected].week;
		new FlxTimer().start(1, function(t){
			switchState(new PlayState());
			FlxG.sound.music.fadeOut(0.5);
		});
	}

	inline function albumElasticOut(t:Float):Float{
		var ELASTIC_AMPLITUDE:Float = 1;
		var ELASTIC_PERIOD:Float = 0.6;
		return (ELASTIC_AMPLITUDE * Math.pow(2, -10 * t) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * Math.PI) / ELASTIC_PERIOD) + 1);
	}
}