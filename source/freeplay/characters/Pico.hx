package freeplay.characters;

import config.Config;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.FlxG;
import sys.FileSystem;
import flixel.sound.FlxSound;

class Pico extends DJCharacter
{

    final idleCount:Int = 1;
    var doRandomIdle:Bool = false;
    var afkTimer:Float = 0;
	var nextAfkTime:Float = 5;
	static final minAfkTime:Float = 9;
	static final maxAfkTime:Float = 27;

    var cardFlash:FlxSprite;
    var cardGlow:FlxSprite;
    var confirmAtlas:AtlasSprite;

    var scrollTop:FlxBackdrop;
    var scrollMiddle:FlxBackdrop;
    var scrollLower:FlxBackdrop;
    var scrollBack:FlxBackdrop;

    override function setup():Void{
        setPosition(-9, 290);
        freeplaySkin = "pico";
        capsuleDeselectColor = 0xFF9D9A96;
        capsuleSelectOutlineColor = 0xFF795629;
        capsuleDeselectOutlineColor = 0xFF4E2612;

        loadAtlas(Paths.getTextureAtlas("menu/freeplay/dj/pico"));
        antialiasing = true;

        addAnimationByLabel('idle', "Idle", 24, true, -8);
        addAnimationByLabel('intro', "Intro", 24);
        addAnimationByLabel('confirm', "Confirm", 24, true, -8);
        addAnimationByLabel('cheerHoldWin', "RatingHoldWin", 24, true, 0);
        addAnimationByLabel('cheerHoldLose', "RatingHoldLose", 24, true, 0);
        addAnimationByLabel('cheerWin', "Win", 24, false);
        addAnimationByLabel('cheerLose', "Lose", 24, false);
        addAnimationByLabel('jump', "Jump", 24, true, -8);
        addAnimationByLabel('idle1start', "Idle1", 24);

        animationEndCallback = function(name) {
            switch(name){
                case "intro":
                    introFinish();
                    skipNextIdle = true;
                    playAnim("idle", true);
                case "cheerWin" | "cheerLose":
                    playAnim("idle", true);
                case "idle1start":
                    playAnim("idle", true);
                    skipNextIdle = true;
            }
        }

        frameCallback = function(name, frame, index) {
            //switch(name){}
        }

        setupCard();
        nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
    }

