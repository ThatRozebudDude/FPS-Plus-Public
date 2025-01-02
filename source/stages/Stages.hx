package stages;

//import flixel.FlxBasic;
import note.Note;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import scripts.Script;

/**
	This is the base class for stages. When making your own stage make a new class extending this one.    
	@author Rozebud
**/

class Stages extends Script
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
	 * Called every frame in PlayState update.
	 * Don't forget to call `super.update(elasped)` or the update group won't be updated.
     *
     * @param   elpased  The elapsed time between previous frames passed in by PlayState.
	 */
    override public function update(elapsed:Float){
        for(obj in updateGroup){
            obj.update(elapsed);
        }
    }
    //Aliases for intuitive stage creation.
    override function add(x:FlxBasic)         { addToBackground(x); }
    override function remove(x:FlxBasic)         { removeFromBackground(x); }

    //These functions are Deprecated! Use the function as in the base script!!
    inline function addToBackgroundLive(x:FlxBasic){
        trace("addToBackgroundLive is deprecated, use addToBackground or add");
        addToBackground(x);
    }
    inline function removeFromBackgroundLive(x:FlxBasic){
        trace("removeFromBackgroundLive is deprecated, use removeFromBackground or remove");
        removeFromBackground(x);
    }
    inline function addToGfLive(x:FlxBasic){
        trace("addToGfLive is deprecated, use addToGf");
        addToGf(x);
    }
    inline function removeFromGfLive(x:FlxBasic){
        trace("removeFromGfLive is deprecated, use removeFromGf");
        removeFromGf(x);
    }
    inline function addToMiddleLive(x:FlxBasic){
        trace("addToMiddleLive is deprecated, use addToMiddle");
        addToMiddle(x);
    }
    inline function removeFromMiddleLive(x:FlxBasic){
        trace("removeFromMiddleLive is deprecated, use removeFromMiddle");
        removeFromMiddle(x);
    }
    inline function addToCharacterLive(x:FlxBasic){
        trace("addToCharacterLive is deprecated, use addToCharacter");
        addToCharacterLive(x);
    }
    inline function removeFromCharacterLive(x:FlxBasic){
        trace("removeFromCharacterLive is deprecated, use removeFromCharacter");
        removeFromCharacter(x);
    }
    inline function addToForegroundLive(x:FlxBasic){
        trace("addToForegroundLive is deprecated, use addToForeground");
        addToForeground(x);
    }
    inline function removeFromForegroundLive(x:FlxBasic){
        trace("removeFromForegroundLive is deprecated, use removeFromForeground");
        removeFromForeground(x);
    }
    inline function addToOverlayLive(x:FlxBasic){
        trace("addToOverlayLive is deprecated, use addToOverlay");
        addToOverlay(x);
    }
    inline function removeFromOverlayLive(x:FlxBasic){
        trace("removeFromOverlayLive is deprecated, use removeFromOverlay");
        removeFromOverlay(x);
    }
    inline function addToHudLive(x:FlxBasic){
        trace("addToHudLive is deprecated, use addToHud");
        addToHud(x);
    }
    inline function removeHudLive(x:FlxBasic){
        trace("removeHudLive is deprecated, use removeHud");
        removeHud(x);
    }

    override public function toString():String{ return "Stage: " + name; }
}