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

		addByPrefix('idle', offset(), 'BF idle dance', 24, false);
        addByPrefix('singUP', offset(-42, 31), 'BF NOTE UP0', 24, false);
        addByPrefix('singLEFT', offset(9, -7), 'BF NOTE LEFT0', 24, false);
        addByPrefix('singRIGHT', offset(-44, -6), 'BF NOTE RIGHT0', 24, false);
        addByPrefix('singDOWN', offset(-22, -50), 'BF NOTE DOWN0', 24, false);
        addByPrefix('singUPmiss', offset(-37, 29), 'BF NOTE UP MISS', 24, false);
        addByPrefix('singLEFTmiss', offset(9, 19), 'BF NOTE LEFT MISS', 24, false);
        addByPrefix('singRIGHTmiss', offset(-38, 21), 'BF NOTE RIGHT MISS', 24, false);
        addByPrefix('singDOWNmiss', offset(-25, -20), 'BF NOTE DOWN MISS', 24, false);

    }

}