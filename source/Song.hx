package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var speed:Float;

	var player1:String;
	var player2:String;
	var stage:String;
	var gf:String;
}

typedef SongEvents =
{
	var events:Array<Dynamic>;
}

class Song
{

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = CoolUtil.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return swagShit;
	}
	public static function parseEventJSON(rawJson:String):SongEvents
	{
		var swagShit:SongEvents = cast Json.parse(rawJson).events;
		return swagShit;
	}
}
