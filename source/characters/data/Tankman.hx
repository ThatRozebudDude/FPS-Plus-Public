package characters.data;

class Tankman extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "tankman";
        info.spritePath = "week7/tankmanCaptain";
        info.frameLoadType = sparrow;
        
        info.iconName = "tankman";
        info.facesLeft = true;

		addByPrefix('idle', offset(), "Tankman Idle Dance", 24, loop(false));
		addByPrefix('singUP', offset(27, 58), 'Tankman UP note ', 24, loop(false));
	    addByPrefix('singDOWN', offset(68, -106), 'Tankman DOWN note ', 24, loop(false));
		addByPrefix('singRIGHT', offset(-23, -11), 'Tankman Right Note ', 24, loop(false));
		addByPrefix('singLEFT', offset(91, -25), 'Tankman Note Left ', 24, loop(false));

		addByPrefix('prettyGood', offset(101, 15), 'PRETTY GOOD', 24, loop(false));
		addByPrefix('ugh', offset(-14, -8), 'TANKMAN UGH', 24, loop(false));

    }

}