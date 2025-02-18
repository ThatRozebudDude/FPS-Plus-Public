package scripts;

import haxe.macro.Type.ClassType;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;


using StringTools;

/*
	Haxe generates an implementation class for Abstract on compile.
	so, this macro will take advantage of that to create a small alias.

	@author Sulkiez
*/
class ScriptAbstractMacro
{
	public static var availableAbstracts(get, default):Array<String> = [];
	public static function get_availableAbstracts()
	{
		return restricted.RestrictedUtils.callStaticGeneratedMethod(Type.resolveClass("scripts.ListGetter"), "getList");
	}

	#if macro
	public static final excludeAbstracts:Array<String> = [

    ];
	
	public static function buildCompileMacro(){
		#if !display
		for (pack in ["flash", "openfl", "flixel"])
		{
			Compiler.addGlobalMetadata(pack, '@:build(scripts.ScriptAbstractMacro.build())');
		}

		Context.defineModule('scripts.ScriptAbstractMacro', [{
			pack: ['scripts'],
			name: 'ListGetter',
			kind: TypeDefKind.TDClass(null, [], false, false, false),
			fields: [
				{
					name: 'getList',
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
		#end
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
									pack: [],//pack
								});
							}

							var prvAcc = Context.parse('@:privateAccess ($abstractName.$name)', field.pos);

							var field:Field = {
								pos: field.pos,
								name: field.name,
								meta: field.meta,
								kind: FVar(null, prvAcc),
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