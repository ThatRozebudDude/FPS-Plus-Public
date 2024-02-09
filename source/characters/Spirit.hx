package characters;

class Spirit extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "spirit";
        info.spritePath = "week6/spirit";
        info.frameLoadType = packer;
        
        info.iconName = "spirit";
        info.antialiasing = false;

        addByPrefix('idle', offset(-220, -280), "idle spirit_", 24, false);
		addByPrefix('singUP', offset(-220, -238), "up_", 24, false);
		addByPrefix('singRIGHT', offset(-220, -280), "right_", 24, false);
		addByPrefix('singLEFT', offset(-202, -280), "left_", 24, false);
		addByPrefix('singDOWN', offset(170, 110), "spirit down_", 24, false);

		addExtraData("scale", PlayState.daPixelZoom);

    }

}