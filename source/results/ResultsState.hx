package results;

import openfl.Assets;
import story.StoryMenuState;
import shaders.TintShader;
import openfl.filters.ShaderFilter;
import shaders.ColorGradientShader;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import transition.data.StickerOut;
import freeplay.FreeplayState;
import Highscore.Rank;
import PlayState.ScoreStats;
import flixel.math.FlxPoint;
import extensions.flixel.FlxTextExt;
import freeplay.ScrollingText;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import freeplay.DigitDisplay;
import config.Config;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxCamera;
import extensions.flixel.FlxUIStateExt;
import modding.PolymodHandler;

using StringTools;

class ResultsState extends FlxUIStateExt
{
	public static var instance:ResultsState;
	public static var enableDebugControls:Bool = false;

	public var camBg:FlxCamera;
	public var camScroll:FlxCamera;
	public var camCharacter:FlxCamera;
	public var camTitle:FlxCamera;
	public var camUi:FlxCamera;

	public var character:ResultsCharacter;

	public var bg:FlxSprite;
	public var bgShader:ColorGradientShader;
	public var extraGradient:FlxSprite;

	public var resultsTitle:FlxSprite;
	public var ratingsStuff:FlxSprite;
	public var scoreStuff:FlxSprite;
	public var highscoreNew:FlxSprite;

	public var totalNoteCounter:DigitDisplay;
	public var maxComboCounter:DigitDisplay;
	public var sickCounter:DigitDisplay;
	public var goodCounter:DigitDisplay;
	public var badCounter:DigitDisplay;
	public var shitCounter:DigitDisplay;
	public var missCounter:DigitDisplay;
	public var scoreCounter:DigitDisplay;

	public var clearShader:TintShader;
	public var clearPercentText:FlxSprite;
	public var clearPercentSymbol:FlxSprite;
	public var clearPercentCounter:DigitDisplay;

	public var scrollingRankName:FlxBackdrop;

	public var bitmapSongName:FlxBitmapText;

	public var scrollingTextGroup:FlxSpriteGroup = new FlxSpriteGroup();

	var characterString:String;
	var scoreStats:ScoreStats;
	var songNameText:String;
	var saveInfo:SaveInfo;

	var totalNotes:Int = 0;
	var grade:Float = 0;
	var rank:Rank = none;

	var prevHighscore:Int = 0;

	var exiting:Bool = false;
	var shownRank:Bool = false;

	var useCustomStickerSet:Array<String>;

	public function new(_scoreStats:ScoreStats, ?_songNameText:String = "Fabs is on base game", ?_character:String = "Boyfriend", ?_saveInfo:SaveInfo = null, ?_useCustomStickerSet:Array<String> = null) {
		super();

		instance = this;

		if(_scoreStats == null){
			_scoreStats = {
				score: FlxG.random.int(123456, 12345678),
				highestCombo: FlxG.random.int(0, 999),
				accuracy: FlxG.random.int(50, 100),
				sickCount: FlxG.random.int(0, 400),
				goodCount: FlxG.random.int(0, 300),
				badCount: FlxG.random.int(0, 200),
				shitCount: FlxG.random.int(0, 100),
				susCount: FlxG.random.int(0, 999),
				missCount: FlxG.random.int(0, 50),
				comboBreakCount: FlxG.random.int(0, 999),
			};
		} 

		characterString = _character;
		scoreStats = _scoreStats;
		songNameText = _songNameText;
		useCustomStickerSet = _useCustomStickerSet;

		totalNotes = scoreStats.sickCount + scoreStats.goodCount + scoreStats.badCount + scoreStats.shitCount;
		if(totalNotes + scoreStats.missCount > 0){
			grade = Scoring.calculateAccuracy(scoreStats.sickCount, scoreStats.goodCount, scoreStats.badCount, scoreStats.shitCount, scoreStats.missCount);
		}
		
		rank = Highscore.calculateRank(scoreStats);

		saveInfo = _saveInfo;

		if(saveInfo != null){
			if(saveInfo.song != null){
				prevHighscore = Highscore.getScore(saveInfo.song, saveInfo.diff).score;
				Highscore.saveScore(saveInfo.song, scoreStats.score, scoreStats.accuracy, saveInfo.diff, rank);
			}
			else if(saveInfo.week != null){
				prevHighscore = Highscore.getWeekScore(saveInfo.week, saveInfo.diff).score;
				Highscore.saveWeekScore(saveInfo.week, scoreStats.score, scoreStats.accuracy, saveInfo.diff, rank);
			}
		}
	}