    override function songList() {
        createCategory("ALL");

		addSong("Bopeebo-Pico", "dad", 1, ["ALL", "Week 1"]);
		addSong("Fresh-Pico", "dad", 1, ["ALL", "Week 1"]);
		addSong("Dadbattle-Pico", "dad", 1, ["ALL", "Week 1"]);

		addSong("Spookeez-Pico", "spooky", 2, ["ALL", "Week 2"]);
		addSong("South-Pico", "spooky", 2, ["ALL", "Week 2"]);

		addSong("Pico-Pico", "pico", 3, ["ALL", "Week 3"]);
		addSong("Philly-Pico", "pico", 3, ["ALL", "Week 3"]);
		addSong("Blammed-Pico", "pico", 3, ["ALL", "Week 3"]);

		addSong("Eggnog-Pico", "parents-christmas", 5, ["ALL", "Week 5"]);

		addSong("Ugh-Pico", "tankman", 7, ["ALL", "Week 7"]);
		addSong("Guns-Pico", "tankman", 7, ["ALL", "Week 7"]);

		addSong("Darnell", "darnell", 101, ["ALL", "Weekend 1"]);
		addSong("Lit-Up", "darnell", 101, ["ALL", "Weekend 1"]);
		addSong("2hot", "darnell", 101, ["ALL", "Weekend 1"]);
		addSong("Blazin", "darnell", 101, ["ALL", "Weekend 1"]);

        SaveManager.global();
		if(Config.ee2 && Startup.hasEe2){
			addSong("Lil-Buddies-Pico", "pico", 0, ["Secret"]);
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

        var scrollProgress:Float = Math.abs(scrollTop.x % (scrollTop.frameWidth + 20));

        if (scrollTop.animation.curAnim.finished == true){
            if (FlxMath.inBounds(scrollProgress, 500, 700) && scrollTop.animation.curAnim.name != 'sniper'){
                scrollTop.animation.play('sniper', true, false);
            }
        
            if (FlxMath.inBounds(scrollProgress, 700, 1300) && scrollTop.animation.curAnim.name != 'rifle'){
                scrollTop.animation.play('rifle', true, false);
            }
        
            if (FlxMath.inBounds(scrollProgress, 1450, 2000) && scrollTop.animation.curAnim.name != 'rocket launcher'){
                scrollTop.animation.play('rocket launcher', true, false);
            }
        
            if (FlxMath.inBounds(scrollProgress, 0, 300) && scrollTop.animation.curAnim.name != 'uzi'){
                scrollTop.animation.play('uzi', true, false);
            }
        }

        super.update(elapsed);
    }

    final canPlayIdleAfter:Array<String> = ["idle1start", "cheerWin", "cheerLose"];

    override function beat(curBeat:Int):Void{
        if(FlxG.sound.music.playing && curBeat % 2 == 0 && !skipNextIdle && ((curAnim == "idle") || (canPlayIdleAfter.contains(curAnim) && finishedAnim))){
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

        if(FlxG.sound.music.playing && curBeat % 2 == 0){
            FlxTween.cancelTweensOf(cardGlow);
            FlxTween.color(cardGlow, 8/24, 0xFFB7E5FF, 0xFF6C8DEB, {ease: FlxEase.quadOut});
        }
    }

    override function buttonPress():Void{
        afkTimer = 0;
		nextAfkTime = nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
		doRandomIdle = false;
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
        if(!lostSong){
            playAnim("cheerHoldWin", true);
            new FlxTimer().start(1.35, function(t){
                if(curAnim == "cheerHoldWin"){
                    playAnim("cheerWin", true);
                }
            });
        }
        else{
            playAnim("cheerHoldLose", true);
            new FlxTimer().start(1.35, function(t){
                if(curAnim == "cheerHoldLose"){
                    playAnim("cheerLose", true);
                }
            });
        }
    }

    override function toCharacterSelect() {
        playAnim("jump", true);
        FlxTween.tween(scrollBack.velocity, {x: 0}, 1.2, {ease: FlxEase.sineIn});
        FlxTween.tween(scrollLower.velocity, {x: 0}, 1.2, {ease: FlxEase.sineIn});
        FlxTween.tween(scrollTop.velocity, {x: 0}, 1.2, {ease: FlxEase.sineIn});
        FlxTween.tween(scrollMiddle.velocity, {x: 0}, 1.2, {ease: FlxEase.sineIn});
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
        confirmAtlas.visible = true;
        confirmAtlas.playAnim("confirm");
    }

    function setupCard():Void{
        
        var bg = Utils.makeColoredSprite(528, 720, 0xFF98A2F3);
		bg.antialiasing = true;
        backingCard.add(bg);

        scrollBack = new FlxBackdrop(Paths.image('menu/freeplay/bgs/pico/lowerLoop'), X, 20);
        scrollBack.setPosition(0, 200);
        scrollBack.flipX = true;
        scrollBack.alpha = 0.39;
        scrollBack.velocity.x = 110;
        scrollBack.antialiasing = true;
        backingCard.add(scrollBack);

        scrollLower = new FlxBackdrop(Paths.image('menu/freeplay/bgs/pico/lowerLoop'), X, 20);
        scrollLower.setPosition(0, 406);
        scrollLower.velocity.x = -110;
        scrollLower.antialiasing = true;
        backingCard.add(scrollLower);

        var bar = new FlxSprite().loadGraphic(Paths.image("menu/freeplay/bgs/pico/blueBar"));
		bar.antialiasing = true;
        bar.blend = MULTIPLY;
        bar.alpha = 0.4;
        backingCard.add(bar);

        scrollTop = new FlxBackdrop(null, X, 20);
        scrollTop.setPosition(0, 80);
        scrollTop.velocity.x = -220;
        scrollTop.antialiasing = true;
        scrollTop.frames = Paths.getSparrowAtlas('menu/freeplay/bgs/pico/topLoop');
        scrollTop.animation.addByPrefix('uzi', 'uzi info', 24, false);
        scrollTop.animation.addByPrefix('sniper', 'sniper info', 24, false);
        scrollTop.animation.addByPrefix('rocket launcher', 'rocket launcher info', 24, false);
        scrollTop.animation.addByPrefix('rifle', 'rifle info', 24, false);
        scrollTop.animation.addByPrefix('base', 'base', 24, false);
        scrollTop.animation.play('base');
        backingCard.add(scrollTop);

        scrollMiddle = new FlxBackdrop(Paths.image('menu/freeplay/bgs/pico/middleLoop'), X, 15);
        scrollMiddle.setPosition(0, 346);
        scrollMiddle.velocity.x = 220;
        scrollMiddle.antialiasing = true;
        backingCard.add(scrollMiddle);

        cardGlow = new FlxSprite().loadGraphic(Paths.image("menu/freeplay/bgs/pico/glow"));
        cardGlow.antialiasing = true;
        cardGlow.color = 0xFFB7E5FF;
        backingCard.add(cardGlow);

        cardFlash = Utils.makeColoredSprite(528, 720, 0xFF87C9FF);
        cardFlash.antialiasing = true;
        cardFlash.blend = ADD;
        cardFlash.alpha = 0;
        backingCard.add(cardFlash);

        confirmAtlas = new AtlasSprite(5, 55, Paths.getTextureAtlas("menu/freeplay/bgs/pico/pico-confirm"));
        confirmAtlas.antialiasing = true;
        confirmAtlas.addFullAnimation("confirm", 24, false);
        confirmAtlas.visible = false;
        backingCard.add(confirmAtlas);
    }

}