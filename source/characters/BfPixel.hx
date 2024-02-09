package characters;

class BfPixel extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-pixel";
        info.spritePath = "week6/bfPixel";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf-pixel";
        info.facesLeft = true;
		info.deathCharacter = "BfPixelDead";
		info.antialiasing = false;

		addByPrefix('idle', offset(), 'BF IDLE', 24, false);
		addByPrefix('singUP', offset(-6), 'BF UP NOTE', 24, false);
		addByPrefix('singLEFT', offset(-12), 'BF LEFT NOTE', 24, false);
		addByPrefix('singRIGHT', offset(), 'BF RIGHT NOTE', 24, false);
		addByPrefix('singDOWN', offset(), 'BF DOWN NOTE', 24, false);
		addByPrefix('singUPmiss', offset(-6), 'BF UP MISS', 24, false);
		addByPrefix('singLEFTmiss', offset(-12), 'BF LEFT MISS', 24, false);
		addByPrefix('singRIGHTmiss', offset(), 'BF RIGHT MISS', 24, false);
		addByPrefix('singDOWNmiss', offset(), 'BF DOWN MISS', 24, false);

		addExtraData("scale", PlayState.daPixelZoom);

    }

}