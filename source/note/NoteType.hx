package note;

import flixel.tweens.FlxTween.FlxTweenManager;
import note.*;

@:build(modding.GlobalScriptingTypesMacro.build())
class NoteType
{

    public static var types:Map<String, Array<Dynamic>>;
    public static var sustainTypes:Map<String, Array<Dynamic>>;
    public static var typeSkins:Map<String, String>;

    public static function initTypes():Void{
        types = new Map<String, Array<Dynamic>>();
        sustainTypes = new Map<String, Array<Dynamic>>();
        typeSkins = new Map<String, String>();

		for(x in ScriptableNoteType.listScriptClasses()){
			var noteTypeClass:NoteType = ScriptableNoteType.init(x);
            noteTypeClass.defineTypes();
		}
    }

    /**
    * Override this function and define your note types here.
    */
    function defineTypes():Void{}

    function addNoteType(name:String, hitFunction:(Note, Character)->Void, missFunction:(Int, Character)->Void):Void{
        types.set(name, [hitFunction, missFunction]);
    }

    function addSustainType(name:String, hitFunction:(Note, Character)->Void, missFunction:(Int, Character)->Void):Void{
        sustainTypes.set(name, [hitFunction, missFunction]);
    }

    function addTypeSkin(name:String, noteSkinName:String):Void{
        typeSkins.set(name, noteSkinName);
    }

    @:isVar var healthAdjust(never,set):Float;
    @:noCompletion inline function set_healthAdjust(v:Float):Float{ 
        healthAdjust = v;
        PlayState.instance.healthAdjustOverride = v;
        return v;
    }

    function shouldPlayAnimation(note:Note, character:Character):Bool{
        return PlayState.characterShouldPlayAnimation(note, character);
    }
    public function toString():String{ return "NoteType"; }
}