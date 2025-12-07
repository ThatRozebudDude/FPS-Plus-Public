package config;

import flixel.input.gamepad.FlxGamepadInputID;
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

	static final customGraphicKeys = [ALT, BACKSPACE, BREAK, CAPSLOCK, CONTROL, DELETE, DOWN, END, ENTER, ESCAPE, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, GRAVEACCENT, HOME, INSERT, LEFT, MENU, NUMLOCK, PAGEUP, PAGEDOWN, PRINTSCREEN, RIGHT, SCROLL_LOCK, SHIFT, SPACE, TAB, UP, WINDOWS];

	public var key:FlxKey;

	public var iconWidth:Float = 80;
	public var iconHeight:Float = 80;

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
			var yOffset:Float = -3;
			switch(key){
				case BACKSLASH:
					keyText = "\\";
					yOffset += 3;
				case COMMA:
					keyText = ",";
				case LBRACKET:
					keyText = "[";
					yOffset += 4;
				case RBRACKET:
					keyText = "]";
					yOffset += 4;
				case QUOTE:
					keyText = "'";
				case SEMICOLON:
					keyText = ";";
					yOffset -= 10;
				case PLUS:
					keyText = "=";
				case NUMPADPLUS:
					keyText = "+";
				case MINUS | NUMPADMINUS:
					keyText = "-";
				case NUMPADMULTIPLY:
					keyText = "*";
				case SLASH | NUMPADSLASH:
					keyText = "/";
					yOffset += 2;
				case PERIOD | NUMPADPERIOD:
					keyText = ".";
				case ZERO | NUMPADZERO:
					keyText = "0";
				case ONE | NUMPADONE:
					keyText = "1";
				case TWO | NUMPADTWO:
					keyText = "2";
				case THREE | NUMPADTHREE:
					keyText = "3";
				case FOUR | NUMPADFOUR:
					keyText = "4";
				case FIVE | NUMPADFIVE:
					keyText = "5";
				case SIX | NUMPADSIX:
					keyText = "6";
				case SEVEN | NUMPADSEVEN:
					keyText = "7";
				case EIGHT | NUMPADEIGHT:
					keyText = "8";
				case NINE | NUMPADNINE:
					keyText = "9";
				default:
					if(key.toString().length == 1){
						keyText = key.toString();
					}
					else{ keyText = "?"; }
			}
			generateDefaultKeyIcon(keyText, isKeypad, yOffset);
		}

	}

	function generateDefaultKeyIcon(text:String, isKeypad:Bool, yOffset:Float) {
		
		var keyBg = loadKeyGraphic("key" + (isKeypad ? "_kp" : "0"));

		var text = new FlxText(0, 0, 80, text, 80);
		text.setFormat(Paths.font("funkin", "otf"), 80, FlxColor.BLACK, FlxTextAlign.CENTER);
		text.y = (keyBg.height / 2) - (text.height / 2) + yOffset;
		text.text += "\n\n";
		add(text);

	}

	function loadKeyGraphic(frame:String):FlxSprite {
		var k = new FlxSprite(0, 0);
		k.frames = Paths.getSparrowAtlas("ui/keyIcons");
		k.animation.addByPrefix("k", frame, 0, false);
		k.animation.play("k");
		add(k);

		iconWidth = Std.int(k.frameWidth / 10) * 10;
		iconHeight = Std.int(k.frameHeight / 10) * 10;

		return k;
	}

}

//Controller version of KeyIcon
class ControllerIcon extends FlxSpriteGroup
{

	static final psSkinKeys:Array<FlxGamepadInputID> = [A, B, X, Y, BACK, DPAD_DOWN, DPAD_LEFT, DPAD_UP, DPAD_RIGHT, LEFT_SHOULDER, LEFT_TRIGGER, RIGHT_SHOULDER, RIGHT_TRIGGER, LEFT_STICK_CLICK, RIGHT_STICK_CLICK, START, GUIDE];
	static final xSkinKeys:Array<FlxGamepadInputID> = [START, BACK, GUIDE];
	static final ninSkinKeys:Array<FlxGamepadInputID> = [A, B, X, Y, BACK, START, LEFT_SHOULDER, LEFT_TRIGGER, RIGHT_SHOULDER, RIGHT_TRIGGER, LEFT_STICK_CLICK, RIGHT_STICK_CLICK, EXTRA_0];

	public var key:FlxGamepadInputID;

	public var skin:String;

	public var iconWidth:Float = 80;
	public var iconHeight:Float = 80;

	public function new(_x:Float, _y:Float, _key:FlxGamepadInputID, ?_skin = ""){

		super(_x, _y);
		key = _key;
		skin = _skin;
		createGraphics();

	}

	function createGraphics() {

		var postfix:String = "0";
		if(xSkinKeys.contains(key) && skin == "x"){ postfix = "_x"; }
		if(psSkinKeys.contains(key) && skin == "ps"){ postfix = "_ps"; }
		if(ninSkinKeys.contains(key) && skin == "nin"){ postfix = "_nin"; }
		loadKeyGraphic(key.toString().toLowerCase() + postfix);

	}

	function loadKeyGraphic(frame:String):FlxSprite {
		var k = new FlxSprite(0, 0);
		k.frames = Paths.getSparrowAtlas("ui/controllerIcons");
		k.animation.addByPrefix("k", frame, 0, false);
		k.animation.play("k");
		add(k);

		iconWidth = Std.int(k.frameWidth / 10) * 10;
		iconHeight = Std.int(k.frameHeight / 10) * 10;

		return k;
	}

}
