package metadata;

import haxe.Json;

class SongMetadata
{
	private var jsonData:Dynamic;

	public var name:String = "";
	public var artist:String = "Unknown";
	public var album:String = "vol1";
	public var difficulties:Array<Int> = [0, 0, 0];
	public var dadBeats:Array<Int> = [0, 2];
	public var bfBeats:Array<Int> = [1, 3];
	public var compatableInsts:Null<Array<String>> = null;
	public var mixName:String = "Original";

	public function new(song:String)
	{
		if (Utils.exists(Paths.json(song + "/meta"))){
			jsonData = Json.parse(Utils.getText(Paths.json(song + "/meta")));

			if (jsonData.name != null){ name = jsonData.name; }
			else{ name = song; }
	
			if(jsonData.artist != null){ artist = jsonData.artist; }
			if(jsonData.album != null){ album = jsonData.album; }
			if(jsonData.difficulties != null){ difficulties = jsonData.difficulties; }
	
			if(jsonData.dadBeats != null){ dadBeats = jsonData.dadBeats; }
			if(jsonData.bfBeats != null){ bfBeats = jsonData.bfBeats; }
	
			if(jsonData.compatableInsts != null){ compatableInsts = jsonData.compatableInsts; }
			if(jsonData.mixName != null){ mixName = jsonData.mixName; }
		}
	}
}