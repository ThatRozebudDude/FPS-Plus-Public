package characters.data;

class SpookyDark extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "spooky-dark";
        info.spritePath = "week2/spooky_dark";
        info.frameLoadType = sparrow;
        
        info.iconName = "spooky";
        info.focusOffset.set(150, -65);

		addByIndices('danceLeft', offset(), 'Idle', [0, 2, 4, 6], "", 12, loop(false));
		addByIndices('danceRight', offset(), 'Idle', [8, 10, 12, 14], "", 12, loop(false));
		addByPrefix('singUP', offset(-18, 25), 'SingUP', 24, loop(false));
		addByPrefix('singDOWN', offset(-46, -144), 'SingDOWN', 24, loop(false));
		addByPrefix('singLEFT', offset(124, -13), 'SingLEFT', 24, loop(false));
		addByPrefix('singRIGHT', offset(-130, -14), 'SingRIGHT', 24, loop(false));
		addByPrefix("cheer", offset(50, 30), "Cheer", 24, loop(false, 0), false, false);

        info.idleSequence = ["danceLeft", "danceRight"];
        
        info.functions.create = create;

        addAction("flashOn", flashOn);
        addAction("flashOff", flashOff);
        addAction("flashFade", flashFade);
    }

    var flash:Character;

    function create(character:Character):Void{
        flash = new Character(0, 0, "Spooky", characterReference.isPlayer, characterReference.isGirlfriend, characterReference.debugMode);
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