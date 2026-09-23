package;

import caching.*;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Paths
{

	public static final AUDIO_EXTENSION:String = "ogg";

	inline static public function file(key:String, location:String, extension:String):String{
		if(location.endsWith("/")){ location = location.substring(0, location.length-1); } //Prevent people from accidentally using 2 slashes.
		var data:String = 'assets/$location/$key.$extension';
		return data;

	}

	inline static public function image(key:String, forcePath:Bool = false):Dynamic{
		var data:String = file(key, "images", "png");
		if(forcePath || !Utils.exists(data)) { return data; }
		return getGraphicFromCache(data);
	}

	inline static private function getGraphicFromCache(data:String):FlxGraphic{
		if(ImageCache.exists(data)){
			return ImageCache.get(data).graphic;
		}
		return ImageCache.loadLocal(data).graphic;
	}

	inline static public function xml(key:String, ?location:String = "images"):String{
		return file(key, location, "xml");
	}

	inline static public function text(key:String, ?location:String = "data"):String{
		return file(key, location, "txt");
	}

	inline static public function json(key:String, ?location:String = "data/songs"):String{
		return file(key, location, "json");
	}

	inline static public function sound(key:String):String{
		var data:String = file(key, "sounds", AUDIO_EXTENSION);
		if(!AudioCache.trackedSounds.contains(data)){
			AudioCache.trackedSounds.push(data);
		}
		return data;
	}

	inline static public function music(key:String):String{
		var data:String = file(key, "music", AUDIO_EXTENSION);
		if(!AudioCache.trackedMusic.contains(data)){
			AudioCache.trackedMusic.push(data);
		}
		return data;
	}

	inline static public function voices(key:String, type:String = ""):String{
		if(type.length > 0){ type = "-" + type; }
		return 'assets/songs/$key/Voices$type.$AUDIO_EXTENSION';
	}

	inline static public function inst(key:String):String{
		return 'assets/songs/$key/Inst.$AUDIO_EXTENSION';
	}

	inline static public function getSparrowAtlas(key:String, ?xmlFile:String):FlxAtlasFrames{
		if(xmlFile == null){ xmlFile = key; }
		return FlxAtlasFrames.fromSparrow(image(key), xml(xmlFile));
	}

	inline static public function getPackerAtlas(key:String, ?textFile:String):FlxAtlasFrames{
		if(textFile == null){ textFile = key; }
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), text(textFile, "images"));
	}

	inline static public function getTextureAtlas(key:String):String{
		return 'assets/images/$key';
	}

	inline static public function getMultipleSparrowAtlas(keys:Array<String>):FlxAtlasFrames{
		var parentFrames:FlxAtlasFrames = getSparrowAtlas(keys[0]);
		if(keys.length > 1){
			var original:FlxAtlasFrames = parentFrames;
			parentFrames = new FlxAtlasFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);
			for (i in 1...keys.length){
				var extraFrames:FlxAtlasFrames = getSparrowAtlas(keys[i]);
				if(extraFrames != null){
					parentFrames.addAtlas(extraFrames, true);
				}
			}
		}
		return parentFrames;
	}

	inline static public function video(key:String, ?extension:String= "mp4"):String{
		return file(key, "videos", extension);
	}
	
	inline static public function font(key:String, ?extension:String = "ttf"):String{
		return file(key, "fonts", extension);
	}

	inline static public function shader(key:String, ?extension:String = "frag"):String{
		return file(key, "data/shaders", extension);
	}

}
