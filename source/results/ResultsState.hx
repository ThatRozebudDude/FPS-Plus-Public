package results;

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

using StringTools;

class ResultsState extends FlxUIStateExt
{

    var camBg:FlxCamera;
    var camScroll:FlxCamera;
    var camCharacter:FlxCamera;
    var camUi:FlxCamera;

    var character:ResultsCharacter;

    var extraGradient:FlxSprite;

    var resultsTitle:FlxSprite;
    var ratingsStuff:FlxSprite;
    var scoreStuff:FlxSprite;
    var highscoreNew:FlxSprite;

    var totalNoteCounter:DigitDisplay;
    var maxComboCounter:DigitDisplay;
    var sickCounter:DigitDisplay;
    var goodCounter:DigitDisplay;
    var badCounter:DigitDisplay;
    var shitCounter:DigitDisplay;
    var missCounter:DigitDisplay;
    var scoreCounter:DigitDisplay;

    var clearPercentText:FlxSprite;
    var clearPercentSymbol:FlxSprite;
    var clearPercentCounter:DigitDisplay;

    var scrollingRankName:FlxBackdrop;

    var bitmapSongName:FlxBitmapText;

    var scrollingTextGroup:FlxSpriteGroup = new FlxSpriteGroup();

    final goldText:Array<String> =      ["PERFECT ", "CAN'T GET MUCH BETTER ", "UNTOUCHABLE ", "NOTHING BUT THE BEST ", "FLAWLESS ", "AAA+++ TRIPLE ULTRA DELUXE "];
    final perfectText:Array<String> =   ["PERFECT ", "TOP NOTCH ", "CAN'T MISS ", "YOU DID IT ", "SICK "];
    final excellentText:Array<String> = ["EXCELLENT ", "YOU DID IT ", "AMAZING EXECUTION ", "HIT THOSE NOTES ", "AWESOME "];
    final greatText:Array<String> =     ["GREAT ", "GREAT JOB ", "NICE JOB ", "WELL DONE ", "KEEP IT UP "];
    final goodText:Array<String> =      ["GOOD ", "ACCEPTABLE ", "NOT BAD ", "WELL DONE ", "KEEP IT UP "];
    final lossText:Array<String> =      ["LOSS ", "YOU'RE A FAILURE ", "BE ASHAMED ", "WHAT WAS THAT ", "HORRIBLE ", "TRY AGAIN "];

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

