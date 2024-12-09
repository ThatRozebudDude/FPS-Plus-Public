package debug;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage.
	**/
	public var memoryMegas:Float = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (deltaTimeout > 1000) {
			// there's no need to update this every frame and it only causes performance losses.
			deltaTimeout = 0.0;
			return;
		}
		currentTime += deltaTime;
		times.push(currentTime);
		while (times[0] < currentTime - 1000)
			times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = 'FPS: ${currentFPS}';
			
			memoryMegas = cast(System.totalMemory, UInt);
			text += '\nMem: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';

			textColor = 0xFFFFFFFF;
			if (currentFPS <= 60 / 2)
				textColor = 0xFFFF0000;

			text += "\n";
		}

		cacheCount = currentCount;
		deltaTimeout += deltaTime;
	}
}