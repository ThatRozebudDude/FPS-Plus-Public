package config;

import flixel.FlxG;
import openfl.Lib;

using StringTools;

class Config
{
	public static var offset:Float = 0.0;
	public static var healthMultiplier:Float = 1.0;
	public static var healthDrainMultiplier:Float = 1.0;
	public static var comboType:Int = 1;
	public static var downscroll:Bool = false;
	public static var noteGlow:Bool = true;
	public static var ghostTapType:Int = 0;
	public static var framerate:Int = 999;
	public static var bgDim:Int = 0;
	public static var noteSplashType:Int = 1;
	public static var centeredNotes:Bool = false;
	public static var scrollSpeedOverride:Float = -1;
	public static var showComboBreaks:Bool = false;
	public static var showFPS:Bool = false;
	public static var useGPU:Bool = true;
	public static var extraCamMovement:Bool = true;
	public static var camBopAmount:Int = 0;
	public static var showCaptions:Bool = true;
	public static var showAccuracy:Bool = true;
	public static var showMisses:Int = 1;
	public static var autoPause:Bool = true;
	public static var flashingLights:Bool = true;

	public static var ee1:Bool = false;
	public static var ee2:Bool = false;

	public static function load():Void{
		SaveManager.global();

		if(FlxG.save.data != null){
			for(field in Type.getClassFields(Config)){
				if(Reflect.hasField(FlxG.save.data, field)){
					Reflect.setProperty(Config, field, Reflect.field(FlxG.save.data, field));
				}
			}
		}

		Lib.application.window.onClose.add(function(){
			write(false);
		});
	}
	
	public static function write(returnToPrevious:Bool = true):Void{
		SaveManager.global();

		for(field in Type.getClassFields(Config)){
			if(!field.startsWith("_") && !Reflect.isFunction(Reflect.getProperty(Config, field))){
				Reflect.setField(FlxG.save.data, field, Reflect.getProperty(Config, field));
			}
		}
		
		if(returnToPrevious){
			SaveManager.previousSave();
		}
		else{
			SaveManager.flush();
		}
	}

	public static function setFramerate(cap:Int, ?useValueInsteadOfSave:Int = -1):Void{
		var fps:Int = framerate;
		if(useValueInsteadOfSave > -1){ fps = useValueInsteadOfSave; }
		if(fps > cap) { fps = cap; }
		FlxG.updateFramerate = fps;
		FlxG.drawFramerate  = fps;
	}
	
}