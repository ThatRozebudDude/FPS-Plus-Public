#if BACKWARD_COMPATIBILITY
package;

import Chart.LegacyEvents;
import Chart.LegacySong;
import haxe.Json;

using StringTools;

typedef SwagSong = LegacySong;

typedef SongEvents = LegacyEvents;

class Song
{

	public static function loadFromJson(jsonInput:String, ?folder:String):LegacySong
	{
		var rawJson = Utils.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):LegacySong
	{
		var swagShit:LegacySong = cast Json.parse(rawJson).song;
		return swagShit;
	}
	public static function parseEventJSON(rawJson:String):LegacyEvents
	{
		var swagShit:LegacyEvents = cast Json.parse(rawJson).events;
		return swagShit;
	}
}
#end