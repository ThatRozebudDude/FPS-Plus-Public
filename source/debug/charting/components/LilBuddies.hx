package debug.charting.components;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

/*
	Little, current chart preview buddies.

	@author Rozebud
*/

class LilBuddies extends ChartComponentBasic
{

	public var lilStage:FlxSprite;
	public var lilBf:FlxSprite;
	public var lilOpp:FlxSprite;

	override public function new()
	{
		super(32, 432);
		scrollFactor.set();
	
		lilStage = new FlxSprite().loadGraphic(Paths.image("chartEditor/lilStage"));
		add(lilStage);

		lilBf = new FlxSprite().loadGraphic(Paths.image("chartEditor/lilBf"), true, 300, 256);
		lilBf.animation.add("idle", [0, 1], 12, true);
		lilBf.animation.add("0", [3, 4, 5], 12, false);
		lilBf.animation.add("1", [6, 7, 8], 12, false);
		lilBf.animation.add("2", [9, 10, 11], 12, false);
		lilBf.animation.add("3", [12, 13, 14], 12, false);
		lilBf.animation.add("yeah", [17, 20, 23], 12, false);
		lilBf.animation.play("idle");
		lilBf.animation.finishCallback = function(name:String){
			lilBf.animation.play(name, true, false, lilBf.animation.getByName(name).numFrames - 2);
		}
		add(lilBf);

		lilOpp = new FlxSprite().loadGraphic(Paths.image("chartEditor/lilOpp"), true, 300, 256);
		lilOpp.animation.add("idle", [0, 1], 12, true);
		lilOpp.animation.add("0", [3, 4, 5], 12, false);
		lilOpp.animation.add("1", [6, 7, 8], 12, false);
		lilOpp.animation.add("2", [9, 10, 11], 12, false);
		lilOpp.animation.add("3", [12, 13, 14], 12, false);
		lilOpp.animation.play("idle");
		lilOpp.animation.finishCallback = function(name:String){
			lilOpp.animation.play(name, true, false, lilOpp.animation.getByName(name).numFrames - 2);
		}
		add(lilOpp);
	}
}