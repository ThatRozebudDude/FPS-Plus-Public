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

	public static var novid:Bool = false;
	public static var flippymode:Bool = false;

	public function new()
	{
		super();

		PolymodHandler.init();
		hxvlc.util.Handle.init([]); // initializes LibVLC
		FlxSprite.defaultAntialiasing = true;

		#if !debug
		LogStyle.ERROR.openConsole = false;
		LogStyle.ERROR.errorSound = null;
		#end

		LogStyle.WARNING.openConsole = false;
		LogStyle.WARNING.errorSound = null;

		#if sys
		novid = Sys.args().contains("-novid");
		flippymode = Sys.args().contains("-flippymode");
		#end

		SaveManager.global();

		fpsDisplay = new FPSExt(3, 3, 0xFFFFFF);
		fpsDisplay.visible = true;

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

		trace("-=Args=-");
		trace("novid: " + novid);
		trace("flippymode: " + flippymode);

	}
}
