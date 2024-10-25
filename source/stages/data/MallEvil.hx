package stages.data;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class MallEvil extends BaseStage
{

    public override function init(){
        name = "mallEvil";

		var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image("week5/christmas/evilBG"));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.2, 0.2);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		addToBackground(bg);

		var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('week5/christmas/evilTree'));
		evilTree.antialiasing = true;
		evilTree.scrollFactor.set(0.2, 0.2);
		addToBackground(evilTree);

		var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("week5/christmas/evilSnow"));
		evilSnow.antialiasing = true;
		addToBackground(evilSnow);

		dadStart.set(342, 861);
		bfStart.set(1295.5, 866);
		gfStart.set(808.5, 845-60);
    }
}