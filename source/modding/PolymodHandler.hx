package modding ;

import events.Events;
import characters.ScriptableCharacter;
import events.ScriptableEvents;
import polymod.PolymodConfig;
import flixel.FlxG;
import polymod.Polymod;
import sys.FileSystem;

class PolymodHandler
{

    inline static final API_VERSION:String = "0.0.0";

    static var loadedModMetadata:Array<ModMetadata>;

    public static function init():Void{
        buildImports();

        var modDirs:Array<String> = FileSystem.readDirectory("mods/");
        if(modDirs == null){ modDirs = []; }

        trace(PolymodConfig.modMetadataFile);

        trace("BEFORE CULLING: " + modDirs);

        //Remove all non-folder entries from loadedMods.
        for(path in modDirs){
            if(!FileSystem.isDirectory("mods/" + path)){
                modDirs.remove(path);
            }
        }

        trace("AFTER CULLING: " + modDirs);
		
		loadedModMetadata = Polymod.init({
			modRoot: "./mods/",
			dirs: modDirs,
			useScriptedClasses: true,
            frameworkParams: buildFrameworkParams(),
			apiVersionRule: API_VERSION
		});

        trace("LOADED METADATA: " + loadedModMetadata);

        scriptableClassCheck();
    }

    public static function reload():Void{
        Polymod.clearScripts();
        Polymod.registerAllScriptClasses();
        Events.initEvents();
        FlxG.resetState();
        scriptableClassCheck();
    }

    static function scriptableClassCheck():Void{
        trace("ScriptableCharacter: " + ScriptableCharacter.listScriptClasses());
        trace("ScriptableEvents: " + ScriptableEvents.listScriptClasses());
    }

    static function buildImports():Void{
        Polymod.addDefaultImport(Assets);
        Polymod.addDefaultImport(Paths);

        Polymod.addDefaultImport(PlayState);
        Polymod.addDefaultImport(Character);
        Polymod.addDefaultImport(modding.ModdingUtil);
        Polymod.addDefaultImport(Utils);
        Polymod.addDefaultImport(Conductor);

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

    static function buildFrameworkParams():polymod.Polymod.FrameworkParams{
        return {
            assetLibraryPaths: [
                "data" => "data",
                "images" => "images",
                "music" => "music",
                "songs" => "songs",
                "sounds" => "sounds",
                "videos" => "videos"
            ]
        }
    }

}