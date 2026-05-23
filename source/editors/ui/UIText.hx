package editors.ui;

import extensions.flixel.text.FlxBitmapTextExt;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class UIText extends FlxBitmapTextExt
{

	public static inline final X_ADVANCE:Float = 11;

	public function new(_x:Float, _y:Float, _text:String, _scale:Float = 0.5, _fieldWidth:Float = 0){
		super(_x, _y, _text, FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		fieldWidth = Std.int(_fieldWidth/_scale);
		autoSize = _fieldWidth <= 0;
		scale.set(_scale, _scale);
		updateHitbox();
	}
}