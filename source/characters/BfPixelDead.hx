package characters;

class BfPixelDead extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "bf-pixel-dead";
        info.spritePath = "week6/bfPixelsDEAD";
        info.frameLoadType = sparrow;
        
        info.iconName = "bf-pixel";
        info.facesLeft = true;
		info.antialiasing = false;

		addByPrefix('firstDeath', offset(), "BF Dies pixel", 24, false);
		addByPrefix('deathLoop', offset(-36), "Retry Loop", 24, true);
		addByPrefix('deathConfirm', offset(-36), "RETRY CONFIRM", 24, false);

		addExtraData("scale", PlayState.daPixelZoom);

    }

}