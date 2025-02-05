package;

import flixel.FlxG;

using StringTools;

class SaveManager
{

	inline public static function global():Void {
		FlxG.save.close();
		FlxG.save.bind("global", "Rozebud/FunkinFPSPlus");
	}

	inline public static function scores():Void {
		FlxG.save.close();
		FlxG.save.bind("scores", "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-"));
	}

	inline public static function modSpecific():Void {
		FlxG.save.close();
		FlxG.save.bind("data", "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-"));
	}

	inline public static function chartAutosave(song:String):Void {
		FlxG.save.close();
		FlxG.save.bind(song, "Rozebud/FunkinFPSPlus/" + openfl.Lib.current.stage.application.meta["company"].replace(" ", "-") + "." + openfl.Lib.current.stage.application.meta["file"].replace(" ", "-") + "/Chart-Editor-Autosaves");
	}

	inline public static function flush():Void {
		FlxG.save.flush();
	}

	inline public static function close():Void {
		FlxG.save.close();
	}
	
}