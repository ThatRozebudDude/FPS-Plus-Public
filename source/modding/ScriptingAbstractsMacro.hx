package modding;

import haxe.macro.Type.ClassType;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

import polymod.Polymod;
import restricted.RestrictedUtils;


using StringTools;

/*
	Haxe generates an implementation class for Abstract on compile.
	so, this macro will take advantage of that to create a small alias.

	@author Sulkiez
*/
class ScriptingAbstractsMacro
{
	public static var availableAbstracts(get, default):Array<String> = [];
	public static function get_availableAbstracts()
	{
		var ar:Array<String> = restricted.RestrictedUtils.callStaticGeneratedMethod(Type.resolveClass("modding.AbstractLists"), "get");
		var newAr:Array<String> = [];

		for (al in ar){
			var packageArray:Array<String> = al.split(".");
			// package name is fucking broken to me some reason so im trying fix them
			for (pack in packageArray){
				if (packageArray[packageArray.length - 1] == packageArray[packageArray.length - 2])
				{
					packageArray.pop();
				}
			}
			newAr.push(packageArray.join("."));
		}
		return newAr;
	}
	
	public static function addAbstractAliases()
	{
		for (alias in availableAbstracts)
		{
			Polymod.addImportAlias(alias, Type.resolveClass(alias + '_AL'));
		}
	}

	#if macro
	public static final excludeAbstracts:Array<String> = [
		"haxe.macro"
    ];


	// fuck macro
	private static var builtAlready:Bool = false;

	public static function buildCompileMacro(){
		#if !display
		for (pack in ["flash", "openfl", "flixel"])
		{
			Compiler.addGlobalMetadata(pack, '@:build(modding.ScriptingAbstractsMacro.build())');
		}
		#end

		Context.onAfterTyping(function(a)
		{
			if (builtAlready)
				return;
			builtAlready = true;

			Context.defineModule('modding.AbstractLists', [{
				pack: ['modding'],
				name: 'AbstractLists',
				kind: TypeDefKind.TDClass(null, [], false, false, false),
				fields: [
					{
						name: 'get',
						access: [Access.APublic, Access.AStatic],
						kind: FieldType.FFun({
							args: [],
							ret: (macro :Array<String>),
							expr: macro {
								return $v{aliasesList};
							}
						}),
						pos: Context.currentPos()
					}
				],
				pos: Context.currentPos()
			}]);
		});
	}

	public static var aliasesList:Array<String> = [];

	public static function build():Array<Field>{
        var fields:Array<Field> = Context.getBuildFields();

        if (Context.getLocalClass() == null){
            return fields;
        }
        var cls:ClassType = Context.getLocalClass().get();

        if (!cls.name.endsWith("_Impl_") || cls.meta.has(":multiType") || cls.name.contains("_AL")){
            return fields;
        }

        var abstractName:String = cls.name.split("_Impl_")[0];
        if (excludeAbstracts.contains(cls.module) || excludeAbstracts.contains(cls.module + "." + abstractName)){
            return fields;
        };

        var alias = macro class {};
        alias.kind = TDClass();
        alias.params = [
            for(num => entry in cls.params){
                name: "T" + Std.int(num + 1)
            }
        ];
        alias.name = abstractName + "_AL";

		aliasesList.push(cls.module + "." + abstractName);

        for(field in fields){
				switch(field.kind){
					case FVar(t, e):
						if (field.access.contains(AStatic) || field.name.toUpperCase() == field.name){
							var name:String = field.name;
							var packageArray:Array<String> = cls.module.split(".");

							if(packageArray[packageArray.length - 1] == abstractName)
								packageArray.pop();

							if(t == null && e != null){
								t = switch(e.expr){
									case EConst(CRegexp(_)): TPath({ name: "EReg", pack: [] });

									default: null;
								}
							}
							if(t == null){
								t = TPath({
									name: abstractName,
									pack: []
								});
							}

							var field:Field = {
								pos: field.pos,
								name: field.name,
								meta: field.meta,
								kind: FVar(null, Context.parse('@:privateAccess ($abstractName.$name)', field.pos)),
								doc: field.doc,
								access: [APublic, AStatic]
							}

							alias.fields.push(field);
                        }
					case FFun(func):
						if (field.access.contains(AStatic)){
							if (func.expr != null){
								func.expr = macro @:privateAccess $e{func.expr};
								alias.fields.push(field);
							}
						}
					case FProp(get, set, t, e):
						if (get == "default" && (set == "never" || set == "null")){
							alias.fields.push(field);
						}
					default:
				}
		}

        Context.defineModule(cls.module, [alias], Context.getLocalImports());

        return fields;
	}
    #end
}