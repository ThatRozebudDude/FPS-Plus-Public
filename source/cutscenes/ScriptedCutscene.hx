package cutscenes;

import flixel.FlxG;
import flixel.FlxBasic;

class ScriptedCutscene extends FlxBasic
{

    public var totalTime:Float = 0;

    public var started(get, never):Bool;
    var __started:Bool = false;

    public var events:Array<Array<Dynamic>> = [];

    public function new(){
        super();
        init();
    }

    /**
	 * Override this function to initialize all of your cutscene stuff.
	 */
    function init():Void{}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(__started){
            if(events.length > 0){
                totalTime += elapsed;
            }
            
            for(event in events){
                if(event[0] > totalTime){ break; }
                else{
                    if(event[1] != null){
                        event[1]();
                    }
                    events.remove(event);
                }
            }
        } 
    }

    /**
     * Starts the cutscene.
     */
    public function start():Void{
        __started = true;
        
        for(event in events){
            if(event[0] > 0){ break; }
            else{
                if(event[1] != null){
                    event[1]();
                }
                events.remove(event);
            }
        }
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

    /**
     * Adds an object to the background element layer in PlayState.
    **/
    public inline function addToBackgroundLayer(x:FlxBasic):Void{
        playstate().backgroundLayer.add(x);
    }

    /**
     * Removes an object from the background element layer in PlayState.
    **/
    public inline function removeFromBackgroundLayer(x:FlxBasic):Void{
        playstate().backgroundLayer.remove(x);
    }

    /**
     * Adds an object to the girlfriend layer in PlayState.
    **/
    public inline function addToGfLayer(x:FlxBasic):Void{
        playstate().gfLayer.add(x);
    }

    /**
     * Removes an object from the girlfriend layer in PlayState.
    **/
    public inline function removeFromGfLayer(x:FlxBasic):Void{
        playstate().gfLayer.remove(x);
    }

    /**
     * Adds an object to the middle element layer in PlayState.
    **/
    public inline function addToMiddleLayer(x:FlxBasic):Void{
        playstate().middleLayer.add(x);
    }

    /**
     * Removes an object from the middle element layer in PlayState.
    **/
    public inline function removeFromMiddleLayer(x:FlxBasic):Void{
        playstate().middleLayer.remove(x);
    }

    /**
     * Adds an object to the character layer in PlayState.
    **/
    public inline function addToCharacterLayer(x:FlxBasic):Void{
        playstate().characterLayer.add(x);
    }

    /**
     * Removes an object from the character layer in PlayState.
    **/
    public inline function removeFromCharacterLayer(x:FlxBasic):Void{
        playstate().characterLayer.remove(x);
    }

    /**
     * Adds an object to the foreground element layer in PlayState.
    **/
    public inline function addToForegroundLayer(x:FlxBasic):Void{
        playstate().foregroundLayer.add(x);
    }

    /**
     * Removes an object from the foreground element layer in PlayState.
    **/
    public inline function removeFromForegroundLayer(x:FlxBasic):Void{
        playstate().foregroundLayer.remove(x);
    }

    /**
     * Adds an object to the current state.
    **/
    public inline function addGeneric(x:FlxBasic):Void{
        FlxG.state.add(x);
    }

    /**
     * Removes an object from the current state.
    **/
    public inline function removeGeneric(x:FlxBasic):Void{
        FlxG.state.remove(x);
    }

    /**
     * Adds an object to the current substate.
    **/
    public inline function addGenericSubstate(x:FlxBasic):Void{
        FlxG.state.subState.add(x);
    }

    /**
     * Removes an object from the current substate.
    **/
    public inline function removeGenericSubstate(x:FlxBasic):Void{
        FlxG.state.subState.remove(x);
    }

    public inline function boyfriend()     { return PlayState.instance.boyfriend; }
    public inline function gf()            { return PlayState.instance.gf; }
    public inline function dad()           { return PlayState.instance.dad; }
    public inline function playstate()     { return PlayState.instance; }
    public inline function tween()         { return PlayState.instance.tweenManager; }

    function get_started():Bool{ return __started; }
}