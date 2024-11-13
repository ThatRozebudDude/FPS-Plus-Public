package;

import flixel.util.FlxSignal;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

#if hxvlc
import hxvlc.openfl.Video;
#elseif web
import openfl.media.SoundTransform;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
#end

/**
	An adaptation of MAJigsaw77's OpenFL desktop MP4 code to not only make         
	work as a Flixel Sprite, but also allow it to work with standard OpenFL               
	on Web builds as well.              
	@author Rozebud
**/

class VideoHandler extends FlxSprite
{
	/**
		Sets the maximum framerate that the video object will be to the sprite at.
		Helps increase performance on lower end machines and web builds.
	**/
	public static var MAX_FPS = 60;

	/**
		Determines whether the video plays auido. 
	**/
	public var muted(get, set):Bool;
	public var volume:Float = 1;

	public var length(get, never):Float;

	var __muted:Bool = false;
	var paused:Bool = false;
	var finishCallback:Void->Void;
	var waitingStart:Bool = false;
	var startDrawing:Bool = false;
	var frameTimer:Float = 0;
	var completed:Bool = false;
	var destroyed:Bool = false;

	public var onStart:FlxSignal = new FlxSignal();
	public var onEnd:FlxSignal = new FlxSignal();

	#if hxvlc
	var bitmap:Video;
	#elseif web
	var video:Video;
	var netStream:NetStream;
	var netPath:String;
	var netLoop:Bool;
	#end

	public function new(?x:Float = 0, ?y:Float = 0){
		super(x, y);
		makeGraphic(1, 1, FlxColor.TRANSPARENT);
	}

	/**
		Generic play function. 
		Works with both desktop and web builds.
	**/
	public function playMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false){

		#if hxvlc
		playDesktopMP4(videoPath, callback, repeat);
		#end

		#if web
		playWebMP4(videoPath, callback, repeat);
		#end

	}

	//===========================================================================================================//

	#if hxvlc
	/**
		Plays MP4s using VLC Bitmaps as the source.
		Only works on desktop builds.
		It is recommended that you use `playMP4()` instead since that works for desktop and web.
	**/
	@:noCompletion public function playDesktopMP4(path:String, callback:Void->Void, ?repeat:Bool = false):Void {

		//FlxG.autoPause = false;

		//if (FlxG.sound.music != null)
		//{
		//	FlxG.sound.music.stop();
		//}

		finishCallback = callback;

		bitmap = new Video();
		bitmap.onOpening.add(onVLCVideoReady);
		bitmap.onEndReached.add(onVLCComplete);
		
		FlxG.addChildBelowMouse(bitmap);
		bitmap.load(path, (repeat) ? ['input-repeat=65545'] : null);
		bitmap.play();
		bitmap.alpha = 0;
		
		if (FlxG.autoPause) {
			FlxG.signals.focusLost.add(pause);
			FlxG.signals.focusGained.add(resume);
		}

		waitingStart = true;
	}

	function onVLCVideoReady(){
		trace("video loaded!");
	}

	function onVLCComplete(){
		onEnd.dispatch();

		if (finishCallback != null){
			finishCallback();
		}

		destroy();
	}

	function vlcClean(){
		bitmap.stop();

		// Clean player, just in case!
		bitmap.dispose();

		if (FlxG.game.contains(bitmap))
		{
			FlxG.game.removeChild(bitmap);
		}

		trace("Done!");
		completed = true;
	}
	#end

	//===========================================================================================================//

	#if web
	/**
		Plays MP4s using OpenFL NetStreams and Videos as the source.
		Only works on web builds.
		It is recommended that you use `playMP4()` instead since that works for desktop and web.
	**/
	@:noCompletion public function playWebMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false) {

		netLoop = repeat;
		netPath = videoPath;

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

		if (FlxG.autoPause) {
			FlxG.signals.focusLost.add(pause);
			FlxG.signals.focusGained.add(resume);
		}

		netStream.play(netPath);
	}

	function client_onMetaData(videoPath)
	{
		video.attachNetStream(netStream);

		video.width = FlxG.width;
		video.height = FlxG.height;

		waitingStart = true;
	}

	function netConnection_onNetStatus(videoPath){
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
			setSoundTransform(__muted);
		}
	}

	function finishVideo(){
		onEnd.dispatch();
		
		if (finishCallback != null){
				finishCallback();
		}
		
		destroy();

	}

	function netClean(){
		
		netStream.dispose();

		completed = true;

		if (FlxG.game.contains(video))
		{
			FlxG.game.removeChild(video);
		}

		trace("Done!");
		completed = true;
	}

	function setSoundTransform(isMuted:Bool){
		if(!isMuted){
			netStream.soundTransform = new SoundTransform(FlxG.sound.volume);
		}
		else{
			netStream.soundTransform = new SoundTransform(0);
		}
	}
	#end

	//===========================================================================================================//

	//Basically just grabbing the bitmap data from the video objects and drawing it to the FlxSprite every so often. 
	override function update(elapsed){

		super.update(elapsed);

		#if hxvlc
		if(waitingStart){

			if(bitmap.bitmapData != null){
				waitingStart = false;
				startDrawing = true;
				onStart.dispatch();
			}
			
		}

		if(startDrawing && !paused){

			if(frameTimer >= 1/MAX_FPS){
				loadGraphic(bitmap.bitmapData);
				frameTimer = 0;
			}
			frameTimer += elapsed;

		}
		#end

		#if web
		if(FlxG.keys.justPressed.MINUS || FlxG.keys.justPressed.PLUS){
			setSoundTransform(__muted);
		}

		if(waitingStart){
			makeGraphic(video.videoWidth, video.videoHeight, FlxColor.TRANSPARENT);
			waitingStart = false;
			startDrawing = true;
			onStart.dispatch();
		}

		if(startDrawing && !paused){

			if(frameTimer >= 1/MAX_FPS){
				pixels.draw(video);
				frameTimer = 0;
			}
			frameTimer += elapsed;

		}
		#end

	}

	override function destroy():Void{

		if(destroyed){
			return;
		}
			
		destroyed = true;

		if (FlxG.autoPause) {
			FlxG.signals.focusLost.remove(pause);
			FlxG.signals.focusGained.remove(resume);
		}

		#if hxvlc
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

	/**
		Pauses playback of the video.
	**/
	public function pause(){

		#if hxvlc
		if(bitmap != null && !paused){
			bitmap.pause();
		}
		#end

		#if web
		if(netStream != null && !paused){
			netStream.pause();
		}
		#end

		paused = true;
	}

	/**
		Resumes playback of the video.
	**/
	public function resume(){

		#if hxvlc
		if(bitmap != null && paused){ 
			bitmap.resume();
		}
		#end

		#if web
		if(netStream != null && paused){ 
			netStream.resume();
		}
		#end

		paused = false;
	}

	public function skip(){

		#if hxvlc
		onVLCComplete();
		#end
		#if web
		finishVideo();
		#end

	}

	private function get_muted():Bool{
		return __muted;
	}

	private function set_muted(value:Bool):Bool{

		#if web
		if(startDrawing){
			setSoundTransform(value);
		}
		#end

		return __muted = value;
	}
	

	function get_length():Float {
		#if hxvlc
		@:privateAccess
			var smthSilly:String = bitmap.length.toString();

		return Std.parseFloat(smthSilly) / 1000;
		#end
		#if web
		@:privateAccess
		return netStream.__video.duration;
		#end
	}
}
