package stages;

//import flixel.FlxBasic;
import scripts.Script;
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

//@:build(modding.GlobalScriptingTypesMacro.build()) //Not needed since it inherits from Script.
class BaseStage extends Script
{

	public var name:String;
	public var startingZoom:Float = 1;
	public var uiType:String = "Default";

	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var events:Map<String, (String)->Void> = new Map<String, (String)->Void>();
	public var instantStart:Bool = false;

	public var backgroundElements:Array<Dynamic> = [];
	public var gfElements:Array<Dynamic> = [];
	public var middleElements:Array<Dynamic> = [];
	public var characterElements:Array<Dynamic> = [];
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

	public var cameraMovementEnabled:Bool = true;
	public var extraCameraMovementAmount:Null<Float> = null; //Leave null for PlayState default.
	public var cameraStartPosition:FlxPoint; //Leave null for PlayState default.
	public var globalCameraOffset:FlxPoint = new FlxPoint();
	public var bfCameraOffset:FlxPoint = new FlxPoint();
	public var dadCameraOffset:FlxPoint = new FlxPoint();
	public var gfCameraOffset:FlxPoint = new FlxPoint();

	public var useStaticStageCameras:Bool = false;
	public var staticBfCamera:FlxPoint = new FlxPoint(886.5, 560.5);
	public var staticDadCamera:FlxPoint = new FlxPoint(485, 367.5);
	public var staticGfCamera:FlxPoint = new FlxPoint(751.5, 458.5);

	public function new(){}

	/**
	 * Adds arbitrary info to the stage that can be read in PlayState.
	 *
	 * @param	k	A string key.
	 * @param	x	The dyanmic data.
	 */
	public function addExtraData(k:String, x:Dynamic){
		extraData.set(k, x);
	}

	/**
	 * Adds arbitrary info to the stage that can be read in PlayState.
	 *
	 * @param	name	The name of the event.
	 * @param	func	The function that gets called when the event is triggered. Must have no arguments and no return type.
	 */
	public function addEvent(name:String, func:(String)->Void){
		events.set(name, func);
	}

	/**
	 * Add any object that will up updated in the stage's update loop.
	 *
	 * @param	obj		The object that will be added to the update loop.
	 */
	public function addToUpdate(obj:FlxBasic){
		updateGroup.add(obj);
	}

	/**
	 * Remove an object from the stage's update loop.
	 *
	 * @param	obj		The object that will be added to the update loop.
	 */
	public function removeFromUpdate(obj:FlxBasic){
		updateGroup.remove(obj);
	}

	/**
	 * Destroys all objects added to the stage elements.
	 */
	public function destroyAll(){
		for(x in backgroundElements){ x.destroy(); }
		for(x in gfElements){ x.destroy(); }
		for(x in middleElements){ x.destroy(); }
		for(x in characterElements){ x.destroy(); }
		for(x in foregroundElements){ x.destroy(); }
		for(x in overlayElements){ x.destroy(); }
		for(x in hudElements){ x.destroy(); }
		backgroundElements = [];
		gfElements = [];
		middleElements = [];
		characterElements = [];
		foregroundElements = [];
		overlayElements = [];
		hudElements = [];
	}

	/**
	 * Called every frame in PlayState update before the normal update function to update everything in the update group.
	 * You probably shouldn't override this in a script.
	 *
	 * @param	elapsed		The elapsed time between previous frames passed in by PlayState.
	 */
	public function updateTheUpdateGroup(elapsed:Float){
		for(obj in updateGroup){
			obj.update(elapsed);
		}
	}

	override function addToBackground(x:FlxBasic)		{ if(PlayState.isInPlayState()){ PlayState.instance.backgroundLayer.add(x); } 	backgroundElements.push(x); }
	override function removeFromBackground(x:FlxBasic)	{ if(PlayState.isInPlayState()){ PlayState.instance.backgroundLayer.remove(x); } 	backgroundElements.remove(x); }
	override function addToGf(x:FlxBasic)				{ if(PlayState.isInPlayState()){ PlayState.instance.gfLayer.add(x); } 			gfElements.push(x); }
	override function removeFromGf(x:FlxBasic)			{ if(PlayState.isInPlayState()){ PlayState.instance.gfLayer.remove(x); } 			gfElements.remove(x); }
	override function addToMiddle(x:FlxBasic)			{ if(PlayState.isInPlayState()){ PlayState.instance.middleLayer.add(x); } 		middleElements.push(x); }
	override function removeFromMiddle(x:FlxBasic)		{ if(PlayState.isInPlayState()){ PlayState.instance.middleLayer.remove(x); } 		middleElements.remove(x); }
	override function addToCharacter(x:FlxBasic)		{ if(PlayState.isInPlayState()){ PlayState.instance.characterLayer.add(x); } 		characterElements.push(x); }
	override function removeFromCharacter(x:FlxBasic)	{ if(PlayState.isInPlayState()){ PlayState.instance.characterLayer.remove(x); } 	characterElements.remove(x); }
	override function addToForeground(x:FlxBasic)		{ if(PlayState.isInPlayState()){ PlayState.instance.foregroundLayer.add(x); } 	foregroundElements.push(x); }
	override function removeFromForeground(x:FlxBasic)	{ if(PlayState.isInPlayState()){ PlayState.instance.foregroundLayer.remove(x); } 	foregroundElements.remove(x); }
	override function addToOverlay(x:FlxBasic)			{ if(PlayState.isInPlayState()){ PlayState.instance.overlayLayer.add(x); } 		overlayElements.push(x); }
	override function removeFromOverlay(x:FlxBasic)		{ if(PlayState.isInPlayState()){ PlayState.instance.overlayLayer.remove(x); } 	overlayElements.remove(x); }
	override function addToHud(x:FlxBasic)				{ if(PlayState.isInPlayState()){ PlayState.instance.hudLayer.add(x); } 			hudElements.push(x); }
	override function removeHud(x:FlxBasic)				{ if(PlayState.isInPlayState()){ PlayState.instance.hudLayer.remove(x); } 		hudElements.remove(x); }

	//Included for backwards compatibility.
	inline function addToBackgroundLive(x:FlxBasic)			{ addToBackground(x); }
	inline function removeFromBackgroundLive(x:FlxBasic)	{ removeFromBackground(x); }
	inline function addToGfLive(x:FlxBasic)					{ addToGf(x); }
	inline function removeFromGfLive(x:FlxBasic)			{ removeFromGf(x); }
	inline function addToMiddleLive(x:FlxBasic)				{ addToMiddle(x); }
	inline function removeFromMiddleLive(x:FlxBasic)		{ removeFromMiddle(x); }
	inline function addToCharacterLive(x:FlxBasic)			{ addToCharacter(x); }
	inline function removeFromCharacterLive(x:FlxBasic)		{ removeFromCharacter(x); }
	inline function addToForegroundLive(x:FlxBasic)			{ addToForeground(x); }
	inline function removeFromForegroundLive(x:FlxBasic)	{ removeFromForeground(x); }
	inline function addToOverlayLive(x:FlxBasic)			{ addToOverlay(x); }
	inline function removeFromOverlayLive(x:FlxBasic)		{ removeFromOverlay(x); }
	inline function addToHudLive(x:FlxBasic)				{ addToHud(x); }
	inline function removeHudLive(x:FlxBasic)				{ removeHud(x); }

	override public function toString():String{ return "Stage: " + name; }
}