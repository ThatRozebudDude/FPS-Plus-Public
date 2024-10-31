package metadata;

import haxe.Json;

using StringTools;

typedef BaseSongMetadata =
{
	var name:String;
	var icon:String;
	var artist:String;
	var album:String;
	var difficulties:Array<Int>;
	var dadBeats:Array<Int>;
	var bfBeats:Array<Int>;
}

class SongMetadata
{
	public var name:String = "";
	public var icon:String = "";
	public var artist:String = "";
	public var album:String = "";
	public var difficulties:Array<Int> = [0, 0, 0];
	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];

	public function new(song:String)
	{
		var jsonData:BaseSongMetadata = cast Json.parse(Paths.json()).song;
		if (jsonData.name != null){ name = jsonData.name; }
		else{ name = Utils.capitalizeString(song); }

		if(jsonData.icon != null){ icon = jsonData.icon; }
		if(jsonData.artist != null){ artist = jsonData.artist; }
		if(jsonData.album != null){ album = jsonData.album; }
		if(jsonData.difficulties != null){ difficulties = jsonData.difficulties; }
		if(jsonData.dadBeats != null){ bfBeats = jsonData.dadBeats; }
		if(jsonData.bfBeats != null){ bfBeats = jsonData.bfBeats; }
	}
}
