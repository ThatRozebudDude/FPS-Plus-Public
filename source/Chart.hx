package;

import flixel.util.FlxSort;
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
	var length:Int;
	var tag:String;
	var player:Bool;
}

typedef BPMDefinition = {
	var bpm:Float;
	var time:Float;
}

typedef EventFormat = {
	var meta:EventMeta;
	var events:Array<EventDefinition>;
}

typedef EventMeta = {
	var format:String;
}

typedef EventDefinition = {
	var time:Float;
	var lane:Int;
	var tag:String;
}

class Chart
{

	public static inline final CURRENT_CHART_FORMAT:String = "fpsplus_1";

	public static function chartFromSong(song:String, difficulty:String = "normal"):ChartFormat{
		var path = Paths.json("chart-" + difficulty.toLowerCase(), "data/songs/" + song.toLowerCase());
		#if BACKWARD_COMPATIBILITY
		if (!Utils.exists(path)){
			path = Paths.json(song.toLowerCase() + (difficulty == "normal" ? "" : "-" + difficulty.toLowerCase()), "data/songs/" + song.toLowerCase());
		}
		#end

		if (!Utils.exists(path)){
			trace("Chart for \"" + song + "\" with difficulty \"" + difficulty + "\" not found!");
			return getEmptyChart();
		}

		var raw = Utils.getText(path);
		while (!raw.endsWith("}")){
			raw = raw.substr(0, raw.length - 1);
		}

		return chartFromRawJson(raw);
	}

	public static function chartFromRawJson(raw:String):ChartFormat{
		var chart:ChartFormat = getEmptyChart();
		var chartJson:Dynamic = Json.parse(raw);

		#if BACKWARD_COMPATIBILITY
		if(chartJson.meta == null){
			return convertLegacyChart(chartJson.song);
		}
		#end

		//This is where you'd do version upgrading with new formats in the future.

		if(chartJson.meta.format != null)	{ chart.meta.format = chartJson.meta.format; }
		if(chartJson.meta.song != null)		{ chart.meta.song = chartJson.meta.song; }
		if(chartJson.meta.bpm != null)		{ chart.meta.bpm = chartJson.meta.bpm; }

		if(chartJson.meta.player != null)	{ chart.meta.player = chartJson.meta.player; }
		if(chartJson.meta.opponent != null)	{ chart.meta.opponent = chartJson.meta.opponent; }
		if(chartJson.meta.speaker != null)	{ chart.meta.speaker = chartJson.meta.speaker; }

		if(chartJson.meta.stage != null)	{ chart.meta.stage = chartJson.meta.stage; }

		if(chartJson.meta.scroll != null)	{ chart.meta.scroll = chartJson.meta.scroll; }

		if(chartJson.notes != null)			{ chart.notes = chartJson.notes; }

		return chart;
	}

	public static function convertLegacyChart(legacyChart:LegacySong):ChartFormat{
		var chart:ChartFormat = getEmptyChart();
		chart.meta.format = CURRENT_CHART_FORMAT;

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

		for(section in legacyChart.notes){
			if(section.changeBPM == true){ // somehow changeBPM is null in some charts
				chart.meta.bpm.push({bpm: section.bpm, time: secTime});
				curBPM = section.bpm;
			}

			secTime += ((((60 / curBPM) * 1000) / 4) * section.lengthInSteps ?? 16);
			secStep += section.lengthInSteps;

			for(note in section.sectionNotes){
				var player:Bool = true;
				if ((!section.mustHitSection && note[1] < 4) || (section.mustHitSection && note[1] > 3)){
					player = false;
				}

				var tag:String = "";
				if (note[3] != null && note[3] is String){ tag = note[3]; }
				
				chart.notes.push({
					time: note[0],
					direction: Std.int(note[1]) % 4,
					length: Math.round(note[2] / (((60/curBPM)/4)*1000)),
					tag: tag,
					player: player
				});
			}
		}

		return chart;
	}

	public static inline function getEmptyChart():ChartFormat{
		return {
			meta: {
				format: CURRENT_CHART_FORMAT,
				song: "Fresh",
				bpm: [{bpm: 120, time: 0}],
				
				player: "Bf",
				opponent: "Dad",
				speaker: "Gf",

				stage: "Stage",
				scroll: 1
			},
			notes: []
		}
	}

	public static function eventsFromSong(song:String):EventFormat{
		var path = Paths.json("events", "data/songs/" + song.toLowerCase());

		if (!Utils.exists(path)){
			trace("Events for \"" + song + "\" not found!");
			return getEmptyEvents();
		}

		var raw = Utils.getText(path);
		while (!raw.endsWith("}")){
			raw = raw.substr(0, raw.length - 1);
		}

		return eventsFromRawJson(raw, song);
	}

