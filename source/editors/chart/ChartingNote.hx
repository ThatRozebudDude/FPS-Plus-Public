package editors.chart;

import flixel.FlxObject;
import flixel.FlxG;
import shaders.TintShader;
import Chart.NoteDefinition;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class ChartingNote extends FlxTypedSpriteGroup<FlxSprite>
{

	static inline final SUSTAIN_GRAPHIC_WIDTH:Float = 14;

	public var direction:Int = 0;
	public var time:Float = 0;
	public var player:Bool = false;
	public var sustainLength(default, set):Int = 0; //Length in steps.
	public var tag(default, set):String = "";

	var note:FlxSprite;
	var sustainBody:FlxSprite;
	var sustainEnd:FlxSprite;
	var asterisk:FlxSprite;
	var holdOverlap:FlxObject;

	var tintShader:TintShader;

	public function new(){
		super(0, 0);
		var noteFrames = Paths.getSparrowAtlas("ui/notes/NOTE_assets");

		tintShader = new TintShader(0xFFFFFFFF, 0);
		
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
		note.setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		note.updateHitbox();
		note.shader = tintShader.shader;

		sustainBody = new FlxSprite(ChartingState.GRID_SIZE/2 - SUSTAIN_GRAPHIC_WIDTH/2, ChartingState.GRID_SIZE/2);
		sustainBody.frames = noteFrames;
		sustainBody.animation.addByPrefix("0", "purple hold piece", 0, false);
		sustainBody.animation.addByPrefix("1", "blue hold piece", 0, false);
		sustainBody.animation.addByPrefix("2", "green hold piece", 0, false);
		sustainBody.animation.addByPrefix("3", "red hold piece", 0, false);
		sustainBody.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, (ChartingState.GRID_SIZE + ChartingState.GRID_SIZE/2)+1);
		sustainBody.updateHitbox();
		sustainBody.visible = false;
		sustainBody.antialiasing = false;
		sustainBody.shader = tintShader.shader;

		sustainEnd = new FlxSprite(ChartingState.GRID_SIZE/2 - SUSTAIN_GRAPHIC_WIDTH/2, ChartingState.GRID_SIZE*2);
		sustainEnd.frames = noteFrames;
		sustainEnd.animation.addByPrefix("0", "pruple end hold", 0, false);
		sustainEnd.animation.addByPrefix("1", "blue hold end", 0, false);
		sustainEnd.animation.addByPrefix("2", "green hold end", 0, false);
		sustainEnd.animation.addByPrefix("3", "red hold end", 0, false);
		sustainEnd.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, ChartingState.GRID_SIZE/2);
		sustainEnd.updateHitbox();
		sustainEnd.visible = false;
		sustainEnd.shader = tintShader.shader;

		asterisk = new FlxSprite().loadGraphic(Paths.image("fpsPlus/editors/chart/asterisk"));
		asterisk.scale.set(0.5, 0.5);
		asterisk.updateHitbox();
		asterisk.visible = false;
		asterisk.shader = tintShader.shader;

		holdOverlap = new FlxObject(0, 0, ChartingState.GRID_SIZE, 0);

		add(sustainBody);
		add(sustainEnd);
		add(note);
		add(asterisk);

		active = false;
	}

	public function updateProperties(_x:Float, _y:Float, _direction:Int, _time:Float, _player:Bool, _tag:String):Void{
		x = _x;
		y = _y;
		direction = _direction;
		time = _time;
		player = _player;
		tag = _tag;

		holdOverlap.x = note.x;
		holdOverlap.y = note.y + ChartingState.GRID_SIZE;

		asterisk.x = note.x + note.width - asterisk.width;
		asterisk.y = note.y;
		updateSustainGraphics();

		note.animation.play(""+direction);
		sustainBody.animation.play(""+direction);
		sustainEnd.animation.play(""+direction);
	}

	public function set_sustainLength(v:Int):Int{
		sustainLength = v;
		updateSustainGraphics();
		return sustainLength;
	}
	
	public function set_tag(v:String):String{
		tag = v;
		asterisk.visible = tag.length > 0;
		return tag;
	}

	public inline function select():Void{
		if(tintShader.amount != 0.5){
			tintShader.amount = 0.5;
		}
	}

	public inline function deselect():Void{
		if(tintShader.amount != 0){
			tintShader.amount = 0;
		}
	}

	function updateSustainGraphics():Void{
		if(sustainLength > 0){
			sustainBody.visible = true;
			sustainBody.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, (ChartingState.GRID_SIZE*(sustainLength-1))+(ChartingState.GRID_SIZE/2)+1);
			sustainBody.updateHitbox();
			
			sustainEnd.visible = true;
			sustainEnd.y = note.y + (ChartingState.GRID_SIZE*sustainLength);
			sustainEnd.setGraphicSize(SUSTAIN_GRAPHIC_WIDTH, ChartingState.GRID_SIZE/2);
			sustainEnd.updateHitbox();

			holdOverlap.height = (ChartingState.GRID_SIZE*(sustainLength-1))+((ChartingState.GRID_SIZE/2)+1);
		}
		else{
			sustainBody.visible = false;
			sustainEnd.visible = false;
		}
	}

	public inline function generateNoteDefinition():NoteDefinition{
		return {
			time: time,
			direction: direction,
			length: sustainLength,
			tag: tag,
			player: player
		};
	}

	public inline function isMouseOverHold():Bool{
		if(sustainLength > 0){
			return FlxG.mouse.overlaps(holdOverlap);
		}
		return false;
	}

}