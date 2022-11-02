package;

import flixel.graphics.FlxGraphic;

class ImageCache
{
	public static var cache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	public static function add(path:String):Void
	{
		if (!cache.exists(path))
		{
			var data:FlxGraphic = FlxGraphic.fromBitmapData(GPUBitmap.create(path));
			data.persist = true;
			data.destroyOnNoUse = false;
			cache.set(path, data);
		}
	}

	public static function get(path:String):FlxGraphic
		return cache.get(path);

	public static function exists(path:String):Bool
		return cache.exists(path);
}
