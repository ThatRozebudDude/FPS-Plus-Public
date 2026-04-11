package events;

import PlayState.VocalType;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxEase;

using StringTools;

@:build(modding.GlobalScriptingTypesMacro.build())
class Events
{

	public static var events:Map<String, (String)->Void>;
	public static var preEvents:Map<String, (String)->Void>;
	public static var eventsMeta:Map<String, String>;

	public static var ignoreOffset:Array<String>;

	public static function initEvents():Void{
		events = new Map<String, (String)->Void>();
		preEvents = new Map<String, (String)->Void>();
		eventsMeta = new Map<String, String>();
		ignoreOffset = [];

		for(x in ScriptableEvents.listScriptClasses()){
			var eventClass:Events = ScriptableEvents.scriptInit(x);
			eventClass.defineEvents();
		}
	}

	/**
	* Override this function and define your events here.
	*/
	public function defineEvents():Void{}

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
		events.set(prefix, processFunction);
		if(metaDescription != null){
			eventsMeta.set(prefix, metaDescription);
		}
		if(preprocessFunction != null){
			preEvents.set(prefix, preprocessFunction);
		}
		if(ignoreNoteOffset){
			ignoreOffset.push(prefix);
		}
	}

	/**
	* Splits the event tag at each `;` to get the event arguments.
	*/
	public static function getArgs(fullEventTag:String, ?defaultArgs:Array<String>):Array<String>{
		var r = [];

		var args = fullEventTag.split(";");
		for(i in 0...args.length){
			if(i == 0) { continue; }
			r.push(args[i]);
		}

		if(defaultArgs != null && defaultArgs.length > r.length){
			for(i in 0...defaultArgs.length){
				if(i >= r.length){
					r.push(defaultArgs[i]);
				}
			}
		}

		return r;
	}

	//For converting event properties to easing functions.
	private static var __easeCache:Map<String, EaseFunction> = [];
	public static inline function easeNameToEase(ease:String):Null<EaseFunction>{
		if (!__easeCache.exists(ease) && Reflect.hasField(FlxEase, ease)){
			__easeCache.set(ease, Reflect.field(FlxEase, ease));
		}
		return __easeCache.get(ease) ?? FlxEase.linear;
	}

	//Coverts event properties to time. If value ends in "b" the number is treated as a beat duration, if the value ends in "s" the number is treated as a step duration, otherwise it's just time in seconds.
	public static inline function eventConvertTime(v:String):Float{
		var r;
		if(v.endsWith("b")){
			v = v.split("b")[0];
			r = (Conductor.crochet * Std.parseFloat(v) / 1000);
		}
		else if(v.endsWith("s")){
			v = v.split("s")[0];
			r = (Conductor.stepCrochet * Std.parseFloat(v) / 1000);
		}
		else{
			r = Std.parseFloat(v);
		}
		return r;
	}

	public static inline function parseBool(v:String):Bool{
		return (v.toLowerCase() == "true");
	}

	public static inline function parseInt(v:String):Int{
		return Std.parseInt(v);
	}

	public static inline function parseFloat(v:String):Float{
		return Std.parseFloat(v);
	}

	public function toString():String{ return "Events"; }
}