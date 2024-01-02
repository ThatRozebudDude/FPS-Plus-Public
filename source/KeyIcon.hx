package;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class KeyIcon extends FlxSpriteGroup
{

	static final customGraphicKeys = [BACKSPACE, BREAK, CAPSLOCK, CONTROL, DELETE, DOWN, END, ENTER, ESCAPE, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, GRAVEACCENT, HOME, INSERT, LEFT, MENU, NUMLOCK, PAGEUP, PAGEDOWN, PRINTSCREEN, RIGHT, SCROLL_LOCK, SHIFT, SPACE, TAB, UP, WINDOWS];

	public var key:FlxKey;

	public function new(_x:Float, _y:Float, _key:FlxKey){

		super(_x, _y);
		key = _key;
		createGraphics();

	}

	function createGraphics() {

		if(customGraphicKeys.contains(key)){
			loadKeyGraphic(key.toString().toLowerCase());
		}
		else{
			var isKeypad:Bool = key.toString().contains("NUMPAD");
			var keyText:String = "";
			switch(key){
				default:
					keyText = key.toString().charAt(0);
			}
			generateDefaultKeyIcon(keyText, isKeypad);
		}

	}

	function generateDefaultKeyIcon(text:String, isKeypad:Bool) {
		
		var keyBg = loadKeyGraphic("key" + (isKeypad ? "_kp" : "0"));

		var text = new FlxText(0, 0, 80, text, 80);
		text.setFormat(Paths.font("Funkin-Bold", "otf"), 80, FlxColor.BLACK, FlxTextAlign.CENTER);
		text.y = (keyBg.height / 2) - (text.height / 2) - 3;
        add(text);

	}

	function loadKeyGraphic(frame:String):FlxSprite {
		var k = new FlxSprite(0, 0);
		k.frames = Paths.getSparrowAtlas("ui/keyIcons");
		k.animation.addByPrefix("k", frame, 0, false);
		k.animation.play("k");
		add(k);
		return k;
	}

}
