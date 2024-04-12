package debug;

import flixel.math.FlxPoint;
import characters.CharacterInfoBase;
import config.Config;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class ScaleDebug extends FlxState
{

	var char:Character;
	var charScale:Float;

	var infoText:FlxText;

	override function create() {

		char = new Character(200, 200, "SenpaiAngry");
		add(char);
		charScale = char.scale.x;

		infoText = new FlxText(24, 24, 0, "", 16);
		add(infoText);

		super.create();

		updateScale();

	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.anyJustPressed([W])){
			charScale += 0.05;
			updateScale();
		}
		if(FlxG.keys.anyJustPressed([S])){
			charScale -= 0.05;
			updateScale();
		}
		if(FlxG.keys.anyPressed([E])){
			charScale += 0.05;
			updateScale();
		}
		if(FlxG.keys.anyPressed([D])){
			charScale -= 0.05;
			updateScale();
		}

	}

	function updateScale():Void{
		char.scale.set(charScale, charScale);
		char.updateHitbox();
		updateText();
	}

	function updateText():Void{
		infoText.text = "char.scale: " + char.scale + "\nchar.offset: " + char.offset + "\nchar.width: " + char.width + "\nchar.height: " + char.height;
	}

}
