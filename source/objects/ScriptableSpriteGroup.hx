package objects;

import flixel.group.FlxSpriteGroup;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedSpriteGroup extends FlxSpriteGroup{}

@:hscriptClass
class ScriptableSpriteGroup extends ScriptedSpriteGroup implements polymod.hscript.HScriptedClass{}