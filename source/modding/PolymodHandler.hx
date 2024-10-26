package modding;

import polymod.PolymodConfig;
import flixel.FlxG;
import polymod.Polymod;
import sys.FileSystem;

class PolymodHandler
{

    inline static final API_VERSION:String = "0.0.0";

    public static var modDirs:Array<String>;
    public static var loadedModMetadata:Array<ModMetadata>;

	public static function init():Void{
        buildImports();

        modDirs = FileSystem.readDirectory("mods/");
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
			modRoot: "mods",
			dirs: modDirs,
			useScriptedClasses: true,
            errorCallback: onPolymodError,
            frameworkParams: buildFrameworkParams(),
			apiVersionRule: API_VERSION
		});

        trace("LOADED METADATA: " + loadedModMetadata);

        scriptableClassCheck();
    }

    public static function reload():Void{
        Polymod.clearScripts();
        Polymod.registerAllScriptClasses();
        note.NoteType.initTypes();
        events.Events.initEvents();
        scriptableClassCheck();
        FlxG.resetState();
    }

    static function scriptableClassCheck():Void{
        trace("<===== CLASSES =====>");
        
        trace("ScriptableCharacter: " + data.CharacterInfo.ScriptableCharacter.listScriptClasses());
        trace("ScriptableEvents: " + events.ScriptableEvents.listScriptClasses());
        trace("ScriptableNoteTypes: " + note.ScriptableNoteType.listScriptClasses());
        trace("ScriptableCutscene: " + cutscenes.ScriptableCutscene.listScriptClasses());
        trace("ScriptableStage: " + stages.ScriptableStage.listScriptClasses());

        trace("<===== UI SKIN STUFF =====>");

        trace("ScriptableNoteSkin: " + note.ScriptableNoteSkin.listScriptClasses());
        trace("ScriptableNoteSplashSkin: " + note.ScriptableNoteSplashSkin.listScriptClasses());
        trace("ScriptableNoteHoldCoverSkin: " + note.ScriptableNoteHoldCoverSkin.listScriptClasses());
        trace("ScriptableComboPopupSkin: " + ui.ScriptableComboPopupSkin.listScriptClasses());
        trace("ScriptableCountdownSkin: " + ui.ScriptableCountdownSkin.listScriptClasses());
        trace("ScriptableHudNoteSkin: " + ui.ScriptableHudNoteSkin.listScriptClasses());
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
        Polymod.addDefaultImport(Assets);
        Polymod.addDefaultImport(Paths);
        Polymod.addDefaultImport(flixel.group.FlxGroup);
        Polymod.addDefaultImport(flixel.group.FlxSpriteGroup);

        Polymod.addDefaultImport(PlayState);
        Polymod.addDefaultImport(Character);
        Polymod.addDefaultImport(modding.ScriptingUtil);
        Polymod.addDefaultImport(Utils);
        Polymod.addDefaultImport(Conductor);
        Polymod.addDefaultImport(AtlasSprite);
        Polymod.addDefaultImport(Binds);
        Polymod.addDefaultImport(VideoHandler);
        Polymod.addDefaultImport(DialogueBox);
        Polymod.addDefaultImport(debug.ChartingState);

        //Import customizable class so now we can make custom class without importing
        Polymod.addDefaultImport(data.CharacterInfo);
        Polymod.addDefaultImport(note.NoteType);
        Polymod.addDefaultImport(events.Events);
        Polymod.addDefaultImport(stages.BaseStage);

        Polymod.addDefaultImport(cutscenes.ScriptedCutscene);

        Polymod.addDefaultImport(note.NoteSkinBase);
        Polymod.addDefaultImport(note.NoteSplashSkinBase);
        Polymod.addDefaultImport(note.NoteHoldCoverSkinBase);
        Polymod.addDefaultImport(ui.ComboPopupSkinBase);
        Polymod.addDefaultImport(ui.CountdownSkinBase);
        Polymod.addDefaultImport(ui.HudNoteSkinBase);
        
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