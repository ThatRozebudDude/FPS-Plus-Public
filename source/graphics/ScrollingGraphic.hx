package graphics;

import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

class ScrollingGraphic{

	public static function createScrollingGraphicFromSprite(x:Float, y:Float, text:FlxSprite, repeatAxis:FlxAxes = X):FlxBackdrop{
		text.drawFrame(true);
		var r = new FlxBackdrop(text.pixels.clone(), repeatAxis);
		r.x = x;
		r.y = y;
		return r;
	}

}