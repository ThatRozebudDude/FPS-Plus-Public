package;

import flixel.input.gamepad.FlxGamepadInputID;
import haxe.ds.StringMap;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Binds
{

    public static var binds:KeybindMap;

    public static function init() {

        binds = new KeybindMap();

        SaveManager.global();

        //Key binds
        if(FlxG.save.data.binds == null){
            binds = generateDefaultControls();
            FlxG.save.data.binds = binds;
            SaveManager.flush();
        }
        else{
            binds = FlxG.save.data.binds;
            if(binds.length() != generateDefaultControls().length()){
                binds = repairControls();
                FlxG.save.data.binds = binds;
                SaveManager.flush();
            }
        }

        trace(binds);

    }

    static public function generateDefaultControls():KeybindMap {
        var r:KeybindMap = new KeybindMap();

        //Gameplay buttons
        var k:Keybind = {
            name: "Left Note",
            category: "Gameplay",
            binds: [A, LEFT]
        };
        r.set("gameplayLeft", k);

        var k:Keybind = {
            name: "Down Note",
            category: "Gameplay",
            binds: [S, DOWN]
        };
        r.set("gameplayDown", k);

        var k:Keybind = {
            name: "Up Note",
            category: "Gameplay",
            binds: [W, UP]
        };
        r.set("gameplayUp", k);

        var k:Keybind = {
            name: "Right Note",
            category: "Gameplay",
            binds: [D, RIGHT]
        };
        r.set("gameplayRight", k);

        var k:Keybind = {
            name: "Pause",
            category: "Gameplay",
            binds: [ESCAPE, ENTER]
        };
        r.set("pause", k);

        var k:Keybind = {
            name: "Reset",
            category: "Gameplay",
            binds: [R]
        };
        r.set("killbind", k);



        //Menu buttons
        var k:Keybind = {
            name: "Up",
            category: "Menu",
            binds: [W, UP]
        };
        r.set("menuUp", k);

        var k:Keybind = {
            name: "Down",
            category: "Menu",
            binds: [S, DOWN]
        };
        r.set("menuDown", k);

        var k:Keybind = {
            name: "Left",
            category: "Menu",
            binds: [A, LEFT]
        };
        r.set("menuLeft", k);

        var k:Keybind = {
            name: "Right",
            category: "Menu",
            binds: [D, RIGHT]
        };
        r.set("menuRight", k);

        var k:Keybind = {
            name: "Accept",
            category: "Menu",
            binds: [ENTER, SPACE]
        };
        r.set("menuAccept", k);

        var k:Keybind = {
            name: "Back",
            category: "Menu",
            binds: [ESCAPE, BACKSPACE]
        };
        r.set("menuBack", k);



        return r;
    }

    static public function saveControls() {
        SaveManager.global();
        FlxG.save.data.binds = binds;
        SaveManager.flush();
    }

    static public function repairControls():KeybindMap {
        var r:KeybindMap = generateDefaultControls();

        for(x in r.keys){
            if(binds.exists(x)){
                var k:Keybind = {
                    name: r.get(x).name,
                    category: r.get(x).category,
                    binds: binds.get(x).binds
                };
                r.set(x, k);
            }
        }

        return r;
    }

    inline static public function pressed(input:String){
        return FlxG.keys.anyPressed(binds.get(input).binds);
    }

    inline static public function justPressed(input:String){
        return FlxG.keys.anyJustPressed(binds.get(input).binds);
    }

    inline static public function justReleased(input:String){
        return FlxG.keys.anyJustReleased(binds.get(input).binds);
    }
    
}

/*class KeybindMap extends StringMap<Keybind>
{

    public var keyOrder:Array<String> = [];

    override public function set(key:String, value:Keybind):Void {
        if(!keyOrder.contains(key)){
            keyOrder.push(key);
        }
        super.set(key, value);
    }

    override public function remove(key:String):Bool {
        keyOrder.remove(key);
        return super.remove(key);
    }

    override public function clear():Void {
        keyOrder = [];
        super.clear();
    }

}*/

class KeybindMap
{

    public var keys:Array<String> = [];
    public var binds:Array<Keybind> = [];

    public function new() {
        
    }

    public function set(key:String, value:Keybind, ?index:Int = -1):Void {
        if(!keys.contains(key)){
            if(index < 0){
                keys.push(key);
                binds.push(value);
            }
            else{
                keys.insert(index, key);
                binds.insert(index, value);
            }
        }
        else{
            var i = keys.indexOf(key);
            binds[i] = value;
        }
    }

    public function get(key:String):Keybind {
        var i = keys.indexOf(key);
        return binds[i];
    }

    public function remove(key:String):Void {
        var i = keys.indexOf(key);
        binds.remove(binds[i]);
        keys.remove(key);
    }

    public function clear():Void {
        keys = [];
        binds = [];
    }

    public function exists(key:String):Bool {
        return keys.contains(key);
    }

    public function length():Int {
        return keys.length;
    }

}

typedef Keybind = {
    var name:String;
    var category:String;
    var binds:Array<FlxKey>;
}