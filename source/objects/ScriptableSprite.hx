package objects;

import flixel.FlxSprite;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedSprite extends FlxSprite{}

@:hscriptClass
class ScriptableSprite extends FlxSprite implements polymod.hscript.HScriptedClass{}