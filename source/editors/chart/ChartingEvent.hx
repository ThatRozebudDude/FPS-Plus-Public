package editors.chart;

import shaders.TintShader;
import Chart.EventDefinition;
import flixel.FlxSprite;

class ChartingEvent extends FlxSprite
{

	public var lane:Int = 0;
	public var time:Float = 0;
	public var tag:String = "";

	var tintShader:TintShader;

	public function new(){
		super(0, 0);
		tintShader = new TintShader(0xFFFFFFFF, 0);
		shader = tintShader.shader;
		active = false;
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
		loadGraphic(Paths.image("fpsPlus/editors/chart/events/generic"));
		setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		updateHitbox();
	}

	public function select():Void{
		tintShader.amount = 0.5;
	}

	public function deselect():Void{
		tintShader.amount = 0;
	}

	public inline function generateEventDefinition():EventDefinition{
		return {
			time: time,
			lane: lane,
			tag: tag
		};
	}

}