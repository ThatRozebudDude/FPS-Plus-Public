package characters.data;

class BfDark extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-dark";
        info.spritePath = "week2/bf_dark";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf";
        info.facesLeft = true;
        info.focusOffset.set(100, -100);

        addByPrefix('idle', offset(1, 0), 'BF idle dance', 24, loop(false));
        addByPrefix('singUP', offset(-42, 31), 'BF NOTE UP0', 24, loop(false));
        addByPrefix('singLEFT', offset(9, -7), 'BF NOTE LEFT0', 24, loop(false));
        addByPrefix('singRIGHT', offset(-44, -6), 'BF NOTE RIGHT0', 24, loop(false));
        addByPrefix('singDOWN', offset(-22, -50), 'BF NOTE DOWN0', 24, loop(false));
        addByPrefix('singUPmiss', offset(-37, 29), 'BF NOTE UP MISS', 24, loop(true, -4));
        addByPrefix('singLEFTmiss', offset(9, 19), 'BF NOTE LEFT MISS', 24, loop(true, -4));
        addByPrefix('singRIGHTmiss', offset(-38, 21), 'BF NOTE RIGHT MISS', 24, loop(true, -4));
        addByPrefix('singDOWNmiss', offset(-25, -20), 'BF NOTE DOWN MISS', 24, loop(true, -4));
        addByPrefix('hey', offset(1, 5), 'BF HEY', 24, loop(false));
        addByPrefix('scared', offset(-2, 0), 'BF idle shaking', 24);

        info.functions.create = create;

        addAction("flashOn", flashOn);
        addAction("flashOff", flashOff);
        addAction("flashFade", flashFade);
    }

    var bfFlash:Character;

    function create(character:Character):Void{
        bfFlash = new Character(0, 0, "Bf", true);
        character.attachCharacter(bfFlash, true);
        addToCharacter(bfFlash);
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