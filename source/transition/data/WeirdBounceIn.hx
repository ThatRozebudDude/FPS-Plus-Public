package transition.data;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
	Transition animation made to test the new transition system.
**/
class WeirdBounceIn extends BaseTransition{

	var blockThing:FlxSprite;
	var time:Float;

	override public function new(_time:Float){
		
		super();

		time = _time;

		blockThing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blockThing);

	}

	override public function play(){
		FlxTween.tween(blockThing, {x: -blockThing.width}, time, {ease: FlxEase.quartOut, startDelay: 0.2, onComplete: function(tween){
			end();
		}});
	}

}