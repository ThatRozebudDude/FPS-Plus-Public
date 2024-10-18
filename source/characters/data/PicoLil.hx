package characters.data;

class PicoLil extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-lil";
        info.spritePath = "fpsPlus/lil/lilPico";
        info.frameLoadType = load(256, 256);
        
        info.iconName = "pico-lil";
        info.facesLeft = true;
		info.antialiasing = false;
		info.resultsCharacter = "Pico";

		info.deathCharacter = "PicoLil";
		info.deathOffset.set(53, 41);

		add("idle",	offset(), [0, 1], 12, loop(true));

		add("singLEFT", 	offset(),	[3, 4, 5], 		12, loop(true, 1));
		add("singDOWN", 	offset(),	[6, 7, 8], 		12, loop(true, 1));
		add("singUP", 		offset(),	[9, 10, 11], 	12, loop(true, 1));
		add("singRIGHT", 	offset(),	[12, 13, 14], 	12, loop(true, 1));

		add("singLEFTmiss", 	offset(),	[3, 15, 15, 16, 16], 	24, loop(true, -4));
		add("singDOWNmiss", 	offset(),	[6, 18, 18, 19, 19], 	24, loop(true, -4));
		add("singUPmiss", 		offset(),	[9, 21, 21, 22, 22], 	24, loop(true, -4));
		add("singRIGHTmiss", 	offset(),	[12, 24, 24, 25, 25], 	24, loop(true, -4));

		add('firstDeath', offset(), [23, 26, 23, 26, 23, 26, 23, 26, 23, 26, 23, 26, 23, 26, 23, 26], 12, loop(false));
        add('deathLoop', offset(), [23, 26], 12, loop(true));
        add('deathConfirm', offset(), [0, 1], 12, loop(true));

		addExtraData("deathSound", "gameOver/fnf_loss_sfx-pico");
		addExtraData("deathSong", "gameOver/gameOver-pico");
		addExtraData("deathSongEnd", "gameOver/gameOverEnd-pico");
    }

}