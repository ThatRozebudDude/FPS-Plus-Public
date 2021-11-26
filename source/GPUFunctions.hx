package;

import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.display3D.Context3DTextureFormat;

using StringTools;

class GPUFunctions
{
	static var trackedTextures:Array<TexAsset> = new Array<TexAsset>();

	/**

		* Made for MikuMod by Smokey, it kind of works ig?
		*
		* @param   path                The file path.
		* @param   texFormat           The texture format.
		* @param   optimizeForRender   Keep this true. Always. Dumbass.
		* @param   cachekey            Key for the Texture Buffer cache. 
		*
	 */
	public static function getBitmaponGPU(path:String, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = false, ?_cachekey:String):BitmapData
	{
		if (_cachekey == null)
			_cachekey = path;

		for (tex in trackedTextures)
			if (tex.cacheKey == _cachekey){
				trace('Texture $_cachekey already exists! Reusing existing tex');
				return BitmapData.fromTexture(tex.texture);

			}
		trace('creating new texture');
		var bmp = Assets.getBitmapData(path, false);
		var _texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, texFormat, optimizeForRender);
		_texture.uploadFromBitmapData(bmp);
		bmp.dispose();
		bmp.disposeImage();
		var trackedTex = new TexAsset(_texture, _cachekey);
		trackedTextures.push(trackedTex);
		return BitmapData.fromTexture(_texture);
	}

	public static function disposeAllTextures():Void
	{
		var counter:Int = 0;
		for (texture in trackedTextures){
			texture.texture.dispose();
			trackedTextures.remove(texture);
			counter++;
		}
		trace('Disposed $counter textures');
	}

	public static function disposeTexturesByKey(key:String)
	{
		var counter:Int = 0;
		for (i in 0...trackedTextures.length)
		{
			if (trackedTextures[i].cacheKey.contains(key))
			{
				trackedTextures[i].texture.dispose();
				trackedTextures.remove(trackedTextures[i]);
				counter++;
			}
			#if debug
			else
			trace('Not disposing ' + trackedTextures[i].cacheKey + ' using $key');
			#end
		}
		trace('Disposed $counter textures using key $key');
	}
}

class TexAsset
{
	public var texture:Texture;
	public var cacheKey:String;

	public function new(texture:Texture, cacheKey:String)
	{
		this.texture = texture;
		this.cacheKey = cacheKey;
	}
}
