package characters;

class Senpai extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "senpai";
        info.spritePath = "week6/senpai";
        info.frameLoadType = sparrow;
        
        info.iconName = "senpai";
        info.antialiasing = false;

        addByPrefix('idle', offset(), 'Senpai Idle', 24, false);
		addByPrefix('singUP', offset(12, 36), 'SENPAI UP NOTE', 24, false);
		addByPrefix('singLEFT', offset(30), 'SENPAI LEFT NOTE', 24, false);
		addByPrefix('singRIGHT', offset(6), 'SENPAI RIGHT NOTE', 24, false);
		addByPrefix('singDOWN', offset(12), 'SENPAI DOWN NOTE', 24, false);

		addExtraData("scale", PlayState.daPixelZoom);

    }

}