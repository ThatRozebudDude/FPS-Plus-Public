package characters.data;

@charList(false)
@gfList(false)
class BfDjTemp extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-dj-atlas-temp";
        info.spritePath = "menu/freeplay/dj/bf";
        info.frameLoadType = atlas;
        
        info.iconName = "bf";

        addByLabel('idle', offset(), "Idle", 24, loop(false));
        addByLabel('intro', offset(), "Intro", 24, loop(false));
        addByLabel('confirm', offset(), "Confirm", 24, loop(false));
        addByLabel('idle1start', offset(), "Idle1", 24, loop(false));
        addByLabel('idle2start', offset(), "Idle2Start", 24, loop(false));
        addByLabel('idle2loop', offset(), "Idle2Loop", 24, loop(false));
        addByLabel('idle2end', offset(), "Idle2End", 24, loop(false));

    }

}