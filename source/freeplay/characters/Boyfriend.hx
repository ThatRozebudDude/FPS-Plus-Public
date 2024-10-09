package freeplay.characters;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import freeplay.ScrollingText.ScrollingTextInfo;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import config.Config;
import flixel.util.FlxTimer;
import flixel.FlxG;
import sys.FileSystem;
import flixel.sound.FlxSound;

class Boyfriend extends DJCharacter
{

    final idleCount:Int = 2;
    var doRandomIdle:Bool = false;
    var afkTimer:Float = 0;
	var nextAfkTime:Float = 5;
	static final minAfkTime:Float = 9;
	static final maxAfkTime:Float = 27;

    var sound:FlxSound = new FlxSound();
    var data:Array<Dynamic> = [];

    var scrollingText:FlxTypedSpriteGroup<FlxBackdrop> = new FlxTypedSpriteGroup<FlxBackdrop>();
    var scrollingTextStuff:Array<ScrollingTextInfo> = [];

    var cardFlash:FlxSprite;
    var cardPinkFlash:FlxSprite;
    var cardAcceptBg:FlxSprite;
    var cardAcceptText:AtlasSprite;
    var cardAcceptTextGlow:FlxSprite;
    var cardGlowBright:FlxSprite;
    var cardGlowDark:FlxSprite;

    override function setup():Void{
        setPosition(-9, 290);
        loadAtlas(Paths.getTextureAtlas("menu/freeplay/dj/bf"));
        antialiasing = true;

        addAnimationByLabel('idle', "Idle", 24, true, -2);
        addAnimationByLabel('intro', "Intro", 24);
        addAnimationByLabel('confirm', "Confirm", 24, true, -8);
        addAnimationByLabel('cheerHold', "RatingHold", 24, true, 0);
        addAnimationByLabel('cheerWin', "Win", 24, true, -4);
        addAnimationByLabel('cheerLose', "Lose", 24, true, -4);
        addAnimationByLabel('jump', "Jump", 24, true, -4);
        addAnimationByLabel('idle1start', "Idle1", 24);
        addAnimationByLabel('idle2start', "Idle2Start", 24);
        addAnimationByLabel('idle2loop', "Idle2Loop", 24, true);
        addAnimationByLabel('idle2end', "Idle2End", 24);

        animationEndCallback = function(name) {
            switch(name){
                case "intro":
                    introFinish();
                    skipNextIdle = true;
                    playAnim("idle", true);
                case "idle2start":
                    playAnim("idle2loop", true);
            }
        }

        var data = FileSystem.readDirectory("assets/sounds/freeplay/cartoons/");
        for(i in 0...data.length){ data[i] = data[i].split(".ogg")[0]; }
        //trace(data);

        FlxG.sound.list.add(sound);

        frameCallback = function(name, frame, index) {
            switch(name){
                case "idle2start":
                    if(frame == 81){
                        var soundPath = Paths.sound("freeplay/cartoons/" + data[FlxG.random.int(0, data.length-1)]);
                        //trace(soundPath);
                        sound.loadEmbedded(soundPath, true);
                        sound.play(true);
                        FlxG.sound.music.fadeOut(1, 0.25);
                        FlxG.sound.play(Paths.sound("freeplay/remoteClick"), 0.7, false);
                    }
            }
        }

        nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
        setupCard();
    }

