package;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths
{
	static final audioExtension:String = "ogg";

	inline static public function file(key:String, location:String, extension:String):String
		return 'assets/$location/$key.$extension';

	inline static public function font(key:String, ?extension:String = "ttf"):String
		return file(key, "fonts", extension);

	inline static public function xml(key:String, ?location:String = "images"):String
		return file(key, location, "xml");

	inline static public function text(key:String, ?location:String = "data"):String
		return file(key, location, "txt");

	inline static public function json(key:String, ?location:String = "data"):String
		return file(key, location, "json");

	inline static public function image(key:String, forceLoadFromDisk:Bool = false):Dynamic
	{
		var data:String = file(key, "images", "png");

		if (ImageCache.exists(data) && !forceLoadFromDisk)
			return ImageCache.get(data);
		else
			return data;
	}

	inline static public function music(key:String):String
		return file(key, "music", audioExtension);

	inline static public function voices(key:String):String
		return file('$key/Voices', "songs", audioExtension);

	inline static public function inst(key:String):String
		return file('$key/Inst', "songs", audioExtension);

	inline static public function sound(key:String):String
		return file(key, "sounds", audioExtension);

	inline static public function video(key:String):String
		return file(key, "videos", "mp4");

	inline static public function getSparrowAtlas(key:String)
		return FlxAtlasFrames.fromSparrow(image(key), xml(key));

	inline static public function getPackerAtlas(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), text(key, "images"));
}
