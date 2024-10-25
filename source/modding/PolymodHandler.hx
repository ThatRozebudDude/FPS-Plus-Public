package modding;

import flixel.FlxG;
import polymod.Polymod;
import sys.FileSystem;

class PolymodHandler
{

	static final API_VERSION = "0.0.0";
    public static var modList = []; // Mods currently enabled

	public static function init():Void
	{
        buildImports();

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
            }
		});

		Polymod.loadOnlyMods(modList);
        //Check scriptable class
        trace("Scriptable Stage: " + stages.ScriptableStages.listScriptClasses());
	}

    public static function reload():Void{
        Polymod.clearScripts();
        Polymod.registerAllScriptClasses();
        notetypes.NoteType.initTypes();
        events.Events.initEvents();
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
                        //does nothing lol
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

        Polymod.addDefaultImport(PlayState);
        Polymod.addDefaultImport(Character);
        Polymod.addDefaultImport(modding.ModdingUtil);
        Polymod.addDefaultImport(Utils);
        Polymod.addDefaultImport(Conductor);

        //Import customizable class so now we can make custom class without importing
        Polymod.addDefaultImport(characters.CharacterInfoBase);
        Polymod.addDefaultImport(notetypes.NoteType);
        Polymod.addDefaultImport(events.Events);
        Polymod.addDefaultImport(stages.Stages);
        
        Polymod.addImportAlias("lime.utils.Assets", Assets);
        Polymod.addImportAlias("openfl.utils.Assets", Assets);

        Polymod.addImportAlias("flixel.math.FlxPoint", flixel.math.FlxPoint.FlxBasePoint);

        // `Sys`
        // Sys.command() can run malicious processes
        Polymod.blacklistImport("Sys");

        // `Reflect`
        // Reflect.callMethod() can access blacklisted packages
        Polymod.blacklistImport("Reflect");

        // `Type`
        // Type.createInstance(Type.resolveClass()) can access blacklisted packages
        Polymod.blacklistImport("Type");

        // `cpp.Lib`
        // Lib.load() can load malicious DLLs
        Polymod.blacklistImport("cpp.Lib");

        // `Unserializer`
        // Unserializer.DEFAULT_RESOLVER.resolveClass() can access blacklisted packages
        Polymod.blacklistImport("Unserializer");

        // `lime.system.CFFI`
        // Can load and execute compiled binaries.
        Polymod.blacklistImport("lime.system.CFFI");

        // `lime.system.JNI`
        // Can load and execute compiled binaries.
        Polymod.blacklistImport("lime.system.JNI");

        // `lime.system.System`
        // System.load() can load malicious DLLs
        Polymod.blacklistImport("lime.system.System");

        // `lime.utils.Assets`
        // Literally just has a private `resolveClass` function for some reason?
        Polymod.blacklistImport("lime.utils.Assets");
        Polymod.blacklistImport("openfl.utils.Assets");
        Polymod.blacklistImport("openfl.Lib");
        Polymod.blacklistImport("openfl.system.ApplicationDomain");

        // `openfl.desktop.NativeProcess`
        // Can load native processes on the host operating system.
        Polymod.blacklistImport("openfl.desktop.NativeProcess");
    }
}