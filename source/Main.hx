package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{

	public static var fpsDisplay:FPS;

	public static var novid:Bool = Sys.args().contains("-novid");
	public static var nopreload:Bool = Sys.args().contains("-nopreload");
	public static var skipsound:Bool = Sys.args().contains("-skipsound");
	public static var skipcharacters:Bool = Sys.args().contains("-skipcharacters");
	public static var skipgraphics:Bool = Sys.args().contains("-skipgraphics");
	public static var flippymode:Bool = Sys.args().contains("-flippymode");

	public function new()
	{
		super();

		if(!nopreload)
			addChild(new FlxGame(0, 0, Startup, 1, 144, 144, true));
		else
			addChild(new FlxGame(0, 0, TitleVidState, 1, 144, 144, true));

		#if !mobile
		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		fpsDisplay.visible = false;
		addChild(fpsDisplay);
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
