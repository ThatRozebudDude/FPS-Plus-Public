package graphics;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

/*
Base one PerspectiveSprite from base game, thank you fabs. (But also I helped figure stuff out for the original so thank you me.)
https://github.com/FunkinCrew/funkin.assets/blob/develop/preload/scripts/stages/props/PerspectiveSprite.hxc
*/

/**
 * Uses a FlxSkewedSprite to skew the top and bottom of an image between two objects.
 * Supports having differing scrollFactors on the top and bottom points to create an almost 3D effect like old
 * fighting games..
 * (ignore the fact that this isnt true perspective :sob: just a very cheap imitiation)
 */
class PerspectiveSkewSprite extends FlxTypedSpriteGroup<FlxSprite>
{
	
	public var sprite:FlxSkewedSprite;

	public var bottomObj:FlxObject;
	public var topObj:FlxObject;

	public var referenceCamera:FlxCamera = null;

	var bottomVis:FlxSprite;
	var topVis:FlxSprite;

	var debugDraw:Bool = false;

	public function new(_debugDraw:Bool = false):Void{
		debugDraw = _debugDraw;
		super(0, 0);

		sprite = new FlxSkewedSprite();
		sprite.matrixExposed = true;
		sprite.antialiasing = true;
		add(sprite);

		bottomObj = new FlxObject();
		topObj = new FlxObject();

		if(debugDraw){
			bottomVis = new FlxSprite().makeGraphic(10, 10, 0xFF00B3FF);
			bottomVis.offset.x = 5;
			bottomVis.offset.y = 5;
			bottomVis.alpha = 0.7;
			add(bottomVis);

			topVis = new FlxSprite().makeGraphic(10, 10, 0xFFF700FF);
			topVis.offset.x = 5;
			topVis.offset.y = 5;
			topVis.alpha = 0.7;
			add(topVis);
		}
	}

	/**
	 * Set the positions of both objects.
	 */
	public function setPositions(bottomX:Float, bottomY:Float, topX:Float, topY:Float):Void{
		bottomObj.setPosition(bottomX, bottomY);
		topObj.setPosition(topX, topY);
	}

	/**
	 * Set the scrollFactors of both objects.
	 */
	public function setScrollFactors(bottomX:Float, bottomY:Float, topX:Float, topY:Float):Void{
		bottomObj.scrollFactor.set(bottomX, bottomY);
		topObj.scrollFactor.set(topX, topY);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		if(cameras.length <= 0){ return; }
		updateSkew();
	}

	public function updateSkew():Void{
		// correct for scrollfactors..
		var correctedBottom:FlxPoint = FlxPoint.get(
			bottomObj.x + ((referenceCamera == null ? cameras[0] : referenceCamera).scroll.x * (sprite.scrollFactor.x - bottomObj.scrollFactor.x)), 
			bottomObj.y + ((referenceCamera == null ? cameras[0] : referenceCamera).scroll.y * (sprite.scrollFactor.y - bottomObj.scrollFactor.y))
		);
		var correctedTop:FlxPoint = FlxPoint.get(
			topObj.x + ((referenceCamera == null ? cameras[0] : referenceCamera).scroll.x * (sprite.scrollFactor.x - topObj.scrollFactor.x)), 
			topObj.y + ((referenceCamera == null ? cameras[0] : referenceCamera).scroll.y * (sprite.scrollFactor.y - topObj.scrollFactor.y))
		);

		if(debugDraw){
			bottomVis.setPosition(correctedBottom.x, correctedBottom.y);
			topVis.setPosition(correctedTop.x, correctedTop.y);
		}

		var distX = correctedTop.x - correctedBottom.x;
		var distY = correctedTop.y - (correctedBottom.y - sprite.height);

		// (is there a much more elegant/better way to do this?? idk) this is pure eyeballing
		sprite.transformMatrix.a = 1;
		sprite.transformMatrix.b = 0;
		sprite.transformMatrix.c = -(distX / sprite.height);
		sprite.transformMatrix.d = 1 - (distY / sprite.height);
		sprite.transformMatrix.tx = distX / 2;
		sprite.transformMatrix.ty = distY / 2;

		// move sprite to be aligned to the bottom object
		sprite.x = correctedBottom.x - sprite.width/2;
		sprite.y = correctedBottom.y - sprite.height;

		correctedBottom.put();
		correctedTop.put();
	}

	override public function isOnScreen(?camera:FlxCamera):Bool{
		// Turns out skewing an image like crazy fucks up its rendering... oops!
		return true;
	}

	/**
	 * Returns the scroll factor based on a Y value across the object. Useful for positioning objects across the sprite.
	 */
	public function getScrollFactorFromPosition(referenceY:Float):FlxPoint{
		if(referenceY <= topObj.y){
			return FlxPoint.get(topObj.scrollFactor.x, topObj.scrollFactor.y);
		}
		else if(referenceY >= bottomObj.y){
			return FlxPoint.get(bottomObj.scrollFactor.x, bottomObj.scrollFactor.y);
		}
		final lerp:Float = FlxMath.remapToRange(referenceY, topObj.y, bottomObj.y, 0, 1);
		return FlxPoint.get(FlxMath.lerp(topObj.scrollFactor.x, bottomObj.scrollFactor.x, lerp), FlxMath.lerp(topObj.scrollFactor.y, bottomObj.scrollFactor.y, lerp));
	}

}