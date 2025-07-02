package config;

import flixel.FlxG;
using StringTools;

class Config
{
	
	public static var offset:Float = 0.0;
	public static var healthMultiplier:Float = 1.0;
	public static var healthDrainMultiplier:Float = 1.0;
	public static var comboType:Int = 0;
	public static var downscroll:Bool = false;
	public static var noteGlow:Bool = false;
	public static var ghostTapType:Int = 0;
	public static var framerate:Int = 999;
	public static var bgDim:Int = 0;
	public static var noteSplashType:Int = 0;
	public static var centeredNotes:Bool = false;
	public static var scrollSpeedOverride:Float = -1;
	public static var showComboBreaks:Bool = false;
	public static var showFPS:Bool = true;
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

	public static function reload():Void
	{
		SaveManager.global();

		for (field in Type.getClassFields(Config)){
			if (Reflect.hasField(FlxG.save.data, field)){
				Reflect.setProperty(Config, field, Reflect.field(FlxG.save.data, field));
			}
		}
	}
	
	public static function write(option:String, data:Dynamic):Void
	{
		if (Type.getClassFields(Config).contains(option)){
			SaveManager.global();
			Reflect.setField(FlxG.save.data, option, data);
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