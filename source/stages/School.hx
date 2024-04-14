package stages;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class School extends BaseStage
{

	var bgGirls:BackgroundGirls;

    public override function init(){
        name = 'school';
        uiType = "pixel";

		// defaultCamZoom = 0.9;

		var bgSky = new FlxSprite().loadGraphic(Paths.image('week6/weeb/weebSky'));
		bgSky.scrollFactor.set(0.1, 0.1);
		addToBackground(bgSky);

		var repositionShit = -200;

		var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('week6/weeb/weebSchool'));
		bgSchool.scrollFactor.set(0.6, 0.90);
		addToBackground(bgSchool);

		var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('week6/weeb/weebStreet'));
		bgStreet.scrollFactor.set(0.95, 0.95);
		addToBackground(bgStreet);

		var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('week6/weeb/weebTreesBack'));
		fgTrees.scrollFactor.set(0.9, 0.9);
		addToBackground(fgTrees);

		var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		var treetex = Paths.getPackerAtlas("week6/weeb/weebTrees");
		bgTrees.frames = treetex;
		bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		bgTrees.animation.play('treeLoop');
		bgTrees.scrollFactor.set(0.85, 0.85);
		addToBackground(bgTrees);

		var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		treeLeaves.frames = Paths.getSparrowAtlas("week6/weeb/petals");
		treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		treeLeaves.animation.play('leaves');
		treeLeaves.scrollFactor.set(0.85, 0.85);
		addToBackground(treeLeaves);

		var widShit = Std.int(bgSky.width * 6);

		bgSky.setGraphicSize(widShit);
		bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
		bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		treeLeaves.setGraphicSize(widShit);

		fgTrees.updateHitbox();
		bgSky.updateHitbox();
		bgSchool.updateHitbox();
		bgStreet.updateHitbox();
		bgTrees.updateHitbox();
		treeLeaves.updateHitbox();

		bgGirls = new BackgroundGirls(-100, 190);
		bgGirls.scrollFactor.set(0.9, 0.9);

		if (PlayState.SONG.player2 == "SenpaiAngry"){
			bgGirls.getScared();
		}

		bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
		bgGirls.updateHitbox();
		addToBackground(bgGirls);

		dadStart.set(312.5, 932);
		bfStart.set(1006.5, 925.5);
		gfStart.set(640, 801);
    }

	public override function beat(curBeat:Int){
		bgGirls.dance();
	}
}