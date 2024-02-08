package characters;

class Dad extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "dad";
        info.spritePath = "week1/DADDY_DEAREST";
        info.frameLoadType = sparrow;
        
        info.iconName = "dad";

        addByPrefix('idle', offset(), 'Dad idle dance', 24, false);
        addByPrefix('singUP', offset(-9, 50), 'Dad Sing Note UP', 24, false);
        addByPrefix('singRIGHT', offset(-4, 26), 'Dad Sing Note RIGHT', 24, false);
        addByPrefix('singDOWN', offset(2, -32), 'Dad Sing Note DOWN', 24, false);
        addByPrefix('singLEFT', offset(-11, 10), 'Dad Sing Note LEFT', 24, false);

        addExtraData("stepsUntilRelease", 6.1);

    }

}