	override function create() {

		Config.setFramerate(144);

		persistentUpdate = persistentDraw = true;

		camBg = new FlxCamera();
		camBg.filters = [];

		camScroll = new FlxCamera(-50, -50, 1280 + 100, 720 + 100);
		camScroll.bgColor = FlxColor.TRANSPARENT;
		camScroll.angle = -3.8;
		camScroll.filters = [];

		camCharacter = new FlxCamera();
		camCharacter.bgColor = FlxColor.TRANSPARENT;
		camCharacter.filters = [];

		camTitle = new FlxCamera(-50, -50, 1280 + 100, 720 + 100);
		camTitle.bgColor = FlxColor.TRANSPARENT;
		camTitle.angle = -3.8;
		camTitle.filters = [];

		camUi = new FlxCamera();
		camUi.bgColor = FlxColor.TRANSPARENT;
		camUi.filters = [];

		FlxG.cameras.add(camBg, false);
		FlxG.cameras.add(camScroll, false);
		FlxG.cameras.add(camCharacter, false);
		FlxG.cameras.add(camTitle, false);
		FlxG.cameras.add(camUi, false);
		FlxG.cameras.setDefaultDrawTarget(camUi, true);
		this.camera = camUi;

		//var characterClass = Type.resolveClass("results.characters." + characterString);
		//if(characterClass == null){ characterClass = results.characters.Boyfriend; }
		//character = Type.createInstance(characterClass, [rank]);
		if(!ScriptableResultsCharacter.listScriptClasses().contains(characterString)){ characterString = "BoyfriendResults"; }
		character = ScriptableResultsCharacter.init(characterString, rank);
		character.setup();
		character.cameras = [camCharacter];

		bgShader = new ColorGradientShader(character.gradientBottomColor, character.gradientTopColor);

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFFFFFF, 0xFF000000]);
		bg.scrollFactor.set();
		bg.shader = bgShader.shader;
		bg.cameras = [camBg];

		extraGradient = new FlxSprite().loadGraphic(Paths.image("menu/results/gradientCover"));
		extraGradient.color = character.gradientBottomColor;
		extraGradient.x = 1280 - 460;
		extraGradient.y = 720 - 128;
		extraGradient.alpha = 0;

		var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/results/topBarBlack"));
		blackTopBar.y = -blackTopBar.height;
		blackTopBar.antialiasing = true;
		FlxTween.tween(blackTopBar, {y: 0}, 7/24, {ease: FlxEase.quartOut, startDelay: 3/24});

		var soundSystem:FlxSprite = new FlxSprite(-15, -180);
		soundSystem.frames = Paths.getSparrowAtlas("menu/results/soundSystem");
		soundSystem.animation.addByPrefix("", "", 24, false);
		soundSystem.visible = false;
		soundSystem.antialiasing = true;
		new FlxTimer().start(8/24, function(t){
			soundSystem.animation.play("");
			soundSystem.visible = true;
		});
		
		resultsTitle = new FlxSprite(-200, -10);
		resultsTitle.frames = Paths.getSparrowAtlas("menu/results/results");
		resultsTitle.animation.addByPrefix("", "", 24, false);
		resultsTitle.antialiasing = true;
		resultsTitle.visible = false;
		new FlxTimer().start(6/24, function(t){
			resultsTitle.visible = true;
			resultsTitle.animation.play("");
		});

		ratingsStuff = new FlxSprite(-135, 135);
		ratingsStuff.frames = Paths.getSparrowAtlas("menu/results/ratingsPopin");
		ratingsStuff.animation.addByPrefix("", "", 24, false);
		ratingsStuff.antialiasing = true;
		ratingsStuff.visible = false;
		new FlxTimer().start(21/24, function(t){
			ratingsStuff.visible = true;
			ratingsStuff.animation.play("");
		});

		scoreStuff = new FlxSprite(-180, 515);
		scoreStuff.frames = Paths.getSparrowAtlas("menu/results/scorePopin");
		scoreStuff.animation.addByPrefix("", "", 24, false);
		scoreStuff.antialiasing = true;
		scoreStuff.visible = false;
		new FlxTimer().start(36/24, function(t){
			scoreStuff.visible = true;
			scoreStuff.animation.play("");
		});

		highscoreNew = new FlxSprite(44, 557);
		highscoreNew.frames = Paths.getSparrowAtlas("menu/results/highscoreNew");
		highscoreNew.animation.addByPrefix("", "highscoreAnim", 24, false);
		highscoreNew.visible = false;
		highscoreNew.antialiasing = true;
		highscoreNew.animation.onFinish.add(function(name) {
			highscoreNew.animation.play("", true, false, highscoreNew.animation.curAnim.numFrames - 12);
		});

		//COUNTER STUFF AAAHHHHHHHH!!!!!

		

		totalNoteCounter = new DigitDisplay(374, 152, "menu/results/tallieNumber", -1, 1, 10);
		totalNoteCounter.ease = FlxEase.quartOut;
		totalNoteCounter.visible = false;
		if(totalNotes > 999){ totalNoteCounter.x -= (totalNoteCounter.getDigitWidth() + totalNoteCounter.getAdjustedSpacing()); }
		new FlxTimer().start((0.3 * 0) + 1.2, function(t){
			totalNoteCounter.visible = true;
			totalNoteCounter.tweenNumber(totalNotes, 0.5);
			playCounterSoundTickUp();
		});

		maxComboCounter = new DigitDisplay(374, 202, "menu/results/tallieNumber", -1, 1, 10);
		maxComboCounter.ease = FlxEase.quartOut;
		maxComboCounter.visible = false;
		if(scoreStats.highestCombo > 999){ maxComboCounter.x -= (maxComboCounter.getDigitWidth() + maxComboCounter.getAdjustedSpacing()); }
		new FlxTimer().start((0.3 * 1) + 1.2, function(t){
			maxComboCounter.visible = true;
			maxComboCounter.tweenNumber(scoreStats.highestCombo, 0.5);
			playCounterSoundTickUp();
		});

		sickCounter = new DigitDisplay(229, 278, "menu/results/tallieNumber", -1, 1, 10);
		sickCounter.ease = FlxEase.quartOut;
		sickCounter.visible = false;
		sickCounter.digitColor = 0xFF8AE2A0;
		new FlxTimer().start((0.3 * 2) + 1.2, function(t){
			sickCounter.visible = true;
			sickCounter.tweenNumber(scoreStats.sickCount, 0.5);
			playCounterSoundTickUp();
		});

		goodCounter = new DigitDisplay(208, 332, "menu/results/tallieNumber", -1, 1, 10);
		goodCounter.ease = FlxEase.quartOut;
		goodCounter.visible = false;
		goodCounter.digitColor = 0xFF8CC8E6;
		new FlxTimer().start((0.3 * 3) + 1.2, function(t){
			goodCounter.visible = true;
			goodCounter.tweenNumber(scoreStats.goodCount, 0.5);
			playCounterSoundTickUp();
		});

		badCounter = new DigitDisplay(189, 383, "menu/results/tallieNumber", -1, 1, 10);
		badCounter.ease = FlxEase.quartOut;
		badCounter.visible = false;
		badCounter.digitColor = 0xFFE5CF90;
		new FlxTimer().start((0.3 * 4) + 1.2, function(t){
			badCounter.visible = true;
			badCounter.tweenNumber(scoreStats.badCount, 0.5);
			playCounterSoundTickUp();
		});

		shitCounter = new DigitDisplay(219, 438, "menu/results/tallieNumber", -1, 1, 10);
		shitCounter.ease = FlxEase.quartOut;
		shitCounter.visible = false;
		shitCounter.digitColor = 0xFFE68C8D;
		new FlxTimer().start((0.3 * 5) + 1.2, function(t){
			shitCounter.visible = true;
			shitCounter.tweenNumber(scoreStats.shitCount, 0.5);
			playCounterSoundTickUp();
		});

		missCounter = new DigitDisplay(259, 492, "menu/results/tallieNumber", -1, 1, 10);
		missCounter.ease = FlxEase.quartOut;
		missCounter.visible = false;
		missCounter.digitColor = 0xFFC38ADE;
		new FlxTimer().start((0.3 * 6) + 1.2, function(t){
			missCounter.visible = true;
			missCounter.tweenNumber(scoreStats.missCount, 0.5);
			playCounterSoundTickUp();
		});

		clearShader = new TintShader(0xFFFFFFFF, 0);

		clearPercentCounter = new DigitDisplay(838 - 80, 349, "menu/results/clearPercentNumbers", 3, 1, 0, 0, true, false);
		clearPercentCounter.ease = FlxEase.cubeOut;
		clearPercentCounter.setDigitOffset("1", -13);
		clearPercentCounter.visible = false;
		clearPercentCounter.callback = percentCallback;
		clearPercentCounter.digitShader = clearShader.shader;

		clearPercentSymbol = new FlxSprite(clearPercentCounter.x + 80, clearPercentCounter.y + clearPercentCounter.height).loadGraphic(Paths.image("menu/results/clearPercentSymbol"));
		clearPercentSymbol.y -= clearPercentSymbol.height;
		clearPercentSymbol.antialiasing = true;
		clearPercentSymbol.visible = false;
		clearPercentSymbol.shader = clearShader.shader;

		clearPercentText = new FlxSprite(clearPercentCounter.x + 80, clearPercentCounter.y + clearPercentCounter.height).loadGraphic(Paths.image("menu/results/clearPercentText"));
		clearPercentText.y -= clearPercentSymbol.height;
		clearPercentText.antialiasing = true;
		clearPercentText.visible = false;
		clearPercentText.shader = clearShader.shader;

		new FlxTimer().start((0.3 * 7) + 1.2, function(t){
			clearPercentCounter.visible = true;

			if(Math.floor(grade) > 1){
				clearPercentCounter.tweenNumber(Math.floor(grade) - 1, 1.4);
			}
			else{
				clearPercentCounter.setNumber(0, true);
				playCounterSoundTickUp();
			}

			clearPercentText.visible = true;
			clearPercentSymbol.visible = true;
		});

		scoreCounter = new DigitDisplay(71, 611, "menu/results/score-digital-numbers", 10, 1, -31, 0, false, true);
		scoreCounter.ease = FlxEase.cubeOut;
		scoreCounter.y += 150;

		new FlxTimer().start((0.3 * 7) + 1.2, function(t){
			FlxTween.tween(scoreCounter, {y: scoreCounter.y - 150}, 0.7, {ease: FlxEase.quintOut});
			scoreCounter.tweenNumber(scoreStats.score, 1.5);
		});

		//SCROLLING TEXT!!!!!

		var prevRandomArray = [];
		var textArray = rankToRankText(rank);
		for (i in 0...12){
			
			var textIndex = (i % 2 == 1) ? FlxG.random.int(1, textArray.length-1, prevRandomArray) : 0;
			prevRandomArray.push(textIndex);
			prevRandomArray.remove(0);
			if(prevRandomArray.length == textArray.length - 1){ prevRandomArray = []; }

			var tempText = new FlxText(0, 0, 0, textArray[textIndex] + " ");
			tempText.setFormat(Paths.font("5by7"), 50, 0xFFFFFFFF);
			tempText.antialiasing = true;

			var scrolling:FlxBackdrop = ScrollingText.createScrollingText(50, 100 + (135 * (i+1) / 2) + 10, tempText);
			//scrolling.velocity.x = FlxG.random.int(5, 9);
			scrolling.velocity.x = (i % 2 == 0) ? -8 : 8;
			scrolling.antialiasing = true;
			scrolling.color = character.scrollingTextColor;
			
			scrollingTextGroup.add(scrolling);
		}
		scrollingTextGroup.visible = false;
		scrollingTextGroup.cameras = [camScroll];

		var rankName:String = "";
		for(char in (textArray[0]).split("")){ rankName += char + "\n"; }

		var tempRankText = new FlxTextExt(0, 0, 0, rankName);
		tempRankText.setFormat(Paths.font("5by7"), 100, 0xFFFFFFFF);
		tempRankText.antialiasing = true;
		tempRankText.leading = 10;

		scrollingRankName = ScrollingText.createScrollingText(1280 - tempRankText.width, 0, tempRankText, Y);
		scrollingRankName.velocity.y = 30;
		scrollingRankName.antialiasing = true;
		scrollingRankName.visible = false;
		scrollingRankName.spacing.y = 57;

		bitmapSongName = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/resultFont"), Utils.resultsTextCharacters, FlxPoint.get(49, 62)));
		bitmapSongName.text = songNameText;
		bitmapSongName.letterSpacing = -15;
		bitmapSongName.antialiasing = true;
		bitmapSongName.setPosition(550 + 50, 120 + 50);
		bitmapSongName.cameras = [camTitle];
		bitmapSongName.y -= 300;
		if(bitmapSongName.width > 680){
			var scaleAmount:Float = 680/bitmapSongName.width;
			bitmapSongName.scale.set(scaleAmount, scaleAmount);
			bitmapSongName.updateHitbox();
			bitmapSongName.y += (62-(scaleAmount*62))/2;
		}
		new FlxTimer().start(36/24, function(t){
			FlxTween.tween(bitmapSongName, {y: bitmapSongName.y + 300}, 1.2, {ease: FlxEase.quintOut});
		});

		var songNameShader = new ColorGradientShader(0xFFF98862, 0xFFF9FEB1);
		bitmapSongName.shader = songNameShader.shader;

		add(bg);

		add(extraGradient);
		add(scrollingRankName);
		add(blackTopBar);
		add(soundSystem);
		add(resultsTitle);
		add(ratingsStuff);
		add(scoreStuff);

		add(totalNoteCounter);
		add(maxComboCounter);
		add(sickCounter);
		add(goodCounter);
		add(badCounter);
		add(shitCounter);
		add(missCounter);
		add(scoreCounter);

		add(highscoreNew);

		add(clearPercentCounter);
		add(clearPercentSymbol);
		add(clearPercentText);

		add(scrollingTextGroup);
		add(bitmapSongName);
		//add(testPROPROP);

		add(character);

		character.playIntroSong();
		FlxG.sound.music.onComplete = function() {
			character.playSong();
			finishedCounting();
		}

		super.create();
	}

	override function update(elapsed:Float) {

		if((Binds.justPressed("menuAccept") || Binds.justPressed("menuBack")) && !exiting && shownRank){
			returnToMenu();
		}

		if(enableDebugControls){
			if(FlxG.keys.anyJustPressed([TAB])){
				var newResultsState:ResultsState;
				if(FlxG.keys.anyPressed([SHIFT])){
					newResultsState = new ResultsState(null, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([ONE])){
					newResultsState = new ResultsState({
						score: FlxG.random.int(123456, 12345678),
						highestCombo: 100,
						accuracy: 100,
						sickCount: 100,
						goodCount: 0,
						badCount: 0,
						shitCount: 0,
						susCount: 0,
						missCount: 0,
						comboBreakCount: 0,
					}, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([TWO])){
					newResultsState = new ResultsState({
						score: FlxG.random.int(123456, 12345678),
						highestCombo: 100,
						accuracy: 100,
						sickCount: 99,
						goodCount: 1,
						badCount: 0,
						shitCount: 0,
						susCount: 0,
						missCount: 0,
						comboBreakCount: 0,
					}, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([THREE])){
					newResultsState = new ResultsState({
						score: FlxG.random.int(123456, 12345678),
						highestCombo: 90,
						accuracy: 90,
						sickCount: 90,
						goodCount: 0,
						badCount: 10,
						shitCount: 0,
						susCount: 0,
						missCount: 0,
						comboBreakCount: 10,
					}, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([FOUR])){
					newResultsState = new ResultsState({
						score: FlxG.random.int(123456, 12345678),
						highestCombo: 80,
						accuracy: 80,
						sickCount: 80,
						goodCount: 0,
						badCount: 20,
						shitCount: 0,
						susCount: 0,
						missCount: 0,
						comboBreakCount: 20,
					}, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([FIVE])){
					newResultsState = new ResultsState({
						score: FlxG.random.int(123456, 12345678),
						highestCombo: 70,
						accuracy: 70,
						sickCount: 70,
						goodCount: 0,
						badCount: 30,
						shitCount: 0,
						susCount: 0,
						missCount: 0,
						comboBreakCount: 30,
					}, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([SIX])){
					newResultsState = new ResultsState({
						score: FlxG.random.int(123456, 12345678),
						highestCombo: 50,
						accuracy: 50,
						sickCount: 50,
						goodCount: 0,
						badCount: 0,
						shitCount: 0,
						susCount: 0,
						missCount: 50,
						comboBreakCount: 0,
					}, songNameText, characterString, saveInfo);
				}
				else if(FlxG.keys.anyPressed([SEVEN])){
					newResultsState = new ResultsState({
						score: 0,
						highestCombo: 0,
						accuracy: 0,
						sickCount: 0,
						goodCount: 0,
						badCount: 0,
						shitCount: 0,
						susCount: 0,
						missCount: 0,
						comboBreakCount: 0,
					}, songNameText, characterString, saveInfo);
				}
				else{
					newResultsState = new ResultsState(scoreStats, songNameText, characterString, saveInfo);
				}
				switchState(newResultsState);
			}
		}

		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload(false);
			var newResultsState:ResultsState = new ResultsState(scoreStats, songNameText, characterString, saveInfo);
			switchState(newResultsState);
		}

		/*
		var moveAmount = 1;
		if(FlxG.keys.anyPressed([SHIFT])){
			moveAmount = 25;
		}
		
		if(FlxG.keys.anyJustPressed([W])){
			bitmapSongName.y -= moveAmount;
			trace(bitmapSongName.getPosition());
		}
		if(FlxG.keys.anyJustPressed([S])){
			bitmapSongName.y += moveAmount;
			trace(bitmapSongName.getPosition());
		}
		if(FlxG.keys.anyJustPressed([A])){
			bitmapSongName.x -= moveAmount;
			trace(bitmapSongName.getPosition());
		}
		if(FlxG.keys.anyJustPressed([D])){
			bitmapSongName.x += moveAmount;
			trace(bitmapSongName.getPosition());
		}*/

		super.update(elapsed);
	}

	function finishedCounting():Void{
		shownRank = true;

		scrollingTextGroup.visible = true;
		camBg.flash(character.scrollingTextColor, 1);

		if(prevHighscore < scoreStats.score){
			highscoreNew.animation.play("", true);
			highscoreNew.visible = true;
		}

		scrollingRankName.visible = true;

		var gradeAdjust = 0;
		if(grade == 100){
			gradeAdjust = 35;
		}

		clearPercentCounter.setNumber(Math.floor(grade), true);

		clearShader.amount = 1;
		FlxTween.tween(clearShader, {amount: 0}, 0.75, {startDelay: 1/24, ease: FlxEase.quintOut});
		FlxTween.tween(clearPercentCounter, {x: clearPercentCounter.x + 65 + gradeAdjust, y: clearPercentCounter.y + 265}, 1, {startDelay: 0.25, ease: FlxEase.quintInOut});
		FlxTween.tween(clearPercentSymbol, {x: clearPercentSymbol.x + 65 + gradeAdjust, y: clearPercentSymbol.y + 265}, 1, {startDelay: 0.25, ease: FlxEase.quintInOut});
		FlxTween.tween(extraGradient, {alpha: 1}, 1, {startDelay: 0.25, ease: FlxEase.quintInOut});

		FlxTween.tween(clearPercentText, {x: clearPercentText.x + 65 + gradeAdjust, y: clearPercentText.y + 265}, 1, {startDelay: 0.25, ease: FlxEase.quintInOut, onComplete: function(t){
			if(rank == loss){
				var direction = (FlxG.random.bool(50)) ? 1 : -1;
				clearPercentText.acceleration.y = FlxG.random.int(850, 900);
				clearPercentText.velocity.y -= FlxG.random.int(310, 340);
				clearPercentText.velocity.x = 100 * direction;
				clearPercentText.angularVelocity = clearPercentText.velocity.x / 2;
				if(!exiting){ FlxG.sound.play(Paths.sound("freeplay/pop"), 0.7); }
			}
		}});

		character.playAnim();
		FlxG.sound.play(Paths.sound('confirmMenu'));
	}

	public function returnToMenu():Void{
		
		exiting = true;

		switch(PlayState.returnLocation){
			case "story":
				customTransOut = new StickerOut(useCustomStickerSet);

				switchState(new StoryMenuState(true));
				FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1, {onComplete: function(t){
					FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.65);
				}});
				FlxG.sound.music.fadeOut(0.8, 0, function(t){
					FlxG.sound.music.stop();
					Assets.cache.clear("assets/music/results");
				});
			case "freeplay":
				customTransOut = new StickerOut(FreeplayState.curCharacterStickers);
				FreeplayState.playStickerIntro = true;
				if(rank != loss){
					switchState(new FreeplayState(fromSongWin));
				}
				else{
					switchState(new FreeplayState(fromSongLose));
				}
				FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1, {onComplete: function(t){
					FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.65);
				}});
				FlxG.sound.music.fadeOut(0.8, 0, function(t) {
					FlxG.sound.music.stop();
					Assets.cache.clear("assets/music/results");
				});
			default:
				switchState(new MainMenuState());
				FlxG.sound.music.fadeOut(0.3, 0, function(t) {
					FlxG.sound.music.stop();
					Assets.cache.clear("assets/music/results");
				});
		}
	}

	var counterPitch:Float = 1;
	function playCounterSoundTickUp():Void{
		FlxG.sound.play(Paths.sound("scrollMenu"), 1).pitch = counterPitch;
		counterPitch += 1/12;
	}

	function percentCallback(numString:String):Void{
		var value = Std.parseFloat(numString.replace("-", "0"));
		value = (value/100) + 1;
		if(!exiting){ FlxG.sound.play(Paths.sound("scrollMenu"), 0.5).pitch = value; }
	}

	inline function rankToRankText(value:Rank) {
		return switch(value){
			case loss: character.lossText;
			case good: character.goodText;
			case great: character.greatText;
			case excellent: character.excellentText;
			case perfect: character.perfectText;
			default: character.goldText;
		}
	}

}

typedef SaveInfo = {
	song:String,
	week:Null<String>,
	diff:Int
}