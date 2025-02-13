package extensions.flixel;

import flixel.math.FlxMath;
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
		// offset entire image to fit the border
		switch(borderStyle)
		{
			case SHADOW if (_shadowOffset.x != 1 || _shadowOffset.y != 1):
				_graphicOffset.x = _shadowOffset.x > 0 ? _shadowOffset.x : 0;
				_graphicOffset.y = _shadowOffset.y > 0 ? _shadowOffset.y : 0;
			
			case SHADOW: // With the default shadowOffset value
				if (borderSize < 0)
					_graphicOffset.set(-borderSize, -borderSize);
			
			case SHADOW_XY(offsetX, offsetY):
				_graphicOffset.x = offsetX < 0 ? -offsetX : 0;
				_graphicOffset.y = offsetY < 0 ? -offsetY : 0;
			
			case OUTLINE_FAST | OUTLINE if (borderSize < 0):
				_graphicOffset.set(-borderSize, -borderSize);
			
			case NONE | OUTLINE_FAST | OUTLINE:
				_graphicOffset.set(0, 0);
		}
		_matrix.translate(_graphicOffset.x, _graphicOffset.y);
		
		switch (borderStyle)
		{
			case SHADOW if (_shadowOffset.x != 1 || _shadowOffset.y != 1):
				// Render a shadow beneath the text using the shadowOffset property
				applyFormats(_formatAdjusted, true);
				
				var iterations = borderQuality < 1 ? 1 : Std.int(Math.abs(borderSize) * borderQuality);
				final delta = borderSize / iterations;
				for (i in 0...iterations)
				{
					copyTextWithOffset(delta, delta);
				}
				
				_matrix.translate(-_shadowOffset.x * borderSize, -_shadowOffset.y * borderSize);
			
			case SHADOW: // With the default shadowOffset value
				// Render a shadow beneath the text
				applyFormats(_formatAdjusted, true);
				
				final originX = _matrix.tx;
				final originY = _matrix.ty;
				
				final iterations = borderQuality < 1 ? 1 : Std.int(Math.abs(borderSize) * borderQuality);
				var i = iterations + 1;
				while (i-- > 1)
				{
					copyTextWithOffset(borderSize / iterations * i, borderSize / iterations * i);
					// reset to origin
					_matrix.tx = originX;
					_matrix.ty = originY;
				}
			
			case SHADOW_XY(shadowX, shadowY):
				// Render a shadow beneath the text with the specified offset
				applyFormats(_formatAdjusted, true);
				
				final originX = _matrix.tx;
				final originY = _matrix.ty;
				
				// Size is max of both, so (4, 4) has 4 iterations, just like SHADOW
				final size = Math.max(shadowX, shadowY);
				final iterations = borderQuality < 1 ? 1 : Std.int(size * borderQuality);
				var i = iterations + 1;
				while (i-- > 1)
				{
					copyTextWithOffset(shadowX / iterations * i, shadowY / iterations * i);
					// reset to origin
					_matrix.tx = originX;
					_matrix.ty = originY;
				}
			
			case OUTLINE: //THIS IS THE PART THAT IS REWRITTEN!
				// Render an outline around the text
				// (do 8 offset draw calls)
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
				
				final iterations = FlxMath.maxInt(1, Std.int(borderSize * borderQuality));
				var i = iterations + 1;
				while (i-- > 1)
				{
					final curDelta = borderSize / iterations * i;
					copyTextWithOffset(-curDelta, -curDelta); // upper-left
					copyTextWithOffset(curDelta * 2, 0); // upper-right
					copyTextWithOffset(0, curDelta * 2); // lower-right
					copyTextWithOffset(-curDelta * 2, 0); // lower-left
					
					_matrix.translate(curDelta, -curDelta); // return to center
				}
			
			case NONE:
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