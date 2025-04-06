package objects;

import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.display.Display.Package;

using StringTools;

class TankmenBG extends FlxSprite
{
	public static var animationNotes:Array<Dynamic> = [];

	public var strumTime:Float = 0;
	public var goingRight:Bool = false;
	public var tankSpeed:Float = 0.875;

	public var endingOffset:Float;

	public function new(x:Float, y:Float, isGoingRight:Bool)
	{
		super(x, y);

		// makeGraphic(200, 200);

		frames = Paths.getSparrowAtlas('week7/stage/tankmanKilled1');
		antialiasing = true;
		animation.addByPrefix('run', 'tankman running', 24, true);
		animation.addByPrefix('shot1', 'John Shot 1', 24, false);
		animation.addByPrefix('shot2', 'John Shot 2', 24, false);

		animation.play('run');
		animation.curAnim.curFrame = FlxG.random.int(0, animation.curAnim.numFrames - 1);

		updateHitbox();

		//setGraphicSize(Std.int(width * 0.8));
		//updateHitbox();
	}

	public function resetShit(x:Float, y:Float, isGoingRight:Bool)
	{
		setPosition(x, y);
		goingRight = isGoingRight;
		endingOffset = FlxG.random.float(50, 200);
		tankSpeed = (FlxG.random.float(0.6, 1) / 0.8);

		if (goingRight)
			flipX = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (x >= FlxG.width * 2 || x <= FlxG.width * -2)
			visible = false;
		else
			visible = true;

		if (animation.curAnim.name == 'run')
		{
			var endDirection:Float = (FlxG.width * 0.74) + endingOffset;

			if (goingRight)
			{
				endDirection = (FlxG.width * 0.02) - endingOffset;

				x = (endDirection + (Conductor.songPosition - strumTime) * (tankSpeed * scale.x));
			}
			else
			{
				x = (endDirection - (Conductor.songPosition - strumTime) * (tankSpeed * scale.x));
			}
		}

		if (Conductor.songPosition > strumTime && !animation.curAnim.name.startsWith("shot")){
			// kill();
			animation.play("shot" + FlxG.random.int(1, 2));

			offset.y = 150;
			if (goingRight){
				offset.x = 300;
			}
		}

		if (animation.curAnim.name.startsWith("shot") && animation.curAnim.curFrame >= animation.curAnim.frames.length - 1){
			kill();
		}
	}

	static public function loadMappedAnims(fileName:String, song:String)
	{
		var swagshit = Song.loadFromJson(fileName, song);

		var notes = swagshit.notes;

		animationNotes = [];

		for (section in notes)
		{
			for (idk in section.sectionNotes)
			{
				animationNotes.push(idk);
			}
		}

		animationNotes.sort(sortAnims);
		//trace(animationNotes);
		
	}

	static function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}
}
