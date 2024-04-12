package characters;

class Pico extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico";
        info.spritePath = "week3/Pico_FNF_assetss";
        info.frameLoadType = sparrow;
        
        info.iconName = "pico";
        info.facesLeft = true;

        addByPrefix('idle', offset(), "Pico Idle Dance", 24, false);
		addByPrefix('singUP', offset(20, 29), 'pico Up note0', 24, false);
		addByPrefix('singDOWN', offset(92, -77), 'Pico Down Note0', 24, false);
		addByPrefix('singLEFT', offset(86, -11), 'Pico NOTE LEFT0', 24, false);
		addByPrefix('singRIGHT', offset(-46, 1), 'Pico Note Right0', 24, false);
		addByPrefix('singRIGHTmiss', offset(-40, 49), 'Pico Note Right Miss', 24, loop(true, -4));
		addByPrefix('singLEFTmiss', offset(82, 27), 'Pico NOTE LEFT miss', 24, loop(true, -4));
		addByPrefix('singUPmiss', offset(26, 67), 'pico Up note miss', 24, loop(true, -4));
		addByPrefix('singDOWNmiss', offset(86, -37), 'Pico Down Note MISS', 24, loop(true, -4));

    }

}