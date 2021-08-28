package;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import vlc.VlcBitmap;

// THIS IS FOR TESTING
// DONT STEAL MY CODE >:(
class VideoHandlerMP4 extends FlxSprite
{
	public var video:Video;
	public var netStream:NetStream;

	public var finishCallback:Void->Void;
	
	public var waitingStart:Bool = false;
	public var startDrawing:Bool = false;
	public var skipable:Bool = false;
	public var muted:Bool = false;
	public var completed:Bool = false;

	#if desktop
	public var vlcBitmap:VlcBitmap;
	#end

	public function new(?x:Float = 0, ?y:Float = 0)
	{

		super(x, y);

	}

	public function playWebMP4(videoPath:String, callback:Void->Void)
	{
		/*
			var nc:NetConnection = new NetConnection();
			nc.connect(null);

			var ns:NetStream = new NetStream(nc);

			var myVideo:Video = new Video();

			myVideo.width = FlxG.width;
			myVideo.height = FlxG.height;
			myVideo.attachNetStream(ns);

			ns.play(path);

			return myVideo;

			ns.close();
		 */

		FlxG.autoPause = false;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		finishCallback = callback;

		video = new Video();
		video.x = 0;
		video.y = 0;

		FlxG.addChildBelowMouse(video);

		var nc = new NetConnection();
		nc.connect(null);

		netStream = new NetStream(nc);
		netStream.client = {onMetaData: client_onMetaData};

		nc.addEventListener("netStatus", netConnection_onNetStatus);

		netStream.play(videoPath);
	}

	#if desktop
	public function playMP4(path:String, callback:Void->Void, ?repeat:Bool = false, ?canSkip:Bool = false, ?isWindow:Bool = false, ?isFullscreen:Bool = false):Void
	{

		skipable = canSkip;

		//FlxG.autoPause = false;

		//if (FlxG.sound.music != null)
		//{
		//	FlxG.sound.music.stop();
		//}

		finishCallback = callback;

		vlcBitmap = new VlcBitmap();
		vlcBitmap.onVideoReady = onVLCVideoReady;
		vlcBitmap.onComplete = onVLCComplete;
		vlcBitmap.volume = FlxG.sound.volume;

		if (repeat)
			vlcBitmap.repeat = -1;
		else
			vlcBitmap.repeat = 0;

		vlcBitmap.inWindow = isWindow;
		vlcBitmap.fullscreen = isFullscreen;

		FlxG.addChildBelowMouse(vlcBitmap);
		vlcBitmap.play(checkFile(path));
		vlcBitmap.visible = false;

		waitingStart = true;
	}

	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";
		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	/////////////////////////////////////////////////////////////////////////////////////

	function onVLCVideoReady()
	{
		trace("video loaded!");
	}

	public function onVLCComplete()
	{
		sys.thread.Thread.create(() -> {
			if (finishCallback != null)
			{
				finishCallback();
			}
        });

		sys.thread.Thread.create(() -> {
			vlcClean();
		});

		//FlxG.autoPause = true;

	}

	public function vlcClean(){
		vlcBitmap.stop();

		// Clean player, just in case!
		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
		}

		trace("Done!");
		completed = true;
	}
	#end

	/////////////////////////////////////////////////////////////////////////////////////

	function client_onMetaData(videoPath)
	{
		video.attachNetStream(netStream);

		video.width = FlxG.width;
		video.height = FlxG.height;
	}

	function netConnection_onNetStatus(videoPath)
	{
		if (videoPath.info.code == "NetStream.Play.Complete")
		{
			finishVideo();
		}
	}

	function finishVideo()
	{
		
		sys.thread.Thread.create(() -> {
			if (finishCallback != null)
			{
				finishCallback();
			}
			else
				FlxG.switchState(new MainMenuState());
        });
		
		sys.thread.Thread.create(() -> {
			netStream.dispose();

			if (FlxG.game.contains(video))
			{
				FlxG.game.removeChild(video);
			}
		});

		FlxG.autoPause = true;

	}

	override function update(elapsed){

		super.update(elapsed);

		if(vlcBitmap != null){

			if(!muted)
				vlcBitmap.volume = FlxG.sound.volume;
			else
				vlcBitmap.volume = 0;

		}

		if(waitingStart){

			if(vlcBitmap.initComplete){
				makeGraphic(vlcBitmap.bitmapData.width,vlcBitmap.bitmapData.height,FlxColor.TRANSPARENT);

				waitingStart = false;
				startDrawing = true;
			}
			
		}

		if(startDrawing){

			pixels.draw(vlcBitmap.bitmapData);

		}

		if(skipable){

			if(PlayerSettings.player1.controls.ACCEPT){
				onVLCComplete();
				destroy();
			}

		}

	}

	override function destroy(){

		if(!completed){
			vlcClean();
		}
		super.destroy();
		
	}

	public function pause(){

		vlcBitmap.pause();

	}

	public function resume(){

		vlcBitmap.resume();

	}
	
}
