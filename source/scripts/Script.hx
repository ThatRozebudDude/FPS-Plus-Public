package scripts;

import flixel.FlxG;
import flixel.FlxBasic;
import note.Note;

@:build(modding.GlobalScriptingTypesMacro.build())
class Script
{
	/**
	* Called when the script is created.
	*/
	public function create(){}

	/**
	* Called after the script is created. Can be used to check if other scripts or certain stage elements exist that wouldn't have before `create()`.
	*/
	public function postCreate(){}

	/**
	 * Called every frame in PlayState update.
	 *
	 * @param   elapsed  The elapsed time between previous frames passed in by PlayState.
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
	 * Called once the song end.
	 */
	public function songEnd(){}
 
	/**
	 * Called when the game is paused.
	 */
	public function pause(){}

	/**
	 * Called every frame in PauseSubState update.
	 *
	 * @param   elapsed  The elapsed time between previous frames passed in by PlayState.
	 */
	public function pauseUpdate(elapsed:Float){}
 
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
	 * Called every frame in GameOverSubState update.
	 *
	 * @param   elapsed  The elapsed time between previous frames passed in by PlayState.
	 */
	public function gameOverUpdate(elapsed:Float){}
 
	/**
	 * Called when the leaving PlayState.
	 */
	public function exit(){}

	/**
	 * Called when a character hits a note.
	 */
	public function noteHit(character:Character, note:Note){}

	 /**
	  * Called when you miss a note. `countedMiss` will be `true` when the miss adds to your miss count and `false` when it just plays the miss animation while not adding to your miss count.
	  */
	public function noteMiss(direction:Int, countedMiss:Bool){}

	function addToBackground(x:FlxBasic)		{ PlayState.instance.backgroundLayer.add(x); }
	function removeFromBackground(x:FlxBasic)	{ PlayState.instance.backgroundLayer.remove(x); }
	function addToGf(x:FlxBasic)				{ PlayState.instance.gfLayer.add(x); }
	function removeFromGf(x:FlxBasic)			{ PlayState.instance.gfLayer.remove(x); }
	function addToMiddle(x:FlxBasic)			{ PlayState.instance.middleLayer.add(x); }
	function removeFromMiddle(x:FlxBasic)		{ PlayState.instance.middleLayer.remove(x); }
	function addToCharacter(x:FlxBasic)			{ PlayState.instance.characterLayer.add(x); }
	function removeFromCharacter(x:FlxBasic)	{ PlayState.instance.characterLayer.remove(x); }
	function addToForeground(x:FlxBasic)		{ PlayState.instance.foregroundLayer.add(x); }
	function removeFromForeground(x:FlxBasic)	{ PlayState.instance.foregroundLayer.remove(x); }
	function addToOverlay(x:FlxBasic)			{ PlayState.instance.overlayLayer.add(x); }
	function removeFromOverlay(x:FlxBasic)		{ PlayState.instance.overlayLayer.remove(x); }
	function addToHud(x:FlxBasic)				{ PlayState.instance.hudLayer.add(x); }
	function removeHud(x:FlxBasic)				{ PlayState.instance.hudLayer.remove(x); }

	function addGeneric(x:FlxBasic)				{ FlxG.state.add(x); }
	function removeGeneric(x:FlxBasic)			{ FlxG.state.remove(x); }
	function addGenericSubstate(x:FlxBasic)		{ FlxG.state.subState.add(x); }
	function removeGenericSubstate(x:FlxBasic)	{ FlxG.state.subState.remove(x); }

	public function toString():String{ return "Script"; }
}