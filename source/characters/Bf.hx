package characters;

class Bf extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf";
        info.spritePath = "BOYFRIEND";
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
        addByPrefix('hey', offset(7, 4), 'BF HEY', 24, false);

        addByPrefix('firstDeath', offset(37, 11), "BF dies", 24, false);
        addByPrefix('deathLoop', offset(37, 5), "BF Dead Loop", 24, true);
        addByPrefix('deathConfirm', offset(37, 69), "BF Dead confirm", 24, false);

        addByPrefix('scared', offset(-4), 'BF idle shaking', 24);

    }

}