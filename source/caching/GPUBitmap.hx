package caching;

import openfl.display3D.textures.Texture;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3D;

using StringTools;

/**
	Creates textures that exist only in the GPU's VRAM and not RAM.
	Originally written by Smokey, additional developement by Rozebud.
**/

class GPUBitmap
{
	/**

		* Creates BitmapData for a sprite and deletes the reference stored in RAM leaving only the texture in VRAM.
		*
		* @param   path					The file path.
		* @param   texFormat			The texture format.
		* @param   optimizeForRender	Generates mipmaps.
		* @param   cachekey				Key for the Texture Buffer cache. 
		*
	 */
	public static function create(path:String, optimizeForRender:Bool = true):BitmapData{
		var bmp = Assets.getBitmapData(path, false);
		var texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, Context3DTextureFormat.BGRA, optimizeForRender);
		texture.uploadFromBitmapData(bmp);
		bmp.dispose();
		bmp.disposeImage();
		return BitmapData.fromTexture(texture);
	}
}