	public static function eventsFromRawJson(raw:String, ?song:String):EventFormat{
		var events:EventFormat = getEmptyEvents();
		var eventsJson:Dynamic = Json.parse(raw);

		#if BACKWARD_COMPATIBILITY
		if(eventsJson.meta == null){
			return convertLegacyEvents(eventsJson.events, song);
		}
		#end

		//This is where you'd do version upgrading with new formats in the future.

		if(eventsJson.meta.format != null)	{ events.meta.format = eventsJson.meta.format; }
		if(eventsJson.events != null)		{ events.events = eventsJson.events; }

		return events;
	}

	public static function convertLegacyEvents(legacyEvents:LegacyEvents, ?song:String):EventFormat{
		var events:EventFormat = getEmptyEvents();
		events.meta.format = CURRENT_CHART_FORMAT;

		for(event in legacyEvents.events){
			events.events.push({
				time: event[1],
				lane: event[2],
				tag: event[3]
			});
		}

		events.events.sort(function(a:EventDefinition, b:EventDefinition):Int{
			var r:Int = 0;
			r = FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
			if(r == 0){
				r = FlxSort.byValues(FlxSort.ASCENDING, a.lane, b.lane);
			}
			return r;
		});

		//Convert must hit sections into camera events.
		if(song != null){
			var chartPath:String = Paths.json(song.toLowerCase() + "-hard", "data/songs/" + song.toLowerCase());
			if(!Utils.exists(chartPath)){
				chartPath = Paths.json(song.toLowerCase(), "data/songs/" + song.toLowerCase());
			}
			if(!Utils.exists(chartPath)){
				chartPath = Paths.json(song.toLowerCase() + "-easy", "data/songs/" + song.toLowerCase());
			}

			if(Utils.exists(chartPath)){
				//Get chart for mustHitSections.
				var legacyChart:LegacySong = Json.parse(Utils.getText(chartPath)).song   ;

				//For some reason trying to initialize a stage is breaking everything if someone can get it to work that would be nice.
				//Regex instead. For fun. Also I guess it doesn't need to create all the stage stuff so that's kinda nice.
				//Will not work 100% of the time, I can think of a few edge cases that would break this but whatever.
				var startState:Bool = true;
				if(Utils.exists("assets/data/stages/" + legacyChart.stage + ".hxc")){
					var scriptText:String = Utils.getText("assets/data/stages/" + legacyChart.stage + ".hxc");
					startState = startState && !(new EReg("cameraMovementEnabled(?|\\s*)=(?|\\s*)false;", "").match(scriptText));
					startState = startState && !(new EReg("cameraMovementEnabled(?|\\s*)=(?|\\s*)!cameraMovementEnabled;", "").match(scriptText));
				}

				//Make a list of every toggleCamMovement event.
				var currentState:Bool = startState;
				var toggleCamPositions:Array<Dynamic> = [{time: 0, allowed: currentState}];
				for(event in events.events){
					if(event.tag.startsWith("toggleCamMovement")){
						currentState = !currentState;
						toggleCamPositions.push({
							time: event.time,
							allowed: currentState
						});
					}
				}

				var prevFocus:Null<Bool> = null;
				var secTime:Float = 0;
				var curBPM:Float = legacyChart.bpm;

				for(section in legacyChart.notes){
					var allowCamMovement:Bool = true;

					for(t in toggleCamPositions){
						if(t.time > secTime && !Utils.inRange(secTime, t.time, 1)){ break; }
						allowCamMovement = t.allowed;
					}

					if((prevFocus == null || section.mustHitSection != prevFocus) && allowCamMovement){
						events.events.push({
							time: secTime,
							lane: 0,
							tag: "camFocus" + (section.mustHitSection ? "Bf" : "Dad")
						});
						prevFocus = section.mustHitSection;
					}

					if(section.changeBPM == true){ curBPM = section.bpm; }
					secTime += ((((60 / curBPM) * 1000) / 4) * section.lengthInSteps ?? 16);
				}
			}
		}

		events.events.sort(function(a:EventDefinition, b:EventDefinition):Int{
			var r:Int = 0;
			r = FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
			if(r == 0){
				r = FlxSort.byValues(FlxSort.ASCENDING, a.lane, b.lane);
			}
			return r;
		});

		return events;
	}

	public static inline function getEmptyEvents():EventFormat{
		return {
			meta: {
				format: CURRENT_CHART_FORMAT,
			},
			events: []
		}
	}
}


#if BACKWARD_COMPATIBILITY
typedef LegacySong = {
	var song:String;
	var notes:Array<LegacySection>;
	var bpm:Float;
	var speed:Float;
	var player1:String;
	var player2:String;
	var stage:String;
	var gf:String;
}

typedef LegacySection = {
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
}

typedef LegacyEvents = {
	var events:Array<Dynamic>;
}
#end