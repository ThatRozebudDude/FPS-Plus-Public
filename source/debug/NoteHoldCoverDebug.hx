package debug;

import note.NoteHoldCover;
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

class NoteHoldCoverDebug extends FlxState
{

	var infoText:FlxText;

	var cover:NoteHoldCover;

	override function create() {

		var box = new FlxSprite().makeGraphic(110, 110, 0xFF808080);
		box.screenCenter(XY);
		add(box);

		infoText = new FlxText(24, 24, 0, "", 16);
		add(infoText);
		
		NoteHoldCover.coverPath = "week6/weeb/pixelUI/noteHoldCovers-pixel";
		cover = new NoteHoldCover(box, 0);
		add(cover);

		super.create();

		updateText();

	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.anyJustPressed([SPACE])){
			cover.start();
		}

		if(FlxG.keys.anyJustReleased([SPACE])){
			cover.end(true);
		}

		if(FlxG.keys.anyJustPressed([ANY])){
			updateText();
		}
	}

	function updateText() {
		infoText.text = "";
	}

}
