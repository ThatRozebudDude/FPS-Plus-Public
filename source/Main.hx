package;

import webm.WebmPlayer;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{

	public static var fpsDisplay:FPS;

	#if web
		var vHandler:VideoHandler;
	#elseif desktop
		var webmHandle:WebmHandler;
	#end

	public static var video:Bool = !Sys.args().contains("-novid");
	public static var preload:Bool = !Sys.args().contains("-nopreload");

	public function new()
	{
		super();

		if(preload)
			addChild(new FlxGame(0, 0, Startup, 1, 144, 144, true));
		else
			addChild(new FlxGame(0, 0, TitleVidState, 1, 144, 144, true));

		#if !mobile
		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		fpsDisplay.visible = false;
		addChild(fpsDisplay);
		#end

		if(video){
		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		#if web
		var str1:String = "HTML CRAP";
		vHandler = new VideoHandler();
		vHandler.init1();
		vHandler.video.name = str1;
		addChild(vHandler.video);
		vHandler.init2();
		GlobalVideo.setVid(vHandler);
		vHandler.source(ourSource);
		#elseif desktop
		WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT"; 
		webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end
		}

	}
}
