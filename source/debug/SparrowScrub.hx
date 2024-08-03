package debug;

import flixel.FlxObject;
import flixel.FlxG;
import flxanimate.FlxAnimate;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class SparrowScrub extends FlxState
{

	var sparrow:FlxSprite;
	var camFollow:FlxObject;
	var curFrame:Int = 0;

	public function new() {
		super();
	}

	override function create() {

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		//var pico = new Character(0, 0, "PicoAll", true, false, true);
		//pico.playAnim("reload");
		//add(pico);

		sparrow = new FlxSprite();
		sparrow.frames = Paths.getSparrowAtlas("weekend1/PicoBullet");
		sparrow.animation.addByPrefix("full", "", 0, false);
		sparrow.antialiasing = true;
		//sparrow.screenCenter();
		sparrow.animation.play("full");
		add(sparrow);

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

		if (FlxG.keys.justPressed.LEFT){
			curFrame -= amount;
			if(curFrame < 0) {curFrame = 0;}
			sparrow.animation.play("full", true, false, curFrame);
			trace(curFrame);
		}

		if (FlxG.keys.justPressed.RIGHT){
			curFrame += amount;
			if(curFrame > sparrow.animation.curAnim.numFrames - 1) {curFrame = sparrow.animation.curAnim.numFrames - 1;}
			sparrow.animation.play("full", true, false, curFrame);
			trace(curFrame);
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


		if (FlxG.keys.justPressed.I)
			sparrow.y -= amount;
		if (FlxG.keys.justPressed.K)
			sparrow.y += amount;
		if (FlxG.keys.justPressed.J)
			sparrow.x -= amount;
		if (FlxG.keys.justPressed.L)
			sparrow.x += amount;
		if (FlxG.keys.justPressed.ENTER)
			trace(sparrow.getPosition());


		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += zoomSpeed * FlxG.camera.zoom;
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= zoomSpeed * FlxG.camera.zoom;

		super.update(elapsed);
	}
}
