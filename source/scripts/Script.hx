package scripts;

import flixel.FlxG;
import flixel.FlxBasic;

@:build(modding.GlobalScriptingTypesMacro.build())
class Script
{
    /**
	* Called when the script is created.
	*/
    public function create(){}

    /**
     * Called every frame in PlayState update.
     *
     * @param   elpased  The elapsed time between previous frames passed in by PlayState.
     */
    public function update(elapsed:Float){}
 
    /**
     * Called every beat hit in PlayState.
     *
     * @param   curBeat  The current song beat passed in by PlayState.
     */
    public function beat(curBeat:Int){}
 
    /**
     * Called every beat during the countdown.
     *
     * @param   curBeat  The current song beat passed in by PlayState.
     */
    public function countdownBeat(curBeat:Int){}
 
    /**
     * Called every step hit in PlayState.
     *
     * @param   curStep  The current song step passed in by PlayState.
     */
    public function step(curStep:Int){}
 
    /**
     * Called once the song starts.
     */
    public function songStart(){}
 
    /**
     * Called when the game is paused.
     */
    public function pause(){}
 
    /**
     * Called when the game is unpaused.
     */
    public function unpause(){}
 
    /**
     * Called when the game over state is started.
     */
    public function gameOverStart(){}
 
    /**
     * Called when the starting the game over loop animation.
     */
    public function gameOverLoop(){}
 
    /**
     * Called when the game over retry is confirmed.
     */
    public function gameOverEnd(){}
 
    /**
     * Called when the leaving PlayState.
     */
    public function exit(){}

    inline function addToBackground(x:FlxBasic)         { PlayState.instance.backgroundLayer.add(x); }
    inline function removeFromBackground(x:FlxBasic)    { PlayState.instance.backgroundLayer.remove(x); }
    inline function addToGf(x:FlxBasic)                 { PlayState.instance.gfLayer.add(x); }
    inline function removeFromGf(x:FlxBasic)            { PlayState.instance.gfLayer.remove(x); }
    inline function addToMiddle(x:FlxBasic)             { PlayState.instance.middleLayer.add(x); }
    inline function removeFromMiddle(x:FlxBasic)        { PlayState.instance.middleLayer.remove(x); }
    inline function addToCharacter(x:FlxBasic)          { PlayState.instance.characterLayer.add(x); }
    inline function removeFromCharacter(x:FlxBasic)     { PlayState.instance.characterLayer.remove(x); }
    inline function addToForeground(x:FlxBasic)         { PlayState.instance.foregroundLayer.add(x); }
    inline function removeFromForeground(x:FlxBasic)    { PlayState.instance.foregroundLayer.remove(x); }
    inline function addToOverlay(x:FlxBasic)            { PlayState.instance.overlayLayer.add(x); }
    inline function removeFromOverlay(x:FlxBasic)       { PlayState.instance.overlayLayer.remove(x); }
    inline function addToHud(x:FlxBasic)                { PlayState.instance.hudLayer.add(x); }
    inline function removeHud(x:FlxBasic)               { PlayState.instance.hudLayer.remove(x); }

    inline function addGeneric(x:FlxBasic)              { FlxG.state.add(x); }
    inline function removeGeneric(x:FlxBasic)           { FlxG.state.remove(x); }
    inline function addGenericSubstate(x:FlxBasic)      { FlxG.state.subState.add(x); }
    inline function removeGenericSubstate(x:FlxBasic)   { FlxG.state.subState.remove(x); }

    public function toString():String{ return "Script"; }
}