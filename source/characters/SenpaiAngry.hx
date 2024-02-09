package characters;

class SenpaiAngry extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "senpai-angry";
        info.spritePath = "week6/senpai";
        info.frameLoadType = sparrow;
        
        info.iconName = "senpai-angry";
        info.antialiasing = false;

        addByPrefix('idle', offset(), 'Angry Senpai Idle', 24, false);
		addByPrefix('singUP', offset(6, 36), 'Angry Senpai UP NOTE', 24, false);
		addByPrefix('singLEFT', offset(24, 6), 'Angry Senpai LEFT NOTE', 24, false);
		addByPrefix('singRIGHT', offset(), 'Angry Senpai RIGHT NOTE', 24, false);
		addByPrefix('singDOWN', offset(6, 6), 'Angry Senpai DOWN NOTE', 24, false);

		addExtraData("scale", PlayState.daPixelZoom);

    }

}