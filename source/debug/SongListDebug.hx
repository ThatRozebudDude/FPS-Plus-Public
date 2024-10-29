package debug;

import modding.PolymodHandler;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class SongListDebug extends FlxState
{

	public function new() {
		super();
	}

	override function create() {
		var songFile:Array<String> = Utils.getTextInLines(Paths.text("songlist_bf", "data/freeplay"));
		for(line in songFile){
			line = line.trim();
			if(line.startsWith("category")){
				var categoryName = line.split("|")[1].trim();
				trace("CATEGORY: \"" + categoryName + "\"");
			}
			if(line.startsWith("song")){
				var parts:Array<String> = line.split("|");
				var name:String = parts[1].trim();
				var icon:String = parts[2].trim();
				var fullArrayString:String = parts[3].trim();

				var categoryArray:Array<String> = fullArrayString.split(",");
				for(i in 0...categoryArray.length){
					if(i == 0){ categoryArray[i] = categoryArray[i].substring(1); }
					if(i == categoryArray.length-1){ categoryArray[i] = categoryArray[i].substring(0, categoryArray[i].length-1); }
					categoryArray[i] = categoryArray[i].trim();
				}
				
				trace("SONG: addSong(" + name + ", " + icon + ", " + categoryArray + ");");
			}
		}
	}
}