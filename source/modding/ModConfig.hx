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

				if(!configMap.exists(meta.uid)){
					configMap.set(meta.uid, new Map<String, ModSetting>());
				}

				for(i in 0...json.config.length){
					var setting:ModSetting = null;

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
					
					if(setting != null){
						if(!configMap.get(meta.uid).exists(json.config[i].name)){
							configMap.get(meta.uid).set(json.config[i].name, setting);
						}
						else{
							//Should probably add more checks later to make sure stuff doesn't go out of bounds or whatever.
							if(configMap.get(meta.uid).get(json.config[i].name).type != setting.type){
								trace(meta.uid + "\t" + json.config[i].name + "\tWrong type!");
								configMap.get(meta.uid).set(json.config[i].name, setting);
							}
							else if(json.config[i].properties.range != null && (configMap.get(meta.uid).get(json.config[i].name).value * 1 < json.config[i].properties.range[0] * 1 || configMap.get(meta.uid).get(json.config[i].name).value * 1 > json.config[i].properties.range[1] * 1)){
								trace(meta.uid + "\t" + json.config[i].name + "\tOut of range!");
								configMap.get(meta.uid).set(json.config[i].name, setting);
							}
							else if(json.config[i].properties.values != null && (json.config[i].properties.values.indexOf(configMap.get(meta.uid).get(json.config[i].name).value) == -1)){
								trace(meta.uid + "\t" + json.config[i].name + "\tIndex not found!");
								configMap.get(meta.uid).set(json.config[i].name, setting);
							}
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

	public static function get(uid:String, name:String):Dynamic{
		if(configMap.exists(uid)){
			//trace(uid + "\t" + name + "\t" + configMap.get(uid).get(name).value);
			return configMap.get(uid).get(name).value;
		}
		//trace(uid + "\t" + name + "\tDOES NOT EXIST?");
		return null;
	}

}

typedef ModSetting = {
	type:String,
	value:Dynamic
}