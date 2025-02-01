package ui;

import flixel.math.FlxPoint;
import haxe.Json;

typedef CountdownSegment = {
	var graphicPath:String;
	var audioPath:String;
	var scale:Float;
	var antialiasing:Bool;
	var offset:FlxPoint;
}

typedef CountdownSkinInfo = {
	var first:CountdownSegment;
	var second:CountdownSegment;
	var third:CountdownSegment;
	var fourth:CountdownSegment;
}

class CountdownSkinBase{

	public var info:CountdownSkinInfo = {
		first: {
			graphicPath: null, 
			audioPath: null, 
			scale: 1, 
			antialiasing: true, 
			offset: new FlxPoint(), 
		},
		second: {
			graphicPath: null, 
			audioPath: null, 
			scale: 1, 
			antialiasing: true, 
			offset: new FlxPoint(), 
		},
		third: {
			graphicPath: null, 
			audioPath: null, 
			scale: 1, 
			antialiasing: true, 
			offset: new FlxPoint(), 
		},
		fourth: {
			graphicPath: null, 
			audioPath: null, 
			scale: 1, 
			antialiasing: true, 
			offset: new FlxPoint(), 
		}
	};

	public function new(_skin:String){
		var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/countdown")));

		if(skinJson.first.audioPath != null)		{ info.first.audioPath = skinJson.first.audioPath; }
		if(skinJson.first.graphicPath != null)		{ info.first.graphicPath = skinJson.first.graphicPath; }
		if(skinJson.first.scale != null)			{ info.first.scale = skinJson.first.scale; }
		if(skinJson.first.antialiasing != null)		{ info.first.antialiasing = skinJson.first.antialiasing; }
		if(skinJson.first.offset != null)			{ info.first.offset.set(skinJson.first.offset[0], skinJson.first.offset[1]); }

		if(skinJson.second.audioPath != null)		{ info.second.audioPath = skinJson.second.audioPath; }
		if(skinJson.second.graphicPath != null)		{ info.second.graphicPath = skinJson.second.graphicPath; }
		if(skinJson.second.scale != null)			{ info.second.scale = skinJson.second.scale; }
		if(skinJson.second.antialiasing != null)	{ info.second.antialiasing = skinJson.second.antialiasing; }
		if(skinJson.second.offset != null)			{ info.second.offset.set(skinJson.second.offset[0], skinJson.second.offset[1]); }

		if(skinJson.third.audioPath != null)		{ info.third.audioPath = skinJson.third.audioPath; }
		if(skinJson.third.graphicPath != null)		{ info.third.graphicPath = skinJson.third.graphicPath; }
		if(skinJson.third.scale != null)			{ info.third.scale = skinJson.third.scale; }
		if(skinJson.third.antialiasing != null)		{ info.third.antialiasing = skinJson.third.antialiasing; }
		if(skinJson.third.offset != null)			{ info.third.offset.set(skinJson.third.offset[0], skinJson.third.offset[1]); }

		if(skinJson.fourth.audioPath != null)		{ info.fourth.audioPath = skinJson.fourth.audioPath; }
		if(skinJson.fourth.graphicPath != null)		{ info.fourth.graphicPath = skinJson.fourth.graphicPath; }
		if(skinJson.fourth.scale != null)			{ info.fourth.scale = skinJson.fourth.scale; }
		if(skinJson.fourth.antialiasing != null)	{ info.fourth.antialiasing = skinJson.fourth.antialiasing; }
		if(skinJson.fourth.offset != null)			{ info.fourth.offset.set(skinJson.fourth.offset[0], skinJson.fourth.offset[1]); }
	}

	public function toString():String{ return "CountdownSkinBase"; }
}