/****
* Copyright (c) 2013 Jason O'Neil
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
****/

package compiletime;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Format;
import haxe.Json;
#if yaml
import yaml.Yaml;
import yaml.Parser;
import yaml.Renderer;
import yaml.util.ObjectMap;
#end
using StringTools;
using Lambda;

class CompileTime
{
    /** Inserts a date object of the date and time that this was compiled */
    macro public static function buildDate():ExprOf<Date> {
        var date = Date.now();
        var year = toExpr(date.getFullYear());
        var month = toExpr(date.getMonth());
        var day = toExpr(date.getDate());
        var hours = toExpr(date.getHours());
        var mins = toExpr(date.getMinutes());
        var secs = toExpr(date.getSeconds());
        return macro new Date($year, $month, $day, $hours, $mins, $secs);
    }

    /** Returns a string of the date and time that this was compiled */
    macro public static function buildDateString():ExprOf<String> {
        return toExpr(Date.now().toString());
    }

    /** Returns a string of the current git sha1 */
    macro public static function buildGitCommitSha():ExprOf<String> {
        var proc = new sys.io.Process('git', ['log', "--pretty=format:'%h'", '-n', '1']);
        var sha1 = proc.stdout.readLine();
        return toExpr(sha1);
    }

    /** Reads a file at compile time, and inserts the contents into your code as a string.  The file path is resolved using `Context.resolvePath`, so it will search all your class paths */
    macro public static function readFile(path:String):ExprOf<String> {
        return toExpr(loadFileAsString(path));
    }

    /** Reads a file at compile time, and inserts the contents into your code as an interpolated string, similar to using 'single $quotes'.  */
    macro public static function interpolateFile(path:String):ExprOf<String> {
        return Format.format( toExpr(loadFileAsString(path)) );
    }

    /** Same as readFile, but checks that the file is valid Json */
    macro public static function readJsonFile(path:String):ExprOf<String> {
        var content = loadFileAsString(path);
        try Json.parse(content) catch (e:Dynamic) {
            haxe.macro.Context.error('Json from $path failed to validate: $e', Context.currentPos());
        }
        return toExpr(content);
    }

    /** Same as readFile, but checks that the file is valid Json */
    macro public static function parseJsonFile(path:String):ExprOf<{}> {
        var content = loadFileAsString(path);
        var obj = try Json.parse(content) catch (e:Dynamic) {
            haxe.macro.Context.error('Json from $path failed to validate: $e', Context.currentPos());
        }
        return toExpr(obj);
    }

    #if yaml
    macro public static function parseYamlFile(path:String) {
      var content = loadFileAsString(path);
      var data = Yaml.parse(content, Parser.options().useObjects());
      var s = haxe.Json.stringify(data);
      var json = haxe.Json.parse(s);
      return toExpr(json);
    }
    #end


    /** Same as readFile, but checks that the file is valid Xml */
    macro public static function readXmlFile(path:String):ExprOf<String> {
        var content = loadFileAsString(path);
        try Xml.parse(content) catch (e:Dynamic) {
            haxe.macro.Context.error('Xml from $path failed to validate: $e', Context.currentPos());
        }
        return toExpr(content);
    }

    #if markdown
        /** Same as readFile, but checks that the file is valid Xml */
        macro public static function readMarkdownFile(path:String):ExprOf<String> {
            var content = loadFileAsString(path);
            try {
                content = Markdown.markdownToHtml( content );
                Xml.parse(content);
            } catch (e:Dynamic) {
                haxe.macro.Context.error('Markdown from $path did not produce valid XML: $e', Context.currentPos());
            }
            return toExpr(content);
        }
    #end

    /** Import a package at compile time.  Is a simple mapping to haxe.macro.Compiler.include(), but means you don't have to wrap your code in conditionals. */
    macro public static function importPackage(path:String, ?recursive:Bool = true, ?ignore : Array<String>, ?classPaths : Array<String>) {
        haxe.macro.Compiler.include(path, recursive, ignore, classPaths);
        return toExpr(0);
    }

    /** Returns an Array of Classes.  By default it will return all classes, but you can also search for classes in a particular package,
    classes that extend a particular type, and you can choose whether to look for classes recursively or not. */
    macro public static function getAllClasses<T>(?inPackage:String, ?includeChildPackages:Bool = true, ?extendsBaseClass:ExprOf<Class<T>>):ExprOf<Iterable<Class<T>>> {

        // Add the onGenerate function to search for matching classes and add them to our metadata.
        // Make sure we run it once per-compile, not once per-controller-per-compile.
        // Also ensure that it is re-run for each new compile if using the compiler cache.
        #if (haxe_ver < 4.0)
        Context.onMacroContextReused(function () {
            allClassesSearches = new Map();
            return true;
        });
        #end
        if ( Lambda.count(allClassesSearches)==0 ) {
            Context.onGenerate(checkForMatchingClasses);
        }

        // Add the search to our static var so we can get results during onGenerate
        var baseClass:ClassType = getClassTypeFromExpr(extendsBaseClass);
        var baseClassName:String = (baseClass == null) ? "" : baseClass.pack.join('.') + '.' + baseClass.name;
        var listID = '$inPackage,$includeChildPackages,$baseClassName';
        allClassesSearches[listID] = {
            inPackage: inPackage,
            includeChildPackages: includeChildPackages,
            baseClass: baseClass
        };

        if (extendsBaseClass!=null)
            return macro CompileTimeClassList.getTyped($v{listID}, $extendsBaseClass);
        else
            return macro CompileTimeClassList.get($v{listID});
    }

