package transition.data;

import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
	Transition animation made to test the new transition system.
**/
class StrangeExpandIn extends BaseTransition{

	var blockThing:FlxSprite;
	var time:Float;

	final PADDING:Int = 2;

	override public function new(_time:Float){
		
		super();

		time = _time;

		blockThing = new FlxSprite(PADDING/2, PADDING/2).makeGraphic(FlxG.width + PADDING, FlxG.height + PADDING, FlxColor.BLACK);
		add(blockThing);

	}

	override public function play(){
		FlxTween.tween(blockThing.scale, {x: 0, y: 0}, time, {ease: FlxEase.quartOut, startDelay: 0.2, onComplete: function(tween){
			end();
		}});
	}

}