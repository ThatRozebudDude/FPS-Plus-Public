package;

import flixel.util.FlxColor;
import lime.media.AudioBuffer;
import lime.utils.Bytes;
import flixel.sound.FlxSound;
import openfl.geom.Rectangle;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;

/*
Adapted from the waveform code from psych engine.
Originally I used this in Vinyl Girl for the Analog background.
Bleh. 
*/

@:access(flixel.sound.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)

class WaveformSprite extends FlxSprite
{

    public var audioSource:FlxSound;
    public var waveformColor:FlxColor = 0xFFFFFFFF;
    public var waveformSampleLength:Float = 0.5;
    public var waveformDrawStep:Float = 1;
    public var waveformDrawNegativeSpace:Float = 0;
    public var waveformMultiply:Float = 1;

    public var framerate:Float = 60;
    public var uncapFramerate:Bool = false;

    var frametime:Float = 0;

    public override function new(x, y, _width:Int, _height:Int, _audioSource:FlxSound) {
        super(x, y);

        width = _width;
        height = _height;

        makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF);
        audioSource = _audioSource;
    }

    public override function update(elapsed) {
        super.update(elapsed);
        if(active && audioSource.playing){
            if(frametime >= 1/framerate || uncapFramerate){
                updateWaveform();
                frametime = 0;
            }
            else{
                frametime += elapsed;
            }
        }
    }

    var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];

	function updateWaveform() {
		#if desktop
		if(waveformPrinted) {
			makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF);
			pixels.fillRect(new Rectangle(0, 0, width, height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var st:Float = audioSource.time;
		var et:Float = st + (1000 * waveformSampleLength);

		if (audioSource._sound != null && audioSource._sound.__buffer != null) {
			var bytes:Bytes = audioSource._sound.__buffer.data.toBytes();

			wavData = waveformData(
				audioSource._sound.__buffer,
				bytes,
				st,
				et,
				waveformMultiply,
				wavData,
				Std.int(height)
			);
		}

		// Draws
		var gSize:Int = Std.int(width);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var leftLength:Int = (
			wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length
		);

		var rightLength:Int = (
			wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length
		);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length) {
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * waveformDrawStep, (lmin + rmin) + (lmax + rmax), waveformDrawStep - waveformDrawNegativeSpace), waveformColor);
		}

		waveformPrinted = true;
		#end
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>, ?steps:Float):Array<Array<Array<Float>>>
	{
			#if (lime_cffi && !macro)
			if (buffer == null || buffer.data == null) return [[[0], [0]], [[0], [0]]];
	
			var khz:Float = (buffer.sampleRate / 1000);
			var channels:Int = buffer.channels;
	
			var index:Int = Std.int(time * khz);
	
			var samples:Float = ((endTime - time) * khz);
	
			if (steps == null) steps = 1280;
	
			var samplesPerRow:Float = samples / steps;
			var samplesPerRowI:Int = Std.int(samplesPerRow);
	
			var gotIndex:Int = 0;
	
			var lmin:Float = 0;
			var lmax:Float = 0;
	
			var rmin:Float = 0;
			var rmax:Float = 0;
	
			var rows:Float = 0;
	
			var simpleSample:Bool = true;//samples > 17200;
			var v1:Bool = false;
	
			if (array == null) array = [[[0], [0]], [[0], [0]]];
	
			while (index < (bytes.length - 1)) {
				if (index >= 0) {
					var byte:Int = bytes.getUInt16(index * channels * 2);
	
					if (byte > 65535 / 2) byte -= 65535;
	
					var sample:Float = (byte / 65535);
	
					if (sample > 0) {
						if (sample > lmax) lmax = sample;
					} else if (sample < 0) {
						if (sample < lmin) lmin = sample;
					}
	
					if (channels >= 2) {
						byte = bytes.getUInt16((index * channels * 2) + 2);
	
						if (byte > 65535 / 2) byte -= 65535;
	
						sample = (byte / 65535);
	
						if (sample > 0) {
							if (sample > rmax) rmax = sample;
						} else if (sample < 0) {
							if (sample < rmin) rmin = sample;
						}
					}
				}
	
				v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
				while (simpleSample ? v1 : rows >= samplesPerRow) {
					v1 = false;
					rows -= samplesPerRow;
	
					gotIndex++;
	
					var lRMin:Float = Math.abs(lmin) * multiply;
					var lRMax:Float = lmax * multiply;
	
					var rRMin:Float = Math.abs(rmin) * multiply;
					var rRMax:Float = rmax * multiply;
	
					if (gotIndex > array[0][0].length) array[0][0].push(lRMin);
						else array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;
	
					if (gotIndex > array[0][1].length) array[0][1].push(lRMax);
						else array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;
	
					if (channels >= 2) {
						if (gotIndex > array[1][0].length) array[1][0].push(rRMin);
							else array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;
	
						if (gotIndex > array[1][1].length) array[1][1].push(rRMax);
							else array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
					}
					else {
						if (gotIndex > array[1][0].length) array[1][0].push(lRMin);
							else array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;
	
						if (gotIndex > array[1][1].length) array[1][1].push(lRMax);
							else array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
					}
	
					lmin = 0;
					lmax = 0;
	
					rmin = 0;
					rmax = 0;
				}
	
				index++;
				rows++;
				if(gotIndex > steps) break;
			}
	
			return array;
			#else
			return [[[0], [0]], [[0], [0]]];
			#end
	}


}