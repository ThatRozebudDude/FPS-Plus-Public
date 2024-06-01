package freeplay;

import flixel.FlxSprite;

class DJCharacter extends FlxSprite
{

    public var introFinish:Void->Void;

    public function new(_x:Float, _y:Float, _character:String = "bf", _introFinish:Void->Void) {
        super(_x, _y);
        introFinish = _introFinish;
        setCharacter(_character);
    }

    function setCharacter(character:String):Void{
        switch(character){
            case "bf":
                frames = Paths.getSparrowAtlas("menu/freeplay/dj/bf");
                antialiasing = true;

                animation.addByPrefix("idle", "Boyfriend DJ0", 24, false, false, false);
                animation.addByPrefix("intro", "boyfriend dj intro", 24, false, false, false);
                animation.addByPrefix("confirm", "Boyfriend DJ confirm", 24, false, false, false);
                
                animation.callback = function(name, frameNumber, frameIndex) {
                    switch(name){
                        case "idle":
                            offset.set(0, 0);
                        case "intro":
                            offset.set(5, 427);
                        case "confirm":
                            offset.set(43, -24);
                    }
                }

                animation.finishCallback = function(name) {
                    switch(name){
                        case "idle":
                            animation.play("idle", true, false, animation.curAnim.numFrames - 4);
                        case "intro":
                            introFinish();
                            animation.play("idle", true);
                    }
                }
        }
    }

}