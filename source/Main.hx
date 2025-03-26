package;

import flixel.system.debug.log.LogStyle;
import extensions.openfl.display.FPSExt;
import modding.PolymodHandler;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import debug.*;
import openfl.display.FPS;

class Main extends Sprite
{

	public static var fpsDisplay:FPSExt;

	public static var novid:Bool = false;
	public static var flippymode:Bool = false;

	public function new()
	{
		super();

		PolymodHandler.init();

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

		addChild(new FlxGame(0, 0, Startup, 60, 60, true));
		addChild(fpsDisplay);

		//On web builds, video tends to lag quite a bit, so this just helps it run a bit faster.
		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		trace("-=Args=-");
		trace("novid: " + novid);
		trace("flippymode: " + flippymode);

	}
}
