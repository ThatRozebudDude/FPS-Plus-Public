package;

import haxe.Json;

using StringTools;

typedef ChartFormat = {
	var meta:ChartMeta;
	var notes:Array<NoteDefinition>;
}

typedef ChartMeta = {
	var format:String;
	var song:String;
	var bpm:Array<BPMDefinition>;
	var player:String;
	var opponent:String;
	var speaker:String;
	var stage:String;
	var scroll:Float;
}

typedef NoteDefinition = {
	var time:Float;
	var direction:Int;
	var length:Float;
	var tag:String;
	var player:Bool;
}

typedef BPMDefinition = {
	var bpm:Float;
	var time:Float;
	var step:Int;
}

class Chart
{
	public static function fromSong(song:String, difficulty:String = "normal"):ChartFormat{
		var path = Paths.json(difficulty.toLowerCase(), "data/songs/" + song.toLowerCase());
		#if BACKWARD_COMPATIBILITY
		if (!Utils.exists(path)){
			path = Paths.json(song.toLowerCase() + (difficulty == "normal" ? "" : "-" + difficulty.toLowerCase()), "data/songs/" + song.toLowerCase());
		}
		#end

		if (!Utils.exists(path)){
			trace("Chart of song: " + song + " difficulty: " + difficulty + " not found!");
			return getEmptyChart();
		}

		var raw = Utils.getText(path);
		while (!raw.endsWith("}")){
			raw = raw.substr(0, raw.length - 1);
		}

		return fromRawJson(raw, song);
	}

	public static function fromRawJson(raw:String, ?song:String):ChartFormat{
		var chart:ChartFormat = getEmptyChart();
		
		var chartJson:Dynamic = Json.parse(raw);

		#if BACKWARD_COMPATIBILITY
		if (chartJson.song.song != null){
			return convertLegacyChart(chartJson.song);
		}
		#end

		if (chartJson.meta.format != null){ chart.meta.format = chartJson.meta.format; }
		if (chartJson.meta.song != null){ chart.meta.song = chartJson.meta.song; }
		else if (song != null){ chartJson.meta.song = song; }
		if (chartJson.meta.bpm != null){ chart.meta.bpm = chartJson.meta.bpm; }

		if (chartJson.meta.player != null){ chart.meta.player = chartJson.meta.player; }
		if (chartJson.meta.opponent != null){ chart.meta.opponent = chartJson.meta.opponent; }
		if (chartJson.meta.speaker != null){ chart.meta.speaker = chartJson.meta.speaker; }

		if (chartJson.meta.stage != null){ chart.meta.stage = chartJson.meta.stage; }

		if (chartJson.meta.scroll != null){ chart.meta.scroll = chartJson.meta.scroll; }

		if (chartJson.notes != null){ chart.notes = chartJson.meta.notes; }

		return chart;
	}

	public static function convertLegacyChart(legacyChart:LegacySong):ChartFormat
	{
		var chart:ChartFormat = getEmptyChart();
		chart.meta.format = "fpsplus_legacy";

		chart.meta.song = legacyChart.song;
		chart.meta.scroll = legacyChart.speed;

		chart.meta.player = legacyChart.player1;
		chart.meta.opponent = legacyChart.player2;
		if (legacyChart.gf != null){ chart.meta.speaker = legacyChart.gf; }
		if (legacyChart.stage != null){ chart.meta.stage = legacyChart.stage; }

		chart.meta.bpm[0].bpm = legacyChart.bpm;

		var secTime:Float = 0;
		var secStep:Int = 0;
		var curBPM:Float = legacyChart.bpm;

		for (section in legacyChart.notes){
			for (note in section.sectionNotes){
				var player:Bool = true;
				if ((!section.mustHitSection && note[1] < 4) || (section.mustHitSection && note[1] > 3)){
					player = false;
				}

				var tag:String = "";
				if (note[3] != null && note[3] is String){ tag = note[3]; }
				
				chart.notes.push({
					time: note[0],
					direction: Std.int(note[1]) % 4,
					length: note[2],
					tag: tag,
					player: player
				});
			}

			if (section.changeBPM == true){ // somehow changeBPM is null in some charts
				chart.meta.bpm.push({bpm: section.bpm, time: secTime, step: secStep});
				curBPM = section.bpm;
			}

			secTime += ((((60 / curBPM) * 1000) / 4) * section.lengthInSteps ?? 16);
			secStep += section.lengthInSteps;
		}

		return chart;
	}

	public static inline function getEmptyChart():ChartFormat
	{
		return {
			meta: {
				format: "Unknown",
				song: "",
				bpm: [{bpm: 100, time: 0, step: 0}],
				
				player: "Bf",
				opponent: "Dad",
				speaker: "Gf",

				stage: "Stage",
				scroll: 1
			},
			notes: []
		}
	}
}


#if BACKWARD_COMPATIBILITY
typedef LegacySong =
{
	var song:String;
	var notes:Array<LegacySection>;
	var bpm:Float;
	var speed:Float;

	var player1:String;
	var player2:String;
	var stage:String;
	var gf:String;
}

typedef LegacySection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
}
#end