    #if macro
        static function toExpr(v:Dynamic) {
            return Context.makeExpr(v, Context.currentPos());
        }

        static function loadFileAsString(path:String) {
            try {
                var p = Context.resolvePath(path);
                Context.registerModuleDependency(Context.getLocalModule(),p);
                return sys.io.File.getContent(p);
            }
            catch(e:Dynamic) {
                return haxe.macro.Context.error('Failed to load file $path: $e', Context.currentPos());
            }
        }

        static function isSameClass(a:ClassType, b:ClassType):Bool {
            return (
                a.pack.join(".") == b.pack.join(".")
                && a.name == b.name
            );
        }

        static function implementsInterface(cls:ClassType, interfaceToMatch:ClassType):Bool {
            while (cls!=null) {
                for ( i in cls.interfaces ) {
                    if (isSameClass(i.t.get(), interfaceToMatch)) {
                        return true;
                    }
                }
                if (cls.superClass!=null) {
                    cls = cls.superClass.t.get();
                }
                else cls = null;
            }
            return false;
        }

        static function isSubClassOfBaseClass(subClass:ClassType, baseClass:ClassType):Bool {
            var cls = subClass;
            while (cls.superClass != null)
            {
                cls = cls.superClass.t.get();
                if (isSameClass(baseClass, cls)) { return true; }
            }
            return false;
        }

        static function getClassTypeFromExpr(e:Expr):ClassType {
            var ct:ClassType = null;
            var fullClassName = null;
            var parts = new Array<String>();
            var nextSection = e.expr;
            while (nextSection != null) {
                // Break the loop unless we explicitly encounter a next section...
                var s = nextSection;
                nextSection = null;

                switch (s) {
                    // Might be a direct class name, no packages
                    case EConst(c):
                        switch (c) {
                            case CIdent(s):
                                if (s != "null") parts.unshift(s);
                            default:
                        }
                    // Might be a fully qualified package name
                    // { expr => EField({ expr => EField({ expr => EConst(CIdent(sys)), pos => #pos(src/server/Server.hx:35: characters 53-56) },db), pos => #pos(src/server/Server.hx:35: characters 53-59) },Object), pos => #pos(src/server/Server.hx:35: characters 53-66) }
                    case EField(e, field):
                        parts.unshift(field);
                        nextSection = e.expr;
                    default:
                }
            }
            fullClassName = parts.join(".");
            if (fullClassName != "") {
                switch (Context.follow(Context.getType(fullClassName))) {
                    case TInst(classType, _):
                        ct = classType.get();
                    default:
                        throw "Currently CompileTime.getAllClasses() can only search by package name or base class, not interface, typedef etc.";
                }
            }
            return ct;
        }

        static var allClassesSearches:Map<String,CompileTimeClassSearch> = new Map();
        static function checkForMatchingClasses(allTypes:Array<haxe.macro.Type>) {
            // Prepare a map to store our results.
            var getAllClassesResult:Map<String,Array<String>> = new Map();
            for (listID in allClassesSearches.keys()) {
                getAllClassesResult[listID] = [];
            }

            // Go through all the types and look for matches.
            for (type in allTypes) {
                switch type {
                    // We only care for Classes
                    case TInst(t, _):
                        var className = t.toString();
                        var classType = t.get();
                        if (t.get().isInterface==false) {
                            // Check if this class matches any of our searches.
                            for (listID in allClassesSearches.keys()) {
                                var search = allClassesSearches[listID];
                                if (classMatchesSearch(className,classType,search)) {
                                    getAllClassesResult[listID].push(className);
                                }
                            }
                        }
                    default:
                }
            }

            // Add the results to some metadata so it's available at runtime.
            switch (Context.getType("CompileTimeClassList")) {
                case TInst(classType, _):
                    var ct = classType.get();
                    // Get rid of any existing metadata (if using the compiler cache)
                    if (ct.meta.has('classLists'))
                        ct.meta.remove('classLists');
                    // Add the class names to CompileTimeClassList as metadata
                    var classListsMetaArray:Array<Expr> = [];
                    for (listID in getAllClassesResult.keys()) {
                        var classNames = getAllClassesResult[listID];
                        var itemAsArray = macro [$v{listID}, $v{classNames.join(",")}];
                        classListsMetaArray.push(itemAsArray);
                    }
                    ct.meta.add('classLists', classListsMetaArray, Context.currentPos());
                default:
            }

            return;
        }

        static function classMatchesSearch(className:String, classType:ClassType, search:CompileTimeClassSearch):Bool {
            // Check if it belongs to a certain package or subpackage
            if (search.inPackage != null) {
                if (search.includeChildPackages) {
                    if (className.startsWith(search.inPackage + ".") == false)
                        return false;
                }
                else {
                    var re = new EReg("^" + search.inPackage + "\\.([A-Z][a-zA-Z0-9]*)$", "");
                    if (re.match(className) == false)
                        return false;
                }
            }

            // Check if it is a subclass of a certain type
            if (search.baseClass != null) {
                if (search.baseClass.isInterface) {
                    if (implementsInterface(classType, search.baseClass) == false)
                        return false;
                }
                else {
                    if (isSubClassOfBaseClass(classType, search.baseClass) == false)
                        return false;
                }
            }

            return true;
        }
    #end
}

#if macro
    typedef CompileTimeClassSearch = {
        inPackage:String,
        includeChildPackages:Bool,
        baseClass:ClassType
    }
#end
