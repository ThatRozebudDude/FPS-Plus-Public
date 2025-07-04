package config;

import flixel.FlxG;
using StringTools;

class CacheConfig
{
	
	public static var characters(get, set):Null<Bool>;
	public static var graphics(get, set):Null<Bool>;

	public static inline function get_characters():Null<Bool>{
		SaveManager.global();
		var r = FlxG.save.data.charPreload3;
		SaveManager.previousSave();
		return r;
	}

	public static inline function set_characters(value:Null<Bool>):Null<Bool>{
		SaveManager.global();
		FlxG.save.data.charPreload3 = value;
		SaveManager.previousSave();
		return value;
	}

	public static inline function get_graphics():Null<Bool>{
		SaveManager.global();
		var r = FlxG.save.data.graphicsPreload3;
		SaveManager.previousSave();
		return r;
	}

	public static inline function set_graphics(value:Null<Bool>):Null<Bool>{
		SaveManager.global();
		FlxG.save.data.graphicsPreload3 = value;
		SaveManager.previousSave();
		return value;
	}

	public static function check():Void{
		SaveManager.global();
		if(FlxG.save.data.charPreload3 == null) {
			FlxG.save.data.charPreload3 = false;
		}
		if(FlxG.save.data.graphicsPreload3 == null) {
			FlxG.save.data.graphicsPreload3 = false;
		}
		SaveManager.previousSave();
	}
	
}