    public function new(_scoreStats:ScoreStats, ?_songNameText:String = "Fabs is on base game", ?_character:String = "bf", ?_saveInfo:SaveInfo = null) {
        super();

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

        totalNotes = scoreStats.sickCount + scoreStats.goodCount + scoreStats.badCount + scoreStats.shitCount;
        if(totalNotes + scoreStats.missCount > 0){
            grade = (scoreStats.sickCount + scoreStats.goodCount) / (totalNotes + scoreStats.missCount);
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

        camScroll = new FlxCamera();
        camScroll.bgColor = FlxColor.TRANSPARENT;
        camScroll.angle = -3.8;

        camCharacter = new FlxCamera();
        camCharacter.bgColor = FlxColor.TRANSPARENT;

        camUi = new FlxCamera();
        camUi.bgColor = FlxColor.TRANSPARENT;

        FlxG.cameras.add(camBg, false);
        FlxG.cameras.add(camScroll, false);
		FlxG.cameras.add(camCharacter, false);
		FlxG.cameras.add(camUi, false);
		FlxG.cameras.setDefaultDrawTarget(camUi, true);
        this.camera = camUi;

        FlxG.sound.playMusic(Paths.music("results/excellent-intro"), 1, false);
        FlxG.sound.music.onComplete = function() {
            playSongBasedOnRank(rank);
            finishedCounting();
        }

        var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
        bg.scrollFactor.set();
        bg.cameras = [camBg];

        extraGradient = new FlxSprite().loadGraphic(Paths.image("menu/results/gradientCover"));
        extraGradient.color = 0xFFFDC05C;
        extraGradient.x = 1280 - 460;
        extraGradient.y = 720 - 128;
        extraGradient.alpha = 0;

        var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/results/topBarBlack"));
        blackTopBar.y = -blackTopBar.height;
        FlxTween.tween(blackTopBar, {y: 0}, 7/24, {ease: FlxEase.quartOut, startDelay: 3/24});

        var soundSystem:FlxSprite = new FlxSprite(-15, -180);
        soundSystem.frames = Paths.getSparrowAtlas("menu/results/soundSystem");
        soundSystem.animation.addByPrefix("", "", 24, false);
        soundSystem.visible = false;
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
        highscoreNew.animation.finishCallback = function(name) {
            highscoreNew.animation.play("", true, false, highscoreNew.animation.curAnim.numFrames - 12);
        }

        //COUNTER STUFF AAAHHHHHHHH!!!!!

        

        totalNoteCounter = new DigitDisplay(374, 152, "menu/results/tallieNumber", -1, 1, 10);
        totalNoteCounter.ease = FlxEase.quartOut;
        totalNoteCounter.visible = false;
        new FlxTimer().start((0.3 * 0) + 1.2, function(t){
            totalNoteCounter.visible = true;
            totalNoteCounter.tweenNumber(totalNotes, 0.5);
            playCounterSoundTickUp();
        });

        maxComboCounter = new DigitDisplay(374, 202, "menu/results/tallieNumber", -1, 1, 10);
        maxComboCounter.ease = FlxEase.quartOut;
        maxComboCounter.visible = false;
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

        clearPercentCounter = new DigitDisplay(838 - 80, 349, "menu/results/clearPercentNumbers", 3, 1, 0, 0, true, false);
        clearPercentCounter.ease = FlxEase.quartOut;
        clearPercentCounter.setDigitOffset("1", -13);
        clearPercentCounter.visible = false;
        clearPercentCounter.callback = percentCallback;

        clearPercentSymbol = new FlxSprite(clearPercentCounter.x + 80, clearPercentCounter.y + clearPercentCounter.height).loadGraphic(Paths.image("menu/results/clearPercentSymbol"));
        clearPercentSymbol.y -= clearPercentSymbol.height;
        clearPercentSymbol.antialiasing = true;
        clearPercentSymbol.visible = false;

        clearPercentText = new FlxSprite(clearPercentCounter.x + 80, clearPercentCounter.y + clearPercentCounter.height).loadGraphic(Paths.image("menu/results/clearPercentText"));
        clearPercentText.y -= clearPercentSymbol.height;
        clearPercentText.antialiasing = true;
        clearPercentText.visible = false;

        new FlxTimer().start((0.3 * 7) + 1.2, function(t){
            clearPercentCounter.visible = true;
            clearPercentCounter.tweenNumber(Math.floor(grade * 100), 1.7);

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

            var tempText = new FlxText(0, 0, 0, textArray[textIndex]);
			tempText.setFormat(Paths.font("5by7"), 50, 0xFFFEDA6C);
			tempText.antialiasing = true;

			var scrolling:FlxBackdrop = ScrollingText.createScrollingText(0, 50 + (135 * (i+1) / 2) + 10, tempText);
			//scrolling.velocity.x = FlxG.random.int(5, 9);
			scrolling.velocity.x = (i % 2 == 0) ? -8 : 8;
			scrolling.antialiasing = true;
			
			scrollingTextGroup.add(scrolling);
        }
        scrollingTextGroup.visible = false;
        scrollingTextGroup.cameras = [camScroll];

        var rankName:String = "";
        for(char in textArray[0].split("")){ rankName += char + "\n"; }
        rankName = rankName.substr(0, rankName.length-2);

        var tempRankText = new FlxTextExt(0, 0, 0, rankName);
		tempRankText.setFormat(Paths.font("5by7"), 100, 0xFFFFFFFF);
		tempRankText.antialiasing = true;
		tempRankText.leading = 10;

		scrollingRankName = ScrollingText.createScrollingText(1280 - tempRankText.width, 0, tempRankText, Y);
		scrollingRankName.velocity.y = 30;
		scrollingRankName.antialiasing = true;
		scrollingRankName.visible = false;
		scrollingRankName.spacing.y = 7;

		bitmapSongName = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/resultFont"), Utils.resultsTextCharacters, FlxPoint.get(49, 62)));
		bitmapSongName.text = songNameText + " ";
		bitmapSongName.letterSpacing = -15;
		bitmapSongName.antialiasing = true;
		bitmapSongName.setPosition(545, 120);
		bitmapSongName.cameras = [camScroll];
        bitmapSongName.y -= 300;
        new FlxTimer().start(36/24, function(t){
            FlxTween.tween(bitmapSongName, {y: bitmapSongName.y + 300}, 1.2, {ease: FlxEase.quintOut});
        });

        var songNameShader = new ColorGradientShader(0xFFF98862, 0xFFF9FEB1);
        bitmapSongName.shader = songNameShader.shader;

        character = new ResultsCharacter(characterString, rank);
        character.cameras = [camCharacter];

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

        super.create();
    }

    override function update(elapsed:Float) {

        if((Binds.justPressed("menuAccept") || Binds.justPressed("menuBack")) && !exiting && shownRank){
            returnToMenu();
        }

        /*if(FlxG.keys.anyJustPressed([TAB])){
            if(FlxG.keys.anyPressed([SHIFT])){
                switchState(new ResultsState(null));
            }
            else{
                switchState(new ResultsState(scoreStats, songNameText, characterString, saveInfo));
            }
        }*/

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
        camBg.flash(0xFFFEDA6C, 1);

        if(prevHighscore < scoreStats.score){
            highscoreNew.animation.play("", true);
            highscoreNew.visible = true;
        }

        scrollingRankName.visible = true;

        var gradeAdjust = 0;
        if(grade == 1){
            gradeAdjust = 35;
        }

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
    }

    public function returnToMenu():Void{
        
        exiting = true;

		switch(PlayState.returnLocation){
			case "story":

                var stickerSets:Array<String> = null;

                trace(saveInfo.week);

                switch(saveInfo.week){
                    case 0:
                        stickerSets = ["bf", "gf"];
                    case 1:
                        stickerSets = ["bf", "gf", "dad"];
                    case 2:
                        stickerSets = ["bf", "gf", "skid", "pump", "monster"];
                    case 3:
                        stickerSets = ["bf", "gf", "pico"];
                    case 4:
                        stickerSets = ["bf", "gf", "mom"];
                    case 5:
                        stickerSets = ["bf", "gf", "dad", "mom", "monster"];
                    case 6:
                        stickerSets = ["bf", "gf", "spirit", "senpai"];
                    case 7:
                        stickerSets = ["bf", "gf", "pico", "tankman"];
                    case 101:
                        stickerSets = ["pico", "nene", "darnell"];
                }

                customTransOut = new StickerOut(stickerSets);

				switchState(new StoryMenuState(true));
                FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1, {onComplete: function(t){
                    FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.65);
                }});
                FlxG.sound.music.fadeOut(0.8, 0, function(t){
                    FlxG.sound.music.stop();
                });
			case "freeplay":
                customTransOut = new StickerOut();
			    FreeplayState.playStickerIntro = true;
				switchState(new FreeplayState(false));
                FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1, {onComplete: function(t){
                    FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.65);
                }});
                FlxG.sound.music.fadeOut(0.8, 0, function(t) {
                    FlxG.sound.music.stop();
                });
			default:
				switchState(new MainMenuState());
                FlxG.sound.music.fadeOut(0.3, 0, function(t) {
                    FlxG.sound.music.stop();
                });
		}
	}

    function playSongBasedOnRank(_rank:Rank):Void{
        switch(characterString){
            default:
                switch(_rank){
                    case perfect | gold:
                        FlxG.sound.playMusic(Paths.music("results/perfect"), 1, true); 
                    case excellent:
                        FlxG.sound.playMusic(Paths.music("results/excellent-loop"), 1, true); 
                    case loss:
                        FlxG.sound.playMusic(Paths.music("results/shit-intro"), 1, true);
                        FlxG.sound.music.onComplete = function() {
                            FlxG.sound.playMusic(Paths.music("results/shit-loop"), 1, true); 
                        }
                    default:
                        FlxG.sound.playMusic(Paths.music("results/normal"), 1, true); 
                }
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
            case loss: lossText;
            case good: goodText;
            case great: greatText;
            case excellent: excellentText;
            case perfect: perfectText;
            default: goldText;
        }
    }

}

typedef SaveInfo = {
    song:String,
    week:Null<Int>,
    diff:Int
}