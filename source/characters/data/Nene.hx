package characters.data;

import stages.elements.ABot;
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
        addByPrefix("sad", offset(0, 0), "Laugh", 24, loop(true, -6), false, false);
        addByIndices("laughCutscene", offset(0, 0), "Laugh", [0,1,2,3,4,5,6,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11], "", 24, loop(false, 0), false, false);
        addByPrefix("comboCheer", offset(-120, 53), "ComboCheer", 24, loop(false, 0), false, false);
        addByIndices("comboCheerHigh", offset(-40, -20), "ComboFawn", [0,1,2,3,4,5,6,4,5,6,4,5,6,4,5,6], "", 24, loop(false, 0), false, false);
        addByPrefix("raiseKnife", offset(0, 51), "KnifeRaise", 24, loop(false, 0), false, false);
        addByPrefix("idleKnife", offset(-98, 51), "KnifeIdle", 24, loop(false, 0), false, false);
        addByPrefix("lowerKnife", offset(135, 51), "KnifeLower", 24, loop(false, 0), false, false);

        addAnimChain("raiseKnife", "idleKnife");
        addAnimChain("laughCutscene", "idleLoop");

        info.idleSequence = ["danceLeft", "danceRight"];

        info.functions.create = create;
        info.functions.add = onAdd;
        info.functions.songStart = songStart;
        info.functions.update = update;
        info.functions.beat = beat;
        info.functions.danceOverride = danceOverride;

        addExtraData("reposition", [0, -165]);
    }

    var knifeRaised:Bool = false;
    var blinkTime:Float = 0;

    var abot:ABot;
    var abotLookDir:Bool = false;

    final BLINK_MIN:Float = 1;
    final BLINK_MAX:Float = 3;

    function create(character:Character):Void{
        abot = new ABot(-134.5, 311);
		abot.lookLeft();
        addToCharacter(abot);
    }

    //ABot doesn't move with the reposition for some reason. Maybe because he is a sprite group?
    function onAdd(character:Character):Void{
        //abot.setPosition(character.x - 134.5, character.y + 311);
        abot.x += character.reposition.x;
		abot.y += character.reposition.y;
    }

    function update(character:Character, elapsed:Float):Void{
        
        if(character.curAnim == "idleKnife"){
            blinkTime -= elapsed;

            if(blinkTime <= 0){
                character.playAnim("idleKnife", true);
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
            }
        }

        if(!character.debugMode){
            if(playstate.camFocus == "dad" && abotLookDir){
                abotLookDir = !abotLookDir;
                abot.lookLeft();
            }
            else if(playstate.camFocus == "bf" && !abotLookDir){
                abotLookDir = !abotLookDir;
                abot.lookRight();
            }
        }
        
    }

    function beat(character:Character, beat:Int) {
        abot.bop();

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

    function songStart(character:Character):Void{
        abot.setAudioSource(FlxG.sound.music);
		abot.startVisualizer();
    }

}