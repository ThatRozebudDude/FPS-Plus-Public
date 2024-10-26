package events;

import PlayState.VocalType;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxEase;

using StringTools;

class Events
{

    public static var events:Map<String, (String)->Void>;
    public static var eventsMeta:Map<String, String>;

    public static function initEvents():Void{
        events = new Map<String, (String)->Void>();
        eventsMeta = new Map<String, String>();

		for(x in ScriptableEvents.listScriptClasses()){
			var eventClass:Events = ScriptableEvents.init(x);
            eventClass.defineEvents();
		}
    }

    /**
    * Override this function and define your events here.
    */
    public function defineEvents():Void{}

    function addEvent(prefix:String, processFunction:(String)->Void, metaDescription:String = null):Void{
        events.set(prefix, processFunction);
		if(metaDescription != null){
			eventsMeta.set(prefix, metaDescription);
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

    //For converting event properties to easing functions. Please let me know if there is a better way.
	public static inline function easeNameToEase(ease:String):Null<flixel.tweens.EaseFunction>{
		var r;
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

    var boyfriend(get, never):Character;
    @:noCompletion inline function get_boyfriend()  { return PlayState.instance.boyfriend; }
    var gf(get, never):Character;
    @:noCompletion inline function get_gf()         { return PlayState.instance.gf; }
    var dad(get, never):Character;
    @:noCompletion inline function get_dad()        { return PlayState.instance.dad; }
    var playstate(get, never):PlayState;
    @:noCompletion inline function get_playstate()  { return PlayState.instance; }
    var tween(get, never):FlxTweenManager;
    @:noCompletion inline function get_tween()      { return PlayState.instance.tweenManager; }
    var data(get, never):Map<String, Dynamic>;
    @:noCompletion inline function get_data()       { return PlayState.instance.arbitraryData; }

	var splitVocalTrack(get, never):VocalType;
    @:noCompletion inline function get_splitVocalTrack()    { return VocalType.splitVocalTrack; }
    var noVocalTrack(get, never):VocalType;
    @:noCompletion inline function get_noVocalTrack()       { return VocalType.noVocalTrack; }
    var combinedVocalTrack(get, never):VocalType;
    @:noCompletion inline function get_combinedVocalTrack() { return VocalType.combinedVocalTrack; }

	public function toString():String{ return "Events"; }
}