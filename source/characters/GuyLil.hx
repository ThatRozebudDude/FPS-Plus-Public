package characters;

class GuyLil extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "guy-lil";
        info.spritePath = "chartEditor/lilOpp";
        info.frameLoadType = load(300, 256);
        
        info.iconName = "face-lil";
        info.antialiasing = false;

        add("idle", offset(), [0, 1], 12, true);

		add("singLEFT", 	offset(),   [3, 4, 5], 		12, false);
		add("singDOWN", 	offset(),   [6, 7, 8], 		12, false);
		add("singUP", 	    offset(),   [9, 10, 11], 	12, false);
	    add("singRIGHT", 	offset(),   [12, 13, 14], 	12, false);

    }

}