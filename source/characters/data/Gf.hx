package characters.data;

using StringTools;

@gfList(true)
class Gf extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "gf";
        info.spritePath = "GF_assets";
        info.frameLoadType = sparrow;
        
        info.iconName = "gf";
		info.focusOffset.set();

        addByIndices('danceLeft', offset(0, -9), 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, loop(false));
		addByIndices('danceRight', offset(0, -9), 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, loop(false));
		addByIndices('idleLoop', offset(0, -9), 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, loop(true));
		addByPrefix('cheer', offset(), 'GF Cheer', 24, loop(false));
		addByPrefix('singLEFT', offset(0, -19), 'GF left note', 24, loop(false));
		addByPrefix('singRIGHT', offset(0, -20), 'GF Right Note', 24, loop(false));
		addByPrefix('singUP', offset(0, 4), 'GF Up Note', 24, loop(false));
		addByPrefix('singDOWN', offset(0, -20), 'GF Down Note', 24, loop(false));
		addByIndices('sad', offset(-2, -21), 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, loop(false));
		addByIndices('hairBlow', offset(45, -8), "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
		addByIndices('hairFall', offset(0, -9), "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, loop(false));
		addByPrefix('scared', offset(-2, -17), 'GF FEAR', 24);

		info.idleSequence = ["danceLeft", "danceRight"];

		info.functions.create = create;
		info.functions.update = update;
		info.functions.danceOverride = danceOverride;
		info.functions.playAnim = playAnim;
    }

	function create(character:Character):Void{
		if(!character.isGirlfriend){
			character.focusOffset.set(150 * (character.isPlayer ? -1 : 1), -100);
		}
	}

	function update(character:Character, elpased:Float):Void{
		if (character.curAnim == 'hairFall' && character.curAnimFinished()){
			character.playAnim('danceRight');
		}
	}

	function danceOverride(character:Character):Void{
		if (!character.curAnim.startsWith('hair')){
			character.defaultDanceBehavior();
		}
	}

	function playAnim(character:Character, anim:String):Void{
		if (anim == 'singLEFT') { character.idleSequenceIndex = 1; }
		else if (anim == 'singRIGHT') { character.idleSequenceIndex = 0; }
		//if (anim == 'singUP' || anim == 'singDOWN') { character.idleSequenceIndex++; }
	}

}