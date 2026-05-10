#if BACKWARD_COMPATIBILITY
package;

import haxe.Json;
import Chart.LegacySong;
import Chart.LegacySection;
import Chart.LegacyEvents;

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