package note;

import flixel.tweens.FlxTween.FlxTweenManager;

class NoteType
{

    public static var types:Map<String, Array<Dynamic>>;
    public static var sustainTypes:Map<String, Array<Dynamic>>;

    public static function initTypes():Void{
        types = new Map<String, Array<Dynamic>>();
        sustainTypes = new Map<String, Array<Dynamic>>();

        var noteTypeClasses = CompileTime.getAllClasses("note.types", false, note.NoteType);
        //trace(noteTypeClasses);
		for(x in noteTypeClasses){
			var noteTypeClass = Type.createInstance(x, []);
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

    var boyfriend(get,never):Character;
    @:noCompletion inline function get_boyfriend()  { return PlayState.instance.boyfriend; }
    var gf(get,never):Character;
    @:noCompletion inline function get_gf()         { return PlayState.instance.gf; }
    var dad(get,never):Character;
    @:noCompletion inline function get_dad()        { return PlayState.instance.dad; }
    var playstate(get,never):PlayState;
    @:noCompletion inline function get_playstate()  { return PlayState.instance; }
    var tween(get,never):FlxTweenManager;
    @:noCompletion inline function get_tween()      { return PlayState.instance.tweenManager; }
    var data(get,never):Map<String, Dynamic>;
    @:noCompletion inline function get_data()       { return PlayState.instance.arbitraryData; }

}