package freeplay.characters;

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

        if(curAnim == "idle2loop"){
            playAnim("idle2end", true);
            if(sound.playing){ sound.fadeOut(1, 0, function(t){ sound.stop(); }); }
            FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume, 1);
        }
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
            if(!lostSong){
                playAnim("cheerWin", true);
            }
            else{
                playAnim("cheerLose", true);
            }
        });
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