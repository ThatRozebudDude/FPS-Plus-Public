package note;

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

    inline function boyfriend()     { return PlayState.instance.boyfriend; }
    inline function gf()            { return PlayState.instance.gf; }
    inline function dad()           { return PlayState.instance.dad; }
    inline function playstate()     { return PlayState.instance; }
    inline function tween()         { return PlayState.instance.tweenManager; }
    inline function data()          { return PlayState.instance.arbitraryData; }

}