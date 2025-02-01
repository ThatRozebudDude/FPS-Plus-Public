package data;

import flixel.util.FlxSignal;
import flixel.util.FlxSignal;
import flixel.FlxG;

/**
	Not song events or anything like that, just in-game events that can be cancelled or skipped.
	@author Sulkiez
**/

class GameplayEvent
{
	public var onEvent:FlxSignal = new FlxSignal();
	public var onCancel:FlxSignal = new FlxSignal();

	public var name:String = "Event";
	private var cancelable:Bool = true;

	private var canceled:Bool = false;

	public function new(_name:String, _cancelable:Bool){
		name = _name;
		cancelable = _cancelable;
	}

	public function call()
	{
		if (!canceled){
			onEvent.dispatch();
		}
	}

	public function cancel()
	{
		if (cancelable)
		{
			canceled = true;
			onCancel.dispatch();
		}
	}
}