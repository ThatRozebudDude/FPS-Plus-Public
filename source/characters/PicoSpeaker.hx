package characters;

@charList(false)
@gfList(true)
class PicoSpeaker extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-speaker";
        info.spritePath = "week7/picoSpeaker";
        info.frameLoadType = sparrow;
        
        info.iconName = "pico";

        addByPrefix('shoot1', offset(), "Pico shoot 1", 24, loop(true, -3));
		addByPrefix('shoot2', offset(0, -128), "Pico shoot 2", 24, loop(true, -3));
		addByPrefix('shoot3', offset(413, -64), "Pico shoot 3", 24, loop(true, -3));
		addByPrefix('shoot4', offset(440, -19), "Pico shoot 4", 24, loop(true, -3));

    }

}