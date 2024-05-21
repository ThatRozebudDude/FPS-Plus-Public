package freeplay;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;

class ScrollingText
{

    public static function createScrollingText(x:Float, y:Float, text:FlxText):FlxBackdrop{
        text.drawFrame(true);
        var r = new FlxBackdrop(text.pixels, X);
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