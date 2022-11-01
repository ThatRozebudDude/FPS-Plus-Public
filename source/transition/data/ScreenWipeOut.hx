package transition.data;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;

/**
	Recreation of the normal FNF transition out.
**/
class ScreenWipeOut extends BasicTransition
{
	var blockThing:FlxSprite;
	var time:Float;

	override public function new(_time:Float)
	{
		super();

		time = _time;

		blockThing = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 2, [FlxColor.BLACK, FlxColor.BLACK, 0x00000000]);
		blockThing.y -= blockThing.height;
		add(blockThing);
	}

	override public function play()
	{
		FlxTween.tween(blockThing, {y: 0}, time, {
			onComplete: function(tween)
			{
				end();
			}
		});
	}
}
