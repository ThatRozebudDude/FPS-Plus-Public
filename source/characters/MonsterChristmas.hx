package characters;

class MonsterChristmas extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "monster-christmas";
        info.spritePath = "week5/monsterChristmas";
        info.frameLoadType = sparrow;
        
        info.iconName = "monster";

		addByPrefix('idle', offset(), 'monster idle', 24, false);
		addByPrefix('singUP', offset(-21, 53), 'monster up note', 24, false);
		addByPrefix('singDOWN', offset(-52, -91), 'monster down', 24, false);
		addByPrefix('singLEFT', offset(-51, 10), 'Monster Right note', 24, false);
		addByPrefix('singRIGHT', offset(-30, 7), 'Monster left note', 24, false);

    }

}