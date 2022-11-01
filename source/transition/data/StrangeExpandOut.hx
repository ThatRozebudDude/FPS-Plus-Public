package transition.data;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
	Transition animation made to test the new transition system.
**/
class StrangeExpandOut extends BasicTransition
{
	var blockThing:FlxSprite;
	var time:Float;
	var wait:Float;
	var time2:Float;

	override public function new(_time:Float, _wait:Float, _time2:Float)
	{
		super();

		time = _time;
		wait = _wait;
		time2 = _time2;

		blockThing = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 4), FlxColor.BLACK);
		blockThing.x -= blockThing.width;
		blockThing.screenCenter(Y);
		add(blockThing);
	}

	override public function play()
	{
		FlxTween.tween(blockThing, {x: 0}, time, {
			ease: FlxEase.quartOut,
			onComplete: function(tween)
			{
				FlxTween.tween(blockThing.scale, {y: 4}, time2, {
					ease: FlxEase.quartOut,
					startDelay: wait,
					onComplete: function(tween)
					{
						end();
					}
				});
			}
		});
	}
}
