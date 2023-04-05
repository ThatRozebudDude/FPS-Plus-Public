package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var id:Int;

	public var defualtIconScale:Float = 1;
	public var iconScale:Float = 1;
	public var iconSize:Float;

	private var tween:FlxTween;

	//private static final pixelIcons:Array<String> = ["bf-pixel", "senpai", "senpai-angry", "spirit"];

	public function new(char:String = 'face', isPlayer:Bool = false, ?_id:Int = -1)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);
			
		//BF Default Icons
		animation.add('bf', [0, 1, 2], 0, false, isPlayer);
		animation.add('bf-car', [0, 1, 2], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1, 2], 0, false, isPlayer);
		animation.add('bf-pixel', [0, 1, 2], 0, false, isPlayer);
		
		//Ivan Icons
		animation.add('ivan-stressed', [3, 4, 5], 0, false, isPlayer);
		animation.add('ivan-twoface', [6, 7, 8], 0, false, isPlayer);
		animation.add('ivan-twoface-win', [8], 0, false, isPlayer);
		
		// epic cawth woman
		animation.add('cawth', [9, 10, 11], 0, false, isPlayer);
		// okay enough cawth appreciation
		
		//Dumb Ivan Icon
		animation.add('ivan-em', [12, 13, 14], 0, false, isPlayer);
		
		//The best Easter Egg in the game.
		animation.add('bf-old', [15, 16, 17], 0, false, isPlayer);
		
		//Other icons.
		animation.add('sink', [18, 18, 18], 0, false, isPlayer);
		animation.add('face', [20, 20, 20], 0, false, isPlayer);
		animation.add('emily-silly', [19], 0, false, isPlayer);
		animation.add('lordX', [21, 22, 23], 0, false, isPlayer);
		
		// GF Has no icon, so we give her the icon of No. #20
		animation.add('gf', [20, 20, 20], 0, false, isPlayer);
		animation.add('gf-car', [20, 20, 20], 0, false, isPlayer);
		animation.add('gf-pixel', [20, 20, 20], 0, false, isPlayer);
		
		
		// To do: load fail-safe.

		iconSize = width;

		id = _id;
		
		antialiasing = false;
		animation.play(char);
		scrollFactor.set();

		tween = FlxTween.tween(this, {}, 0);
	}

	override function update(elapsed:Float)
	{


		super.update(elapsed);
		setGraphicSize(Std.int(iconSize * iconScale));
		updateHitbox();

		if (sprTracker != null){
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}

	public function tweenToDefaultScale(_time:Float, _ease:Null<flixel.tweens.EaseFunction>){

		tween.cancel();
		tween = FlxTween.tween(this, {iconScale: this.defualtIconScale}, _time, {ease: _ease});

	}

}
