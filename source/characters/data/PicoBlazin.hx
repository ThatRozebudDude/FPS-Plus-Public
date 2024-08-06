package characters.data;

import flixel.FlxG;
import flixel.FlxSprite;

class PicoBlazin extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-blazin";
        info.spritePath = "weekend1/picoBlazin";
        info.frameLoadType = atlas;
        
        info.iconName = "pico";
        info.deathCharacter = "PicoBlazin";
        info.facesLeft = true;
        info.deathOffset.set(-160, 250);

        addByLabel('idle', offset(), "Idle", 24, loop(true));
        addByLabel('punchHigh1', offset(), "Punch High 1", 24, loop(false));
        addByLabel('punchHigh2', offset(), "Punch High 2", 24, loop(false));
        addByLabel('punchLow1', offset(), "Punch Low 1", 24, loop(false));
        addByLabel('punchLow2', offset(), "Punch Low 2", 24, loop(false));
        addByLabel('uppercutPrep', offset(), "Uppercut Prep", 24, loop(false));
        addByLabel('uppercutPunch', offset(), "Uppercut Punch", 24, loop(false));
        addByLabel('uppercutPunchLoop', offset(), "Uppercut Punch Loop", 24, loop(true));
        addByLabel('block', offset(), "Block", 24, loop(false));
        addByLabel('dodge', offset(), "Dodge", 24, loop(false));
        addByLabel('hitHigh', offset(), "Hit High", 24, loop(false));
        addByLabel('hitLow', offset(), "Hit Low", 24, loop(false));
        addByLabel('uppercutHit', offset(), "Uppercut Hit", 24, loop(false));
        addByStartingAtLabel('hitSpin', offset(), "Hit Spin", 3, 24, loop(true));
        addByLabel('fakeHit', offset(), "Fake Hit", 24, loop(false));
        addByLabel('taunt', offset(), "Taunt", 24, loop(false));
        addByLabel('tauntLaughLoop', offset(), "Taunt Laugh Loop", 24, loop(true));

        addByLabel('firstDeath', offset(), "Low Death Intro", 24, loop(false));
        addByLabel('deathLoop', offset(), "Low Death Loop", 24, loop(true));
        addByLabel('deathConfirm', offset(), "Low Death Confirm", 24, loop(false));

        addAnimChain("uppercutPunch", "uppercutPunchLoop");
        addAnimChain("taunt", "tauntLaughLoop");

        addExtraData("scale", 1.75);
        addExtraData("worldPopupOffset", [1657, 658]);
        addExtraData("deathDelay", 0.125);
        addExtraData("deathSound", "gameOver/fnf_loss_sfx-pico-gutpunch");
		addExtraData("deathSong", "gameOver/gameOver-pico");
		addExtraData("deathSongEnd", "gameOver/gameOverEnd-pico");

        info.functions.deathCreate = deathCreate;
        info.functions.deathAdd = deathAdd;
        info.functions.playAnim = playAnim;
    }

    var isOnDeathScreen:Bool = false;

    var retrySprite:FlxSprite;

    function deathCreate(character:Character) {
        isOnDeathScreen = true;

        retrySprite = new FlxSprite(character.x + 371, character.y + 644);
        retrySprite.frames = Paths.getSparrowAtlas("weekend1/picoBlazinDeathConfirm");
        retrySprite.animation.addByPrefix("retry", "", 24, false);
        retrySprite.antialiasing = true;
        retrySprite.scale.set(1.75, 1.75);
        retrySprite.updateHitbox();
        retrySprite.visible = false;
    }

    function deathAdd(character:Character) {
        FlxG.state.subState.add(retrySprite);
    }

    function playAnim(character:Character, anim:String) {
        if(!isOnDeathScreen) return;
        
        if(anim == "deathConfirm") {
            retrySprite.animation.play("retry", true);
            retrySprite.visible = true;
            character.visible = false;
        }
    }

}