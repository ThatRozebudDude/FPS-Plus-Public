package;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.FlxG;

@:access(openfl.display.BitmapData)
@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
class ImageCache
{

    //GPU image caching stuff.      ==============================================================================
    
    public static var cache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

    public static function add(path:String):Void{
        var data:FlxGraphic = FlxGraphic.fromBitmapData(GPUBitmap.create(path));
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

    //OpenFL image cache clearing.  ==============================================================================

    public static var trackedAssets:Array<String> = new Array<String>();

    public static function clear(){
        for(key in FlxG.bitmap._cache.keys()){
            if(openfl.Assets.cache.hasBitmapData(key) && !exists(key)){
                openfl.Assets.cache.removeBitmapData(key);
                removeGraphic(FlxG.bitmap.get(key));
                trackedAssets.remove(key);
            }
		}

        //cleanup leftover assets
        for(key in trackedAssets){
            if(openfl.Assets.cache.hasBitmapData(key) && !exists(key)){
                openfl.Assets.cache.removeBitmapData(key);
                FlxG.bitmap.get(key).dump();
            }
		}

        trackedAssets = [];
    }

    static function removeGraphic(graphic:FlxGraphic){
		if(graphic.bitmap.__texture != null){
			graphic.bitmap.__texture.dispose();
        }
        graphic.bitmap.dispose();

		FlxG.bitmap.remove(graphic);
        graphic.dump();
		graphic.destroy();
	}

}