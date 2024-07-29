package characters.data;

class Pico extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico";
        info.spritePath = "week3/Pico_FNF_assetss";
        info.frameLoadType = sparrow;
        
        info.iconName = "pico";
        info.facesLeft = true;
        info.focusOffset.set(312, -100);

        addByPrefix('idle', offset(), "Idle", 24, loop(false));
		addByPrefix('singUP', offset(20, 29), 'Sing Up', 24, loop(false));
		addByPrefix('singDOWN', offset(92, -77), 'Sing Down', 24, loop(false));
		addByPrefix('singLEFT', offset(86, -11), 'Sing Left', 24, loop(false));
		addByPrefix('singRIGHT', offset(-46, 1), 'Sing Right', 24, loop(false));
		addByPrefix('singRIGHTmiss', offset(-40, 49), 'Miss Right', 24, loop(true, -4));
		addByPrefix('singLEFTmiss', offset(82, 27), 'Miss Left', 24, loop(true, -4));
		addByPrefix('singUPmiss', offset(26, 67), 'Miss Up', 24, loop(true, -4));
		addByPrefix('singDOWNmiss', offset(86, -37), 'Miss Down', 24, loop(true, -4));

    }

}