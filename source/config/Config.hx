package config;

import flixel.FlxG;
using StringTools;

class Config
{
	
	public static var offset:Float;
	public static var accuracy:String;
	public static var healthMultiplier:Float;
	public static var healthDrainMultiplier:Float;
	public static var comboType:Int;
	public static var downscroll:Bool;
	public static var noteGlow:Bool;
	public static var ghostTapType:Int;
	public static var framerate:Int;
	public static var controllerScheme:Int;
	public static var bgDim:Int;
	public static var noteSplashType:Int;
	public static var centeredNotes:Bool;
	public static var scrollSpeedOverride:Float;
	public static var showComboBreaks:Bool;
	public static var showFPS:Bool;
	public static var extraCamMovement:Bool;
	public static var camBopAmount:Int;
	public static var showCaptions:Bool;

	public static function resetSettings():Void{

		SaveManager.global();

		FlxG.save.data.offset = 0.0;
		FlxG.save.data.accuracy = "simple";
		FlxG.save.data.healthMultiplier = 1.0;
		FlxG.save.data.healthDrainMultiplier = 1.0;
		FlxG.save.data.comboType = 0;
		FlxG.save.data.downscroll = false;
		FlxG.save.data.noteGlow = false;
		FlxG.save.data.ghostTapType = 0;
		FlxG.save.data.framerate = 999;
		FlxG.save.data.controllerScheme = 0;
		FlxG.save.data.bgDim = 0;
		FlxG.save.data.noteSplashType = 0;
		FlxG.save.data.centeredNotes = false;
		FlxG.save.data.scrollSpeedOverride = -1;
		FlxG.save.data.showComboBreaks = false;
		FlxG.save.data.showFPS = false;
		FlxG.save.data.extraCamMovement = false;
		FlxG.save.data.camBopAmount = 0;
		FlxG.save.data.showCaptions = true;
		reload();

	}
	
	public static function reload():Void
	{

		SaveManager.global();

		offset = FlxG.save.data.offset;
		accuracy = FlxG.save.data.accuracy;
		healthMultiplier = FlxG.save.data.healthMultiplier;
		healthDrainMultiplier = FlxG.save.data.healthDrainMultiplier;
		comboType = FlxG.save.data.comboType;
		downscroll = FlxG.save.data.downscroll;
		noteGlow = FlxG.save.data.noteGlow;
		ghostTapType = FlxG.save.data.ghostTapType;
		framerate = FlxG.save.data.framerate;
		controllerScheme = FlxG.save.data.controllerScheme;
		bgDim = FlxG.save.data.bgDim;
		noteSplashType = FlxG.save.data.noteSplashType;
		centeredNotes = FlxG.save.data.centeredNotes;
		scrollSpeedOverride = FlxG.save.data.scrollSpeedOverride;
		showComboBreaks = FlxG.save.data.showComboBreaks;
		showFPS = FlxG.save.data.showFPS;
		extraCamMovement = FlxG.save.data.extraCamMovement;
		camBopAmount = FlxG.save.data.camBopAmount;
		showCaptions = FlxG.save.data.showCaptions;
	}
	
	public static function write(
								offsetW:Float, 
								accuracyW:String, 
								healthMultiplierW:Float, 
								healthDrainMultiplierW:Float, 
								comboTypeW:Int, 
								downscrollW:Bool, 
								noteGlowW:Bool,
								ghostTapTypeW:Int,
								framerateW:Int,
								controllerSchemeW:Int,
								bgDimW:Int,
								noteSplashTypeW:Int,
								centeredNotesW:Bool,
								scrollSpeedOverrideW:Float,
								showComboBreaksW:Bool,
								showFPSW:Bool,
								extraCamMovementW:Bool,
								camBopAmountW:Int,
								showCaptionsW:Bool
								):Void
	{

		SaveManager.global();

		FlxG.save.data.offset = offsetW;
		FlxG.save.data.accuracy = accuracyW;
		FlxG.save.data.healthMultiplier = healthMultiplierW;
		FlxG.save.data.healthDrainMultiplier = healthDrainMultiplierW;
		FlxG.save.data.comboType = comboTypeW;
		FlxG.save.data.downscroll = downscrollW;
		FlxG.save.data.noteGlow = noteGlowW;
		FlxG.save.data.ghostTapType = ghostTapTypeW;
		FlxG.save.data.framerate = framerateW;
		FlxG.save.data.controllerScheme = controllerSchemeW;
		FlxG.save.data.bgDim = bgDimW;
		FlxG.save.data.noteSplashType = noteSplashTypeW;
		FlxG.save.data.centeredNotes = centeredNotesW;
		FlxG.save.data.scrollSpeedOverride = scrollSpeedOverrideW;
		FlxG.save.data.showComboBreaks = showComboBreaksW;
		FlxG.save.data.showFPS = showFPSW;
		FlxG.save.data.extraCamMovement = extraCamMovementW;
		FlxG.save.data.camBopAmount = camBopAmountW;
		FlxG.save.data.showCaptions = showCaptionsW;

		SaveManager.flush();
		
		reload();

	}
	
	public static function configCheck():Void
	{

		SaveManager.global();

		if(FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0.0;
		if(FlxG.save.data.accuracy == null)
			FlxG.save.data.accuracy = "simple";
		if(FlxG.save.data.healthMultiplier == null)
			FlxG.save.data.healthMultiplier = 1.0;
		if(FlxG.save.data.healthDrainMultiplier == null)
			FlxG.save.data.healthDrainMultiplier = 1.0;
		if(FlxG.save.data.comboType == null)
			FlxG.save.data.comboType = 1;
		if(FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
		if(FlxG.save.data.noteGlow == null)
			FlxG.save.data.noteGlow = true;
		if(FlxG.save.data.ghostTapType == null)
			FlxG.save.data.ghostTapType = 0;
		if(FlxG.save.data.framerate == null)
			FlxG.save.data.framerate = 999;
		if(FlxG.save.data.controllerScheme == null)
			FlxG.save.data.controllerScheme = 0;
		if(FlxG.save.data.bgDim == null)
			FlxG.save.data.bgDim = 0;
		if(FlxG.save.data.noteSplashType == null)
			FlxG.save.data.noteSplashType = 1;
		if(FlxG.save.data.centeredNotes == null)
			FlxG.save.data.centeredNotes = false;
		if(FlxG.save.data.scrollSpeedOverride == null)
			FlxG.save.data.scrollSpeedOverride = -1;
		if(FlxG.save.data.showComboBreaks == null)
			FlxG.save.data.showComboBreaks = false;
		if(FlxG.save.data.showFPS == null)
			FlxG.save.data.showFPS = false;
		if(FlxG.save.data.extraCamMovement == null)
			FlxG.save.data.extraCamMovement = false;
		if(FlxG.save.data.camBopAmount == null)
			FlxG.save.data.camBopAmount = 0;
		if(FlxG.save.data.showCaptions == null)
			FlxG.save.data.showCaptions = true;

		if(FlxG.save.data.ee1 == null)
			FlxG.save.data.ee1 = false;
		if(FlxG.save.data.ee2 == null)
			FlxG.save.data.ee2 = false;
	}

	public static function setFramerate(cap:Int, ?useValueInsteadOfSave:Int = -1){
		var fps:Int = framerate;
		if(useValueInsteadOfSave > -1){ fps = useValueInsteadOfSave; }
		if(fps > cap) { fps = cap; }
		FlxG.updateFramerate = fps;
		FlxG.drawFramerate  = fps;
	}
	
}