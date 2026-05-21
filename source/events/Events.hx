package events;

import flixel.tweens.FlxEase;

using StringTools;

typedef EventDefinition = {
	var prefix:String;
	var eventFunction:(String)->Void;
	var preprocessFunction:(String)->Void;
	var ignoreOffset:Bool; //Ignores the note offset. Basically for events that need to sync to the music.
	var executeAtStart:Bool; //Makes it so that if an event has this and the event time is 0 it will execute when the state is loaded instead of at the begining of the song.
	var editor:EventEditorProperties;
}

typedef EventEditorProperties = {
	var description:String;
	var arguments:Array<EventArgument>;
	var hidden:Bool;
}

//Still unsure exactly how I wanna handle this.
typedef EventArgument = {
	var name:String;
	var type:EventArgumentType;
	var value:String;
}

enum abstract EventArgumentType(String) from String to String {
	var bool;
	var int;
	var float;
	var string;
	var ease;
	var time;
	var character;
	var color;
	var vocalTrack;
	var normalizedFloat;
}

@:build(modding.GlobalScriptingTypesMacro.build())
class Events
{

	public static var events:Map<String, EventDefinition>;

	public static var ignoreOffsets:Array<String>; 
	public static var executeAtStart:Array<String>;

	public static function initEvents():Void{
		events = new Map<String, EventDefinition>();
		ignoreOffsets = [];
		executeAtStart = [];

		for(scriptName in ScriptableEvents.listScriptClasses()){
			var eventClass:Events = ScriptableEvents.scriptInit(scriptName);
			eventClass.defineEvents();
		}

		for(event in events){
			if(event.ignoreOffset)		{ ignoreOffsets.push(event.prefix); }
			if(event.executeAtStart)	{ executeAtStart.push(event.prefix); }
		}
	}

	function registerEvent(definition:Dynamic):Void{
		var def:EventDefinition = generateEventDefinition();

		if(definition.prefix != null){ def.prefix = definition.prefix; }
		else{ trace("Event has no prefix"); return; }

		if(definition.eventFunction != null)		{ def.eventFunction = definition.eventFunction; }
		if(definition.preprocessFunction != null)	{ def.preprocessFunction = definition.preprocessFunction; }
		if(definition.ignoreOffset != null)			{ def.ignoreOffset = definition.ignoreOffset; }
		if(definition.executeAtStart != null)		{ def.executeAtStart = definition.executeAtStart; }
		if(definition.editor != null) {
			if(definition.editor.description != null)	{ def.editor.description = definition.editor.description; }
			if(definition.editor.hidden != null)		{ def.editor.hidden = definition.editor.hidden; }
			if(definition.editor.arguments != null)		{ def.editor.arguments = definition.editor.arguments; }
		}

		events.set(def.prefix, def);
	}

	/**
	* Override this function and define your events here.
	*/
	public function defineEvents():Void{}

	#if BACKWARD_COMPATIBILITY
	/**
	 * Adds an event that will be processed once the cutscene is started.
	 *
	 * @param   prefix				The event tag prefix used to call the event. Basically the event's name.
	 * @param   processFunction		The function that is run when the event is triggered. It get's passed the whole event tag as it's parameter.
	 * @param   metaDescription		The description of the function that will appear in the chart editor.
	 * @param   preprocessFunction	A function that is run at the start of PlayState. Useful if you need to have something already loaded for the event. It get's passed the whole event tag as it's parameter.
	 * @param   ignoreNoteOffset	Whether the event should ignore the user's note offset. This should only really be used if the event needs to sync with the audio of a song.
	 */
	function addEvent(prefix:String, processFunction:(String)->Void, metaDescription:String = null, preprocessFunction:(String)->Void = null, ignoreNoteOffset:Bool = false):Void{
		var def:EventDefinition = generateEventDefinition();
		def.prefix = prefix;
		def.eventFunction = processFunction;
		if(preprocessFunction != null){ def.preprocessFunction = preprocessFunction; }
		if(ignoreNoteOffset){ def.ignoreOffset = ignoreNoteOffset; }
		if(metaDescription != null){ def.editor = {description: metaDescription, arguments: null, hidden: false}; }

		registerEvent(def);
	}
	#end

	public static function generateEventDefinition():EventDefinition{
		return {
			prefix: null,
			eventFunction: null,
			preprocessFunction: null,
			ignoreOffset: false,
			executeAtStart: false,
			editor: generateEventEditorProperties()
		};
	}
	
	public static function generateEventEditorProperties():EventEditorProperties{
		return {
			description: null,
			arguments: null,
			hidden: false
		};
	}

