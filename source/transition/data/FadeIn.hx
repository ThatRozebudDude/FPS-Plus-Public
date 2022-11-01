package transition.data;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
	A simple fade from a color.
**/
class FadeIn extends BasicTransition
{
	var blockThing:FlxSprite;
	var time:Float;

	override public function new(_time:Float, ?_color:FlxColor = FlxColor.BLACK)
	{
		super();

		time = _time;

		blockThing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, _color);
		blockThing.alpha = 1;
		add(blockThing);
	}

	override public function play()
	{
		FlxTween.tween(blockThing, {alpha: 0}, time, {
			ease: FlxEase.quartOut,
			onComplete: function(tween)
			{
				end();
			}
		});
	}
}
