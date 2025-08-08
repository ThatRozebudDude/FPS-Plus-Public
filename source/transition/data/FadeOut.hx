package transition.data;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
    A simple fade to a color.
**/
class FadeOut extends BaseTransition{

    var blockThing:FlxSprite;
    var time:Float;

	final PADDING:Int = 2;

    override public function new(_time:Float, ?_color:FlxColor = FlxColor.BLACK){
        
        super();

        time = _time;

        blockThing = new FlxSprite().makeGraphic(FlxG.width + PADDING, FlxG.height + PADDING, _color);
        blockThing.alpha = 0;
		blockThing.screenCenter(XY);
        add(blockThing);

    }

    override public function play(){
        FlxTween.tween(blockThing, {alpha: 1}, time, {ease: FlxEase.quartOut, onComplete: function(tween){
            end();
        }});
    }

}