package;

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
class VideoHandlerMP4
{
	public static var video:Video;
	public static var netStream:NetStream;
	public static var finishCallback:Void->Void;

	#if desktop
	public static var vlcBitmap:VlcBitmap;
	#end

	public function new()
	{
		FlxG.autoPause = false;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}
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
	public function playMP4(path:String, callback:Void->Void, ?repeat:Bool = false, ?isWindow:Bool = false, ?isFullscreen:Bool = false):Void
	{
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
			vlcBitmap.stop();

			// Clean player, just in case!
			vlcBitmap.dispose();

			if (FlxG.game.contains(vlcBitmap))
			{
				FlxG.game.removeChild(vlcBitmap);
			}
		});

		FlxG.autoPause = true;

		trace("Done!");

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
	
}
