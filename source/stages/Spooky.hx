package stages;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class Spooky extends BaseStage
{

	var halloweenBG:FlxSprite;

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

    public override function init(){
        name = 'spooky';
        startingZoom = 1.05;

		halloweenBG = new FlxSprite(-200, -100);
		halloweenBG.frames = Paths.getSparrowAtlas("week2/halloween_bg");
		halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
		halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
		halloweenBG.animation.play('idle');
		halloweenBG.antialiasing = true;
		addToBackground(halloweenBG);

		dadStart.set(346, 849);
    }

	public override function beat(curBeat:Int){
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset){
			lightningStrikeShit(curBeat);
		}
	}

	function lightningStrikeShit(curBeat:Int):Void
	{
		FlxG.sound.play(Paths.sound('thunder_' + FlxG.random.int(1, 2)));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend().playAnim('scared', true);
		gf().playAnim('scared', true);
	}
}