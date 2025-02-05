package caching;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.FlxG;

@:access(openfl.display.BitmapData)
@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
class ImageCache
{

	//GPU image caching stuff. ==============================================================================
	
	public static var keepCache:Bool = false;
	
	public static var cache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	public static function add(path:String):Void{
		var bitmap = GPUBitmap.create(path);
	
		bitmap.lock();
		bitmap.disposeImage();
		
		var data:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);
		data.persist = true;
		data.destroyOnNoUse = false;

		cache.set(path, data);
	}

	public static function get(path:String):FlxGraphic{
		return cache.get(path);
	}

	public static function exists(path:String){
		return cache.exists(path);
	}

	//Local/CPU image caching stuff. ==============================================================================

	public static var localCache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	public static function addLocal(path:String):FlxGraphic{
		if (!Utils.exists(path))
			return null;
		
		var bitmap:BitmapData = openfl.Assets.getBitmapData(path);
		if (config.Config.useGPU && bitmap.image != null)
		{
			bitmap.lock();
			if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}

		var data:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, path, false);
		data.persist = true; // Disabled because it messes up the map

		localCache.set(path, data);
		return data;
	}

	//OpenFL image cache clearing. ==============================================================================

	public static function clear(){
		for(key in FlxG.bitmap._cache.keys()){
			if(openfl.Assets.cache.hasBitmapData(key) && !exists(key)){
				openfl.Assets.cache.removeBitmapData(key);
				removeGraphic(FlxG.bitmap.get(key));
				FlxG.bitmap.removeByKey(key);
			}
		}

		//cleanup local cached assets
		for(key in localCache.keys()){
			removeGraphic(localCache.get(key));
		}

		ImageCache.localCache.clear();
	}

	static function removeGraphic(graphic:FlxGraphic){
		if(graphic.bitmap.__texture != null){
			graphic.bitmap.__texture.dispose();
		}
		graphic.bitmap.dispose();

		graphic.dump();
		graphic.destroy();
	}

}