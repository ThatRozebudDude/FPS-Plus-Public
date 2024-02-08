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
            if(checkForRepair()){
                binds = repairControls();
                FlxG.save.data.binds = binds;
                SaveManager.flush();
            }
        }

    }

    static public function generateDefaultControls():KeybindMap {
        var r:KeybindMap = new KeybindMap();

        //Gameplay buttons
        var k:Keybind = {
            name: "Left Note",
            category: "Gameplay",
            binds: [LEFT, A],
            controllerBinds: [DPAD_LEFT, X]
        };
        r.set("gameplayLeft", k);

        var k:Keybind = {
            name: "Down Note",
            category: "Gameplay",
            binds: [DOWN, S],
            controllerBinds: [DPAD_DOWN, A]
        };
        r.set("gameplayDown", k);

        var k:Keybind = {
            name: "Up Note",
            category: "Gameplay",
            binds: [UP, W],
            controllerBinds: [DPAD_UP, Y]
        };
        r.set("gameplayUp", k);

        var k:Keybind = {
            name: "Right Note",
            category: "Gameplay",
            binds: [RIGHT, D],
            controllerBinds: [DPAD_RIGHT, B]
        };
        r.set("gameplayRight", k);

        var k:Keybind = {
            name: "Pause",
            category: "Gameplay",
            binds: [ESCAPE, ENTER],
            controllerBinds: [START]
        };
        r.set("pause", k);

        var k:Keybind = {
            name: "Die",
            category: "Gameplay",
            binds: [R],
            controllerBinds: [BACK]
        };
        r.set("killbind", k);



        //Menu buttons
        var k:Keybind = {
            name: "Up",
            category: "Menu",
            binds: [UP, W],
            controllerBinds: [DPAD_UP, LEFT_STICK_DIGITAL_UP]
        };
        r.set("menuUp", k);

        var k:Keybind = {
            name: "Down",
            category: "Menu",
            binds: [DOWN, S],
            controllerBinds: [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]
        };
        r.set("menuDown", k);

        var k:Keybind = {
            name: "Left",
            category: "Menu",
            binds: [LEFT, A],
            controllerBinds: [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]
        };
        r.set("menuLeft", k);

        var k:Keybind = {
            name: "Right",
            category: "Menu",
            binds: [RIGHT, D],
            controllerBinds: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]
        };
        r.set("menuRight", k);

        var k:Keybind = {
            name: "Accept",
            category: "Menu",
            binds: [ENTER, SPACE],
            controllerBinds: [A, START]
        };
        r.set("menuAccept", k);

        var k:Keybind = {
            name: "Back",
            category: "Menu",
            binds: [ESCAPE, BACKSPACE],
            controllerBinds: [B]
        };
        r.set("menuBack", k);



        return r;
    }

    static public function saveControls() {
        SaveManager.global();
        FlxG.save.data.binds = binds;
        SaveManager.flush();
    }

    static function checkForRepair():Bool {
        
        var defaultThing = generateDefaultControls();

        var r = (binds.length() != defaultThing.length());

        if(!r){
            for(i in 0...binds.binds.length){
                if(binds.binds[i].name != defaultThing.binds[i].name){
                    r = true;
                    break;
                }
            }
        }

        return r;

    }

    static public function repairControls():KeybindMap {
        var r:KeybindMap = generateDefaultControls();

        for(x in r.keys){
            if(binds.exists(x)){
                var k:Keybind = {
                    name: r.get(x).name,
                    category: r.get(x).category,
                    binds: binds.get(x).binds,
                    controllerBinds: binds.get(x).controllerBinds
                };
                r.set(x, k);
            }
        }

        return r;
    }

    static public function resetToDefaultControls() {
        SaveManager.global();
        binds = generateDefaultControls();
        FlxG.save.data.binds = binds;
        SaveManager.flush();
    }

    inline static public function pressed(input:String){
        return pressedKeyboardOnly(input) || pressedControllerOnly(input);
    }

    inline static public function justPressed(input:String){
        return justPressedKeyboardOnly(input) || justPressedControllerOnly(input);
    }

    inline static public function justReleased(input:String){
        return justReleasedKeyboardOnly(input) || justReleasedControllerOnly(input);
    }

    inline static public function pressedKeyboardOnly(input:String){
        return FlxG.keys.anyPressed(binds.get(input).binds);
    }

    inline static public function justPressedKeyboardOnly(input:String){
        return FlxG.keys.anyJustPressed(binds.get(input).binds);
    }

    inline static public function justReleasedKeyboardOnly(input:String){
        return FlxG.keys.anyJustReleased(binds.get(input).binds);
    }

    inline static public function pressedControllerOnly(input:String){
        var r:Bool = false;
        for(x in binds.get(input).controllerBinds){
            r = FlxG.gamepads.anyPressed(x);
            if(r){ break; }
        }
        return r;
    }

    inline static public function justPressedControllerOnly(input:String){
        var r:Bool = false;
        for(x in binds.get(input).controllerBinds){
            r = FlxG.gamepads.anyJustPressed(x);
            if(r){
                break; }
        }
        return r;
    }

    inline static public function justReleasedControllerOnly(input:String){
        var r:Bool = false;
        for(x in binds.get(input).controllerBinds){
            r = FlxG.gamepads.anyJustReleased(x);
            if(r){ break; }
        }
        return r;
    }
    
}

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
    var controllerBinds:Array<FlxGamepadInputID>;
}