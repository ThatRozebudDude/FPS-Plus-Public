package config;

import flixel.FlxG;
import openfl.Lib;
import restricted.RestrictedUtils;

using StringTools;

class Config
{
	@isConfig public static var offset:Float = 0.0;
	@isConfig public static var healthMultiplier:Float = 1.0;
	@isConfig public static var healthDrainMultiplier:Float = 1.0;
	@isConfig public static var comboType:Int = 1;
	@isConfig public static var downscroll:Bool = false;
	@isConfig public static var noteGlow:Bool = true;
	@isConfig public static var ghostTapType:Int = 0;
	@isConfig public static var framerate:Int = 999;
	@isConfig public static var bgDim:Int = 0;
	@isConfig public static var noteSplashType:Int = 1;
	@isConfig public static var centeredNotes:Bool = false;
	@isConfig public static var scrollSpeedOverride:Float = -1;
	@isConfig public static var showComboBreaks:Bool = false;
	@isConfig public static var showFPS:Bool = false;
	@isConfig public static var useGPU:Bool = true;
	@isConfig public static var extraCamMovement:Bool = true;
	@isConfig public static var camBopAmount:Int = 0;
	@isConfig public static var showCaptions:Bool = true;
	@isConfig public static var showAccuracy:Bool = true;
	@isConfig public static var showMisses:Int = 1;
	@isConfig public static var autoPause:Bool = true;
	@isConfig public static var flashingLights:Bool = true;

	@isConfig public static var ee1:Bool = false;
	@isConfig public static var ee2:Bool = false;

	static var configList(get, default):Array<String>;

	public static function load():Void{
		SaveManager.global();

		if(FlxG.save.data != null){
			for(field in configList){
				if(Reflect.hasField(FlxG.save.data, field)){
					Reflect.setProperty(Config, field, Reflect.field(FlxG.save.data, field));
				}
			}
		}

		Lib.application.window.onClose.add(write);
	}
	
	public static function write():Void{
		SaveManager.global();

		for(field in configList){
			Reflect.setField(FlxG.save.data, field, Reflect.getProperty(Config, field));
		}
		
		SaveManager.previousSave();
	}

	public static function setFramerate(cap:Int, ?useValueInsteadOfSave:Int = -1):Void{
		var fps:Int = framerate;
		if(useValueInsteadOfSave > -1){ fps = useValueInsteadOfSave; }
		if(fps > cap) { fps = cap; }
		FlxG.updateFramerate = fps;
		FlxG.drawFramerate  = fps;
	}

	static function get_configList():Array<String>
	{
		if (configList != null){ // Preventing excessive Reflect calls
			return configList;
		}

		configList = [];

		for (field in Type.getClassFields(Config)){
			if (RestrictedUtils.hasMetadata(Config, field, "isConfig")){
				configList.push(field);
			}
		}

		return configList;
	}

}