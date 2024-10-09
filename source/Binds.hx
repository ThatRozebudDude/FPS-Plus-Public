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
            saveControls();
        }
        else{
            setControls();
            if(checkForRepair()){
                binds = repairControls();
                saveControls();
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
            controllerBinds: [DPAD_LEFT, X],
            local: false
        };
        r.set("gameplayLeft", k);

        var k:Keybind = {
            name: "Down Note",
            category: "Gameplay",
            binds: [DOWN, S],
            controllerBinds: [DPAD_DOWN, A],
            local: false
        };
        r.set("gameplayDown", k);

        var k:Keybind = {
            name: "Up Note",
            category: "Gameplay",
            binds: [UP, W],
            controllerBinds: [DPAD_UP, Y],
            local: false
        };
        r.set("gameplayUp", k);

        var k:Keybind = {
            name: "Right Note",
            category: "Gameplay",
            binds: [RIGHT, D],
            controllerBinds: [DPAD_RIGHT, B],
            local: false
        };
        r.set("gameplayRight", k);

        var k:Keybind = {
            name: "Pause",
            category: "Gameplay",
            binds: [ESCAPE, ENTER],
            controllerBinds: [START],
            local: false
        };
        r.set("pause", k);

        var k:Keybind = {
            name: "Die",
            category: "Gameplay",
            binds: [R],
            controllerBinds: [BACK],
            local: false
        };
        r.set("killbind", k);



        //Menu buttons
        var k:Keybind = {
            name: "Up",
            category: "Menu",
            binds: [UP, W],
            controllerBinds: [DPAD_UP, LEFT_STICK_DIGITAL_UP],
            local: false
        };
        r.set("menuUp", k);

        var k:Keybind = {
            name: "Down",
            category: "Menu",
            binds: [DOWN, S],
            controllerBinds: [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
            local: false
        };
        r.set("menuDown", k);

        var k:Keybind = {
            name: "Left",
            category: "Menu",
            binds: [LEFT, A],
            controllerBinds: [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
            local: false
        };
        r.set("menuLeft", k);

        var k:Keybind = {
            name: "Right",
            category: "Menu",
            binds: [RIGHT, D],
            controllerBinds: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
            local: false
        };
        r.set("menuRight", k);

        var k:Keybind = {
            name: "Accept",
            category: "Menu",
            binds: [ENTER, SPACE],
            controllerBinds: [A, START],
            local: false
        };
        r.set("menuAccept", k);

        var k:Keybind = {
            name: "Back",
            category: "Menu",
            binds: [ESCAPE, BACKSPACE],
            controllerBinds: [B],
            local: false
        };
        r.set("menuBack", k);

        var k:Keybind = {
            name: "Cycle Left",
            category: "Menu",
            binds: [Q],
            controllerBinds: [LEFT_SHOULDER],
            local: false
        };
        r.set("menuCycleLeft", k);

        var k:Keybind = {
            name: "Cycle Right",
            category: "Menu",
            binds: [E],
            controllerBinds: [RIGHT_SHOULDER],
            local: false
        };
        r.set("menuCycleRight", k);

        var k:Keybind = {
            name: "Change Character",
            category: "Menu",
            binds: [TAB],
            controllerBinds: [Y],
            local: false
        };
        r.set("menuChangeCharacter", k);



        return r;
    }

    static public function setControls():Void{
        binds.clear();

        SaveManager.global();
        for(key in cast(FlxG.save.data.binds, KeybindMap).keys){
            binds.set(key, FlxG.save.data.binds.get(key));
        }

        SaveManager.modSpecific();
        if(FlxG.save.data.binds != null){
            for(key in cast(FlxG.save.data.binds, KeybindMap).keys){
                binds.set(key, FlxG.save.data.binds.get(key));
            }
        }

        SaveManager.global();
    }

    static public function saveControls():Void{
        var g:KeybindMap = new KeybindMap();
        var l:KeybindMap = new KeybindMap();

        for(key in binds.keys){
            if(binds.get(key).local){
                l.set(key, binds.get(key));
            }
            else{
                g.set(key, binds.get(key));
            }
        }

        SaveManager.global();
        FlxG.save.data.binds = g;
        SaveManager.flush();

        SaveManager.modSpecific();
        FlxG.save.data.binds = l;
        SaveManager.flush();

        SaveManager.global();
    }

    static function checkForRepair():Bool {
        
        var defaultThing = generateDefaultControls();

        var r = (binds.length() != defaultThing.length());

        if(!r){
            for(i in 0...binds.binds.length){
                if(binds.binds[i].name != defaultThing.binds[i].name || 
                   binds.binds[i].category != defaultThing.binds[i].category || 
                   binds.binds[i].local != defaultThing.binds[i].local){
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
                    controllerBinds: binds.get(x).controllerBinds,
                    local: r.get(x).local
                };
                r.set(x, k);
            }
        }

        return r;
    }

    static public function resetToDefaultControls() {
        binds = generateDefaultControls();
        saveControls();
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
    var name:String;                                //The name of the input in the config menu.
    var category:String;                            //The category of the input in the config menu.
    var binds:Array<FlxKey>;                        //The default keyboard keys of input.
    var controllerBinds:Array<FlxGamepadInputID>;   //The default controller buttons of input.
    var local:Bool;                                 //Whether the input is global (false) or mod specific (true). If you need to add extra keys that are only for a mod, make this true.
}