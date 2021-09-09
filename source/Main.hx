package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{

	public static var fpsDisplay:FPS;

	public static var novid:Bool = false;
	public static var nopreload:Bool = false;
	public static var skipsound:Bool = false;
	public static var skipcharacters:Bool = false;
	public static var skipgraphics:Bool = false;
	public static var flippymode:Bool = false;

	public function new()
	{
		super();

		#if sys
		novid = Sys.args().contains("-novid");
		nopreload = Sys.args().contains("-nopreload");
		skipsound = Sys.args().contains("-skipsound");
		skipcharacters = Sys.args().contains("-skipcharacters");
		skipgraphics = Sys.args().contains("-skipgraphics");
		flippymode = Sys.args().contains("-flippymode");
		#end

		if(!nopreload)
			addChild(new FlxGame(0, 0, Startup, 1, 144, 144, true));
		else
			addChild(new FlxGame(0, 0, TitleVidState, 1, 144, 144, true));

		#if !mobile
		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		fpsDisplay.visible = false;
		addChild(fpsDisplay);
		#end

		//On web builds, video 
		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		trace("-=Args=-");
		trace("novid: " + novid);
		trace("nopreload: " + nopreload);
		trace("skipsound: " + skipsound);
		trace("skipcharacters: " + skipcharacters);
		trace("skipgraphics: " + skipgraphics);
		trace("flippymode: " + flippymode);

	}
}
