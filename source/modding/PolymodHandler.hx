package modding;

import openfl.Assets;
import haxe.Json;
import polymod.PolymodConfig;
import flixel.FlxG;
import polymod.Polymod;

using StringTools;

class PolymodHandler
{

    public static final API_VERSION:Array<Int> = [1, 0, 0];
    public static final API_VERSION_STRING:String = API_VERSION[0]+"."+API_VERSION[1]+"."+API_VERSION[2];

    //public static final API_VERSION_RULE:String = ">=1.0.0 <1.1.0";
    
    public static var allModDirs:Array<String>;
    public static var disabledModDirs:Array<String>;
    public static var malformedMods:Map<String, ModError>;
    
    public static var loadedModDirs:Array<String>;
    public static var loadedModMetadata:Array<ModMetadata>;

	public static function init():Void{
        buildImports();

        reInit();

        scriptableClassCheck();
    }

    public static function reload(?restartState:Bool = true):Void{
        reloadScripts();
        scriptableClassCheck();
        if(restartState){ FlxG.resetState(); }
    }

    public static function reInit():Void{
        buildModDirectories();

        loadedModMetadata = Polymod.init({
			modRoot: "./mods/",
			dirs: loadedModDirs,
			useScriptedClasses: true,
            errorCallback: onPolymodError,
            frameworkParams: buildFrameworkParams()
		});

        trace("Mod Meta List: " + loadedModMetadata);

        Polymod.clearCache();

        reloadScripts();
    }

    public static function buildModDirectories():Void{
        //Get disabled list. Create file if not already created.
        var disabled:String;
        if(sys.FileSystem.exists("mods/disabled")){
            disabled = sys.io.File.getContent("mods/disabled");
        }
        else{
            disabled = "";
            sys.io.File.saveContent("mods/disabled", "");
            trace("\"disable\" not found, creating");
        }

        disabledModDirs = disabled.split("\n");
        for(dir in disabledModDirs){ dir = dir.trim(); }
        while(disabledModDirs.contains("")){
            disabledModDirs.remove("");
        }

        trace("Disabled Mod List: " + disabledModDirs);
        
        //Get all directories in the mods folder.
        allModDirs = sys.FileSystem.readDirectory("mods/");
        if(allModDirs == null){ allModDirs = []; }

        trace("Mod Directories: " + allModDirs);

        //Remove all non-folder entries.
        allModDirs = allModDirs.filter(function(path){ return sys.FileSystem.isDirectory("mods/" + path); });

        trace("Culled Mod Directories: " + allModDirs);

        var order:String;
        if(sys.FileSystem.exists("mods/order")){
            order = sys.io.File.getContent("mods/order");
        }
        else{
            order = "";
            sys.io.File.saveContent("mods/order", "");
            trace("\"order\" not found, creating");
        }

        var modOrder = order.split("\n");
        var modOrderFilter:Array<String> = [];
        var dupelicateList:Array<String> = [];
        for(dir in modOrder){
            dir = dir.trim();
            if(!allModDirs.contains(dir) || dupelicateList.contains(dir)){
                modOrderFilter.push(dir);
                continue;
            }
            dupelicateList.push(dir);
        }

        modOrder = modOrder.filter(function(dir){
            var r = true;
            if(modOrderFilter.contains(dir)){
                r = false;
                modOrderFilter.remove(dir);
            }
            return r;
        });

        for(dir in allModDirs){
            if(!modOrder.contains(dir)){
                modOrder.push(dir);
            }
        }

        allModDirs = modOrder;
        while(allModDirs.contains("")){
            allModDirs.remove("");
        }

        var write:String = "";
        for(dir in allModDirs){ write += dir+"\n"; }
        sys.io.File.saveContent("mods/order", write);

        loadedModDirs = [];

        //Remove disabled mods from this list.
        for(path in allModDirs){
            if(!disabledModDirs.contains(path)){
                loadedModDirs.push(path);
            }
        }

        trace("Checking Mod Directories: " + loadedModDirs);

        //Do version handling
        //For some reason, the version rule didnt't actually seem to be preventing mods from loading(?) so I'll manually check to cull the mods from the list.
        malformedMods = new Map<String, ModError>();

        for(mod in loadedModDirs){
            if(!sys.FileSystem.exists("mods/" + mod + "/meta.json")){
                malformedMods.set(mod, MISSING_META_JSON);
                trace("COULD NOT LOAD MOD \"" + mod + "\": MISSING_META_JSON");
                continue;
            }

            var json = Json.parse(sys.io.File.getContent("mods/" + mod + "/meta.json"));
            if(json.api_version == null || json.mod_version == null){
                malformedMods.set(mod, MISSING_META_FIELDS);
                trace("COULD NOT LOAD MOD \"" + mod + "\": MISSING_META_FIELDS");
                continue;
            }

            var modAPIVersion:Array<Int> = [Std.parseInt(json.api_version.split(".")[0]), Std.parseInt(json.api_version.split(".")[1]), Std.parseInt(json.api_version.split(".")[2])];
            if(modAPIVersion[0] < API_VERSION[0]){
                malformedMods.set(mod, API_VERSION_TOO_OLD);
                trace("COULD NOT LOAD MOD \"" + mod + "\": API_VERSION_TOO_OLD");
                continue;
            }
            else if(modAPIVersion[0] > API_VERSION[0]){
                malformedMods.set(mod, API_VERSION_TOO_NEW);
                trace("COULD NOT LOAD MOD \"" + mod + "\": API_VERSION_TOO_NEW");
                continue;
            }

            if(modAPIVersion[1] > API_VERSION[1]){
                malformedMods.set(mod, API_VERSION_TOO_NEW);
                trace("COULD NOT LOAD MOD \"" + mod + "\": API_VERSION_TOO_NEW");
                continue;
            }
        }

        loadedModDirs = loadedModDirs.filter(function(mod){ return !malformedMods.exists(mod); });

        trace("Final Mod Directories: " + loadedModDirs);
    }

