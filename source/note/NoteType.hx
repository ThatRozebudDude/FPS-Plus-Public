package note;

import flixel.tweens.FlxTween.FlxTweenManager;
import note.*;

@:build(modding.GlobalScriptingTypesMacro.build())
class NoteType
{

	public static var types:Map<String, Array<Dynamic>>;
	public static var sustainTypes:Map<String, Array<Dynamic>>;
	public static var typeSkins:Map<String, String>;

	public static var typeGroups:Map<String, Array<String>>;

	public var localTypes:Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();
	public var localSustainTypes:Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();
	public var localTypeSkins:Map<String, String> = new Map<String, String>();

	public static function initTypes():Void{
		types = new Map<String, Array<Dynamic>>();
		sustainTypes = new Map<String, Array<Dynamic>>();
		typeSkins = new Map<String, String>();
		typeGroups = new Map<String, Array<String>>();

		typeGroups.set("All Note Types", []);

		for(x in ScriptableNoteType.listScriptClasses()){
			typeGroups.set(x, []);

			var noteTypeClass:NoteType = ScriptableNoteType.init(x);
			noteTypeClass.defineTypes();

			for(k => v in noteTypeClass.localTypes){
				types.set(k, v);
				if(!typeGroups.get("All Note Types").contains(k)){
					typeGroups.get("All Note Types").push(k);
				}
				if(!typeGroups.get(x).contains(k)){
					typeGroups.get(x).push(k);
				}
			}
			for(k => v in noteTypeClass.localSustainTypes){
				sustainTypes.set(k, v);
				if(!typeGroups.get("All Note Types").contains(k)){
					typeGroups.get("All Note Types").push(k);
				}
				if(!typeGroups.get(x).contains(k)){
					typeGroups.get(x).push(k);
				}
			}
			for(k => v in noteTypeClass.localTypeSkins){
				typeSkins.set(k, v);
			}
		}
	}

	/**
	* Override this function and define your note types here.
	*/
	function defineTypes():Void{}

	function addNoteType(name:String, hitFunction:(Note, Character)->Void, missFunction:(Int, Character)->Void):Void{
		localTypes.set(name, [hitFunction, missFunction]);
	}

	function addSustainType(name:String, hitFunction:(Note, Character)->Void, missFunction:(Int, Character)->Void):Void{
		localSustainTypes.set(name, [hitFunction, missFunction]);
	}

	function addTypeSkin(name:String, noteSkinName:String):Void{
		localTypeSkins.set(name, noteSkinName);
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