	/**
	* Splits the event tag at each `;` to get the event arguments.
	*/
	public static function getArgs(fullEventTag:String, ?defaultArgs:Array<String>):Array<String>{
		var result:Array<String> = [];
		var args:Array<String> = fullEventTag.split(";");
		args.shift();

		if(defaultArgs == null){
			defaultArgs = getDefaultArguments(fullEventTag.split(";")[0]);
		}

		if(defaultArgs.length > 0){
			for (i in 0...defaultArgs.length){
				result.push(args[i] != null && args[i].length > 0 ? args[i] : defaultArgs[i]);
			}

			return result;
		}
		else{
			return args;
		}
	}

	//For converting event properties to easing functions.
	public static inline function parseEase(ease:String):Null<flixel.tweens.EaseFunction>{
		var r:Null<flixel.tweens.EaseFunction>;
		switch(ease){
			default:
				r = FlxEase.linear;

			case "quadIn":
				r = FlxEase.quadIn;
			case "quadOut":
				r = FlxEase.quadOut;
			case "quadInOut":
				r = FlxEase.quadInOut;

			case "cubeIn":
				r = FlxEase.cubeIn;
			case "cubeOut":
				r = FlxEase.cubeOut;
			case "cubeInOut":
				r = FlxEase.cubeInOut;

			case "quartIn":
				r = FlxEase.quartIn;
			case "quartOut":
				r = FlxEase.quartOut;
			case "quartInOut":
				r = FlxEase.quartInOut;

			case "quintIn":
				r = FlxEase.quintIn;
			case "quintOut":
				r = FlxEase.quintOut;
			case "quintInOut":
				r = FlxEase.quintInOut;

			case "smoothStepIn":
				r = FlxEase.smoothStepIn;
			case "smoothStepOut":
				r = FlxEase.smoothStepOut;
			case "smoothStepInOut":
				r = FlxEase.smoothStepInOut;

			case "smootherStepIn":
				r = FlxEase.smootherStepIn;
			case "smootherStepOut":
				r = FlxEase.smootherStepOut;
			case "smootherStepInOut":
				r = FlxEase.smootherStepInOut;

			case "sineIn":
				r = FlxEase.sineIn;
			case "sineOut":
				r = FlxEase.sineOut;
			case "sineInOut":
				r = FlxEase.sineInOut;

			case "bounceIn":
				r = FlxEase.bounceIn;
			case "bounceOut":
				r = FlxEase.bounceOut;
			case "bounceInOut":
				r = FlxEase.bounceInOut;

			case "circIn":
				r = FlxEase.circIn;
			case "circOut":
				r = FlxEase.circOut;
			case "circInOut":
				r = FlxEase.circInOut;

			case "expoIn":
				r = FlxEase.expoIn;
			case "expoOut":
				r = FlxEase.expoOut;
			case "expoInOut":
				r = FlxEase.expoInOut;

			case "backIn":
				r = FlxEase.backIn;
			case "backOut":
				r = FlxEase.backOut;
			case "backInOut":
				r = FlxEase.backInOut;

			case "elasticIn":
				r = FlxEase.elasticIn;
			case "elasticOut":
				r = FlxEase.elasticOut;
			case "elasticInOut":
				r = FlxEase.elasticInOut;
		}
		return r;
	}

	#if BACKWARD_COMPATIBILITY
	@:noCompletion
	public static inline function easeNameToEase(ease:String):Null<flixel.tweens.EaseFunction>{
		return parseEase(ease);
	}
	#end

	//Coverts event properties to time. If value ends in "b" the number is treated as a beat duration, if the value ends in "s" the number is treated as a step duration, otherwise it's just time in seconds.
	public static inline function parseTime(v:String):Float{
		var r:Float;
		if(v.endsWith("b")){
			v = v.split("b")[0];
			r = (Conductor.getCrotchet() * Std.parseFloat(v));
		}
		else if(v.endsWith("s")){
			v = v.split("s")[0];
			r = (Conductor.getStepCrotchet() * Std.parseFloat(v));
		}
		else{
			r = Std.parseFloat(v);
		}
		return r;
	}

	#if BACKWARD_COMPATIBILITY
	@:noCompletion
	public static inline function eventConvertTime(v:String):Float{
		return parseTime(v);
	}
	#end

	public static inline function parseBool(v:String):Bool{
		return (v.toLowerCase().trim().startsWith("t"));
	}

	public static inline function parseInt(v:String):Int{
		return Std.parseInt(v);
	}

	public static inline function parseFloat(v:String):Float{
		return Std.parseFloat(v);
	}

	public static function getDefaultArguments(prefix:String):Array<String>{
		var eventDefinition:EventDefinition = events.get(prefix);
		if(eventDefinition == null){ return []; }
		var r:Array<String> = [];
		if(eventDefinition.editor != null && eventDefinition.editor.arguments != null){
			for(arg in eventDefinition.editor.arguments){
				r.push(arg.value);
			}
		}
		return r;
	}


	public function toString():String{ return "Events"; }
}