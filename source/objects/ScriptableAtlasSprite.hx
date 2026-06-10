package objects;

import graphics.AtlasSprite;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedAtlasSprite extends AtlasSprite{}

@:hscriptClass
class ScriptableAtlasSprite extends AtlasSprite implements polymod.hscript.HScriptedClass{}