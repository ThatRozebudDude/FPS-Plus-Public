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

class BaseStage extends Script
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

    override public function toString():String{ return "Stage: " + name; }
}