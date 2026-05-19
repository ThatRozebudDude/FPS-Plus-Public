package editors.ui;

import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;

using StringTools;

class Alert extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	static inline final LERP_RATIO:Float = 0.2;
	static inline final ALPHA_LERP_RATIO:Float = 0.2;

	public var wantedX:Float = 0;
	public var wantedY:Float = 0;

	public var text(default, set):String;

	var box:Box;
	var textElement:UIText;

	var totalTime:Float = 0;
	var lifetime:Float = 0;
	var extraPadding:Int = 0;

	public var hasLifetime:Bool = true;
	public var doLerp:Bool = true;

	public function new(_x:Float, _y:Float, _text:String = "", _lifetime:Float = 1.5, _fieldWidth:Int = 0, _extraPadding:Int = 0){
		super(_x, _y);
		wantedX = _x;
		wantedY = _y;
		lifetime = _lifetime;
		alpha = 0;
		extraPadding = _extraPadding;

		textElement = new UIText(LABEL_PADDING, 0, "Text", 0.5, _fieldWidth);
		textElement.color = UIColors.FILL_TEXT_COLOR;

		box = new Box(0, 0, textElement.width + (LABEL_PADDING*2) + (extraPadding*2), textElement.height + 4 + (extraPadding*2));
		box.offset.set(extraPadding, 0);

		textElement.y = (box.height/2) - (textElement.height/2);

		add(box);
		add(textElement);

		text = _text;
	}

	override public function update(elapsed:Float):Void{
		if(doLerp){
			x = Utils.fpsAdjustedLerp(x, wantedX, LERP_RATIO, 60, true);
			y = Utils.fpsAdjustedLerp(y, wantedY, LERP_RATIO, 60, true);
		}
		if(hasLifetime){
			if(alpha < 1 && totalTime < lifetime){
				alpha = Utils.fpsAdjustedLerp(alpha, 1, ALPHA_LERP_RATIO, 60, true, 0.01);
			}
			else if(alpha > 0 && totalTime >= lifetime){
				alpha = Utils.fpsAdjustedLerp(alpha, 0, ALPHA_LERP_RATIO, 60, true, 0.01);
			}
			else if(alpha == 0 && totalTime >= lifetime){
				kill();
			}
			totalTime += elapsed;
		}

		box.width = textElement.width + (LABEL_PADDING*2) + (extraPadding*2);
		box.height = textElement.height + 4 + (extraPadding*2);
		elementWidth = box.width;
		elementHeight = box.height;

		box.alpha = alpha;
		textElement.alpha = alpha;

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

	public function set_text(v:String):String{
		text = v;
		textElement.text = text;
		return text;
	}
	
}