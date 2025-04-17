package;

import flixel.FlxG;

using StringTools;

class SaveManager
{

	static var currentLocation:String = "";
	static var previousLocation:String = "";

	static var currentChart:String = "";

	inline public static function global():Void{
		previousLocation = currentLocation;
		FlxG.save.close();
		FlxG.save.bind("global", "Rozebud/FunkinFPSPlus");
		currentLocation = "global";
	}

	inline public static function scores():Void{
		previousLocation = currentLocation;
		FlxG.save.close();
		FlxG.save.bind("scores", "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-"));
		currentLocation = "scores";
	}

	inline public static function modSpecific():Void{
		previousLocation = currentLocation;
		FlxG.save.close();
		FlxG.save.bind("data", "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-"));
		currentLocation = "modSpecific";
	}

	inline public static function chartAutosave(song:String):Void{
		previousLocation = currentLocation;
		currentChart = song;
		FlxG.save.close();
		FlxG.save.bind(currentChart, "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-") + "/Chart-Editor-Autosaves");
		currentLocation = "chartAutosave";
	}

	inline public static function modConfig():Void{
		previousLocation = currentLocation;
		FlxG.save.close();
		FlxG.save.bind("modConfig", "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-"));
		currentLocation = "modConfig";
	}

	inline public static function flush():Void{
		FlxG.save.flush();
	}

	inline public static function close():Void{
		FlxG.save.close();
	}

	public static function previousSave():Void{
		switch(previousLocation){
			case "global":
				global();
			case "scores":
				scores();
			case "modSpecific":
				modSpecific();
			case "chartAutosave":
				chartAutosave(currentChart);
			case "modConfig":
				modConfig();
			default:
				trace("Invalid save location.");
		}
	}
	
}