package extensions.flixel;

import openfl.display.BitmapData;
import flixel.text.FlxText;

class FlxTextExt extends FlxText
{

	public var outlineSteps:Int = 16;
	public var outlineExpandDistance:Float = 8;

	public var leading(get, set):Null<Int>;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		antialiasing = true;
	}

	override function applyBorderStyle():Void
	{
		var iterations:Int = Std.int(borderSize * borderQuality);
		if (iterations <= 0)
		{
			iterations = 1;
		}
		var delta:Float = borderSize / iterations;

		switch (borderStyle)
		{
			case SHADOW:
				// Render a shadow beneath the text
				// (do one lower-right offset draw call)
				applyFormats(_formatAdjusted, true);

				for (i in 0...iterations)
				{
					copyTextWithOffset(delta, delta);
				}

				_matrix.translate(-shadowOffset.x * borderSize, -shadowOffset.y * borderSize);

			case OUTLINE:
				
				applyFormats(_formatAdjusted, true);

				var outlineExpandDelta:Float = outlineExpandDistance;

				while(true){

					var breakAfterThing:Bool = false;
					
					if(outlineExpandDelta > borderSize){
						outlineExpandDelta = borderSize;
						breakAfterThing = true;
					}

					var stepSize:Float = 360/outlineSteps;
					for(j in 0...outlineSteps){
						copyTextAtAngle(stepSize * j, outlineExpandDelta);
					}

					if(breakAfterThing){
						break;
					}

					outlineExpandDelta += outlineExpandDistance;

				}

			case OUTLINE_FAST:
				// Render an outline around the text
				// (do 4 diagonal offset draw calls)
				// (this method might not work with certain narrow fonts)
				applyFormats(_formatAdjusted, true);

				var curDelta:Float = delta;
				for (i in 0...iterations)
				{
					copyTextWithOffset(-curDelta, -curDelta); // upper-left
					copyTextWithOffset(curDelta * 2, 0); // upper-right
					copyTextWithOffset(0, curDelta * 2); // lower-right
					copyTextWithOffset(-curDelta * 2, 0); // lower-left

					_matrix.translate(curDelta, -curDelta); // return to center
					curDelta += delta;
				}

			default:
		}
	}

	inline function copyTextAtAngle(angle:Float, distance:Float = 1) {

		var newX = distance * cos(angle);
		var newY = distance * sin(angle);

		var graphic:BitmapData = _hasBorderAlpha ? _borderPixels : graphic.bitmap;
		_matrix.translate(newX, newY);
		drawTextFieldTo(graphic);
		_matrix.translate(-newX, -newY);
	}

	//my lookup table :face_holding_back_tears:
	inline function cos(a:Float):Float{

		switch(a){
			case 0 | 360:
				return 1;
			case 22.5 | 337.5:
				return 0.92387953251;
			case 45 | 315:
				return 0.70710678118;
			case 67.5 | 292.5:
				return 0.38268343236;
			case 90 | 270:
				return 0;
			case 112.5 | 247.5:
				return -0.38268343236;
			case 135 | 225:
				return -0.70710678118;
			case 157.5 | 202.5:
				return -0.92387953251;
			case 180:
				return -1;
			default:
				//trace("not in table");
				return Math.cos(angle);
		}

	}

	inline function sin(a:Float):Float{

		switch(a){
			case 0 | 180 | 360:
				return 0;
			case 22.5 | 157.5:
				return 0.38268343236;
			case 45 | 135:
				return 0.70710678118;
			case 67.5 | 112.5:
				return 0.92387953251;
			case 90:
				return 1;
			case 202.5 | 337.5:
				return -0.38268343236;
			case 225 | 315:
				return -0.70710678118;
			case 247.5 | 292.5:
				return -0.92387953251;
			case 270:
				return -1;
			default:
				//trace("not in table");
				return Math.sin(angle);
		}

	}

	function set_leading(value:Null<Int>):Null<Int> {
		_defaultFormat.leading = value;
		updateDefaultFormat();
		return value;
	}

	inline function get_leading():Null<Int> {
		return _defaultFormat.leading;
	}
}