package results;

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

class ResultsState extends FlxUIStateExt
{

    var camBg:FlxCamera;
    var camScroll:FlxCamera;
    var camCharacter:FlxCamera;
    var camUi:FlxCamera;

    var resultsTitle:FlxSprite;
    var ratingsStuff:FlxSprite;
    var scoreStuff:FlxSprite;

    var totalNoteCounter:DigitDisplay;
    var maxComboCounter:DigitDisplay;
    var sickCounter:DigitDisplay;
    var goodCounter:DigitDisplay;
    var badCounter:DigitDisplay;
    var shitCounter:DigitDisplay;
    var missCounter:DigitDisplay;
    var scoreCounter:DigitDisplay;

    public function new() {
        super();    
    }

    override function create() {

        Config.setFramerate(144);

		persistentUpdate = persistentDraw = true;

        camBg = new FlxCamera();

        camScroll = new FlxCamera();
        camScroll.bgColor = FlxColor.TRANSPARENT;

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

        //temp music i wanna hear somethin'
        FlxG.sound.playMusic(Paths.music("results/excellent-intro"), 1, false);
        FlxG.sound.music.onComplete = function() {
            FlxG.sound.playMusic(Paths.music("results/excellent-loop"), 1, true); 
        }

        var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
        bg.scrollFactor.set();
        bg.cameras = [camBg];

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
        resultsTitle.visible = false;
        new FlxTimer().start(6/24, function(t){
            resultsTitle.visible = true;
            resultsTitle.animation.play("");
        });

        ratingsStuff = new FlxSprite(-135, 135);
        ratingsStuff.frames = Paths.getSparrowAtlas("menu/results/ratingsPopin");
        ratingsStuff.animation.addByPrefix("", "", 24, false);
        ratingsStuff.visible = false;
        new FlxTimer().start(21/24, function(t){
            ratingsStuff.visible = true;
            ratingsStuff.animation.play("");
        });

        scoreStuff = new FlxSprite(-180, 515);
        scoreStuff.frames = Paths.getSparrowAtlas("menu/results/scorePopin");
        scoreStuff.animation.addByPrefix("", "", 24, false);
        scoreStuff.visible = false;
        new FlxTimer().start(36/24, function(t){
            scoreStuff.visible = true;
            scoreStuff.animation.play("");
        });

        //COUNTER STUFF AAAHHHHHHHH!!!!!

        totalNoteCounter = new DigitDisplay(374, 152, "menu/results/tallieNumber", -1, 1, 10);
        totalNoteCounter.ease = FlxEase.quartOut;
        totalNoteCounter.visible = false;
        new FlxTimer().start((0.3 * 0) + 1.2, function(t){
            totalNoteCounter.visible = true;
            totalNoteCounter.tweenNumber(500, 0.5);
        });

        maxComboCounter = new DigitDisplay(374, 202, "menu/results/tallieNumber", -1, 1, 10);
        maxComboCounter.ease = FlxEase.quartOut;
        maxComboCounter.visible = false;
        new FlxTimer().start((0.3 * 1) + 1.2, function(t){
            maxComboCounter.visible = true;
            maxComboCounter.tweenNumber(372, 0.5);
        });

        sickCounter = new DigitDisplay(229, 278, "menu/results/tallieNumber", -1, 1, 10);
        sickCounter.ease = FlxEase.quartOut;
        sickCounter.visible = false;
        new FlxTimer().start((0.3 * 2) + 1.2, function(t){
            sickCounter.visible = true;
            sickCounter.tweenNumber(250, 0.5);
        });

        goodCounter = new DigitDisplay(208, 332, "menu/results/tallieNumber", -1, 1, 10);
        goodCounter.ease = FlxEase.quartOut;
        goodCounter.visible = false;
        new FlxTimer().start((0.3 * 3) + 1.2, function(t){
            goodCounter.visible = true;
            goodCounter.tweenNumber(100, 0.5);
        });

        badCounter = new DigitDisplay(189, 383, "menu/results/tallieNumber", -1, 1, 10);
        badCounter.ease = FlxEase.quartOut;
        badCounter.visible = false;
        new FlxTimer().start((0.3 * 4) + 1.2, function(t){
            badCounter.visible = true;
            badCounter.tweenNumber(75, 0.5);
        });

        shitCounter = new DigitDisplay(219, 438, "menu/results/tallieNumber", -1, 1, 10);
        shitCounter.ease = FlxEase.quartOut;
        shitCounter.visible = false;
        new FlxTimer().start((0.3 * 5) + 1.2, function(t){
            shitCounter.visible = true;
            shitCounter.tweenNumber(40, 0.5);
        });

        missCounter = new DigitDisplay(259, 492, "menu/results/tallieNumber", -1, 1, 10);
        missCounter.ease = FlxEase.quartOut;
        missCounter.visible = false;
        new FlxTimer().start((0.3 * 6) + 1.2, function(t){
            missCounter.visible = true;
            missCounter.tweenNumber(35, 0.5);
        });

        scoreCounter = new DigitDisplay(71, 611, "menu/results/score-digital-numbers", 10, 1, -31, 0, false, true);
        scoreCounter.ease = FlxEase.cubeOut;
        scoreCounter.y += 150;
        new FlxTimer().start((0.3 * 7) + 1.2, function(t){
            FlxTween.tween(scoreCounter, {y: scoreCounter.y - 150}, 0.7, {ease: FlxEase.quintOut});
            scoreCounter.tweenNumber(123456, 1.5);
        });

        add(bg);
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

        super.create();
    }

    override function update(elapsed:Float) {

        if(FlxG.keys.anyJustPressed([TAB])){
            switchState(new ResultsState());
        }

        super.update(elapsed);
    }

    function finishedCounting():Void{
        
    }

}