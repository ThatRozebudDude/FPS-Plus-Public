package debug;

import flixel.FlxObject;
import flixel.FlxG;
import flxanimate.FlxAnimate;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class AtlasScrub extends FlxState
{

	var atlas:AtlasSprite;
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

		atlas = new AtlasSprite(0, 0, Paths.getTextureAtlas("menu/characterSelect/characters/locked/CharacterSelect_Locked"));
		atlas.addFullAnimation("full", 0, false);
		atlas.antialiasing = true;
		atlas.screenCenter();
		atlas.playAnim("full");
		add(atlas);

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
			atlas.playAnim("full", true, false, curFrame);
			trace(curFrame);
		}

		if (FlxG.keys.justPressed.RIGHT){
			curFrame += amount;
			if(curFrame > atlas.anim.length - 1) {curFrame = atlas.anim.length - 1;}
			atlas.playAnim("full", true, false, curFrame);
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
		

		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += zoomSpeed * FlxG.camera.zoom;
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= zoomSpeed * FlxG.camera.zoom;

		super.update(elapsed);
	}
}
