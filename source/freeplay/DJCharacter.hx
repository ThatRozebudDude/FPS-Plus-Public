package freeplay;

import sys.FileSystem;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;

class DJCharacter extends AtlasSprite
{

    public var introFinish:Void->Void;
    var idleCount:Int = 0;

    public var doRandomIdle:Bool = false;

    public var character:String;

    var sound:FlxSound = new FlxSound();
    var data:Array<Dynamic> = [];

    public function new(_x:Float, _y:Float, _character:String = "bf", _introFinish:Void->Void) {
        super(_x, _y, null);
        introFinish = _introFinish;
        setCharacter(_character);
    }

    function setCharacter(_character:String):Void{

        character = _character;
        loadAtlas(Paths.getTextureAtlas("menu/freeplay/dj/" + character));

        switch(character){
            case "bf":
                antialiasing = true;

                addAnimationByLabel('idle', "Idle", 24, true, -2);
                addAnimationByLabel('intro', "Intro", 24);
                addAnimationByLabel('confirm', "Confirm", 24, true, -8);
                addAnimationByLabel('idle1start', "Idle1", 24);
                addAnimationByLabel('idle2start', "Idle2Start", 24);
                addAnimationByLabel('idle2loop', "Idle2Loop", 24, true);
                addAnimationByLabel('idle2end', "Idle2End", 24);

                idleCount = 2;

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
        }
    }

    public function playRandomIdle():Void{
        if(idleCount == 0){ return; }
        var rng = FlxG.random.int(1, idleCount);
        playAnim("idle" + rng + "start", true);
    }

    public function beat(curBeat:Int):Void{
        switch(character){
			case "bf":
				if(FlxG.sound.music.playing && curBeat % 2 == 0 && ((curAnim == "idle") || (curAnim == "idle1start" && finishedAnim) || (curAnim == "idle2end" && finishedAnim))){
                    if(!doRandomIdle){
                        playAnim("idle", true);
                    }
                    else{
                        playRandomIdle();
                        doRandomIdle = false;
                    }
				}
		}
    }


    public function buttonPress():Void{
        switch(character){
			case "bf":
				if(curAnim == "idle2loop"){
                    playAnim("idle2end", true);
                    if(sound.playing){ sound.fadeOut(1, 0, function(t){ sound.stop(); }); }
                    FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume, 1);
                }
		}
    }

}