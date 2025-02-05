package debug;

import cutscenes.ScriptedCutscene;
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

class CutsceneDebug extends FlxState
{
	var cutsceneTest:ScriptedCutscene;

	override function create() {
		cutsceneTest = new ScriptedCutscene();
		cutsceneTest.addEvent(0, event1);
		cutsceneTest.addEvent(1, event2);
		cutsceneTest.addEvent(3, event3);
		add(cutsceneTest);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(cutsceneTest != null && FlxG.keys.anyJustPressed([SPACE])){
			cutsceneTest.start();
		}
	}

	function event1():Void{
		trace("THIS IS THE FIRST EVENT! YAY!");
	}

	function event2():Void{
		trace("THIS IS THE SECOND EVENT! ONE SECOND HAS PASSED!");
	}

	function event3():Void{
		trace("THE END, DESTROYING EVERYTHING AND KILLING MYSELF!");
	}

}
