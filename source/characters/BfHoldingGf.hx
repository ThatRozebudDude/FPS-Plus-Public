package characters;

class BfHoldingGf extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-holding-gf";
        info.spritePath = "week7/bfAndGF";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf";
        info.facesLeft = true;
        info.deathCharacter = "BfHoldingGfDead";

        addByPrefix('idle', offset(), 'BF idle dance', 24, false);
	    addByPrefix('singDOWN', offset(-10, -10), 'BF NOTE DOWN0', 24, false);
		addByPrefix('singLEFT', offset(12, 7), 'BF NOTE LEFT0', 24, false);
		addByPrefix('singRIGHT', offset(-41, 23), 'BF NOTE RIGHT0', 24, false);
		addByPrefix('singUP', offset(-29, 10), 'BF NOTE UP0', 24, false);

		addByPrefix('singDOWNmiss', offset(-10, -10), 'BF NOTE DOWN MISS', 24, false);
		addByPrefix('singLEFTmiss', offset(12, 7), 'BF NOTE LEFT MISS', 24, false);
		addByPrefix('singRIGHTmiss', offset(-41, 23), 'BF NOTE RIGHT MISS', 24, false);
		addByPrefix('singUPmiss', offset(-29, 10), 'BF NOTE UP MISS', 24, false);
		addByPrefix('bfCatch', offset(), 'BF catches GF', 24, false);

    }

}