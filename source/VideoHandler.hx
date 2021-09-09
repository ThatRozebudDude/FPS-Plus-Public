package;

import openfl.media.SoundTransform;
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

/**
	An adaptation of PolybiusProxy's OpenFL desktop MP4 code to not only make         
	work as a Flixel Sprite, but also allow it to work with standard OpenFL               
	on Web builds as well.              
	By Rozebud.
**/

class VideoHandler extends FlxSprite
{
	public static var MAX_FPS = 60;

	public var skipable:Bool = false;
	public var muted:Bool = false;
	public var completed:Bool = false;

	var finishCallback:Void->Void;
	var waitingStart:Bool = false;
	var startDrawing:Bool = false;
	var frameCount:Float = 0;

	#if desktop
	public var vlcBitmap:VlcBitmap;
	#end

	#if web
	public var video:Video;
	public var netStream:NetStream;
	public var netPath:String;
	public var netLoop:Bool;
	#end

	public function new(?x:Float = 0, ?y:Float = 0)
	{

		super(x, y);

	}

	public function playMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false, ?canSkip:Bool = false){

		#if desktop
		playDesktopMP4(videoPath, callback, repeat, canSkip);
		#end

		#if web
		playWebMP4(videoPath, callback, repeat, canSkip);
		#end

	}

	#if desktop
	public function playDesktopMP4(path:String, callback:Void->Void, ?repeat:Bool = false, ?canSkip:Bool = false, ?isWindow:Bool = false, ?isFullscreen:Bool = false):Void
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
		if (finishCallback != null)
		{
			finishCallback();
		}

		vlcClean();

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

	#if web
	public function playWebMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false, ?canSkip:Bool = false)
	{
		skipable = canSkip;
		netLoop = repeat;
		netPath = videoPath;

		FlxG.autoPause = false;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		finishCallback = callback;

		video = new Video();
		video.x = -1280;
		video.y = -720;

		FlxG.addChildBelowMouse(video);

		var nc = new NetConnection();
		nc.connect(null);

		netStream = new NetStream(nc);
		netStream.client = {onMetaData: client_onMetaData};

		nc.addEventListener("netStatus", netConnection_onNetStatus);

		netStream.play(netPath);
	}

	function client_onMetaData(videoPath)
	{
		video.attachNetStream(netStream);

		video.width = FlxG.width;
		video.height = FlxG.height;

		waitingStart = true;
	}

	function netConnection_onNetStatus(videoPath)
	{
		if (videoPath.info.code == "NetStream.Play.Complete")
		{
			if(netLoop){
				netStream.play(netPath);
			}
			else{
				finishVideo();
			}
		}
		if (videoPath.info.code == "NetStream.Play.Start")
		{
			if(muted){
				netStream.soundTransform = new SoundTransform(0);
			}
		}
		if (videoPath.info.code == "NetStream.Play.Start")
		{
			if(!muted){
				netStream.soundTransform = new SoundTransform(FlxG.sound.volume);
			}
			else{
				netStream.soundTransform = new SoundTransform(0);
			}
		}
	}

	function finishVideo()
	{
		
		if (finishCallback != null)
		{
				finishCallback();
		}
		
		netClean();

	}

	public function netClean(){
		
		netStream.dispose();

		completed = true;

		if (FlxG.game.contains(video))
		{
			FlxG.game.removeChild(video);
		}

		trace("Done!");
		completed = true;
	}
	#end

	override function update(elapsed){

		super.update(elapsed);

		#if desktop
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

				if(frameCount >= 1/MAX_FPS){
					pixels.draw(vlcBitmap.bitmapData);
					frameCount = 0;
				}
				frameCount += elapsed;

		}

		if(skipable){

			if(PlayerSettings.player1.controls.ACCEPT){
				onVLCComplete();
				destroy();
			}

		}
		#end

		#if web
		if(!muted){
			if(FlxG.keys.justPressed.MINUS || FlxG.keys.justPressed.PLUS){
				netStream.soundTransform = new SoundTransform(FlxG.sound.volume);
			}
		}

		if(waitingStart){

			makeGraphic(video.videoWidth, video.videoHeight, FlxColor.TRANSPARENT);

			waitingStart = false;
			startDrawing = true;
			
		}

		if(startDrawing){

			if(frameCount >= 1/MAX_FPS){
				pixels.draw(video);
				frameCount = 0;
			}
			frameCount += elapsed;

		}

		if(skipable){

			if(PlayerSettings.player1.controls.ACCEPT){
				finishVideo();
				destroy();
			}

		}
		#end

	}

	override function destroy(){

		#if desktop
		if(!completed){
			vlcClean();
		}
		#end

		#if web
		if(!completed){
			netClean();
		}
		#end

		super.destroy();
		
	}

	public function pause(){

		#if desktop
		vlcBitmap.pause();
		#end

		#if web
		netStream.pause();
		#end

	}

	public function resume(){

		#if desktop
		vlcBitmap.resume();
		#end

		#if web
		netStream.resume();
		#end

	}
	
}
