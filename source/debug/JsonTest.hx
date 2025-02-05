package debug;

import haxe.Json;
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

class JsonTest extends FlxState
{
	
	final json1 = '{
		"startCutscene": {
		  "name": "test1",
		  "storyOnly": true
		},
		"endCutscene": {
		  "name": "test2",
		  "storyOnly": false
		}
	  }';

	final json2 = '{
		"startCutscene": "null",
		"endCutscene": "null"
	  }';

	final json3 = '{
		"startCutscene": "null",
		"endCutscene": {
			"name": "testBRO",
			"storyOnly": true
		  }
	  }';


	//testing to see how shit works
	override function create() {
		super.create();

		var obj1 = Json.parse(json1);
		var obj2 = Json.parse(json2);
		var obj3 = Json.parse(json3);

		trace(obj1);
		trace(obj2);
		trace(obj3);

		trace(Type.typeof(obj3.startCutscene));
		trace(Type.typeof(obj3.endCutscene));
	}

}
