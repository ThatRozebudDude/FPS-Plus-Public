package debug;

import graphics.PerspectiveSkewSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class PerspectiveSkewDebug extends FlxState
{

	var skewObject:PerspectiveSkewSprite;
	
	var testGuy1:FlxSprite;
	var testGuy2:FlxSprite;
	var testGuy3:FlxSprite;

	var camFollow:FlxObject;

	public function new() {
		super();
	}

	override function create() {
		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		skewObject = new PerspectiveSkewSprite();
		skewObject.setPositions(1280/2, 720-182, 1280/2, 182);
		skewObject.setScrollFactors(1.2, 1.2, 0.8, 0.8);
		skewObject.sprite.loadGraphic(Paths.image("fpsPlus/title/newgrounds_logo"));
		skewObject.updateSkew();

		testGuy1 = new FlxSprite(skewObject.sprite.x, skewObject.sprite.y).loadGraphic(Paths.image("fpsPlus/title/backgroundBf"));
		testGuy1.scale.set(0.5, 0.5);
		testGuy1.updateHitbox();
		testGuy1.scrollFactor.set(skewObject.getScrollFactorFromPosition(testGuy1.y).x, skewObject.getScrollFactorFromPosition(testGuy1.y).y);
		testGuy1.x -= testGuy1.width/2;
		testGuy1.y -= testGuy1.height;

		testGuy2 = new FlxSprite(skewObject.sprite.x + skewObject.sprite.width/2, skewObject.sprite.y + skewObject.sprite.height/2).loadGraphic(Paths.image("fpsPlus/title/backgroundBf"));
		testGuy2.scale.set(0.5, 0.5);
		testGuy2.updateHitbox();
		testGuy2.scrollFactor.set(skewObject.getScrollFactorFromPosition(testGuy2.y).x, skewObject.getScrollFactorFromPosition(testGuy2.y).y);
		testGuy2.x -= testGuy2.width/2;
		testGuy2.y -= testGuy2.height;

		testGuy3 = new FlxSprite(skewObject.sprite.x + skewObject.sprite.width, skewObject.sprite.y + skewObject.sprite.height).loadGraphic(Paths.image("fpsPlus/title/backgroundBf"));
		testGuy3.scale.set(0.5, 0.5);
		testGuy3.updateHitbox();
		testGuy3.scrollFactor.set(skewObject.getScrollFactorFromPosition(testGuy3.y).x, skewObject.getScrollFactorFromPosition(testGuy3.y).y);
		testGuy3.x -= testGuy3.width/2;
		testGuy3.y -= testGuy3.height;

		add(skewObject);
		add(testGuy1);
		add(testGuy2);
		add(testGuy3);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	final zoomSpeed:Float = 0.005;
	final moveSpeed:Float = 400;
	
	override function update(elapsed:Float) {
		var amount:Int = 1;

		if (FlxG.keys.pressed.SHIFT){
			amount = 10;
		}
		
		if (FlxG.keys.pressed.W)
			camFollow.velocity.y = -1 * moveSpeed / FlxG.camera.zoom;
		else if (FlxG.keys.pressed.S)
			camFollow.velocity.y = moveSpeed / FlxG.camera.zoom;
		else
			camFollow.velocity.y = 0;

		if (FlxG.keys.pressed.A)
			camFollow.velocity.x = -1 * moveSpeed / FlxG.camera.zoom;
		else if (FlxG.keys.pressed.D)
			camFollow.velocity.x = moveSpeed / FlxG.camera.zoom;
		else
			camFollow.velocity.x = 0;

		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += zoomSpeed * FlxG.camera.zoom;
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= zoomSpeed * FlxG.camera.zoom;

		super.update(elapsed);
	}
}
