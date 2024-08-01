package characters.data;

class Bf extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf";
        info.spritePath = "BOYFRIEND";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf";
        info.facesLeft = true;
        info.focusOffset.set(100, -120);

        addByPrefix('idle', offset(), 'BF idle dance', 24, loop(false));
        addByPrefix('singUP', offset(-42, 31), 'BF NOTE UP0', 24, loop(false));
        addByPrefix('singLEFT', offset(9, -7), 'BF NOTE LEFT0', 24, loop(false));
        addByPrefix('singRIGHT', offset(-44, -6), 'BF NOTE RIGHT0', 24, loop(false));
        addByPrefix('singDOWN', offset(-22, -50), 'BF NOTE DOWN0', 24, loop(false));
        addByPrefix('singUPmiss', offset(-37, 29), 'BF NOTE UP MISS', 24, loop(true, -4));
        addByPrefix('singLEFTmiss', offset(9, 19), 'BF NOTE LEFT MISS', 24, loop(true, -4));
        addByPrefix('singRIGHTmiss', offset(-38, 21), 'BF NOTE RIGHT MISS', 24, loop(true, -4));
        addByPrefix('singDOWNmiss', offset(-25, -20), 'BF NOTE DOWN MISS', 24, loop(true, -4));
        addByPrefix('hey', offset(1, 5), 'BF HEY', 24, loop(false));
        addByPrefix('cheer', offset(-20, 20), 'Cheer', 24, loop(false));

        addByPrefix('firstDeath', offset(27, 6), "BF dies", 24, loop(false));
        addByPrefix('deathLoop', offset(27, 0), "BF Dead Loop", 24, loop(true));
        addByPrefix('deathConfirm', offset(27, 64), "BF Dead confirm", 24, loop(false));

        addByPrefix('scared', offset(-2, 0), 'BF idle shaking', 24);
    }

}