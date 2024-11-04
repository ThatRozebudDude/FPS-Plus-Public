package objects;

import flixel.FlxObject;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedObject extends FlxObject{}

@:hscriptClass
class ScriptableObject extends ScriptedObject implements polymod.hscript.HScriptedClass{}