package editors.chart;

import Chart.BPMDefinition;
import flixel.FlxSprite;

class ChartingBPM extends FlxSprite
{

	static inline final SUSTAIN_GRAPHIC_WIDTH:Float = 14;

	public var bpm:Float = 0;
	public var time:Float = 0;

	public function new(){
		super(0, 0);
		loadGraphic(Paths.image("fpsPlus/editors/chart/metronomeIcon"));
		active = false;
	}

	public function updateProperties(_x:Float, _y:Float, _bpm:Int, _time:Float, _player:Bool, _tag:String):Void{
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