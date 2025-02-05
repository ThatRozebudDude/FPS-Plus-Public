package objects;

import flixel.FlxG;
import flixel.FlxSprite;

class PicoBullet extends FlxSprite
{

	final MAX_DISTANCE:Int = 100;

	public function new(_x:Float = 0, _y:Float = 0) {
		super(_x, _y);

		frames = Paths.getSparrowAtlas("weekend1/PicoBullet");
		animation.addByPrefix("pop", "Pop", 24, false);
		animation.play("pop");
		animation.callback = bulletCallback;
		antialiasing = true;
	}

	function bulletCallback(name:String, frame:Int, index:Int):Void{
		switch(frame){
			case 1:
				x += FlxG.random.int(0, MAX_DISTANCE);
			case 16:
				x += FlxG.random.int(0, Std.int(MAX_DISTANCE/2));
			case 27:
				x += FlxG.random.int(0, Std.int(MAX_DISTANCE/4));
			case 35:
				x += FlxG.random.int(0, Std.int(MAX_DISTANCE/8));
		}
	}

}