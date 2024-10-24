package;

import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
import polymod.format.ParseRules;
import polymod.Polymod;
import sys.FileSystem;

import flixel.FlxG;

class ModHandler
{
	private static final MOD_DIR:String = 'mods';

	static final API_VERSION = "0.1.0";

	private static final extensions:Map<String, PolymodAssetType> = [
		'mp3' => AUDIO_GENERIC,
		'ogg' => AUDIO_GENERIC,
		'png' => IMAGE,
		'xml' => TEXT,
		'txt' => TEXT,
		'hx' => TEXT,
		'json' => TEXT,
		'ttf' => FONT,
		'otf' => FONT,
		'mp4' => VIDEO
	];

	public static var modList = ["fuck"]; // enabled mods

	public static function initialize():Void
	{
		if (!Utils.exists(MOD_DIR))
		{
			trace('Mods Folder Missing. Creating $MOD_DIR folder...');
			FileSystem.createDirectory(MOD_DIR);
			return;
		}
		trace("Initializing ModHandler...");
		initPolymod();
		Polymod.loadOnlyMods(modList);
	}

	public static function initPolymod()
	{
		Polymod.init({
			modRoot: MOD_DIR,
			dirs: [],
			
			framework: Framework.CUSTOM,
			
			errorCallback: onPolymodError,

			frameworkParams: buildFrameworkParams(),

			customBackend: ModBackend,

			ignoredFiles: Polymod.getDefaultIgnoreList(),

			// Parsing rules for various data formats.
			parseRules: getParseRules()
		});
	}

	public static function getParseRules():ParseRules
	{
		var output:ParseRules = ParseRules.getDefault();
		output.addType("txt", TextFileFormat.LINES);
		return output != null ? output : null;
	}

	static inline function buildFrameworkParams():polymod.FrameworkParams
	{
		return {
			assetLibraryPaths: [
				"data" => "./data",
				"songs" => "./songs",
				"sounds" => "./sounds",
				"music" => "./music",
				"images" => "./images",
				"videos" => "./videos"
			]
		}
	}

	static function onPolymodError(error:PolymodError):Void
	{
		// Perform an action based on the error code.
		switch (error.code)
		{
			case MISSING_ICON:
			default:
				// Log the message based on its severity.
				switch (error.severity)
				{
					case NOTICE:
						trace(error.message, null);
					case WARNING:
						trace(error.message, null);
					case ERROR:
						trace(error.message, null);
				}
		}
	}
}

class ModBackend extends OpenFLBackend
{
	//idk but it here uh what
	public function new()
		super();

	public override function clearCache()
		super.clearCache();

	public override function exists(id:String):Bool
		return super.exists(id);

	public override function getBytes(id:String):lime.utils.Bytes
		return super.getBytes(id);

	public override function getText(id:String):String
		return super.getText(id);

	public override function list(type:PolymodAssetType = null):Array<String>
		return super.list(type);
}