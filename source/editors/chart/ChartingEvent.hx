package editors.chart;

import Chart.EventDefinition;
import flixel.FlxSprite;

class ChartingEvent extends FlxSprite
{

	public var lane:Int = 0;
	public var time:Float = 0;
	public var tag:String = "";

	public function new(){
		super(0, 0);
	}

	public function updateProperties(_x:Float, _y:Float, _lane:Int, _time:Float, _tag:String):Void{
		x = _x;
		y = _y;
		lane = _lane;
		time = _time;
		tag = _tag;

		setEventGraphic();
	}

	//TODO: Actually make it load the correct graphic.
	function setEventGraphic():Void{
		loadGraphic(Paths.image("fpsPlus/editors/chart/events/generic")); //I'm going to move the event icons to this folder and probably redo them to look better.
		setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		updateHitbox();
	}

	public inline function generateEventDefinition():EventDefinition{
		return {
			time: time,
			lane: lane,
			tag: tag
		};
	}

}