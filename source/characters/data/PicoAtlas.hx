package characters.data;

//Made to test atlas stuff. Assets are in the art folder.

@charList(false)
@gfList(false)
class PicoAtlas extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico";
        info.spritePath = "week3/pico_atlas";
        info.frameLoadType = atlas;
        
        info.iconName = "pico";
        info.facesLeft = true;

        addByLabel('idle', offset(), "Idle", 24, loop(false));
		addByLabel('singUP', offset(), 'Sing Up', 24, loop(false));
		addByLabel('singDOWN', offset(), 'Sing Down', 24, loop(false));
		addByLabel('singLEFT', offset(), 'Sing Left', 24, loop(false));
		addByLabel('singRIGHT', offset(), 'Sing Right', 24, loop(false));

    }

}