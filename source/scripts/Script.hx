package scripts;

import hscript.Parser;
import hscript.Interp;

using StringTools;

/**
	Enhanced Hscript Interpreter that supports importing Package, get Object from parent instance...
	@author Soushimiya
**/

class Script extends Interp
{
    public var parent:Dynamic;

    override public function new(path:String){
        super();
        setVariables();

        var parser = new Parser();
        parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
        
        var scriptToRun:String = "";
        //custom "parser" cuz i'm so lazy
        for (line in Utils.getTextInLines(path)){
            switch(line.split(" ")[0]){
                case "import":
                    importClass(line.split("import ")[1].split(";")[0]);
                    line = "//import " + line.split("import ")[1];
            }

            scriptToRun += line + "\n";
        }

        execute(parser.parseString(scriptToRun));
    }

    //call Function in Interp
    public function callFunc(func:String, ?args:Array<Dynamic>):Dynamic {
		if (variables.exists(func)) {
			if (args == null){ args = []; }

			try {
				return Reflect.callMethod(null, variables.get(func), args);
			}
			catch(e){
				trace(e.message);
            }
		}
		return null;
	}

    //import Class to Interp from String
    public function importClass(classPath:String) {
        var className:String = classPath.split(".")[classPath.split(".").length - 1];

        if (variables.exists(className)){
            trace(className + "already imported!");
            return;
        }

        variables.set(className, Type.resolveClass(classPath));
	}

    //import some default classes
    private function setVariables(){
        importClass("Paths");
        importClass("Character");
        importClass("Utils");
        importClass("Conductor");
        importClass("PlayState");
        importClass("Math");
        importClass("StringTools");

        variables.set('add', flixel.FlxG.state.add);
		variables.set('insert', flixel.FlxG.state.insert);
		variables.set('remove', flixel.FlxG.state.remove);
    }

    override public function resolve(id:String):Dynamic {
		if (parent != null) {
            var instanceFields = Type.getInstanceFields(Type.getClass(parent));
			// search in object
			if (id == "this"){ return parent; }
            if ((Type.typeof(parent) == TObject) && Reflect.hasField(parent, id)) {
				return Reflect.field(parent, id);
			}
			if (instanceFields.contains(id)) {
				return Reflect.getProperty(parent, id);
            }
		}

		return super.resolve(id);
	}
}