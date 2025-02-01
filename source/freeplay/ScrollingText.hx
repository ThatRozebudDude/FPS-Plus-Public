package freeplay;

import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;

class ScrollingText
{

	public static function createScrollingText(x:Float, y:Float, text:FlxSprite, ?repeatAxis:FlxAxes = X):FlxBackdrop{
		text.drawFrame(true);
		var r = new FlxBackdrop(text.pixels, repeatAxis);
		r.x = x;
		r.y = y;
		return r;
	}

}

typedef ScrollingTextInfo = {
	text:String,
	font:String,
	size:Int,
	color:FlxColor,
	position:FlxPoint,
	velocity:Float
}