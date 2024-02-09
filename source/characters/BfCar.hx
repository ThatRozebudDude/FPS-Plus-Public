package characters;

class BfCar extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-car";
        info.spritePath = "week4/bfCar";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf";
        info.facesLeft = true;

		addByPrefix('idle', offset(-5), 'BF idle dance', 24, false);
		addByPrefix('singUP', offset(-29, 27), 'BF NOTE UP0', 24, false);
		addByPrefix('singLEFT', offset(12, -6), 'BF NOTE LEFT0', 24, false);
		addByPrefix('singRIGHT', offset(-38, -7), 'BF NOTE RIGHT0', 24, false);
		addByPrefix('singDOWN', offset(-10, -50), 'BF NOTE DOWN0', 24, false);
		addByPrefix('singUPmiss', offset(-29, 27), 'BF NOTE UP MISS', 24, false);
		addByPrefix('singLEFTmiss', offset(12, 24), 'BF NOTE LEFT MISS', 24, false);
		addByPrefix('singRIGHTmiss', offset(-30, 21), 'BF NOTE RIGHT MISS', 24, false);
		addByPrefix('singDOWNmiss', offset(-11, -19), 'BF NOTE DOWN MISS', 24, false);

    }

}