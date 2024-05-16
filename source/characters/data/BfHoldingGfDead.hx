package characters.data;

@charList(false)
class BfHoldingGfDead extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-holding-gf-dead";
        info.spritePath = "week7/bfHoldingGF-DEAD";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf";
        info.facesLeft = true;

        addByPrefix('firstDeath', offset(37, 14), "BF Dies with GF", 24, loop(false));
		addByPrefix('deathLoop', offset(37, -3), "BF Dead with GF Loop", 24, loop(true));
		addByPrefix('deathConfirm', offset(37, 28), "RETRY confirm holding gf", 24, loop(false));

    }

}