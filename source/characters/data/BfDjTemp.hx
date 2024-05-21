package characters.data;

@charList(false)
@gfList(false)
class BfDjTemp extends CharacterInfoBase
{

    override public function new(){

        super();

        info.spritePath = "menu/freeplay/dj/bf";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf";

        addByPrefix("idle", offset(0, 0), "Boyfriend DJ0", 24, loop(false, 0), false, false);
        addByPrefix("intro", offset(5, 427), "boyfriend dj intro", 24, loop(false, 0), false, false);
        addByPrefix("confirm", offset(43, -24), "Boyfriend DJ confirm", 24, loop(false, 0), false, false);

    }

}