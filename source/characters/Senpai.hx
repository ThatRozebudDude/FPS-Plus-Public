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

        addByPrefix('idle', offset(), 'Senpai Idle', 24, loop(false));
		addByPrefix('singUP', offset(2, 6), 'SENPAI UP NOTE', 24, loop(false));
		addByPrefix('singLEFT', offset(5), 'SENPAI LEFT NOTE', 24, loop(false));
		addByPrefix('singRIGHT', offset(1), 'SENPAI RIGHT NOTE', 24, loop(false));
		addByPrefix('singDOWN', offset(2), 'SENPAI DOWN NOTE', 24, loop(false));

		addExtraData("scale", PlayState.daPixelZoom);
		addExtraData("reposition", [0, 102]);

    }

}