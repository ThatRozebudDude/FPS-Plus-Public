package cutscenes;

import flixel.FlxG;
import flixel.FlxBasic;

class ScriptedCutscene extends FlxBasic
{

    public var totalTime:Float = 0;

    public var started(get, never):Bool;
    var __started:Bool = false;

    public var events:Array<Array<Dynamic>> = [];

    /**
	 * Do not override this function, override `init()` instead.
	 */
    public function new(){
        super();
        init();
    }

    /**
	 * Override this function to initialize all of your stage elements.
	 */
    function init(){}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(__started){
            totalTime += elapsed;
            
            for(event in events){
                if(event[0] > totalTime){ break; }
                else{
                    event[1]();
                    events.remove(event);
                }
            }

            if(events.length == 0){
                destroy();
            }
        } 
    }

    /**
     * Starts the cutscene.
     */
    public function start():Void{
        __started = true;
    }

    /**
	 * Adds an event that will be processed once the cutscene is started.
	 *
	 * @param   _time       The time in seconds that the event will occur at.
	 * @param   _function   The function that will be run when the event is called.
	 */
    public function addEvent(_time:Float, _function:Void->Void):Void{
        events.push([_time, _function]);
        events.sort((a, b) -> { Utils.sign(a[0] - b[0]); });
    }

    public inline function addToBackgroundLayer(x:FlxBasic):Void{
        playstate().backgroundLayer.add(x);
    }

    public inline function removeFromBackgroundLayer(x:FlxBasic):Void{
        playstate().backgroundLayer.remove(x);
    }

    public inline function addToGfLayer(x:FlxBasic):Void{
        playstate().gfLayer.add(x);
    }

    public inline function removeFromGfLayer(x:FlxBasic):Void{
        playstate().gfLayer.remove(x);
    }

    public inline function addToMiddleLayer(x:FlxBasic):Void{
        playstate().middleLayer.add(x);
    }

    public inline function removeFromMiddleLayer(x:FlxBasic):Void{
        playstate().middleLayer.remove(x);
    }

    public inline function addToCharacterLayer(x:FlxBasic):Void{
        playstate().characterLayer.add(x);
    }

    public inline function removeFromCharacterLayer(x:FlxBasic):Void{
        playstate().characterLayer.remove(x);
    }

    public inline function addToForegroundLayer(x:FlxBasic):Void{
        playstate().foregroundLayer.add(x);
    }

    public inline function removeFromForegroundLayer(x:FlxBasic):Void{
        playstate().foregroundLayer.remove(x);
    }

    public inline function addGeneric(x:FlxBasic):Void{
        FlxG.state.add(x);
    }

    public inline function removeGeneric(x:FlxBasic):Void{
        FlxG.state.remove(x);
    }

    public inline function boyfriend()     { return PlayState.instance.boyfriend; }
    public inline function gf()            { return PlayState.instance.gf; }
    public inline function dad()           { return PlayState.instance.dad; }
    public inline function playstate()     { return PlayState.instance; }
    public inline function tween()         { return PlayState.instance.tweenManager; }

    function get_started():Bool{ return __started; }
}