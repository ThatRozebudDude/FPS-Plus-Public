package;

import config.Config;
import openfl.Lib;
import flixel.system.debug.log.LogStyle;
import extensions.openfl.display.FPSExt;
import modding.PolymodHandler;
import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.Sprite;
import openfl.display.InteractiveObject;

class Main extends Sprite
{

	public static var fpsDisplay:InteractiveObject;

	public static var launchArguments:LaunchArguments = {
		no_vid: false,
		flippy_mode: false,
		no_mods: false,
	}

	public function new()
	{
		super();

		#if sys
		launchArguments.no_vid = Sys.args().contains("-no_vid");
		launchArguments.flippy_mode = Sys.args().contains("-flippy_mode");
		launchArguments.no_mods = Sys.args().contains("-no_mods") || #if MOD_SUPPORT false #else true #end;
		#end

		PolymodHandler.init();
		hxvlc.util.Handle.init([]); // initializes LibVLC
		FlxSprite.defaultAntialiasing = true;

		#if !debug
		LogStyle.ERROR.openConsole = false;
		LogStyle.ERROR.errorSound = null;
		#end

		LogStyle.WARNING.openConsole = false;
		LogStyle.WARNING.errorSound = null;

		SaveManager.global();

		fpsDisplay = new FPSExt(3, 3, 0xFFFFFF);
		fpsDisplay.visible = true;
		fpsDisplay.alpha = 1;

		untyped FlxG.cameras = new extensions.flixel.system.frondEnds.CameraFrontEndExt();

		var game:FlxGame = new FlxGame(1280, 720, Startup, 60, 60, true);

		@:privateAccess
		game._customSoundTray = ui.FunkinSoundTray;

		addChild(game);
		addChild(fpsDisplay);

		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		#if sys
		Lib.current.stage.window.onClose.add(function(){
			if(Config.initialized){ Config.write(); }
			hxvlc.util.Handle.dispose();
			Sys.exit(0);
		});
		#end

		trace("launchArguments: " + launchArguments);
	}
}

typedef LaunchArguments = {
	var no_vid:Bool;
	var flippy_mode:Bool;
	var no_mods:Bool;
}