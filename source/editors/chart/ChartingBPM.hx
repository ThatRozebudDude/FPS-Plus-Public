package editors.chart;

import Chart.BPMDefinition;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class ChartingBPM extends FlxSprite
{

	static inline final SUSTAIN_GRAPHIC_WIDTH:Float = 14;

	public var bpm:Float = 1;
	public var time:Float = 0;

	public var updateVisibility:Bool = true;

	public function new(){
		super(0, 0);
		loadGraphic(Paths.image("fpsPlus/editors/chart/metronomeIcon"));
		setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		updateHitbox();
	}

	override function update(elapsed:Float){
		if(updateVisibility){
			var positionOnScreen:FlxPoint = getScreenPosition();
			visible = (positionOnScreen.y + ChartingState.GRID_SIZE >= 0 && positionOnScreen.y <= 720);
			positionOnScreen.put();
		}
		super.update(elapsed);
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