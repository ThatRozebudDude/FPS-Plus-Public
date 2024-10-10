package transition.data;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;

/**
    Recreation of the normal FNF transition in.
**/
class ScreenWipeIn extends BaseTransition{

    var blockThing:FlxSprite;
    var time:Float;
    var ease:Null<EaseFunction>;

    override public function new(_time:Float, ?_ease:Null<EaseFunction>){
        
        super();

        time = _time;

        if(_ease == null){
            ease = FlxEase.linear;
        }
        else{
            ease = _ease;
        }

        blockThing = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height*2, [0x00000000, FlxColor.BLACK, FlxColor.BLACK]);
        blockThing.y -= blockThing.height/2;
        add(blockThing);

    }

    override public function play(){
        FlxTween.tween(blockThing, {y: blockThing.height/2}, time, {ease: ease, onComplete: function(tween){
            end();
        }});
    }

}