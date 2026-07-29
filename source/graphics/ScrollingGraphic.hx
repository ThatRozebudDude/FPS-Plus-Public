package graphics;

import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;

class ScrollingGraphic{

	public static function createScrollingGraphicFromSprite(x:Float, y:Float, text:FlxSprite, repeatAxis:FlxAxes = X):FlxBackdrop{
		text.drawFrame(true);
		var r = new FlxBackdrop(text.pixels.clone(), repeatAxis);
		r.x = x;
		r.y = y;
		return r;
	}

}