    override function songList() {
        createCategory("ALL");
		createCategory("ERECT");

		addSong("Tutorial", "gf", 0, ["ALL", "Week 1"]);

		addSong("Bopeebo", "dad", 1, ["ALL", "Week 1"]);
		addSong("Fresh", "dad", 1, ["ALL", "Week 1"]);
		addSong("Dadbattle", "dad", 1, ["ALL", "Week 1"]);

		addSong("Spookeez", "spooky", 2, ["ALL", "Week 2"]);
		addSong("South", "spooky", 2, ["ALL", "Week 2"]);
		addSong("Monster", "monster", 2, ["ALL", "Week 2"]);

		addSong("Pico", "pico", 3, ["ALL", "Week 3"]);
		addSong("Philly", "pico", 3, ["ALL", "Week 3"]);
		addSong("Blammed", "pico", 3, ["ALL", "Week 3"]);

		addSong("Satin-Panties", "mom", 4, ["ALL", "Week 4"]);
		addSong("High", "mom", 4, ["ALL", "Week 4"]);
		addSong("Milf", "mom", 4, ["ALL", "Week 4"]);

		addSong("Cocoa", "parents-christmas", 5, ["ALL", "Week 5"]);
		addSong("Eggnog", "parents-christmas", 5, ["ALL", "Week 5"]);
		addSong("Winter-Horrorland", "monster", 5, ["ALL", "Week 5"]);

		addSong("Senpai", "senpai", 6, ["ALL", "Week 6"]);
		addSong("Roses", "senpai", 6, ["ALL", "Week 6"]);
		addSong("Thorns", "spirit", 6, ["ALL", "Week 6"]);

		addSong("Ugh", "tankman", 7, ["ALL", "Week 7"]);
		addSong("Guns", "tankman", 7, ["ALL", "Week 7"]);
		addSong("Stress", "tankman", 7, ["ALL", "Week 7"]);

		addSong("Darnell-Bf", "darnell", 101, ["ALL", "Weekend 1"]);

		//ERECT SONGS!!!!

		addSong("Bopeebo-Erect", "dad", 1, ["ERECT", "Week 1"]);
		addSong("Fresh-Erect", "dad", 1, ["ERECT", "Week 1"]);
		addSong("Dadbattle-Erect", "dad", 1, ["ERECT", "Week 1"]);

		addSong("Spookeez-Erect", "spooky", 2, ["ERECT", "Week 2"]);
		addSong("South-Erect", "spooky", 2, ["ERECT", "Week 2"]);

		addSong("Pico-Erect", "pico", 3, ["ERECT", "Week 3"]);
		addSong("Philly-Erect", "pico", 3, ["ERECT", "Week 3"]);
		addSong("Blammed-Erect", "pico", 3, ["ERECT", "Week 3"]);

		addSong("Satin-Panties-Erect", "mom", 4, ["ERECT", "Week 4"]);
		addSong("High-Erect", "mom", 4, ["ERECT", "Week 4"]);
		
		addSong("Cocoa-Erect", "parents-christmas", 5, ["ERECT", "Week 5"]);
		addSong("Eggnog-Erect", "parents-christmas", 5, ["ERECT", "Week 5"]);

		addSong("Senpai-Erect", "senpai", 6, ["ERECT", "Week 6"]);
		addSong("Roses-Erect", "senpai", 6, ["ERECT", "Week 6"]);
		addSong("Thorns-Erect", "spirit", 6, ["ERECT", "Week 6"]);

		addSong("Ugh-Erect", "tankman", 7, ["ERECT", "Week 7"]);

		SaveManager.global();
		if(Config.ee2 && Startup.hasEe2){
			addSong("Lil-Buddies", "bf", 0, ["Secret"]);
			addSong("Lil-Buddies-Erect", "bf", 0, ["Secret"]);
			//maybe i'll make... lil buddies... pico mix! :O
		}
    }

    override function update(elapsed:Float):Void{
        if(curAnim == "idle"){
            afkTimer += elapsed;
            if(afkTimer >= nextAfkTime){
                trace("random idle set");
                afkTimer = 0;
                nextAfkTime = nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
                doRandomIdle = true;
            }
        }

        super.update(elapsed);
    }

    final canPlayIdleAfter:Array<String> = ["idle1start", "idle2end", "cheerWin", "cheerLose"];

    override function beat(curBeat:Int):Void{
        if(FlxG.sound.music.playing && curBeat % 2 == 0 && !skipNextIdle &&  ((curAnim == "idle") || (canPlayIdleAfter.contains(curAnim) && finishedAnim))){
            if(!doRandomIdle){
                playAnim("idle", true);
            }
            else{
                playRandomIdle();
                doRandomIdle = false;
            }
        }
        else if(skipNextIdle){
            skipNextIdle = false;
        }
    }

