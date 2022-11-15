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

	private static final pixelIcons:Array<String> = ["bf-pixel", "senpai", "senpai-angry", "spirit"];

	public function new(char:String = 'face', isPlayer:Bool = false, ?_id:Int = -1)
	{
		super();
		loadGraphic(Paths.image('icons/' + char), true, 150, 150);
			
		animation.add(char, [0, 1, 2], 0, false, isPlayer);

		iconSize = width;

		id = _id;
		
		antialiasing = !pixelIcons.contains(char);
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
