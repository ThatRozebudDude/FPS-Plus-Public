package characters;

class Monster extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "monster";
        info.spritePath = "week2/Monster_Assets";
        info.frameLoadType = sparrow;
        
        info.iconName = "monster";

		addByPrefix('idle', offset(), 'monster idle', 24, false);
		addByPrefix('singUP', offset(-23, 87), 'monster up note', 24, false);
		addByPrefix('singDOWN', offset(-63, -86), 'monster down', 24, false);
		addByPrefix('singLEFT', offset(-51, 15), 'Monster Right note', 24, false);
		addByPrefix('singRIGHT', offset(-31, 4), 'Monster left note', 24, false);

    }

}