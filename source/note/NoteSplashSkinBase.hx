package note;

import haxe.Json;
import flixel.math.FlxPoint;

typedef NoteSplashAnim = {
	var prefix:String;
	var framerateRange:Array<Int>;
	var offset:Array<Float>;
}

typedef NoteSplashSkinInfo = {
	var path:String;
	var anims:Array<Array<NoteSplashAnim>>;

	var randomRotation:Bool;
	var limitedRotationAngles:Bool;

	var alpha:Float;
	var antialiasing:Bool;
	var scale:Float;
}

class NoteSplashSkinBase
{
 
	public var info:NoteSplashSkinInfo = {
		path: null,
		anims: [
			[], [], [], []
		],
		randomRotation: true,
		limitedRotationAngles: false,
		alpha: 1,
		antialiasing: true,
		scale: 1
	};

	public function new(_skin:String){
		var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/noteSplash")));
		info.path = skinJson.path;
		if(skinJson.randomRotation != null){ info.randomRotation = skinJson.randomRotation; }
		if(skinJson.limitedRotationAngles != null){ info.limitedRotationAngles = skinJson.limitedRotationAngles; }
		if(skinJson.alpha != null){ info.alpha = skinJson.alpha; }
		if(skinJson.antialiasing != null){ info.antialiasing = skinJson.antialiasing; }
		if(skinJson.scale != null){ info.scale = skinJson.scale; }

		var leftAnims:Array<Dynamic> = skinJson.animations.left;
		var downAnims:Array<Dynamic> = skinJson.animations.down;
		var upAnims:Array<Dynamic> = skinJson.animations.up;
		var rightAnims:Array<Dynamic> = skinJson.animations.right;

		for(anim in leftAnims)		{ addAnim(0, anim.prefix, anim.framerateRange, anim.offset); }
		for(anim in downAnims)		{ addAnim(1, anim.prefix, anim.framerateRange, anim.offset); }
		for(anim in upAnims)		{ addAnim(2, anim.prefix, anim.framerateRange, anim.offset); }
		for(anim in rightAnims)		{ addAnim(3, anim.prefix, anim.framerateRange, anim.offset); }
	}

	function addAnim(_direction:Int, _name:String, ?_framerateRange:Array<Int>, ?_offset:Array<Float>) {
		if(_offset == null){ _offset = [0, 0]; }
		if(_framerateRange == null){ _framerateRange = [24, 24]; }
		if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
		info.anims[_direction].push({
			prefix: _name,
			framerateRange: _framerateRange,
			offset: _offset
		});
	}

	/**
	 * Generates the x and y offsets for an animation.
	 *
	 * @param   _x  The x offset of the animation.
	 * @param   _y  The y offset of the animation.
	 */
	inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
		return [_x, _y];
	}

	public function toString():String{ return "NoteSplashSkinBase"; }
}