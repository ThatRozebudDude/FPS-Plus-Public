package editors.chart;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class ChartingNote extends FlxTypedSpriteGroup<FlxSprite>
{

	static inline final SUSTAIN_GRAPHIC_WIDTH:Float = 14;

	public var direction:Int = 0;
	public var time:Float = 0;
	public var player:Bool = false;
	public var sustainLength(default, set):Int = 0; //Length in steps.

	var note:FlxSprite;
	var sustainBody:FlxSprite;
	var sustainEnd:FlxSprite;

	public function new(_x:Float, _y:Float, _direction:Int, _time:Float, _player:Bool){
		super(_x, _y);

		direction = _direction;
		time = _time;
		player = _player;

		var noteFrames = Paths.getSparrowAtlas("ui/notes/NOTE_assets");
		
		note = new FlxSprite();
		note.frames = noteFrames;
		note.animation.addByPrefix("0", "purple0", 0, false);
		note.animation.addByPrefix("1", "blue0", 0, false);
		note.animation.addByPrefix("2", "green0", 0, false);
		note.animation.addByPrefix("3", "red0", 0, false);
		note.animation.addByPrefix("0-selected", "Purple Active", 0, false);
		note.animation.addByPrefix("1-selected", "Blue Active", 0, false);
		note.animation.addByPrefix("2-selected", "Green Active", 0, false);
		note.animation.addByPrefix("3-selected", "Red Active", 0, false);
		note.animation.play(""+direction);
		note.setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		note.updateHitbox();

		sustainBody = new FlxSprite(ChartingState.GRID_SIZE/2 - SUSTAIN_GRAPHIC_WIDTH/2, ChartingState.GRID_SIZE/2);
		sustainBody.frames = noteFrames;
		sustainBody.animation.addByPrefix("0", "purple hold piece", 0, false);
		sustainBody.animation.addByPrefix("1", "blue hold piece", 0, false);
		sustainBody.animation.addByPrefix("2", "green hold piece", 0, false);
		sustainBody.animation.addByPrefix("3", "red hold piece", 0, false);
		sustainBody.animation.play(""+direction);
		sustainBody.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, (ChartingState.GRID_SIZE + ChartingState.GRID_SIZE/2)+1);
		sustainBody.updateHitbox();
		sustainBody.visible = false;
		sustainBody.antialiasing = false;

		sustainEnd = new FlxSprite(ChartingState.GRID_SIZE/2 - SUSTAIN_GRAPHIC_WIDTH/2, ChartingState.GRID_SIZE*2);
		sustainEnd.frames = noteFrames;
		sustainEnd.animation.addByPrefix("0", "pruple end hold", 0, false);
		sustainEnd.animation.addByPrefix("1", "blue hold end", 0, false);
		sustainEnd.animation.addByPrefix("2", "green hold end", 0, false);
		sustainEnd.animation.addByPrefix("3", "red hold end", 0, false);
		sustainEnd.animation.play(""+direction);
		sustainEnd.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, ChartingState.GRID_SIZE/2);
		sustainEnd.updateHitbox();
		sustainEnd.visible = false;

		add(sustainBody);
		add(sustainEnd);
		add(note);
	}

	public function set_sustainLength(v:Int):Int{
		sustainLength = v;

		if(sustainLength > 0){
			sustainBody.visible = true;
			sustainBody.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, (ChartingState.GRID_SIZE*(sustainLength-1))+(ChartingState.GRID_SIZE/2)+1);
			sustainBody.updateHitbox();
			
			sustainEnd.visible = true;
			sustainEnd.y = note.y + (ChartingState.GRID_SIZE*sustainLength);
		}
		else{
			sustainBody.visible = false;
			sustainEnd.visible = false;
		}


		return sustainLength;
	}

	public function select():Void{
		note.animation.play(direction+"-selected", true);
	}

	public function deselect():Void{
		note.animation.play(""+direction, true);
	}

}