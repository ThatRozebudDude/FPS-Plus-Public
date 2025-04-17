package modding;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import flixel.FlxG;

class ModConfig
{

	static var configMap:Map<String, Map<String, Dynamic>> = new Map<String, Map<String, ModSetting>>();

	static function load():Void{
		SaveManager.modConfig();

		if(FlxG.save.data.configMap != null){
			configMap = FlxG.save.data.configMap;
		}

		for(dir in PolymodHandler.allModDirs){
			if(!PolymodHandler.malformedMods.exists(dir)){
				if(!FileSystem.exists("mods/" + dir + "/config.json")){
					continue;
				}
				var meta = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
				var json = Json.parse(File.getContent("mods/" + dir + "/config.json"));

				if(!configMap.exists(meta.uuid)){
					configMap.set(meta.uuid, new Map<String, ModSetting>());
				}

				for(i in 0...json.config.length){
					var setting:ModSetting;

					switch(json.config[i].type){
						case "bool":
							setting = {
								type: "bool",
								value: json.config[i].properties.defaultBool
							};
						case "int":
							setting = {
								type: "int",
								value: Std.int(json.config[i].properties.defaultValue)
							};
						case "float":
							setting = {
								type: "float",
								value: json.config[i].properties.defaultValue
							};
						case "list":
							setting = {
								type: "list",
								value: json.config[i].properties.values[Std.int(json.config[i].properties.defaultIndex)]
							};
						default:
							trace("Unknown config type \"" + json.config[i].type + "\", skipping.");
					}
					
					if(!configMap.get(meta.uuid).exists(json.config[i].name)){
						configMap.get(meta.uuid).set(json.config[i].name, setting);
					}
					else{
						//Should probably add more checks later to make sure stuff doesn't go out of bounds or whatever.
						if(configMap.get(meta.uuid).get(json.config[i].name).type != setting.type){
							configMap.get(meta.uuid).set(json.config[i].name, setting);
						}
					}
				}
			}
		}

		save();

		SaveManager.previousSave();
	}

	static function save():Void{
		SaveManager.modConfig();
		FlxG.save.data.configMap = configMap;
		SaveManager.previousSave();
	}

	public static function get(uuid:String, name:String):Dynamic{
		var r = configMap.get(uuid);
		if(r != null){ r = r.get(name).value; }
		return r;
	}

}

typedef ModSetting = {
	type:String,
	value:Dynamic
}