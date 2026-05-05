package editors.ui;

import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;

using StringTools;

class Popup extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	static inline final LERP_RATIO:Float = 0.2;
	static inline final ALPHA_LERP_RATIO:Float = 0.2;

	public var wantedX:Float = 0;
	public var wantedY:Float = 0;

	var box:Box;
	var text:UIText;

	var totalTime:Float = 0;
	var lifetime:Float = 0;

	public function new(_x:Float, _y:Float, _text:String = "", _lifetime:Float = 1.5){
		super(_x, _y);
		wantedX = _x;
		wantedY = _y;
		lifetime = _lifetime;
		alpha = 0;

		text = new UIText(LABEL_PADDING, 0, _text);
		text.color = UIColors.FILL_TEXT_COLOR;

		box = new Box(0, 0, text.width + (LABEL_PADDING*2), 24);

		text.y = (box.height/2) - (text.height/2);

		add(box);
		add(text);

		elementWidth = box.width;
		elementHeight = box.height;
	}

	override public function update(elapsed:Float):Void{
		x = Utils.fpsAdjustedLerp(x, wantedX, LERP_RATIO, 60, true);
		y = Utils.fpsAdjustedLerp(y, wantedY, LERP_RATIO, 60, true);

		if(alpha < 1 && totalTime < lifetime){
			alpha = Utils.fpsAdjustedLerp(alpha, 1, ALPHA_LERP_RATIO, 60, true, 0.01);
		}
		else if(alpha > 0 && totalTime >= lifetime){
			alpha = Utils.fpsAdjustedLerp(alpha, 0, ALPHA_LERP_RATIO, 60, true, 0.01);
		}
		else if(alpha == 0 && totalTime >= lifetime){
			kill();
		}

		box.alpha = alpha;
		text.alpha = alpha;

		totalTime += elapsed;

		super.update(elapsed);
	}

	override function destroy() {
		super.destroy();
	}

	public inline function snapToWantedPosition():Void{
		x = wantedX;
		y = wantedY;
	}
	
	public inline function setWantedToPosition():Void{
		wantedX = x;
		wantedY = y;
	}
	
}