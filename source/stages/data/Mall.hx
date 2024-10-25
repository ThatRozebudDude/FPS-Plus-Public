package stages.data;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class Mall extends BaseStage
{

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

    public override function init(){
        name = "mall";
		startingZoom = 0.8;

		var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('week5/christmas/bgWalls'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.2, 0.2);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		addToBackground(bg);

		upperBoppers = new FlxSprite(-240, -90);
		upperBoppers.frames = Paths.getSparrowAtlas("week5/christmas/upperBop");
		upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		upperBoppers.antialiasing = true;
		upperBoppers.scrollFactor.set(0.33, 0.33);
		upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		upperBoppers.updateHitbox();
		addToBackground(upperBoppers);

		var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image("week5/christmas/bgEscalator"));
		bgEscalator.antialiasing = true;
		bgEscalator.scrollFactor.set(0.3, 0.3);
		bgEscalator.active = false;
		bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		bgEscalator.updateHitbox();
		addToBackground(bgEscalator);

		var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image("week5/christmas/christmasTree"));
		tree.antialiasing = true;
		tree.scrollFactor.set(0.40, 0.40);
		addToBackground(tree);

		bottomBoppers = new FlxSprite(-300, 140);
		bottomBoppers.frames = Paths.getSparrowAtlas("week5/christmas/bottomBop");
		bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		bottomBoppers.antialiasing = true;
		bottomBoppers.scrollFactor.set(0.9, 0.9);
		bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		bottomBoppers.updateHitbox();
		addToBackground(bottomBoppers);

		var underSnow:FlxSprite = Utils.makeColoredSprite(5400, 3000, 0xFFF3F4F5);
		underSnow.setPosition(-1200, 800);
		underSnow.antialiasing = true;
		addToBackground(underSnow);

		var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image("week5/christmas/fgSnow"));
		fgSnow.active = false;
		fgSnow.antialiasing = true;
		addToBackground(fgSnow);

		santa = new FlxSprite(-840, 150);
		santa.frames = Paths.getSparrowAtlas("week5/christmas/santa");
		santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		santa.animation.addByPrefix('idleLoop', 'santa idle in fear', 24, true);
		santa.animation.play("idleLoop", true);
		santa.antialiasing = true;
		addToForeground(santa);

		dadStart.set(42, 882);
		bfStart.set(1175.5, 866);
		gfStart.set(808.5, 845-60);

		bfCameraOffset.set(0, -70);

		addEvent("mall-toggleSantaVisible", toggleSantaVisible);
    }

	public override function beat(curBeat:Int){
		upperBoppers.animation.play('bop', true);
		bottomBoppers.animation.play('bop', true);
		santa.animation.play('idle', true);
	}

	function toggleSantaVisible(tag:String) {
		santa.visible = !santa.visible;
	}
}