package stages;

//import flixel.FlxBasic;
import flixel.math.FlxPoint;

/**
	This is the base class for stages. 
	When making your own stage make a new class extending this one.    
	@author Rozebud
**/

class BasicStage
{

    public var name:String;
    public var startingZoom:Float = 1.05;
    public var uiType:String = "default";
    public var cameraMovementEnabled:Bool = true;
    public var cameraStartPosition:FlxPoint; //Leave null for PlayState default.

    public var backgroundElements:Array<Dynamic> = [];
    public var middleElements:Array<Dynamic> = [];
    public var foregroundElements:Array<Dynamic> = [];

    var boyfriend:Character;
    var gf:Character;
    var dad:Character;

    /**
	 * Do not override this function, override `init()` instead.
	 *
	 * @param   _bf  Reference to the PlayState's boyfriend.
	 * @param   _gf  Reference to the PlayState's gf.
	 * @param   _dad  Reference to the PlayState's dad.
	 */
    public function new(_bf:Character, _gf:Character, _dad:Character){
        boyfriend = _bf;
        gf = _gf;
        dad = _dad;
        init();
    }

    /**
	 * Override this function to initialize all of your stage elements.
	 */
    function init(){}


    /**
	 * Adds an object to `backgroundElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToBackground(x:Dynamic){
        backgroundElements.push(x);
    }

    /**
	 * Adds an object to `middleElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToMiddle(x:Dynamic){
        middleElements.push(x);
    }

    /**
	 * Adds an object to `foregroundElements` to be added to PlayState.
	 *
	 * @param   x  The object to add. Should be any type that can be added to a state.
	 */
    public function addToForeground(x:Dynamic){
        foregroundElements.push(x);
    }

    /**
	 * Destroys all objects added to the stage elements.
	 */
    public function destroyAll(){
        for(x in backgroundElements){ x.destroy(); }
        for(x in middleElements){ x.destroy(); }
        for(x in foregroundElements){ x.destroy(); }
    }


    /**
	 * Called every frame in PlayState update.
	 */
    public function update(elpased:Float){}

    /**
	 * Called every beat hit in PlayState.
	 */
    public function beat(curBeat:Int){}

    /**
	 * Called every step hit in PlayState.
	 */
    public function step(curStep:Int){}

}