    static function reloadScripts():Void{
        Polymod.clearScripts();
        Polymod.registerAllScriptClasses();
        note.NoteType.initTypes();
        events.Events.initEvents();
    }

    static function scriptableClassCheck():Void{
        trace("<== CLASSES ==>");
        trace("ScriptableCharacter: " + characters.ScriptableCharacter.listScriptClasses());
        trace("ScriptableEvents: " + events.ScriptableEvents.listScriptClasses());
        trace("ScriptableNoteTypes: " + note.ScriptableNoteType.listScriptClasses());
        trace("ScriptableNoteSkin: " + note.ScriptableNoteSkin.listScriptClasses());
        trace("ScriptableCutscene: " + cutscenes.ScriptableCutscene.listScriptClasses());
        trace("ScriptableStage: " + stages.ScriptableStage.listScriptClasses());
        trace("ScriptableScript: " + scripts.ScriptableScript.listScriptClasses());
        trace("ScriptableCharacterSelectCharacter: " + characterSelect.ScriptableCharacterSelectCharacter.listScriptClasses());
        trace("ScriptableDJCharacter: " + freeplay.ScriptableDJCharacter.listScriptClasses());
        trace("ScriptableResultsCharacter: " + results.ScriptableResultsCharacter.listScriptClasses());

        trace("<== CUSTOM OBJECTS ==>");
        trace("ScriptableObject: " + objects.ScriptableObject.listScriptClasses());
        trace("ScriptableSprite: " + objects.ScriptableSprite.listScriptClasses());
        trace("ScriptableAtlasSprite: " + objects.ScriptableAtlasSprite.listScriptClasses());
        trace("ScriptableSpriteGroup: " + objects.ScriptableSpriteGroup.listScriptClasses());
    }

	static function onPolymodError(error:PolymodError):Void{
		// Perform an action based on the error code.
		switch (error.code){
			case MISSING_ICON:
                
			default:
				// Log the message based on its severity.
				switch (error.severity){
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

        //Default imports
        Polymod.addDefaultImport(Assets);
        Polymod.addDefaultImport(Paths);
        Polymod.addDefaultImport(flixel.group.FlxGroup);
        Polymod.addDefaultImport(flixel.group.FlxSpriteGroup);

        Polymod.addDefaultImport(PlayState);
        Polymod.addDefaultImport(GameOverSubstate);
        Polymod.addDefaultImport(PauseSubState);

        Polymod.addDefaultImport(Character);
        Polymod.addDefaultImport(Conductor);
        Polymod.addDefaultImport(AtlasSprite);
        Polymod.addDefaultImport(Binds);
        Polymod.addDefaultImport(VideoHandler);
        Polymod.addDefaultImport(shaders.RuntimeShader);
        Polymod.addDefaultImport(debug.ChartingState);

        Polymod.addDefaultImport(Utils);
        Polymod.addDefaultImport(modding.ScriptingUtil);

        //Import scriptable classes so they can be made without importing
        Polymod.addDefaultImport(characters.CharacterInfoBase);
        Polymod.addDefaultImport(note.NoteType);
        Polymod.addDefaultImport(events.Events);
        Polymod.addDefaultImport(stages.BaseStage);

        Polymod.addDefaultImport(cutscenes.ScriptedCutscene);
        Polymod.addDefaultImport(scripts.Script);
        Polymod.addDefaultImport(freeplay.DJCharacter);
        Polymod.addDefaultImport(characterSelect.CharacterSelectCharacter);
        Polymod.addDefaultImport(note.NoteSkinBase);
        Polymod.addDefaultImport(results.ResultsCharacter);

        Polymod.addDefaultImport(objects.ScriptableObject.ScriptedObject);
        Polymod.addDefaultImport(objects.ScriptableSprite.ScriptedSprite);
        Polymod.addDefaultImport(objects.ScriptableAtlasSprite.ScriptedAtlasSprite);
        Polymod.addDefaultImport(objects.ScriptableSpriteGroup.ScriptedSpriteGroup);
        
        //Alias
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

enum ModError{
    MISSING_META_JSON;
    MISSING_META_FIELDS;
    API_VERSION_TOO_OLD;
    API_VERSION_TOO_NEW;
}