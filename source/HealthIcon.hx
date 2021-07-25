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

	var pixelIcons:Array<String> = ["bf-pixel", "senpai", "senpai-angry", "spirit"];

	public function new(char:String = 'face', isPlayer:Bool = false, ?_id:Int = -1)
	{
		super();
		if(Config.betterIcons){
			loadGraphic('assets/images/fpsPlus/iconGrid.png', true, 150, 150);
			
			animation.add('bf', [0, 1, 30], 0, false, isPlayer);
			animation.add('bf-car', [0, 1, 30], 0, false, isPlayer);
			animation.add('bf-christmas', [0, 1, 30], 0, false, isPlayer);
			animation.add('bf-pixel', [21, 41, 40], 0, false, isPlayer);
			animation.add('spooky', [2, 3, 31], 0, false, isPlayer);
			animation.add('pico', [4, 5, 32], 0, false, isPlayer);
			animation.add('mom', [6, 7, 33], 0, false, isPlayer);
			animation.add('mom-car', [6, 7, 33], 0, false, isPlayer);
			animation.add('tankman', [8, 9, 50], 0, false, isPlayer);
			animation.add('face', [10, 11, 38], 0, false, isPlayer);
			animation.add('dad', [12, 13, 34], 0, false, isPlayer);
			animation.add('senpai', [22, 42, 43], 0, false, isPlayer);
			animation.add('senpai-angry', [44, 45, 46], 0, false, isPlayer);
			animation.add('spirit', [23, 47, 48], 0, false, isPlayer);
			animation.add('bf-old', [14, 15, 39], 0, false, isPlayer);
			animation.add('parents-christmas', [17, 18, 36], 0, false, isPlayer);
			animation.add('monster', [19, 20, 37], 0, false, isPlayer);
			animation.add('monster-christmas', [19, 20, 37], 0, false, isPlayer);
			animation.add('gf', [16, 49, (_id != -1) ? 49 : 35], 0, false, isPlayer);
			animation.add('gf-car', [16, 49, 35], 0, false, isPlayer);
			animation.add('gf-pixel', [16, 49, 35], 0, false, isPlayer);
			
		}
		else{
			loadGraphic('assets/images/iconGrid.png', true, 150, 150);
			
			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf-car', [0, 1], 0, false, isPlayer);
			animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
			animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
			animation.add('spooky', [2, 3], 0, false, isPlayer);
			animation.add('pico', [4, 5], 0, false, isPlayer);
			animation.add('mom', [6, 7], 0, false, isPlayer);
			animation.add('mom-car', [6, 7], 0, false, isPlayer);
			animation.add('tankman', [8, 9], 0, false, isPlayer);
			animation.add('face', [10, 11], 0, false, isPlayer);
			animation.add('dad', [12, 13], 0, false, isPlayer);
			animation.add('senpai', [22, 22], 0, false, isPlayer);
			animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
			animation.add('spirit', [23, 23], 0, false, isPlayer);
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
			animation.add('gf', [16], 0, false, isPlayer);
			animation.add('gf-car', [16], 0, false, isPlayer);
			animation.add('gf-pixel', [16], 0, false, isPlayer);
			animation.add('parents-christmas', [17, 18], 0, false, isPlayer);
			animation.add('monster', [19, 20], 0, false, isPlayer);
			animation.add('monster-christmas', [19, 20], 0, false, isPlayer);
		}

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
			if(Config.betterIcons){
				if(id == FreeplayState.curSelected){
					animation.curAnim.curFrame = 2;
				}
				else{
					animation.curAnim.curFrame = 0;
				}

			}
		}
	}

	public function tweenToDefaultScale(_time:Float, _ease:Null<flixel.tweens.EaseFunction>){

		tween.cancel();
		tween = FlxTween.tween(this, {iconScale: this.defualtIconScale}, _time, {ease: _ease});

	}

}
