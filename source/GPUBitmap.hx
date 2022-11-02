package;

import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.textures.Texture;
import openfl.utils.Assets;

using StringTools;

/**
	Creates textures that exist only in VRAM and not standard RAM.
	Originally written by Smokey, additional developement by Rozebud.
**/
class GPUBitmap
{
	private static var trackedTextures:Map<String, Texture> = [];

	/**
	 * Creates BitmapData for a sprite and deletes the reference stored in RAM leaving only the texture in VRAM.
	 * 
	 * @param	path				The file path.
	 * @param	format				The texture format.
	 * @param	optimizeForRender   Generates mipmaps.
	 * @param	cacheKey			Key for the Texture Buffer cache.
	 * 
	 */
	public static function create(path:String, format:Context3DTextureFormat = BGRA, optimizeForRender:Bool = false, ?cacheKey:String):BitmapData
	{
		if (cacheKey == null)
			cacheKey = path;

		if (trackedTextures.exists(cacheKey))
			return BitmapData.fromTexture(trackedTextures.get(cacheKey));

		var bitmapData:BitmapData = Assets.getBitmapData(path, false);

		var texture:Texture = FlxG.stage.context3D.createTexture(bitmapData.width, bitmapData.height, format, optimizeForRender);
		texture.uploadFromBitmapData(bitmapData);

		if (bitmapData != null)
		{
			bitmapData.dispose();
			bitmapData.disposeImage();
			bitmapData = null;
		}

		trackedTextures.set(cacheKey, texture);
		return BitmapData.fromTexture(trackedTextures.get(cacheKey));
	}

	public static function disposeAllTextures():Void
	{
		for (key => texture in trackedTextures)
		{
			texture.dispose();
			trackedTextures.remove(key);
		}
	}

	public static function disposeTexturesByKey(key:String):Void
	{
		for (key => texture in trackedTextures)
		{
			if (trackedTextures.exists(key))
			{
				texture.dispose();
				trackedTextures.remove(key);
			}
		}
	}

	public static function disposeAll():Void
	{
		for (key => texture in trackedTextures)
		{
			texture.dispose();
			trackedTextures.remove(key);
		}

		trackedTextures = [];
	}
}
