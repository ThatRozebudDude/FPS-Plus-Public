package cutscenes;

import PlayState.VocalType;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxG;
import flixel.FlxBasic;
import scripts.Script;

class Cutscene extends Script
{

    public var totalTime:Float = 0;

    var started:Bool = false;

    public var events:Array<Array<Dynamic>> = [];

    public function new(args:Array<Dynamic>){}

    override function update(elapsed:Float) {
        if(started){
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
        started = true;
        
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

    //These functions are Deprecated! Use the function as in the base script!!

    /**
     * Adds an object to the background element layer in PlayState.
    **/
    public function addToBackgroundLayer(x:FlxBasic):Void{
        trace("addToBackgroundLayer is deprecated, use addToBackground");
        addToBackground(x);
    }

    /**
     * Removes an object from the background element layer in PlayState.
    **/
    public function removeFromBackgroundLayer(x:FlxBasic):Void{
        trace("removeFromBackgroundLayer is deprecated, use removeFromBackground");
        removeFromBackground(x);
    }

    /**
     * Adds an object to the girlfriend layer in PlayState.
    **/
    public function addToGfLayer(x:FlxBasic):Void{
        trace("addToGfLayer is deprecated, use addToGf");
        addToGf(x);
    }

    /**
     * Removes an object from the girlfriend layer in PlayState.
    **/
    public function removeFromGfLayer(x:FlxBasic):Void{
        trace("removeFromGfLayer is deprecated, use removeFromGf");
        removeFromGf(x);
    }

    /**
     * Adds an object to the middle element layer in PlayState.
    **/
    public function addToMiddleLayer(x:FlxBasic):Void{
        trace("addToMiddleLayer is deprecated, use addToMiddle");
        addToMiddle(x);
    }

    /**
     * Removes an object from the middle element layer in PlayState.
    **/
    public function removeFromMiddleLayer(x:FlxBasic):Void{
        trace("removeFromMiddleLayer is deprecated, use removeFromMiddle");
        removeFromMiddle(x);
    }

    /**
     * Adds an object to the character layer in PlayState.
    **/
    public function addToCharacterLayer(x:FlxBasic):Void{
        trace("addToCharacterLayer is deprecated, use addToCharacter");
        addToCharacter(x);
    }

    /**
     * Removes an object from the character layer in PlayState.
    **/
    public function removeFromCharacterLayer(x:FlxBasic):Void{
        trace("removeFromCharacterLayer is deprecated, use removeFromCharacter");
        removeFromCharacter(x);
    }

    /**
     * Adds an object to the foreground element layer in PlayState.
    **/
    public function addToForegroundLayer(x:FlxBasic):Void{
        trace("addToForegroundLayer is deprecated, use addToForeground");
        addToForeground(x);
    }

    /**
     * Removes an object from the foreground element layer in PlayState.
    **/
    public function removeFromForegroundLayer(x:FlxBasic):Void{
        trace("removeFromForegroundLayer is deprecated, use removeFromForeground");
        removeFromForeground(x);
    }

    public function next(?doCamFadeIn:Bool = true):Void{
        if(PlayState.instance.inEndingCutscene){ PlayState.instance.endSong(); }
        else{ 
            PlayState.instance.startCountdown();
            if(doCamFadeIn){
                playstate.hudShader.alpha = 0;
                tween.tween(playstate.hudShader, {alpha: 1}, 0.3);
            }
        }  
    }

    public function focusCameraBasedOnFirstSection():Void{
        if(PlayState.SONG.notes[0].mustHitSection){ PlayState.instance.camFocusBF(); }
        else{ PlayState.instance.camFocusOpponent(); }
    }
}