package editors.chart;

import Chart.BPMDefinition;
import flixel.FlxSprite;

class ChartingBPM extends FlxSprite
{

	static inline final SUSTAIN_GRAPHIC_WIDTH:Float = 14;

	public var bpm:Float = 1;
	public var time:Float = 0;

	public function new(){
		super(0, 0);
		loadGraphic(Paths.image("fpsPlus/editors/chart/metronomeIcon"));
		setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		updateHitbox();
		active = false;
	}

	public function updateProperties(_x:Float, _y:Float, _bpm:Float, _time:Float):Void{
		x = _x;
		y = _y;
		bpm = _bpm;
		time = _time;
	}

	public inline function generateBPMDefinition():BPMDefinition{
		return {
			bpm: bpm,
			time: time,
		};
	}

}