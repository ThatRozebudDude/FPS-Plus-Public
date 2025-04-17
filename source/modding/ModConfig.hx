package modding;

import flixel.FlxG;

class ModConfig
{

	static var configMap:Map<String, Map<String, Dynamic>> = new MapMap<String, Map<String, Dynamic>>();

	static function load():Void{
		SaveManager.modConfig();

		if(FlxG.save.data.configMap != null){
			configMap = FlxG.save.data.configMap;
		}

		SaveManager.previousSave();
	}

	static function save():Void{
		SaveManager.modConfig();
		FlxG.save.data.configMap = configMap;
		SaveManager.previousSave();
	}

	public static function get(uuid:String, name:String):Dynamic{
		var r = configMap.get(uuid);
		if(r != null){ r = r.get(name); }
		return r;
	}

}