    override function buttonPress():Void{
        afkTimer = 0;
		nextAfkTime = nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
		doRandomIdle = false;

        if(curAnim == "idle2loop"){
            playAnim("idle2end", true);
            if(sound.playing){ sound.fadeOut(1, 0, function(t){ sound.stop(); }); }
            FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume, 1);
        }
    }

    override function playIdle():Void{
        playAnim("idle", true);
    }

    override function playIntro():Void{
        playAnim("intro", true);
    }

    override function playConfirm():Void{
        playAnim("confirm", true);
    }

    override function playCheer(lostSong:Bool):Void{
        playAnim("cheerHold", true);
        new FlxTimer().start(1.3, function(t){
            if(!lostSong && curAnim == "cheerHold"){
                playAnim("cheerWin", true);
            }
            else if(curAnim == "cheerHold"){
                playAnim("cheerLose", true);
            }
        });
    }

    override function toCharacterSelect() {
        playAnim("jump", true);
        for(text in scrollingText){
            FlxTween.tween(text.velocity, {x: 0}, 1.4, {ease: FlxEase.sineIn});
        }
    }

    public function playRandomIdle():Void{
        if(idleCount == 0){ return; }
        var rng = FlxG.random.int(1, idleCount);
        playAnim("idle" + rng + "start", true);
    }

    override function backingCardStart():Void{
        FlxTween.cancelTweensOf(cardFlash);
        cardFlash.alpha = 1;
        FlxTween.tween(cardFlash, {alpha: 0}, 16/24, {ease: FlxEase.quartOut});
    }

    override function backingCardSelect():Void{
        cardAcceptBg.visible = true;

        cardAcceptText.visible = true;
        cardAcceptText.playAnim("text");

        cardPinkFlash.alpha = 1;
        FlxTween.tween(cardPinkFlash, {alpha: 0}, 6/24, {ease: FlxEase.quadOut});

        FlxTween.tween(cardGlowDark, {alpha: 0.5}, 0.33, {ease: FlxEase.quadOut, onComplete: function(t){
            cardGlowDark.alpha = 0.6;
            cardGlowBright.alpha = 1;
            cardAcceptTextGlow.visible = true;
            FlxTween.tween(cardAcceptTextGlow, {alpha: 0.4}, 0.5);
            FlxTween.tween(cardGlowBright, {alpha: 0}, 0.5);
        }});
    }

    function setupCard():Void{
        setUpScrollingText();
        addScrollingText();

        var bg = new FlxSprite().loadGraphic(Paths.image("menu/freeplay/bgs/bf/cardBg"));
		bg.antialiasing = true;
        backingCard.add(bg);

        backingCard.add(scrollingText);
        
        cardAcceptBg = Utils.makeColoredSprite(528, 720, 0xFF171831);
        cardAcceptBg.antialiasing = true;
        cardAcceptBg.visible = false;
        backingCard.add(cardAcceptBg);

        cardGlowBright = new FlxSprite(-30, 240).loadGraphic(Paths.image('menu/freeplay/bgs/bf/confirmGlowBright'));
        cardGlowBright.antialiasing = true;
        cardGlowBright.alpha = 0;
        cardGlowBright.blend = ADD;
        backingCard.add(cardGlowBright);

        cardGlowDark = new FlxSprite(cardGlowBright.x, cardGlowBright.y).loadGraphic(Paths.image('menu/freeplay/bgs/bf/confirmGlowDark'));
        cardGlowDark.antialiasing = true;
        cardGlowDark.alpha = 0;
        backingCard.add(cardGlowDark);

        cardAcceptText = new AtlasSprite(640, 420, Paths.getTextureAtlas("menu/freeplay/bgs/bf/backing-text-yeah"));
        cardAcceptText.antialiasing = true;
        cardAcceptText.visible = false;
        cardAcceptText.addFullAnimation("text", 24, false);
        backingCard.add(cardAcceptText);

        cardAcceptTextGlow = new FlxSprite(-8, 165).loadGraphic(Paths.image("menu/freeplay/bgs/bf/glowingText"));
        cardAcceptTextGlow.antialiasing = true;
        cardAcceptTextGlow.visible = false;
        cardAcceptTextGlow.blend = ADD;
        backingCard.add(cardAcceptTextGlow);

        cardPinkFlash = Utils.makeColoredSprite(528, 720, 0xFFFFD0D5);
        cardPinkFlash.antialiasing = true;
        cardPinkFlash.alpha = 0;
        backingCard.add(cardPinkFlash);

        cardFlash = Utils.makeColoredSprite(528, 720, 0xFFFEF8A5);
        cardFlash.antialiasing = true;
        cardFlash.blend = ADD;
        cardFlash.alpha = 0;
        backingCard.add(cardFlash);
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

}