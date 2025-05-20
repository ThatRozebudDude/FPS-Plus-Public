package config;

import flixel.FlxG;
using StringTools;

class CacheConfig
{
	
	public static var characters(get, set):Null<Bool>;
	public static var graphics(get, set):Null<Bool>;

	public static inline function get_characters() {
		return FlxG.save.data.charPreload3;
	}

	public static inline function set_characters(value:Null<Bool>) {
		FlxG.save.data.charPreload3 = value;
		return value;
	}

	public static inline function get_graphics() {
		return FlxG.save.data.graphicsPreload3;
	}

	public static inline function set_graphics(value:Null<Bool>) {
		FlxG.save.data.graphicsPreload3 = value;
		return value;
	}

	public static function check():Bool{

		if(characters == null || graphics == null) {
			return false;
		}

		return true;

	}
	
}