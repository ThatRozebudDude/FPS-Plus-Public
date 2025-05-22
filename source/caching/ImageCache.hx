package caching;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import config.Config;
import openfl.utils.Assets;
import caching.GPUBitmap;

class ImageCache
{
	//The amount of state switches needed to destroy an asset.
	inline public static final DESTROY_PERIOD:Int = 2;

	public static function get(path:String):GraphicAsset{
		if (localCache.exists(path)){
			var local = localCache.get(path);
			local.remain += 1;
			return local;
		}

		return preloadCache.get(path);
	}

	public static function exists(path:String):Bool{
		if (localCache.exists(path))
			return true;
		
		return preloadCache.exists(path);
	}

	public static function clearAll():Void{
		clearPreload();
		clearLocal();
	}

	//Preload graphic stuff. ==============================================================================

	public static var preloadCache:Map<String, GraphicAsset> = new Map<String, GraphicAsset>();

	public static function preload(path:String):GraphicAsset{
		var graphic = new GraphicAsset(path, false);
		preloadCache.set(path, graphic);
		return graphic;
	}

	public static function clearPreload():Void{
		for(key => graphic in preloadCache){
			removePreload(key);
		}

		preloadCache.clear();
	}

	public static function removePreload(key):Void{
		if(preloadCache.exists(key)){
			preloadCache.get(key).destroy();
			preloadCache.remove(key);
		}
	}

	//Local image caching stuff. ==============================================================================

	public static var localCache:Map<String, GraphicAsset> = new Map<String, GraphicAsset>();

	public static var forceClearOnTransition:Bool = false;

	public static function loadLocal(path:String):GraphicAsset{
		var graphic = new GraphicAsset(path);
		localCache.set(path, graphic);
		return graphic;
	}

	public static function destroyByCount():Void{
		for(key => data in localCache){
			data.remain -= 1;
			if(data.autoDestroy && data.remain < 1){
				removeLocal(key);
			}
		}
	}

	public static function clearLocal():Void{
		for(key => graphic in localCache){
			removeLocal(key);
		}

		localCache.clear();
	}

	public static function removeLocal(key):Void{
		if(localCache.exists(key)){
			localCache.get(key).destroy();
			localCache.remove(key);
		}
	}

	public static function refreshLocal():Void{
		for(key => value in localCache){
			value.remain = DESTROY_PERIOD;
		}
	}
}

@:access(openfl.display.BitmapData)
@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
class GraphicAsset implements IFlxDestroyable
{
	public var key:String;

	public var graphic:FlxGraphic;

	public var autoDestroy:Bool = true;

	public var remain(default, set):Int = ImageCache.DESTROY_PERIOD;
	function set_remain(value:Int):Int{
		if(value > ImageCache.DESTROY_PERIOD){
			value = ImageCache.DESTROY_PERIOD;
		}
		return remain = value;
	}

	public function new(key:String, autoDestroy:Bool = true, customBitmap:Dynamic = null){
		this.key = key;
		this.autoDestroy = autoDestroy;

		var bitmap:Dynamic = customBitmap;
		if (bitmap == null){
			if(Config.useGPU){
				bitmap = GPUBitmap.create(key);
			}
			else{
				bitmap = Assets.getBitmapData(key, false);
			}
		}
		
		bitmap.lock();
		bitmap.disposeImage();
		
		var data:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
		data.persist = true;
		data.destroyOnNoUse = false;

		this.graphic = data;
	}

	public function destroy():Void{
		if(graphic.bitmap.__texture != null){
			graphic.bitmap.__texture.dispose();
		}
		graphic.bitmap.dispose();

		//graphic.dump();
		graphic.destroy();
	}
}