package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import funkin.vis.dsp.SpectralAnalyzer;
import funkin.vis.audioclip.frontends.LimeAudioClip;

using Lambda;

class ABotVisualizer extends FlxTypedSpriteGroup<FlxSprite>
{
	// public var vis:VisShit;
	public var updateRate:Float = 1/30;
	var updateCount:Float = 0;

	var analyzer:SpectralAnalyzer;

	var volumes:Array<Float> = [];

	public var snd:FlxSound;

	public function new(snd:FlxSound, ?pixel:Bool = false){
		super();

		this.snd = snd;

		// vis = new VisShit(snd);
		// vis.snd = snd;	

		var visCount = pixel ? (7 + 1) : (7 + 1);
		var visScale = pixel ? 6 : 1;

		var visFrms:FlxAtlasFrames = Paths.getSparrowAtlas(pixel ? "week6/abot/aBotVizPixel" : "weekend1/abot/aBotViz");

		// these are the differences in X position, from left to right
		var positionX:Array<Float> = pixel ? [0, 7 * visScale, 8 * visScale, 9 * visScale, 10 * visScale, 6 * visScale, 7 * visScale] : [0, 59, 56, 66, 54, 52, 51];
		var positionY:Array<Float> = pixel ? [0, -2 * visScale, -1 * visScale, 0, 0, 1 * visScale, 2 * visScale] : [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

		for (index in 1...visCount){
			// pushes initial value
			volumes.push(0.0);

			// Sum the offsets up to the current index
			var sum = function(num:Float, total:Float) return total += num;
			var posX:Float = positionX.slice(0, index).fold(sum, 0);
			var posY:Float = positionY.slice(0, index).fold(sum, 0);
	  
			var viz:FlxSprite = new FlxSprite(posX, posY);
			viz.frames = visFrms;
			viz.antialiasing = pixel ? false : true;
			viz.scale.set(visScale, visScale);
			add(viz);
	  
			var visStr = 'viz';
			viz.animation.addByPrefix('VIZ', '$visStr${index}0', 0);
			viz.animation.play('VIZ', false, false, 6);
			viz.visible = false;
		}
	}

	public function initAnalyzer(){
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, 7, 0.1, 40);
		//analyzer.minDb = -65;
		//analyzer.maxDb = -10;
		analyzer.maxFreq = 22000;
		// we use a very low minFreq since some songs use low low subbass like a boss
		analyzer.minFreq = 10;

		#if desktop
		// On desktop it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
	}

	override function update(elapsed:Float){
		updateCount += elapsed;
		super.update(elapsed);
	}

	static inline function min(x:Int, y:Int):Int{
		return x > y ? y : x;
	}

	override function draw(){
		if(updateCount >= updateRate){
			if (analyzer != null) drawFFT();
			updateCount = 0;
		}
		super.draw();
	}

	/**
	 * TJW funkin.vis based visualizer! updateFFT() is the old nasty shit that dont worky!
	 */
	function drawFFT():Void
	{
		var levels = analyzer.getLevels();

		for (i in 0...min(group.members.length, levels.length)){
			var animFrame:Int = Math.round(levels[i].value * 6);
		
			// don't display if we're at 0 volume from the level
			group.members[i].visible = animFrame > 0;
		
			// decrement our animFrame, so we can get a value from 0-5 for animation frames
			animFrame -= 1;
		
			#if desktop
			// Web version scales with the Flixel volume level.
			// This line brings platform parity but looks worse.
			// animFrame = Math.round(animFrame * FlxG.sound.volume);
			#end
		
			animFrame = Math.floor(Math.min(5, animFrame));
			animFrame = Math.floor(Math.max(0, animFrame));
		
			animFrame = Std.int(Math.abs(animFrame - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!
		
			group.members[i].animation.curAnim.curFrame = animFrame;
		}
	}

	// function updateFFT(elapsed:Float)
	// {
	//	 if (vis.snd != null)
	//	 {
	//		 vis.checkAndSetBuffer();
	//		 if (vis.setBuffer)
	//		 {
	//			 var remappedShit:Int = 0;
	//			 if (vis.snd.playing) remappedShit = Std.int(FlxMath.remapToRange(vis.snd.time, 0, vis.snd.length, 0, vis.numSamples));
	//			 else
	//				 remappedShit = Std.int(FlxMath.remapToRange(Conductor.instance.songPosition, 0, vis.snd.length, 0, vis.numSamples));
	//			 var fftSamples:Array<Float> = [];
	//			 var swagBucks = remappedShit;
	//			 for (i in remappedShit...remappedShit + (Std.int((44100 * (1 / 144)))))
	//			 {
	//				 var left = vis.audioData[swagBucks] / 32767;
	//				 var right = vis.audioData[swagBucks + 1] / 32767;
	//				 var balanced = (left + right) / 2;
	//				 swagBucks += 2;
	//				 fftSamples.push(balanced);
	//			 }
	//			 var freqShit = vis.funnyFFT(fftSamples);
	//			 for (i in 0...group.members.length)
	//			 {
	//				 var getSliceShit = function(s:Int) {
	//					 var powShit = FlxMath.remapToRange(s, 0, group.members.length, 0, MathUtil.logBase(10, freqShit[0].length));
	//					 return Math.round(Math.pow(10, powShit));
	//				 };
	//				 // var powShit:Float = getSliceShit(i);
	//				 var hzSliced:Int = getSliceShit(i);
	//				 var sliceLength:Int = Std.int(freqShit[0].length / group.members.length);
	//				 var volSlice = freqShit[0].slice(hzSliced, getSliceShit(i + 1));
	//				 var avgVel:Float = 0;
	//				 for (slice in volSlice)
	//				 {
	//					 avgVel += slice;
	//				 }
	//				 avgVel /= volSlice.length;
	//				 avgVel *= 10000000;
	//				 volumes[i] += avgVel - (elapsed * (volumes[i] * 50));
	//				 var animFrame:Int = Std.int(volumes[i]);
	//				 animFrame = Math.floor(Math.min(5, animFrame));
	//				 animFrame = Math.floor(Math.max(0, animFrame));
	//				 animFrame = Std.int(Math.abs(animFrame - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!
	//				 group.members[i].animation.curAnim.curFrame = animFrame;
	//				 if (FlxG.keys.justPressed.U)
	//				 {
	//					 trace(avgVel);
	//					 trace(group.members[i].animation.curAnim.curFrame);
	//				 }
	//			 }
	//			 // group.members[0].animation.curAnim.curFrame =
	//		 }
	//	 }
	// }
	// public function updateViz()
	// {
	//	 if (vis.snd != null)
	//	 {
	//		 var remappedShit:Int = 0;
	//		 vis.checkAndSetBuffer();
	//		 if (vis.setBuffer)
	//		 {
	//			 // var startingSample:Int = Std.int(FlxMath.remapToRange)
	//			 if (vis.snd.playing) remappedShit = Std.int(FlxMath.remapToRange(vis.snd.time, 0, vis.snd.length, 0, vis.numSamples));
	//			 for (i in 0...group.members.length)
	//			 {
	//				 var sampleApprox:Int = Std.int(FlxMath.remapToRange(i, 0, group.members.length, remappedShit, remappedShit + 500));
	//				 var left = vis.audioData[sampleApprox] / 32767;
	//				 var animFrame:Int = Std.int(FlxMath.remapToRange(left, -1, 1, 0, 6));
	//				 group.members[i].animation.curAnim.curFrame = animFrame;
	//			 }
	//		 }
	//	 }
	// }
}