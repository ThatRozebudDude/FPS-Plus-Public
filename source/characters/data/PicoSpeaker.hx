package characters.data;

import flixel.FlxG;
import stages.elements.TankmenBG;

@charList(false)
@gfList(true)
class PicoSpeaker extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-speaker";
        info.spritePath = "week7/picoSpeaker";
        info.frameLoadType = sparrow;
        
        info.iconName = "pico";
        info.focusOffset.set();

        addByPrefix('shoot1', offset(), "Pico shoot 1", 24, loop(true, -3));
		addByPrefix('shoot2', offset(0, -128), "Pico shoot 2", 24, loop(true, -3));
		addByPrefix('shoot3', offset(413, -64), "Pico shoot 3", 24, loop(true, -3));
		addByPrefix('shoot4', offset(440, -19), "Pico shoot 4", 24, loop(true, -3));

        info.idleSequence = [];

        info.functions.update = update;
        info.functions.idleEndOverride = idleEndOverride;

        addExtraData("reposition", [254, 18]);
    }

    function update(character:Character, elpased:Float):Void{
        if (TankmenBG.animationNotes.length > 0){
            if (Conductor.songPosition > TankmenBG.animationNotes[0][0]){
                //trace('played shoot anim' + TankmenBG.animationNotes[0][1]);

                var shootAnim:Int = 1;

                if (TankmenBG.animationNotes[0][1] >= 2)
                    shootAnim = 3;

                shootAnim += FlxG.random.int(0, 1);

                character.playAnim('shoot' + shootAnim, true);
                TankmenBG.animationNotes.shift();
            }
        }
    }

    function idleEndOverride(character:Character):Void{
        character.playAnim(character.curAnim, true, false, character.getAnimLength(character.curAnim) - 1);
    }

}