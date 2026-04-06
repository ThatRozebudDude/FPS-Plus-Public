package config;

import openfl.events.Event;
import flixel.FlxG;
import openfl.Lib;
import restricted.RestrictedUtils;
import haxe.rtti.Meta;

using StringTools;

typedef ConfigInfo = {
	key:String,
	field:String
}

/* HOW TO USE `@configParam`
 * Any field that has the metadata `@configParam` will be automatically added to the game's save data.
 * The argument is the key that will be used in the save data, i.e. `@configParam("key") public static var value:Int = 0;` will save to `key` in the save and be accessible with `Config.value` in the code.
 */

class Config
{
	@configParam("offset")					public static var offset:Float = 0.0;
	@configParam("healthMultiplier")		public static var healthMultiplier:Float = 1.0;
	@configParam("healthDrainMultiplier")	public static var healthDrainMultiplier:Float = 1.0;
	@configParam("comboType")				public static var comboType:Int = 1;
	@configParam("downscroll")				public static var downscroll:Bool = false;
	@configParam("noteGlow")				public static var noteGlow:Bool = true;
	@configParam("ghostTapType")			public static var ghostTapType:Int = 0;
	@configParam("framerate")				public static var framerate:Int = 999;
	@configParam("bgDim")					public static var bgDim:Int = 0;
	@configParam("noteSplashType")			public static var noteSplashType:Int = 1;
	@configParam("centeredNotes")			public static var centeredNotes:Bool = false;
	@configParam("scrollSpeedOverride")		public static var scrollSpeedOverride:Float = -1;
	@configParam("showComboBreaks")			public static var showComboBreaks:Bool = false;
	@configParam("showFPS")					public static var showFPS:Bool = false;
	@configParam("useGPU")					public static var useGPU:Bool = true;
	@configParam("extraCamMovement_2")		public static var extraCamMovement:Int = 0;
	@configParam("camBopAmount")			public static var camBopAmount:Int = 0;
	@configParam("showCaptions")			public static var showCaptions:Bool = true;
	@configParam("showAccuracy")			public static var showAccuracy:Bool = true;
	@configParam("showMisses")				public static var showMisses:Int = 1;
	@configParam("autoPause")				public static var autoPause:Bool = true;
	@configParam("flashingLights")			public static var flashingLights:Bool = true;
	@configParam("fullscreen")				public static var fullscreen:Bool = false;
	#if UPDATE_CHECKING @configParam("checkForUpdates") public static var checkForUpdates:Bool = true; #end

	@configParam("ee1")						public static var ee1:Bool = false;
	@configParam("ee2")						public static var ee2:Bool = false;

	static var configList(get, default):Array<ConfigInfo>;

	public static final ALLOWED_FRAMERATE_VALUES:Array<Int> = [60, 120, 144, 240, 360, 480, 999];

	public static var initialized:Bool = false;

	public static function load():Void{
		loadSaveData();

		openfl.Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e:openfl.events.KeyboardEvent) -> {
			for(key in Binds.binds.get("fullscreen").binds){
				if (e.keyCode == key){
					fullscreen = !fullscreen;
					FlxG.fullscreen = fullscreen;
					//write();
				}
			}
		});

		FlxG.fullscreen = fullscreen;

		var framerateValue:Int = ALLOWED_FRAMERATE_VALUES.indexOf(framerate);
		if(framerateValue == -1){
			framerate = ALLOWED_FRAMERATE_VALUES[ALLOWED_FRAMERATE_VALUES.length-1];
		}

		initialized = true;
	}

	public static function loadSaveData():Void{
		SaveManager.global();

		if(FlxG.save.data != null){
			//Section for upgrading config settings from older versions to newer versions.
			if(FlxG.save.data.extraCamMovement != null && FlxG.save.data.extraCamMovement_2 == null){
				trace("[Config] Fixing extraCamMovement");
				if(FlxG.save.data.extraCamMovement){
					FlxG.save.data.extraCamMovement_2 = 0;
				}
				else{
					FlxG.save.data.extraCamMovement_2 = 2;
				}
			}

			//Load save data to Config fields.
			for(info in configList){
				if(Reflect.hasField(FlxG.save.data, info.key)){
					Reflect.setProperty(Config, info.field, Reflect.field(FlxG.save.data, info.key));
				}
			}
		}
	}
	
	public static function write():Void{
		SaveManager.global();

		for(info in configList){
			Reflect.setField(FlxG.save.data, info.key, Reflect.getProperty(Config, info.field));
		}
		
		SaveManager.previousSave();
	}

	public static function setFramerate(cap:Int, ?useValueInsteadOfSave:Int = -1):Void{
		var fps:Int = framerate;
		if(useValueInsteadOfSave > -1){ fps = useValueInsteadOfSave; }
		if(fps == 999 && cap == 999){ fps = 0; }
		else{ fps = (fps > cap) ? cap : fps; }
		FlxG.updateFramerate = fps;
		FlxG.drawFramerate = fps;
	}

	static function get_configList():Array<ConfigInfo>{
		if(configList != null){ // Preventing excessive Reflect calls
			return configList;
		}

		configList = [];
		final statics = Meta.getStatics(Config);

		for(field in Type.getClassFields(Config)){
			if(RestrictedUtils.hasMetadata(Config, field, "configParam")){
				var info = {
					key: Reflect.field(statics, field).configParam[0],
					field: field
				};
				configList.push(info);
			}
		}

		return configList;
	}

}