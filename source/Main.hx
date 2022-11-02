package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	private var gameWidth:Int = 1280;
	private var gameHeight:Int = 720;
	private var zoom:Float = -1;

	public static var novid:Bool = false;
	public static var flippymode:Bool = false;
	public static var framerate:Int = #if web 60 #else 144 #end; // For some reason 144 can't work on web browser XD
	public static var fpsDisplay:FPS;

	public function new()
	{
		super();

		#if sys
		novid = Sys.args().contains("-novid");
		flippymode = Sys.args().contains("-flippymode");
		#end

		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			final ratioX:Float = stageWidth / gameWidth;
			final ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new FlxGame(gameWidth, gameHeight, Startup, zoom, framerate, framerate, true));

		#if !mobile
		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsDisplay);
		#end

		// On web builds, video tends to lag quite a bit, so this just helps it run a bit faster.
		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		trace("-=Args=-");
		trace("novid: " + novid);
		trace("flippymode: " + flippymode);
	}
}
