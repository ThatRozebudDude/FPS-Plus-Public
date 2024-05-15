package debug;

import flixel.FlxG;
import flxanimate.FlxAnimate;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class AtlasDebug extends FlxState
{

	var charPos:FlxSprite;
	var character:AtlasSprite;

	public function new() {
		super();
	}

	override function create() {

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		character = new AtlasSprite(0, 0, Paths.getTextureAtlas("week3/pico_atlas"));
		character.addAnimationByLabel("idle", "Idle", 24, true);
		character.addAnimationByLabel("singUP", "Sing Up", 24);
		character.addAnimationByLabel("singDOWN", "Sing Down", 24);
		character.addAnimationByLabel("singLEFT", "Sing Left", 24);
		character.addAnimationByLabel("singRIGHT", "Sing Right", 24);
		character.addAnimationByLabel("idleWeird", "Idle", 24, true, 5);
		character.antialiasing = true;
		character.screenCenter();
		character.playAnim("idle");
		add(character);

		charPos = new FlxSprite().makeGraphic(8, 8, 0xFF00AAFF);
		add(charPos);

		super.create();
	}

	override function update(elapsed:Float) {

		charPos.setPosition(character.x, character.y);

		if (FlxG.keys.anyJustPressed([ONE])) {
			character.playAnim("idle");
		}
		else if (FlxG.keys.anyJustPressed([TWO])) {
			character.playAnim("singUP");
		}
		else if (FlxG.keys.anyJustPressed([THREE])) {
			character.playAnim("singDOWN");
		}
		else if (FlxG.keys.anyJustPressed([FOUR])) {
			character.playAnim("singLEFT");
		}
		else if (FlxG.keys.anyJustPressed([FIVE])) {
			character.playAnim("singRIGHT");
		}
		else if (FlxG.keys.anyJustPressed([NINE])) {
			character.playAnim("idleWeird");
		}

		if (FlxG.keys.anyJustPressed([SPACE])) {
			character.playAnim(character.curAnim);
		}

		if (FlxG.keys.anyJustPressed([Q])) {
			character.flipX = !character.flipX;
		}
		else if (FlxG.keys.anyJustPressed([W])) {
			character.flipY = !character.flipY;
		}

		super.update(elapsed);
	}
}
