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

        info.functions.create = create;
        info.functions.add = onAdd;
        info.functions.frame = frame;
        info.functions.playAnim = playAnim;
    }

    var retryButton:FlxSprite;
    var nene:FlxSprite;
    var hitRetry:Bool = false;

    function create(character:Character):Void{
        retryButton = new FlxSprite(character.x - 70, character.y - 270);
        retryButton.frames = Paths.getSparrowAtlas("weekend1/Pico_Death_Retry");
        retryButton.animation.addByPrefix("loop", "Retry Text Loop", 24);
        retryButton.animation.addByPrefix("confirm", "Retry Text Confirm", 24, false);
        retryButton.animation.play("loop");
        retryButton.centerOffsets();
        retryButton.antialiasing = true;
        retryButton.visible = false;

        nene = new FlxSprite(character.x - 567, character.y - 327);
        nene.frames = Paths.getSparrowAtlas("weekend1/NeneKnifeToss");
        nene.antialiasing = true;
        nene.animation.addByPrefix("throw", "knife toss", 24, false);
        nene.animation.play("throw");
        nene.animation.finishCallback = function(name:String){
			nene.visible = false;
		}

        FlxG.state.subState.add(nene);
    }

    function onAdd(character:Character):Void{
        FlxG.state.subState.add(retryButton);
    }

    function frame(character:Character, anim:String, frame:Int):Void{
        if(anim == "firstDeath" && frame == 35){
            retryButton.visible = true;
        }
        if(anim == "deathConfirm" && frame == 0 && !hitRetry){
            retryButton.visible = true;
            retryButton.animation.play("confirm", true);
            retryButton.centerOffsets();
            hitRetry = true;
        }
    }

    function playAnim(character:Character, anim:String):Void{
        if(anim == "deathConfirm"){
            retryButton.visible = true;
            retryButton.animation.play("confirm", true);
            retryButton.centerOffsets();
        }
    }

}