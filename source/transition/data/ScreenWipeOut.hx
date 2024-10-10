package transition.data;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;

/**
    Recreation of the normal FNF transition out.
**/
class ScreenWipeOut extends BaseTransition{

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

        blockThing = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height*2, [FlxColor.BLACK, FlxColor.BLACK, 0x00000000]);
        blockThing.y -= blockThing.height;
        add(blockThing);

    }

    override public function play(){
        FlxTween.tween(blockThing, {y: 0}, time, {ease: ease, onComplete: function(tween){
            end();
        }});
    }

}