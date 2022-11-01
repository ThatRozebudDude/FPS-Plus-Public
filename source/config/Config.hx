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
	public static var noFpsCap:Bool;
	public static var controllerScheme:Int;
	public static var bgDim:Int;

	public static function resetSettings():Void
	{
		FlxG.save.data.offset = 0.0;
		FlxG.save.data.accuracy = "simple";
		FlxG.save.data.healthMultiplier = 1.0;
		FlxG.save.data.healthDrainMultiplier = 1.0;
		FlxG.save.data.comboType = 0;
		FlxG.save.data.downscroll = false;
		FlxG.save.data.noteGlow = false;
		FlxG.save.data.ghostTapType = 0;
		FlxG.save.data.noFpsCap = true;
		FlxG.save.data.controllerScheme = 0;
		reload();
	}

	public static function reload():Void
	{
		offset = FlxG.save.data.offset;
		accuracy = FlxG.save.data.accuracy;
		healthMultiplier = FlxG.save.data.healthMultiplier;
		healthDrainMultiplier = FlxG.save.data.healthDrainMultiplier;
		comboType = FlxG.save.data.comboType;
		downscroll = FlxG.save.data.downscroll;
		noteGlow = FlxG.save.data.noteGlow;
		ghostTapType = FlxG.save.data.ghostTapType;
		noFpsCap = FlxG.save.data.noFpsCap;
		controllerScheme = FlxG.save.data.controllerScheme;
		bgDim = FlxG.save.data.bgDim;
	}

	public static function write(offsetW:Float, accuracyW:String, healthMultiplierW:Float, healthDrainMultiplierW:Float, comboTypeW:Int, downscrollW:Bool,
			noteGlowW:Bool, ghostTapTypeW:Int, noFpsCapW:Bool, controllerSchemeW:Int, bgDimW:Int):Void
	{
		FlxG.save.data.offset = offsetW;
		FlxG.save.data.accuracy = accuracyW;
		FlxG.save.data.healthMultiplier = healthMultiplierW;
		FlxG.save.data.healthDrainMultiplier = healthDrainMultiplierW;
		FlxG.save.data.comboType = comboTypeW;
		FlxG.save.data.downscroll = downscrollW;
		FlxG.save.data.noteGlow = noteGlowW;
		FlxG.save.data.ghostTapType = ghostTapTypeW;
		FlxG.save.data.noFpsCap = noFpsCapW;
		FlxG.save.data.controllerScheme = controllerSchemeW;
		FlxG.save.data.bgDim = bgDimW;

		FlxG.save.flush();

		reload();
	}

	public static function configCheck():Void
	{
		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0.0;
		if (FlxG.save.data.accuracy == null)
			FlxG.save.data.accuracy = "simple";
		if (FlxG.save.data.healthMultiplier == null)
			FlxG.save.data.healthMultiplier = 1.0;
		if (FlxG.save.data.healthDrainMultiplier == null)
			FlxG.save.data.healthDrainMultiplier = 1.0;
		if (FlxG.save.data.comboType == null)
			FlxG.save.data.comboType = 0;
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
		if (FlxG.save.data.noteGlow == null)
			FlxG.save.data.noteGlow = false;
		if (FlxG.save.data.ghostTapType == null)
			FlxG.save.data.ghostTapType = 0;
		if (FlxG.save.data.noFpsCap == null)
			FlxG.save.data.noFpsCap = true;
		if (FlxG.save.data.controllerScheme == null)
			FlxG.save.data.controllerScheme = 0;
		if (FlxG.save.data.bgDim == null)
			FlxG.save.data.bgDim = 0;

		if (FlxG.save.data.ee1 == null)
			FlxG.save.data.ee1 = false;
	}
}
