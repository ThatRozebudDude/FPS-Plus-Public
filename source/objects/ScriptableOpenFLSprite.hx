package objects;

import openfl.display.Sprite;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedOpenFLSprite extends Sprite{}

@:hscriptClass
class ScriptableOpenFLSprite extends ScriptedOpenFLSprite implements polymod.hscript.HScriptedClass{}