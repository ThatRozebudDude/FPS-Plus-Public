package;

import haxe.Json;

using StringTools;

class Tags
{

	public static function getTagsFromString(string:String, location:String, removeDuplicates:Bool = true):Array<String>{
		var r:Array<String> = [];

		if(string.startsWith("#")){
			var tag:String = string.substring(1);
			if(Utils.exists("data/tags/"+location+"/"+tag+".json")){
				var tagJson = Json.parse(Utils.getText(Paths.json(tag, "data/tags/"+location)));
				r = tagJson.values;
			}
			else{ trace("Tag \""+location+"/"+tag+"\" does not exist!"); }
		}
		else{ r = [string]; }

		if(removeDuplicates){ r = Utils.removeDuplicates(r); }

		return r;
	}

	public static function getTagsFromArray(array:Array<String>, location:String, removeDuplicates:Bool = true):Array<String>{
		var r:Array<String> = [];

		for(v in array){
			var tag:Array<String> = getTagsFromString(v, location, false);
			r = r.concat(tag);
		}

		if(removeDuplicates){ r = Utils.removeDuplicates(r); }

		return r;
	}

}