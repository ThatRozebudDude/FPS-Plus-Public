package stages;

//import flixel.FlxBasic;
import note.Note;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;

/**
	This is the base class for stages. When making your own stage make a new class extending this one.    
	@author Rozebud
**/

@:build(modding.GlobalScriptingTypesMacro.build())
class BaseStage
{

    public var name:String;
    public var startingZoom:Float = 1;
    public var uiType:String = "Default";
    public var cameraMovementEnabled:Bool = true;
    public var extraCameraMovementAmount:Null<Float> = null; //Leave null for PlayState default.
    public var cameraStartPosition:FlxPoint; //Leave null for PlayState default.
    public var globalCameraOffset:FlxPoint = new FlxPoint();
    public var bfCameraOffset:FlxPoint = new FlxPoint();
    public var dadCameraOffset:FlxPoint = new FlxPoint();
    public var gfCameraOffset:FlxPoint = new FlxPoint();
    public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();
    public var events:Map<String, (String)->Void> = new Map<String, (String)->Void>();
    public var instantStart:Bool = false;

    public var backgroundElements:Array<Dynamic> = [];
    public var middleElements:Array<Dynamic> = [];
    public var foregroundElements:Array<Dynamic> = [];
    public var overlayElements:Array<Dynamic> = [];
    public var hudElements:Array<Dynamic> = [];

    var updateGroup:FlxGroup = new FlxGroup();

    public var useStartPoints:Bool = true; //Auto positions characters if set to true
    public var overrideBfStartPoints:Bool = false;  //Does the opposite of useStartPoints for this specific character.
    public var overrideDadStartPoints:Bool = false; //Does the opposite of useStartPoints for this specific character.
    public var overrideGfStartPoints:Bool = false;  //Does the opposite of useStartPoints for this specific character.
    public var dadStart:FlxPoint = new FlxPoint(314.5, 867);
    public var bfStart:FlxPoint = new FlxPoint(975.5, 862);
    public var gfStart:FlxPoint = new FlxPoint(751.5, 778);

    public function new(){}

    /**
	 * Adds an object to `backgroundElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToBackground(x:FlxBasic){
        backgroundElements.push(x);
    }

    /**
	 * Adds an object to `middleElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToMiddle(x:FlxBasic){
        middleElements.push(x);
    }

    /**
	 * Adds an object to `foregroundElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToForeground(x:FlxBasic){
        foregroundElements.push(x);
    }

    /**
	 * Adds an object to `overlayElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
     public function addToOverlay(x:FlxBasic){
        overlayElements.push(x);
    }
    
    /**
	 * Adds an object to `hudElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToHud(x:FlxBasic){
        hudElements.push(x);
    }

    /**
	 * Adds arbitrary info to the stage that can be read in PlayState.
	 *
	 * @param   k  A string key.
	 * @param   x  The dyanmic data.
	 */
    public function addExtraData(k:String, x:Dynamic){
        extraData.set(k, x);
    }

    /**
     * Adds arbitrary info to the stage that can be read in PlayState.
     *
     * @param   name    The name of the event.
     * @param   func    The function that gets called when the event is triggered. Must have no arguments and no return type.
     */
    public function addEvent(name:String, func:(String)->Void){
        events.set(name, func);
    }

    /**
     * Add any object that will up updated in the stage's update loop.
     *
     * @param   obj     The object that will be added to the update loop.
     */
    public function addToUpdate(obj:FlxBasic){
        updateGroup.add(obj);
    }

    /**
     * Remove an object from the stage's update loop.
     *
     * @param   obj     The object that will be added to the update loop.
     */
    public function removeFromUpdate(obj:FlxBasic){
        updateGroup.remove(obj);
    }

    /**
	 * Destroys all objects added to the stage elements.
	 */
    public function destroyAll(){
        for(x in backgroundElements){ x.destroy(); }
        for(x in middleElements){ x.destroy(); }
        for(x in foregroundElements){ x.destroy(); }
        for(x in overlayElements){ x.destroy(); }
        for(x in hudElements){ x.destroy(); }
    }

    /**
	 * Called after PlayState.create() is done.
	 */
    public function postCreate(){}

    /**
	 * Called every frame in PlayState update.
	 * Don't forget to call `super.update(elasped)` or the update group won't be updated.
     *
     * @param   elpased  The elapsed time between previous frames passed in by PlayState.
	 */
    public function update(elapsed:Float){
        for(obj in updateGroup){
            obj.update(elapsed);
        }
    }

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

    /**
	 * Called when a character hits a note.
	 */
    public function noteHit(character:Character, note:Note){}

    /**
	 * Called when you miss a note. `countedMiss` will be `true` when the miss adds to your miss count and `false` when it just plays the miss animation while not adding to your miss count.
	 */
    public function noteMiss(direction:Int, countedMiss:Bool){}

    //It is only recommended that you only use this if you have to add objects dynamically.
    //For normal stage elements you should just add them to the groups in the init() and toggle their visibility.
    inline function addToBackgroundLive(x:FlxBasic)      { PlayState.instance.backgroundLayer.add(x); }
    inline function removeFromBackgroundLive(x:FlxBasic) { PlayState.instance.backgroundLayer.remove(x); }
    inline function addToGfLive(x:FlxBasic)              { PlayState.instance.gfLayer.add(x); }
    inline function removeFromGfLive(x:FlxBasic)         { PlayState.instance.gfLayer.remove(x); }
    inline function addToMiddleLive(x:FlxBasic)          { PlayState.instance.middleLayer.add(x); }
    inline function removeFromMiddleLive(x:FlxBasic)     { PlayState.instance.middleLayer.remove(x); }
    inline function addToCharacterLive(x:FlxBasic)       { PlayState.instance.characterLayer.add(x); }
    inline function removeFromCharacterLive(x:FlxBasic)  { PlayState.instance.characterLayer.remove(x); }
    inline function addToForegroundLive(x:FlxBasic)      { PlayState.instance.foregroundLayer.add(x); }
    inline function removeFromForegroundLive(x:FlxBasic) { PlayState.instance.foregroundLayer.remove(x); }
    inline function addToOverlayLive(x:FlxBasic)         { PlayState.instance.overlayLayer.add(x); }
    inline function removeFromOverlayLive(x:FlxBasic)    { PlayState.instance.overlayLayer.remove(x); }
    inline function addToHudLive(x:FlxBasic)             { PlayState.instance.hudLayer.add(x); }
    inline function removeHudLive(x:FlxBasic)            { PlayState.instance.hudLayer.remove(x); }

    public function toString():String{ return "Stage: " + name; }
}