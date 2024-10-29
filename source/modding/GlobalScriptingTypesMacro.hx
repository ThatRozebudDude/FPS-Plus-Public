package modding;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
/*
*   A class that automatically adds a bunch useful variables and functions to scriptable classes so they don't have to be repeated across each class.
*/
class GlobalScriptingTypesMacro
{

    public static function build():Array<Field>{

        var cls:ClassType = Context.getLocalClass().get();
        var fields:Array<Field> = Context.getBuildFields();
        var pos:Position = Context.currentPos();

        var fieldsToAdd:Array<Field> = [];

        trace("Applying scripting types to " + cls.name);

        fieldsToAdd.push({
            name: "boyfriend",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Character)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_boyfriend",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return PlayState.instance.boyfriend,
                ret: (macro:Character),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "dad",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Character)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_dad",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return PlayState.instance.dad,
                ret: (macro:Character),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "gf",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Character)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_gf",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return PlayState.instance.gf,
                ret: (macro:Character),
                args:[]
            }),
            pos: pos,
        });
        
        fieldsToAdd.push({
            name: "playstate",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:PlayState)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_playstate",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return PlayState.instance,
                ret: (macro:PlayState),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "tween",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:flixel.tweens.FlxTween.FlxTweenManager)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_tween",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return PlayState.instance.tweenManager,
                ret: (macro:flixel.tweens.FlxTween.FlxTweenManager),
                args:[]
            }),
            pos: pos,
        });
        
        fieldsToAdd.push({
            name: "data",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Map<String, Dynamic>)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_data",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return PlayState.instance.arbitraryData,
                ret: (macro:Map<String, Dynamic>),
                args:[]
            }),
            pos: pos,
        });
        
        fieldsToAdd.push({
            name: "gameover",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:GameOverSubstate)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_gameover",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return GameOverSubstate.instance,
                ret: (macro:GameOverSubstate),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "resultsScreen",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:results.ResultsState)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_resultsScreen",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return results.ResultsState.instance,
                ret: (macro:results.ResultsState),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "withDance",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_withDance",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 0,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "withSing",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_withSing",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 1,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "withPlayAnim",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_withPlayAnim",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 2,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "splitVocalTrack",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_splitVocalTrack",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 2,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "noVocalTrack",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_noVocalTrack",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 0,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "combinedVocalTrack",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_combinedVocalTrack",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 1,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "left",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_left",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 0,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "down",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_down",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 1,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "up",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_up",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 2,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        fieldsToAdd.push({
            name: "right",
            access: [Access.APublic],
            kind: FieldType.FProp("get", "null", (macro:Int)), 
            pos: pos,
        });

        fieldsToAdd.push({
            name: "get_right",
            access: [Access.APrivate, Access.AInline],
            kind: FieldType.FFun({ 
                expr: macro return 3,
                ret: (macro:Int),
                args:[]
            }),
            pos: pos,
        });

        for(field in fieldsToAdd){ fields.push(field); }

        return fields;
    }

}
#end