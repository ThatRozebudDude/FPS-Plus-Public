package debug;

import note.NoteSplash;
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

class NoteSplashDebug extends FlxState
{

	var currentSplashAnim:Int = 1;
	var currentSplashOffsets:FlxPoint = new FlxPoint();

	var infoText:FlxText;

	override function create() {

		var box = new FlxSprite().makeGraphic(110, 110, 0xFFFFFFFF);
		box.screenCenter(XY);
		add(box);

		infoText = new FlxText(24, 24, 0, "", 16);
		add(infoText);

		NoteSplash.splashPath = "ui/noteSplashes";
		currentSplashAnim = 1;
		currentSplashOffsets.set(120, 150);

		super.create();

		updateText();

	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.anyJustPressed([ONE])){
			NoteSplash.splashPath = "ui/noteSplashes";
			currentSplashAnim = 1;
			currentSplashOffsets.set(126, 150);
		}
		if(FlxG.keys.anyJustPressed([TWO])){
			NoteSplash.splashPath = "ui/noteSplashes";
			currentSplashAnim = 2;
			currentSplashOffsets.set(138, 138);
		}
		if(FlxG.keys.anyJustPressed([THREE])){
			NoteSplash.splashPath = "week6/weeb/pixelUI/noteSplashes-pixel";
			currentSplashAnim = 1;
			currentSplashOffsets.set(21, 25);
		}
		if(FlxG.keys.anyJustPressed([FOUR])){
			NoteSplash.splashPath = "week6/weeb/pixelUI/noteSplashes-pixel";
			currentSplashAnim = 2;
			currentSplashOffsets.set(23, 23);
		}

		if(FlxG.keys.anyJustPressed([UP])){
			currentSplashOffsets.y++;
		}
		if(FlxG.keys.anyJustPressed([DOWN])){
			currentSplashOffsets.y--;
		}
		if(FlxG.keys.anyJustPressed([RIGHT])){
			currentSplashOffsets.x++;
		}
		if(FlxG.keys.anyJustPressed([LEFT])){
			currentSplashOffsets.x--;
		}

		if(FlxG.keys.anyJustPressed([ENTER])){
			createNoteSplash();
		}
		if(FlxG.keys.anyPressed([SPACE])){
			createNoteSplash();
		}

		if(FlxG.keys.anyJustPressed([ANY])){
			updateText();
		}
	}

	function createNoteSplash(){
		var bigSplashy = new NoteSplash(1280/2, 720/2, FlxG.random.int(0, 3), currentSplashAnim);
		bigSplashy.offset.set(currentSplashOffsets.x, currentSplashOffsets.y);
		bigSplashy.origin.set(currentSplashOffsets.x, currentSplashOffsets.y);
		add(bigSplashy);
	}

	function updateText() {
		infoText.text = "path: " + NoteSplash.splashPath + "\nanim: " + currentSplashAnim + "\noffset: " + currentSplashOffsets;
	}

}
