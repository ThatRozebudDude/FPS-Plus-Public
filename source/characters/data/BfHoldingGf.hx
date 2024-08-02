package characters.data;

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
        info.focusOffset.set(100, -80);

        addByPrefix("idle", offset(0, 0), "BF idle dance w gf", 24, loop(false, 0), false, false);
        addByPrefix("singDOWN", offset(-20, -9), "BF NOTE DOWN0", 24, loop(false, 0), false, false);
        addByPrefix("singLEFT", offset(10, 3), "BF NOTE LEFT0", 24, loop(false, 0), false, false);
        addByPrefix("singRIGHT", offset(-45, 21), "BF NOTE RIGHT0", 24, loop(false, 0), false, false);
        addByPrefix("singUP", offset(-40, 10), "BF NOTE UP0", 24, loop(false, 0), false, false);

        addByPrefix("singDOWNmiss", offset(-20, -6), "BF NOTE DOWN MISS", 24, loop(true, -4), false, false);
        addByPrefix("singLEFTmiss", offset(10, 4), "BF NOTE LEFT MISS", 24, loop(true, -4), false, false);
        addByPrefix("singRIGHTmiss", offset(-42, 36), "BF NOTE RIGHT MISS", 24, loop(true, -4), false, false);
        addByPrefix("singUPmiss", offset(-33, 6), "BF NOTE UP MISS", 24, loop(true, -4), false, false);

        addByPrefix("bfCatch", offset(4, 90), "BF catches GF", 24, loop(false, 0), false, false);
        addByPrefix("idleNoGf", offset(0, -20), "BF idle dance0", 24, loop(false, 0), false, false);

        addAnimChain("bfCatch", "idle");

        addExtraData("reposition", [75, -20]);
    }

}