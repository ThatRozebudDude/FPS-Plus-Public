package metadata;

import haxe.Json;

class ImageMetadata
{
	private var jsonData:Dynamic;

	public var overrides:Array<Dynamic> = [];
	public var antialiasing:Bool = true;
	public var offset:Array<Int> = [0, 0];

	public function new(path:String)
	{
		if (Utils.exists(Paths.json(path, "images"))){
			jsonData = Json.parse(Utils.getText(Paths.json(path, "images")));

			if (jsonData.overrides != null){ overrides = jsonData.overrides; }
			if (jsonData.antialiasing != null){ antialiasing = jsonData.antialiasing; }
			if (jsonData.offset != null){ offset = jsonData.offset; }
		}
	}
}