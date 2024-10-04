package characters.data;

class PicoChristmas extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-christmas";
        info.spritePath = "week5/picoChristmas";
        info.frameLoadType = sparrow;
        
        info.iconName = "pico";
        info.facesLeft = true;
        info.deathCharacter = "PicoChristmasDead";
        info.resultsCharacter = "Pico";
        info.focusOffset.set(100, -100);

        addByPrefix("idle", offset(0, 0), "Pico Idle Dance xmas", 24, loop(false, 0), false, false);

        addByPrefix("singUP", offset(20, 29), "pico Up note xmas", 24, loop(false, 0), false, false);
        addByPrefix("singDOWN", offset(43, -81), "Pico Down Note xmas", 24, loop(false, 0), false, false);
        addByPrefix("singLEFT", offset(62, -14), "Pico NOTE LEFT xmas", 24, loop(false, 0), false, false);
        addByPrefix("singRIGHT", offset(-90, -4), "Pico Note Right xmas", 24, loop(false, 0), false, false);

        addByPrefix("singRIGHTmiss", offset(-84, 43), "Pico Note Right Miss xmas", 24, loop(true, -2), false, false);
        addByPrefix("singLEFTmiss", offset(60, 25), "Pico NOTE LEFT miss xmas", 24, loop(true, -2), false, false);
        addByPrefix("singUPmiss", offset(26, 67), "pico Up note miss xmas", 24, loop(true, -2), false, false);
        addByPrefix("singDOWNmiss", offset(42, -38), "Pico Down Note MISS xmas", 24, loop(true, -2), false, false);

    }

}