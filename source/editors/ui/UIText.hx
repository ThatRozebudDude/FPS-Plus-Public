package editors.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class UIText extends FlxBitmapText
{

	public static inline final X_ADVANCE:Float = 11;

	public function new(_x:Float, _y:Float, _text:String, _scale:Float = 0.5){
		super(_x, _y, _text, FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		scale.set(_scale, _scale);
		updateHitbox();
	}
}