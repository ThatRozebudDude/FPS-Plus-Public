package modding;

import flixel.FlxG;
import polymod.Polymod;
import sys.FileSystem;

class PolymodHandler
{

    static final API_VERSION:String = "0.0.0";

    //static var loadedMods:Array<String>;

    public static function init():Void{
        var modDirs:Array<String> = FileSystem.readDirectory("mods/");
        if(modDirs == null){ modDirs = []; }

        trace("BEFORE CULLING:");
        trace(modDirs);

        //Remove all non-folder entries from loadedMods.
        for(path in modDirs){
            if(!FileSystem.isDirectory("mods/" + path)){
                modDirs.remove(path);
            }
        }

        trace("AFTER CULLING:");
        trace(modDirs);
		
		Polymod.init({
			modRoot: "./mods/",
			dirs: modDirs,
			useScriptedClasses: true,
			apiVersionRule: API_VERSION
		});

        trace("POLYMOD SCAN:");
		trace(Polymod.scan());
    }

    public static function reload():Void{
        Polymod.clearScripts();
		Polymod.registerAllScriptClasses();
		FlxG.resetState();
    }

}