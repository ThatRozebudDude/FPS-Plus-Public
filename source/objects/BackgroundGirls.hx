package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundGirls extends FlxSprite
{
	public function new(x:Float, y:Float){
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas("week6/weeb/bgFreaks");

		animation.addByIndices('danceLeft', 'BG girls group', Utils.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', Utils.numberArray(30, 15), "", 24, false);

		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function getScared():Void{
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', Utils.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', Utils.numberArray(30, 15), "", 24, false);
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
