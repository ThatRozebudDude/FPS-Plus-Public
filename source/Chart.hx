package;

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
	
}