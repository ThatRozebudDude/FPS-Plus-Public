package characters;

class BfLil extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-lil";
        info.spritePath = "chartEditor/lilBf";
        info.frameLoadType = load(300, 256);
        
        info.iconName = "bf-lil";
        info.facesLeft = true;
		info.antialiasing = false;

		add("idle",	offset(), [0, 1], 12, loop(true));

		add("singLEFT", 	offset(),	[3, 4, 5], 		12, loop(true, 2));
		add("singDOWN", 	offset(),	[6, 7, 8], 		12, loop(true, 2));
		add("singUP", 		offset(),	[9, 10, 11], 	12, loop(true, 2));
		add("singRIGHT", 	offset(),	[12, 13, 14], 	12, loop(true, 2));

		add("singLEFTmiss", 	offset(),	[3, 15, 15, 16, 16], 	24, loop(true, -4));
		add("singDOWNmiss", 	offset(),	[6, 18, 18, 19, 19], 	24, loop(true, -4));
		add("singUPmiss", 		offset(),	[9, 21, 21, 22, 22], 	24, loop(true, -4));
		add("singRIGHTmiss", 	offset(),	[12, 24, 24, 25, 25], 	24, loop(true, -4));

		add("hey", offset(), [17, 20, 23], 12, loop(true, 2));

    }

}