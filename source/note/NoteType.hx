package note;

import note.*;

typedef NoteTypeDefinition = {
	var prefix:String;
	var noteHit:(Note, Character)->Void;
	var noteMiss:(Note, Character)->Void;
	var sustainHit:(Note, Character)->Void;
	var sustainMiss:(Note, Character)->Void;
	var skin:String;
}

@:build(modding.GlobalScriptingTypesMacro.build())
class NoteType
{
	public static var types:Map<String, NoteTypeDefinition>;
	public static var typeGroups:Map<String, Array<String>>;

	public var localTypes:Map<String, NoteTypeDefinition> = new Map<String, NoteTypeDefinition>();

	public static function initTypes():Void{
		types = new Map<String, NoteTypeDefinition>();
		typeGroups = new Map<String, Array<String>>();

		typeGroups.set("All Note Types", []);

		for(scriptName in ScriptableNoteType.listScriptClasses()){
			typeGroups.set(scriptName, []);

			var noteTypeClass:NoteType = ScriptableNoteType.scriptInit(scriptName);
			noteTypeClass.defineTypes();

			for(k => v in noteTypeClass.localTypes){
				types.set(k, v);
				if(!typeGroups.get("All Note Types").contains(k)){
					typeGroups.get("All Note Types").push(k);
				}
				if(!typeGroups.get(scriptName).contains(k)){
					typeGroups.get(scriptName).push(k);
				}
			}
		}
	}

	function registerNoteType(definition:Dynamic):Void{
		var def:NoteTypeDefinition = generateNoteTypeDefinition();

		if(definition.prefix != null) {def.prefix = definition.prefix;}
		else{ trace("NoteType has no prefix"); return; }

		if(definition.noteHit != null) {def.noteHit = definition.noteHit;}
		if(definition.noteMiss != null) {def.noteMiss = definition.noteMiss;}
		if(definition.sustainHit != null) {def.sustainHit = definition.sustainHit;}
		if(definition.sustainMiss != null) {def.sustainMiss = definition.sustainMiss;}
		if(definition.skin != null) {def.skin = definition.skin;}

		localTypes.set(def.prefix, def);
	}

	/**
	* Override this function and define your note types here.
	*/
	function defineTypes():Void{}

	#if BACKWARD_COMPATIBILITY
	function addNoteType(name:String, hitFunction:(Note, Character)->Void, missFunction:(Note, Character)->Void):Void{
		if(!localTypes.exists(name)){
			var def:NoteTypeDefinition = generateNoteTypeDefinition();
			def.prefix = name;
			localTypes.set(name, def);
		}
		if(hitFunction != null){ localTypes.get(name).noteHit = hitFunction; }
		if(missFunction != null){ localTypes.get(name).noteMiss = missFunction; }
	}

	function addSustainType(name:String, hitFunction:(Note, Character)->Void, missFunction:(Note, Character)->Void):Void{
		if(!localTypes.exists(name)){
			var def:NoteTypeDefinition = generateNoteTypeDefinition();
			def.prefix = name;
			localTypes.set(name, def);
		}
		if(hitFunction != null){ localTypes.get(name).sustainHit = hitFunction; }
		if(missFunction != null){ localTypes.get(name).sustainMiss = missFunction; }
	}

	function addTypeSkin(name:String, noteSkinName:String):Void{
		if(!localTypes.exists(name)){
			var def:NoteTypeDefinition = generateNoteTypeDefinition();
			def.prefix = name;
			localTypes.set(name, def);
		}
		if(noteSkinName != null){ localTypes.get(name).skin = noteSkinName; }
	}
	#end

	@:isVar var healthAdjust(never,set):Float;
	@:noCompletion inline function set_healthAdjust(v:Float):Float{ 
		healthAdjust = v;
		PlayState.instance.healthAdjustOverride = v;
		return v;
	}

	function shouldPlayAnimation(note:Note, character:Character):Bool{
		return PlayState.characterShouldPlayAnimation(note, character);
	}

	static function generateNoteTypeDefinition():NoteTypeDefinition{
		return 
		{
			prefix: null,
			noteHit: null,
			noteMiss: null,
			sustainHit: null,
			sustainMiss: null,
			skin: null
		};
	}

	public function toString():String{ return "NoteType"; }
}