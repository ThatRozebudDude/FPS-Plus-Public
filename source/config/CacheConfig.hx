package config;

import flixel.FlxG;
using StringTools;

class CacheConfig
{
	
	public static var music(get, set):Null<Bool>;
	public static var characters(get, set):Null<Bool>;
	public static var graphics(get, set):Null<Bool>;

	public static inline function get_music() {
		return FlxG.save.data.musicPreload3;
	}

	public static inline function set_music(value:Null<Bool>) {
		FlxG.save.data.musicPreload3 = value;
		return value;
	}

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

		if(music == null || characters == null || graphics == null) {
			return false;
		}

		return true;

	}
	
}