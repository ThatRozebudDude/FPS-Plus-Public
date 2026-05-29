package editors.ui;

import flixel.FlxG;
import flixel.FlxSprite;

class Cursor extends FlxSprite
{

	public function new(){
		super(0, 0);

		loadGraphic(Paths.image("fpsPlus/editors/shared/cursor"), true, 64, 64);
		animation.add("idle", [0], 0, false);
		idle();
		scale.set(0.5, 0.5);
		updateHitbox();
		scrollFactor.set(0, 0);
	}

	override function update(elapsed:Float):Void{
		x = FlxG.mouse.viewX;
		y = FlxG.mouse.viewY;
		super.update(elapsed);
	}

	public inline function idle():Void{ 
		animation.play("idle");
	}
}