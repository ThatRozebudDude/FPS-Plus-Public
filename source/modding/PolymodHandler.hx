package modding ;

import flixel.FlxG;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.Polymod;
import sys.FileSystem;

class PolymodHandler
{

	static final API_VERSION = "0.1.0";
    public static var modList = []; // Mods current enabled

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

	public static function init():Void
	{
        buildImports();

		if (!Utils.exists("mods"))
            return;

        //Make Better Mod System Later
        var modDirs:Array<String> = FileSystem.readDirectory("mods");
        for(path in modDirs){
            if(FileSystem.isDirectory("mods/" + path)){
                modList.push(path);
            }
        }
        trace('MOD LIST: ' + modList);

        Polymod.init({
			modRoot: "mods",
			dirs: [],
            useScriptedClasses: true,
			framework: Framework.OPENFL,
			errorCallback: onPolymodError,
			frameworkParams: {
                assetLibraryPaths: [
                    "data" => "./data",
                    "songs" => "./songs",
                    "sounds" => "./sounds",
                    "music" => "./music",
                    "images" => "./images",
                    "videos" => "./videos"
                ]
            },
			ignoredFiles: Polymod.getDefaultIgnoreList()
		});

		Polymod.loadOnlyMods(modList);

        //Check scriptable class
        trace("ScriptableCharacter: " + characters.ScriptableCharacter.listScriptClasses());
	}

    public static function reload():Void{
        Polymod.clearScripts();
		Polymod.registerAllScriptClasses();
		FlxG.resetState();
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
                        //does nothing
					case WARNING:
						trace(error.message, null);
					case ERROR:
						trace(error.message, null);
				}
		}
	}

    static function buildImports():Void{
        Polymod.addDefaultImport(Assets);
        Polymod.addDefaultImport(Paths);

        Polymod.addImportAlias('lime.utils.Assets', Assets);
        Polymod.addImportAlias('openfl.utils.Assets', Assets);

        Polymod.addImportAlias('flixel.math.FlxPoint', flixel.math.FlxPoint.FlxBasePoint);

        // `Sys`
        // Sys.command() can run malicious processes
        Polymod.blacklistImport('Sys');

        // `Reflect`
        // Reflect.callMethod() can access blacklisted packages
        Polymod.blacklistImport('Reflect');

        // `Type`
        // Type.createInstance(Type.resolveClass()) can access blacklisted packages
        Polymod.blacklistImport('Type');

        // `cpp.Lib`
        // Lib.load() can load malicious DLLs
        Polymod.blacklistImport('cpp.Lib');

        // `Unserializer`
        // Unserializer.DEFAULT_RESOLVER.resolveClass() can access blacklisted packages
        Polymod.blacklistImport('Unserializer');

        // `lime.system.CFFI`
        // Can load and execute compiled binaries.
        Polymod.blacklistImport('lime.system.CFFI');

        // `lime.system.JNI`
        // Can load and execute compiled binaries.
        Polymod.blacklistImport('lime.system.JNI');

        // `lime.system.System`
        // System.load() can load malicious DLLs
        Polymod.blacklistImport('lime.system.System');

        // `lime.utils.Assets`
        // Literally just has a private `resolveClass` function for some reason?
        Polymod.blacklistImport('lime.utils.Assets');
        Polymod.blacklistImport('openfl.utils.Assets');
        Polymod.blacklistImport('openfl.Lib');
        Polymod.blacklistImport('openfl.system.ApplicationDomain');

        // `openfl.desktop.NativeProcess`
        // Can load native processes on the host operating system.
        Polymod.blacklistImport('openfl.desktop.NativeProcess');
    }

	//FileSystem readDirectory but with mods folder
	public static inline function readDirectory(path:String) {
		var files = FileSystem.readDirectory(path);
		for (mod in modList) {
			if (FileSystem.exists('mods/$mod/' + path.split("assets/")[1])) {
				var modfile = FileSystem.readDirectory('mods/$mod/' + path.split("assets/")[1]);
				for (file in modfile) {
					if (!files.contains(file))
						files.push(file);
				}
			}
		}
		return files;
	}
}