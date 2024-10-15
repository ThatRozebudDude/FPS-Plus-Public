package characters.data;

import flixel.FlxSprite;
import flixel.FlxG;

@charList(false)
class PicoDead extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "pico-dead";
        info.spritePath = "weekend1/pico_death";
        info.frameLoadType = sparrow;
        
        info.iconName = "pico";
        info.facesLeft = true;
        info.deathOffset.set(-200, -200);

		addByIndices('firstDeath', offset(225, 125), "Pico Death Stab", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47], "", 24, loop(false));
		addByIndices('deathLoop', offset(225, 125), "Pico Death Stab", [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63], "", 24, loop(true));
		addByIndices('deathConfirm', offset(225, 125), "Pico Death Stab", [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63], "", 24, loop(true));

        info.functions.create = deathCreate;
        info.functions.deathAdd = deathAdd;
        info.functions.frame = frame;
        info.functions.playAnim = playAnim;
        //info.functions.update = debugUpdate;

        addExtraData("deathSound", "gameOver/fnf_loss_sfx-pico");
		addExtraData("deathSong", "gameOver/gameOver-pico");
		addExtraData("deathSongEnd", "gameOver/gameOverEnd-pico");
    }

    var retryButton:FlxSprite;
    var nene:FlxSprite;

    function deathCreate(character:Character):Void{
        retryButton = new FlxSprite(character.x - 70, character.y - 270);
        retryButton.frames = Paths.getSparrowAtlas("weekend1/Pico_Death_Retry");
        retryButton.animation.addByPrefix("loop", "Retry Text Loop", 24);
        retryButton.animation.addByPrefix("confirm", "Retry Text Confirm", 24, false);
        retryButton.animation.play("loop");
        retryButton.centerOffsets();
        retryButton.antialiasing = true;
        retryButton.visible = false;

        nene = new FlxSprite(playstate.gf.getScreenPosition().x + 135, playstate.gf.getScreenPosition().y - 20);
        nene.frames = Paths.getSparrowAtlas("weekend1/NeneKnifeToss");
        nene.antialiasing = true;
        nene.animation.addByPrefix("throw", "knife toss", 24, false);
        nene.animation.play("throw");
        nene.animation.finishCallback = function(name:String){
			nene.visible = false;
		}

        addToSubstate(nene);
    }

    function deathAdd(character:Character):Void{
        addToSubstate(retryButton);
    }

    /*function debugUpdate(character:Character, elapsed:Float):Void{
        if(FlxG.keys.anyJustPressed([W])){ nene.y -= 1 ;}
        if(FlxG.keys.anyJustPressed([S])){ nene.y += 1 ;}
        if(FlxG.keys.anyJustPressed([A])){ nene.x -= 1 ;}
        if(FlxG.keys.anyJustPressed([D])){ nene.x += 1 ;}
        if(FlxG.keys.anyJustPressed([W, A, S, D])){ 
            nene.animation.play("throw", true);
            nene.visible = true;
            trace(nene.getPosition() - playstate.gf.getScreenPosition());
        }
    }*/

    function frame(character:Character, anim:String, frame:Int):Void{
        if(anim == "firstDeath" && frame == 35){
            retryButton.visible = true;
        }
    }

    function playAnim(character:Character, anim:String):Void{
        if(anim == "deathConfirm"){
            retryButton.visible = true;
            retryButton.animation.play("confirm", true);
            retryButton.centerOffsets();
            retryButton.x += 15;
        }
    }

}