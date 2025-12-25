package debug;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class AtlasScale extends FlxState
{

	var atlas:AtlasSprite;
	var camFollow:FlxObject;

	var atlasScale:Float = 0.5;

	public function new() {
		super();
	}

	override function create() {

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		atlas = new AtlasSprite(0, 0, Paths.getTextureAtlas("weekend1/picoBlazin"));
		//atlas.applyStageMatrix = true;
		atlas.origin.set(-atlas.timeline.getBoundsOrigin().x, -atlas.timeline.getBoundsOrigin().y);
		atlas.addFullAnimation("full", 24, true);
		atlas.screenCenter();
		atlas.playAnim("full");
		trace(atlas.timeline.getBoundsOrigin());
		trace("Width: " + atlas.width + ", Height: " + atlas.height);
		add(atlas);

		var pos = new FlxSprite(atlas.x, atlas.y).makeGraphic(24, 24, 0xFFFF0000);
		add(pos);

		var origin = new FlxSprite(atlas.x + atlas.origin.x, atlas.y + atlas.origin.y).makeGraphic(24, 24, 0xFF00FF00);
		add(origin);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		FlxTween.tween(this, {atlasScale: 2}, 2, {type: PINGPONG, ease: FlxEase.quadInOut});

		super.create();
	}

	final zoomSpeed:Float = 0.005;
	final moveSpeed:Float = 400;
	
	override function update(elapsed:Float) {

		atlas.scale.set(atlasScale, atlasScale);

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
