package;

import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.Assets;
import lime.utils.Assets as LimeAssets;
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
	static var trackedTextures:Array<TexAsset> = new Array<TexAsset>();

	/**

		* Creates BitmapData for a sprite and deletes the reference stored in RAM leaving only the texture in VRAM.
		*
		* @param   path					The file path.
		* @param   texFormat			The texture format.
		* @param   optimizeForRender	Generates mipmaps.
		* @param   cachekey				Key for the Texture Buffer cache. 
		*
	 */
	public static function create(path:String, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = true, ?_cachekey:String):BitmapData{

		if (_cachekey == null){
			_cachekey = path;
		}

		for (tex in trackedTextures){
			if (tex.cacheKey == _cachekey){
				return BitmapData.fromTexture(tex.texture);
			}
		}

		var bmp = Assets.getBitmapData(path, false);
		var _texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, texFormat, optimizeForRender);
		_texture.uploadFromBitmapData(bmp);
		bmp.dispose();
		bmp.disposeImage();
		var trackedTex = new TexAsset(_texture, _cachekey);
		trackedTextures.push(trackedTex);
		return BitmapData.fromTexture(_texture);
	}

	public static function disposeAllTextures():Void{
		for (texture in trackedTextures){
			texture.texture.dispose();
			trackedTextures.remove(texture);
		}
	}

	public static function disposeTexturesByKey(key:String){
		for (i in 0...trackedTextures.length){
			if (trackedTextures[i].cacheKey.contains(key)){
				trackedTextures[i].texture.dispose();
				trackedTextures.remove(trackedTextures[i]);
			}
		}
	}

	public static function disposeAll(){
		for (i in 0...trackedTextures.length){
			trackedTextures[i].texture.dispose();
		}
		trackedTextures = new Array<TexAsset>();
	}
}

class TexAsset
{
	public var texture:Texture;
	public var cacheKey:String;

	public function new(texture:Texture, cacheKey:String){
		this.texture = texture;
		this.cacheKey = cacheKey;
	}
}
