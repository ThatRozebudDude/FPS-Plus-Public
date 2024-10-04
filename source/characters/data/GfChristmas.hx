package characters.data;

@gfList(true)
class GfChristmas extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "gf-christmas";
        info.spritePath = "week5/gfChristmas";
        info.frameLoadType = sparrow;
        
        info.iconName = "gf";
		info.focusOffset.set();

        addByIndices("danceLeft", offset(0, -9), "GF Dancing Beat", [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, loop(false), false, false);
		addByIndices("danceRight", offset(0, -9), "GF Dancing Beat", [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, loop(false), false, false);
		addByIndices('idleLoop', offset(0, -9), 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, loop(true));
		addByPrefix("cheer", offset(0, 0), "GF Cheer", 24, loop(false), false, false);
		addByPrefix("singLEFT", offset(0, -19), "GF left note", 24, loop(false), false, false);
		addByPrefix("singRIGHT", offset(0, -20), "GF Right Note", 24, loop(false), false, false);
		addByPrefix("singUP", offset(0, 4), "GF Up Note", 24, loop(false), false, false);
		addByPrefix("singDOWN", offset(0, -20), "GF Down Note", 24, loop(false), false, false);
		addByIndices("sad", offset(0, -21), "gf sad", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "", 24, loop(true, -8));
		addByIndices("hairBlow", offset(45, -8), "GF Dancing Beat Hair blowing", [0,1,2,3], "", 24, loop(true), false, false);
		addByIndices("hairFall", offset(0, -9), "GF Dancing Beat Hair Landing", [0,1,2,3,4,5,6,7,8,9,10,11], "", 24, loop(false), false, false);
		addByPrefix("scared", offset(0, -17), "GF FEAR", 24, loop(true), false, false);

		info.idleSequence = ["danceLeft", "danceRight"];

		addExtraData("reposition", [0, 60]);
    }

}