package;

import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

/**
 * FlxTrail but it uses delta time.
 * @author Rozebud :]
 */
class DeltaTrail extends FlxTrail
{

	var _timer:Float = 0;
	var timerMax:Float;
	
	public function new(Target:FlxSprite, ?Graphic:FlxGraphicAsset, Length:Int = 10, Delay:Float = 3 / 60, Alpha:Float = 0.4, Diff:Float = 0.05):Void
	{
			super(Target, Graphic, Length, 0, Alpha, Diff);
			timerMax = Delay;
	}

	override public function update(elapsed:Float):Void
	{
		// Count the frames
		_timer += elapsed;

		// Update the trail in case the intervall and there actually is one.
		if (_timer >= timerMax && _trailLength >= 1)
		{
			_timer = 0;

			// Push the current position into the positons array and drop one.
			var spritePosition:FlxPoint = null;
			if (_recentPositions.length == _trailLength)
			{
				spritePosition = _recentPositions.pop();
			}
			else
			{
				spritePosition = FlxPoint.get();
			}

			spritePosition.set(target.x - target.offset.x, target.y - target.offset.y);
			_recentPositions.unshift(spritePosition);

			// Also do the same thing for the Sprites angle if rotationsEnabled
			if (rotationsEnabled)
			{
				cacheValue(_recentAngles, target.angle);
			}

			// Again the same thing for Sprites scales if scalesEnabled
			if (scalesEnabled)
			{
				var spriteScale:FlxPoint = null; // sprite.scale;
				if (_recentScales.length == _trailLength)
				{
					spriteScale = _recentScales.pop();
				}
				else
				{
					spriteScale = FlxPoint.get();
				}

				spriteScale.set(target.scale.x, target.scale.y);
				_recentScales.unshift(spriteScale);
			}

			// Again the same thing for Sprites frames if framesEnabled
			if (framesEnabled && _graphic == null)
			{
				cacheValue(_recentFrames, target.animation.frameIndex);
				cacheValue(_recentFlipX, target.flipX);
				cacheValue(_recentFlipY, target.flipY);
				cacheValue(_recentAnimations, target.animation.curAnim);
			}

			// Now we need to update the all the Trailsprites' values
			var trailSprite:FlxSprite;

			for (i in 0..._recentPositions.length)
			{
				trailSprite = members[i];
				trailSprite.x = _recentPositions[i].x;
				trailSprite.y = _recentPositions[i].y;

				// And the angle...
				if (rotationsEnabled)
				{
					trailSprite.angle = _recentAngles[i];
					trailSprite.origin.x = _spriteOrigin.x;
					trailSprite.origin.y = _spriteOrigin.y;
				}

				// the scale...
				if (scalesEnabled)
				{
					trailSprite.scale.x = _recentScales[i].x;
					trailSprite.scale.y = _recentScales[i].y;
				}

				// and frame...
				if (framesEnabled && _graphic == null)
				{
					trailSprite.animation.frameIndex = _recentFrames[i];
					trailSprite.flipX = _recentFlipX[i];
					trailSprite.flipY = _recentFlipY[i];

					trailSprite.animation.curAnim = _recentAnimations[i];
				}

				// Is the trailsprite even visible?
				trailSprite.exists = true;
			}
		}

		//super.update(elapsed);
	}
}
