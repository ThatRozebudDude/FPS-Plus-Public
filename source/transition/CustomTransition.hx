package transition;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import transition.data.BasicTransition;

/**
	Automatically adds and plays custom state transition animations.

	This class was made as an alternative to HaxeFlixel's built in 

	transitions to allow for more complex animations.

	Written by Rozebud
**/
class CustomTransition
{
	/**
	 * Plays a custom transition animation and switches states.
	 *
	 * @param	transitionData  The animation that will get played. Can also be anything that extends `BasicTransition`.
	 * @param	state           The state that will be switched to after the animation. If set to `null` the transition will be destroyed after playing instead of switching states.
	**/
	public static function transition(transitionData:BasicTransition, ?state:FlxState = null):Void
	{
		var transitionCamera = new FlxCamera();
		transitionCamera.bgColor.alpha = 0;
		FlxG.cameras.add(transitionCamera, false);

		transitionData.state = state;
		transitionData.cameras = [transitionCamera];
		transitionData.play();

		FlxG.state.add(transitionData);

		return;
	}
}
