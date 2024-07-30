package characters.data;

import flixel.FlxG;
import flixel.math.FlxPoint;

@charList(false)
@gfList(true)
class Nene extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "nene";
        info.spritePath = "weekend1/Nene";
        info.frameLoadType = sparrow;
        
        info.iconName = "face";
        info.focusOffset = new FlxPoint();

		addByIndices("danceLeft", offset(0, 0), "Idle", [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, loop(false, 0), false, false);
        addByIndices("danceRight", offset(0, 0), "Idle", [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, loop(false, 0), false, false);
        addByPrefix("idleLoop", offset(0, 0), "Idle", 24, loop(true, 0), false, false);
        addByIndices("sad", offset(0, 0), "Laugh", [0,1,2,3,4,5,6], "", 24, loop(false, 0), false, false);
        addByIndices("laughCutscene", offset(0, 0), "Laugh", [0,1,2,3,4,5,6,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11], "", 24, loop(false, 0), false, false);
        addByPrefix("comboCheer", offset(-120, 53), "ComboCheer", 24, loop(false, 0), false, false);
        addByIndices("comboCheerHigh", offset(-40, -20), "ComboFawn", [0,1,2,3,4,5,6,4,5,6,4,5,6,4,5,6], "", 24, loop(false, 0), false, false);
        addByPrefix("raiseKnife", offset(0, 52), "KnifeRaise", 24, loop(false, 0), false, false);
        addByPrefix("idleKnife", offset(-99, 52), "KnifeIdle", 24, loop(false, 0), false, false);
        addByPrefix("lowerKnife", offset(135, 52), "KnifeLower", 24, loop(false, 0), false, false);

        addAnimChain("raiseKnife", "idleKnife");
        addAnimChain("laughCutscene", "idleLoop");

        info.idleSequence = ["danceLeft", "danceRight"];

        info.functions.update = update;
        info.functions.beat = beat;
        info.functions.danceOverride = danceOverride;
    }

    var knifeRaised:Bool = false;
    var blinkTime:Float = 0;

    final BLINK_MIN:Float = 1;
    final BLINK_MAX:Float = 3;

    function update(character:Character, elapsed:Float):Void{
        
        if(character.curAnim == "idleKnife"){
            blinkTime -= elapsed;

            if(blinkTime <= 0){
                character.playAnim("idleKnife", true);
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
            }
        }

    }

    function beat(character:Character, beat:Int) {

        //raise knife on low health
        if(PlayState.SONG.song.toLowerCase() != "blazin"){
            if(PlayState.instance.health < 0.4 && !knifeRaised){
                knifeRaised = true;
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
                character.playAnim("raiseKnife", true);
            } 
            else if(PlayState.instance.health >= 0.4 && knifeRaised && character.curAnim == "idleKnife"){
                knifeRaised = false;
                character.playAnim("lowerKnife", true);
                character.idleSequenceIndex = 0;
                character.danceLockout = true;
            }
        }

    }

    function danceOverride(character:Character):Void{
        if(!knifeRaised){
            character.defaultDanceBehavior();
        }
    }

}