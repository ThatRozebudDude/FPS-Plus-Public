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

        addByPrefix('idle', offset(-36, -46), "idle spirit_", 24, loop(false));
		addByPrefix('singUP', offset(-36, -39), "up_", 24, loop(false));
		addByPrefix('singRIGHT', offset(-36, -46), "right_", 24, loop(false));
		addByPrefix('singLEFT', offset(-33, -46), "left_", 24, loop(false));
		addByPrefix('singDOWN', offset(28, 18), "spirit down_", 24, loop(false));

		addExtraData("scale", PlayState.daPixelZoom);

    }

}