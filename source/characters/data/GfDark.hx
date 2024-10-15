package characters.data;

import flixel.tweens.FlxEase;
using StringTools;

@charList(false)
@gfList(true)
class GfDark extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "gf-dark";
        info.spritePath = "week2/gf_dark";
        info.frameLoadType = sparrow;
        
        info.iconName = "gf";
		info.focusOffset.set();

        addByIndices('danceLeft', offset(0, -8), 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, loop(false));
		addByIndices('danceRight', offset(0, -8), 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, loop(false));
		addByIndices('idleLoop', offset(0, -8), 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, loop(true));
		addByPrefix('cheer', offset(), 'GF Cheer', 24, loop(false));
		addByPrefix('scared', offset(-2, -16), 'GF FEAR', 24);

		info.idleSequence = ["danceLeft", "danceRight"];

        info.functions.create = create;

        addAction("flashOn", flashOn);
        addAction("flashOff", flashOff);
        addAction("flashFade", flashFade);
    }

    var flash:Character;

    function create(character:Character):Void{
        flash = new Character(0, 0, "Gf", characterReference.isPlayer, characterReference.isGirlfriend, characterReference.debugMode);
        flash.noLogic = true;
        character.attachCharacter(flash, [withPlayAnim]);
        addToCharacter(flash);
    }

    function flashOn(character:Character):Void{
        character.getSprite().alpha = 0;
    }

    function flashOff(character:Character):Void{
        character.getSprite().alpha = 1;
    }

    function flashFade(character:Character):Void{
        character.getSprite().alpha = 0;
        playstate.tweenManager.tween(character.getSprite(), {alpha: 1}, 1.5);
    }
}