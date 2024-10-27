package;
/**
	This is the base class for making story week. When making your own week make a new class extending this one.    
	@author Rozebud
**/
class Week
{
    public var name:String = "Tutorial";
    public var short:String = "";
    public var songs:Array<String> = ['Tutorial'];
    public var characters:Array<String> = ['dad', 'bf', 'gf'];
    public var unlocked:Bool = true;

    public function create(){}

    public function toString():String{ return "Week"; }
}

@:hscriptClass
class ScriptableWeek extends Week implements polymod.hscript.HScriptedClass{}