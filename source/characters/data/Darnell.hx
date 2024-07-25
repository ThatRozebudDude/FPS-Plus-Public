package characters.data;

class Darnell extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "darnell";
        info.spritePath = "weekend1/darnell";
        info.frameLoadType = sparrow;
        
        info.iconName = "darnell";

        addByIndices('idle', offset(), 'Idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, loop(false));
	    addByPrefix('singUP', offset(8, 5), "Pose Up", 24, loop(true, -8));
	    addByPrefix('singDOWN', offset(0, -3), "Pose Down", 24, loop(true, -8));
	    addByPrefix('singLEFT', offset(1, 0), 'Pose Left', 24, loop(true, -8));
	    addByPrefix('singRIGHT', offset(4, 3), 'Pose Right', 24, loop(true, -8));
	    addByPrefix('laugh', offset(), 'Laugh', 24, loop(false));
	    addByIndices('laughCutscene', offset(), 'Laugh', [0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5], "", 24, loop(false));
	    addByPrefix('lightCan', offset(8, 1), 'Light Can', 24, loop(false));
	    addByPrefix('kickUp', offset(15, 9), 'Kick Up', 24, loop(false));
	    addByPrefix('kneeForward', offset(7, -1), 'Knee Forward', 24, loop(false));
	    addByPrefix('pissed', offset(), 'Gets Pissed', 24, loop(false));
    }

}