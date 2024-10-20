package events.data;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class CameraEvents extends Events
{

    override function defineEvents() {
        addEvent("camMove", camMove);
        addEvent("camZoom", camZoom);
        
        addEvent("flash", flash);
        addEvent("flashHud", flashHud);
        addEvent("fadeOut", fadeOut);
        addEvent("fadeOutHud", fadeOutHud);
        
        addEvent("camShake", camShake);
        addEvent("startCamShake", startCamShake);
        addEvent("endCamShake", endCamShake);
        
        addEvent("camFocusBf", camFocusBf);
        addEvent("camFocusDad", camFocusDad);
        addEvent("camFocusGf", camFocusGf);
        addEvent("camFocusCenter", camFocusCenter);
        
        addEvent("toggleCamBop", toggleCamBop);
        addEvent("toggleCamMovement", toggleCamMovement);
        
        addEvent("camBop", camBop);
        addEvent("camBopBig", camBopBig);
        addEvent("camBopFreq", camBopFreq);
        addEvent("camBopIntensity", camBopIntensity);
        
        addEvent("setDynamicCamAmount", setDynamicCamAmount);
    }

    function camMove(tag:String):Void{
        var args = Events.getArgs(tag);
		playstate.camMove(Std.parseFloat(args[0]), Std.parseFloat(args[1]), Events.eventConvertTime(args[2]), Events.easeNameToEase(args[3]), null);
    }

    function camZoom(tag:String):Void{
        var args = Events.getArgs(tag, [""+playstate.stage.startingZoom, "4b", "quadInOut", "false"]);
        var zoomLevel = Std.parseFloat(args[0]);
        if(Events.parseBool(args[3])){ zoomLevel *= playstate.stage.startingZoom; }
		playstate.camChangeZoom(zoomLevel, Events.eventConvertTime(args[1]), Events.easeNameToEase(args[2]), null);
    }

    function camBopFreq(tag:String):Void{
        var args = Events.getArgs(tag);
        playstate.camBopFrequency = Std.parseInt(args[0]);
    }
    
    function camBopIntensity(tag:String):Void{
        var args = Events.getArgs(tag);
        playstate.camBopIntensity = Std.parseFloat(args[0]);
    }

    function toggleCamBop(tag:String):Void{
        playstate.autoCamBop = !playstate.autoCamBop;
    }

    function toggleCamMovement(tag:String):Void{
        playstate.autoCam = !playstate.autoCam;
    }
    
    function camBop(tag:String):Void{
        playstate.uiBop(0.0175 * playstate.camBopIntensity, 0.03 * playstate.camBopIntensity, 0.8);
    }

    function camBopBig(tag:String):Void{
        playstate.uiBop(0.035 * playstate.camBopIntensity, 0.06 * playstate.camBopIntensity, 0.8);
    }

    function flash(tag:String):Void{
        var args = Events.getArgs(tag, ["1b", "0xFFFFFF"]);
		playstate.camGame.stopFX();
		playstate.camGame.fade(Std.parseInt(args[1]), Events.eventConvertTime(args[0]), true);
    }

    function flashHud(tag:String):Void{
        var args = Events.getArgs(tag, ["1b", "0xFFFFFF"]);
		playstate.camHUD.stopFX();
		playstate.camHUD.fade(Std.parseInt(args[1]), Events.eventConvertTime(args[0]), true);
    }

    function fadeOut(tag:String):Void{
        var args = Events.getArgs(tag, ["1b", "0x000000"]);
		playstate.camGame.stopFX();
		playstate.camGame.fade(Std.parseInt(args[1]), Events.eventConvertTime(args[0]));
    }

    function fadeOutHud(tag:String):Void{
        var args = Events.getArgs(tag, ["1b", "0x000000"]);
		playstate.camHUD.stopFX();
		playstate.camHUD.fade(Std.parseInt(args[1]), Events.eventConvertTime(args[0]));
    }

    function startCamShake(tag:String):Void{
        var args = Events.getArgs(tag, ["0.008", "0.042", "linear"]);
        playstate.startCamShake(Std.parseFloat(args[0]), Events.eventConvertTime(args[1]), Events.easeNameToEase(args[2]));
    }

    function endCamShake(tag:String):Void{
        var args = Events.getArgs(tag, ["0.042", "linear"]);
		playstate.endCamShake(Events.eventConvertTime(args[0]), Events.easeNameToEase(args[1]));
    }
    
    function camFocusBf(tag:String):Void{
        var args = Events.getArgs(tag, ["0", "0", "1.9", "expoOut"]);
        playstate.camFocusBF(Std.parseFloat(args[0]), Std.parseFloat(args[1]), Events.eventConvertTime(args[2]), Events.easeNameToEase(args[3]));
    }
    
    function camFocusDad(tag:String):Void{
        var args = Events.getArgs(tag, ["0", "0", "1.9", "expoOut"]);
        playstate.camFocusOpponent(Std.parseFloat(args[0]), Std.parseFloat(args[1]), Events.eventConvertTime(args[2]), Events.easeNameToEase(args[3]));
    }
    
    function camFocusGf(tag:String):Void{
        var args = Events.getArgs(tag, ["0", "0", "1.9", "expoOut"]);
        playstate.camFocusGF(Std.parseFloat(args[0]), Std.parseFloat(args[1]), Events.eventConvertTime(args[2]), Events.easeNameToEase(args[3]));
    }
    
    function camFocusCenter(tag:String):Void{
        var args = Events.getArgs(tag, ["0", "0", "1.9", "expoOut"]);
		var pos:FlxPoint = new FlxPoint(FlxMath.lerp(playstate.getOpponentFocusPosition().x, playstate.getBfFocusPostion().x, 0.5), FlxMath.lerp(playstate.getOpponentFocusPosition().y, playstate.getBfFocusPostion().y, 0.5));
		playstate.camMove(pos.x + Std.parseFloat(args[0]), pos.y + Std.parseFloat(args[1]), Events.eventConvertTime(args[2]), Events.easeNameToEase(args[3]), "center");
    }
    
    function camShake(tag:String):Void{
        var args = Events.getArgs(tag, ["0.008", "0.042", "1", "0.042", "linear"]);
		playstate.camShake(Std.parseFloat(args[0]), Std.parseFloat(args[1]), Events.eventConvertTime(args[2]), Std.parseFloat(args[3]), Events.easeNameToEase(args[4]));
    }
    
    function setDynamicCamAmount(tag:String):Void{
        var args = Events.getArgs(tag, ["25"]);
		playstate.camOffsetAmount = Std.parseFloat(args[0]);
    }

}