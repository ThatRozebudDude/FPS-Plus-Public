package;

typedef ChartFormat = {
	var meta:ChartMeta;
	var notes:Array<NoteValues>;
}

typedef ChartMeta = {
	var format:String;
	var song:String;
	var bpm:Float;
	var player:String;
	var opponent:String;
	var speaker:String;
	var stage:String;
	var scroll:Float;
}

typedef NoteValues = {
	var time:Float;
	var direction:Int;
	var tag:String;
	var player:Bool;
}

class Chart
{
	
}