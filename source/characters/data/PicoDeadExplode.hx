package characters.data;

import flixel.FlxG;

@charList(false)
class PicoDeadExplode extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-dead-explode";
        info.spritePath = "weekend1/picoExplosionDeath";
        info.frameLoadType = atlas;
        
        info.iconName = "pico";
        info.facesLeft = true;  
        info.deathOffset.set(-541, -344);

		addByLabel('firstDeath', offset(665, 350), "intro", 24, loop(false));
		addByLabel('deathLoop', offset(665, 350), "Loop Start", 24, loop(true));
		addByLabel('deathConfirm', offset(665, 350), "Confirm", 24, loop(false));

        addExtraData("deathDelay", 0.125);
        addExtraData("deathSound", "gameOver/fnf_loss_sfx-pico-explode");
		addExtraData("deathSong", "gameOver/gameOver-pico");
		addExtraData("deathSongEnd", "gameOver/gameOverEnd-pico");

        info.functions.deathCreate = deathCreate;
    }

    function deathCreate(character:Character) {
        gameover.camGameOver.zoom = 0.75;
    }

}