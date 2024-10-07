package freeplay.characters;

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

    override function setup():Void{
        setPosition(-9, 290);
        loadAtlas(Paths.getTextureAtlas("menu/freeplay/dj/pico"));
        antialiasing = true;

        addAnimationByLabel('idle', "Idle", 24, true, -2);
        addAnimationByLabel('intro', "Intro", 24);
        addAnimationByLabel('confirm', "Confirm", 24, true, -8);
        addAnimationByLabel('cheerHold', "RatingHold", 24, true, 0);
        addAnimationByLabel('cheerWin', "Win", 24, true, -2);
        addAnimationByLabel('cheerLose', "Lose", 24, true, -2);
        addAnimationByLabel('jump', "Jump", 24, true, -4);
        addAnimationByLabel('idle1start', "Idle1", 24);

        animationEndCallback = function(name) {
            switch(name){
                case "intro":
                    introFinish();
                    playAnim("idle", true);
                case "idle2start":
                    playAnim("idle2loop", true);
            }
        }

        frameCallback = function(name, frame, index) {
            //switch(name){}
        }

        nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
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

    final canPlayIdleAfter:Array<String> = ["idle1start", "cheerWin", "cheerLose"];

    override function beat(curBeat:Int):Void{
        if(FlxG.sound.music.playing && curBeat % 2 == 0 && ((curAnim == "idle") || (canPlayIdleAfter.contains(curAnim) && finishedAnim))){
            if(!doRandomIdle){
                playAnim("idle", true);
            }
            else{
                playRandomIdle();
                doRandomIdle = false;
            }
        }
    }

    override function buttonPress():Void{
        afkTimer = 0;
		nextAfkTime = nextAfkTime = FlxG.random.float(minAfkTime, maxAfkTime);
		doRandomIdle = false;
    }

    override function playIntro():Void{
        playAnim("intro", true);
    }

    override function playConfirm():Void{
        playAnim("confirm", true);
    }

    override function playCheer(lostSong:Bool):Void{
        if(!lostSong){
        playAnim("cheerHold", true);
            new FlxTimer().start(1.3, function(t){
                playAnim("cheerWin", true);
            });
        }
        else{
            playAnim("cheerLose", true);
        }
    }

    override function toCharacterSelect() {
        playAnim("jump", true);
    }

    public function playRandomIdle():Void{
        if(idleCount == 0){ return; }
        var rng = FlxG.random.int(1, idleCount);
        playAnim("idle" + rng + "start", true);
    }

}