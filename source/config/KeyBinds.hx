package config;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{

    public static function resetBinds():Void{

        FlxG.save.data.upBind = "W";
        FlxG.save.data.downBind = "S";
        FlxG.save.data.leftBind = "A";
        FlxG.save.data.rightBind = "D";
        FlxG.save.data.killBind = "R";

        FlxG.save.data.upBindController = "Y";
        FlxG.save.data.downBindController = "A";
        FlxG.save.data.leftBindController = "X";
        FlxG.save.data.rightBindController = "B";

        PlayerSettings.player1.controls.loadKeyBinds();

	}

    public static function keyCheck():Void
    {
        //Keyboard stuff
        if(FlxG.save.data.upBind == null){
            FlxG.save.data.upBind = "W";
            trace("No UP");
        }
        if(FlxG.save.data.downBind == null){
            FlxG.save.data.downBind = "S";
            trace("No DOWN");
        }
        if(FlxG.save.data.leftBind == null){
            FlxG.save.data.leftBind = "A";
            trace("No LEFT");
        }
        if(FlxG.save.data.rightBind == null){
            FlxG.save.data.rightBind = "D";
            trace("No RIGHT");
        }
        if(FlxG.save.data.killBind == null){
            FlxG.save.data.killBind = "R";
            trace("No KILL");
        }
        
        //Controller stuff
        if(FlxG.save.data.upBindController == null){
            FlxG.save.data.upBindController = "Y";
            trace("No Controller UP");
        }
        if(FlxG.save.data.downBindController == null){
            FlxG.save.data.downBindController = "A";
            trace("No Controller DOWN");
        }
        if(FlxG.save.data.leftBindController == null){
            FlxG.save.data.leftBindController = "X";
            trace("No Controller LEFT");
        }
        if(FlxG.save.data.rightBindController == null){
            FlxG.save.data.rightBindController = "B";
            trace("No Controller RIGHT");
        }
    }

}