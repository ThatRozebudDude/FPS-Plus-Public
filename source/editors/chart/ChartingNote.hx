package editors.chart;

import flixel.FlxSprite;

class ChartingNote extends FlxSprite
{

	public var direction:Int = 0;
	public var time:Float = 0;
	public var player:Bool = false;

	public function new(_x:Float, _y:Float, _direction:Int, _time:Float, _player:Bool){
		super(_x, _y);

		direction = _direction;
		time = _time;
		player = _player;
		
		frames = Paths.getSparrowAtlas("ui/notes/NOTE_assets");
		
		animation.addByPrefix("0", "purple0", 0, false);
		animation.addByPrefix("1", "blue0", 0, false);
		animation.addByPrefix("2", "green0", 0, false);
		animation.addByPrefix("3", "red0", 0, false);
		animation.addByPrefix("0-selected", "Purple Active", 0, false);
		animation.addByPrefix("1-selected", "Blue Active", 0, false);
		animation.addByPrefix("2-selected", "Green Active", 0, false);
		animation.addByPrefix("3-selected", "Red Active", 0, false);

		animation.play(""+direction);

		setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		updateHitbox();
	}

}