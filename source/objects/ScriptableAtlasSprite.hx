package objects;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedAtlasSprite extends AtlasSprite{}

@:hscriptClass
class ScriptableAtlasSprite extends AtlasSprite implements polymod.hscript.HScriptedClass{}