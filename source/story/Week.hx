package story;

/**
	This is the base class for making story week. When making your own week make a new class extending this one.    
	@author Soushimiya
**/
class Week
{
    public var name:String;                                     //Name that will appear in the story menu and results screen.
    public var id:String;                                       //Internal name that will be used by the save file and week name image.
    public var sortOrder:Float = 1000;                          //Determines where in the story mode list the week appears.
    public var songs:Array<String> = [];                        //Name of the songs used in the week.
    public var characters:Array<String> = ["dad", "bf", "gf"];  //Characters that show up in the story menu.
    public var stickerSet:Array<String> = null;                 //The set of stickers to use when returning to the story menu.
    public var color:Int = 0xFFF9CF51;                        //The color that the story menu is set to when selecting the week.

    public function create(){}

    public function toString():String{ return id + ": " + name; }
}

@:hscriptClass
class ScriptableWeek extends Week implements polymod.hscript.HScriptedClass{}