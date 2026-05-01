package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import config.Config;
import Chart.BPMDefinition;

class Conductor extends FlxBasic
{
	public static var bpm:Float = 100;
	public static var songPosition:Float = 0;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var step:Float = 0;
	public static var beat:Float = 0;

	//Reference variables
	static inline final defaultSafeZoneOffset:Float = 160;
	static inline final defaultShitZone:Float = 135;
	static inline final defaultBadZone:Float = 90;
	static inline final defaultGoodZone:Float = 45;

	//Actual timing variables
	public static var safeZoneOffset:Float = 160;
	public static var shitZone:Float = 135;
	public static var badZone:Float = 90;
	public static var goodZone:Float = 45;

	public static var onStepHit:FlxSignal = new FlxSignal();
	public static var onBeatHit:FlxSignal = new FlxSignal();

	public static var bpmChanges:Array<BPMDefinition> = [];

	public inline static function init():Void{
		FlxG.plugins.add(new Conductor());
	}

	public static function reset()
	{
		songPosition = 0;
		step = beat = 0;
		offset = Config.offset;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Conductor.bpmChanges.length < 1 || (songPosition + offset) < 0){
			return;
		}

		var prevStep = Std.int(step);
		var prevBeat = Std.int(beat);

		beat = 0;
		bpm = Conductor.bpmChanges[0].bpm;

		var prevChange = Conductor.bpmChanges[0];
		for(change in Conductor.bpmChanges){
			if((songPosition + offset) >= change.time){
				beat += (change.time - prevChange.time) / (getCrotchet(prevChange.time) * 1000);
				bpm = change.bpm;

				prevChange = change;
			}
		}

		beat += ((songPosition + offset) - prevChange.time) / (getCrotchet(prevChange.time) * 1000);
		step = beat * 4;

		if(Std.int(step) != prevStep){
			onStepHit.dispatch();
		}
		
		if(Std.int(beat) != prevBeat){
			onBeatHit.dispatch();
		}
	}

	public static function setBPMChanges(changes:Array<BPMDefinition>):Void{
		reset();

		bpmChanges = changes.copy();
		bpmChanges.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
		trace("Set up BPM Changes: " + bpmChanges);
	}

	inline public static function resetBPMChanges():Void{
		bpmChanges = [{bpm: bpm, step: 0, time: 0}];
		trace("Clearing BPM Changes");
	}

	public static function getBPMDefine(?position:Float)
	{
		if (position == null){ position = songPosition; }

		var result = bpmChanges[0];
		for(define in Conductor.bpmChanges){
			if(position >= define.time){
				result = define;
			}
		}

		return result;
	}

	public static function getCrotchet(?position:Float):Float{
		return 60 / getBPMDefine(position).bpm;
	}

	public static function getStepCrotchet(?position:Float):Float{
		return getCrotchet(position) / 4;
	}

	/**
	 * Converts a step number to the corresponding time in milliseconds.
	 * Accounts for BPM changes throughout the song.
	 */
	public static function getTimeFromStep(targetStep:Float):Float{
		if(bpmChanges.length < 1) return 0;
		
		var time:Float = 0;
		var currentStep:Float = 0;

		for(i in 0...bpmChanges.length){
			var prevChange = bpmChanges[i];
			var nextChange = i + 1 < bpmChanges.length ? bpmChanges[i + 1] : null;

			var stepDuration:Float;
			if(nextChange != null){
				stepDuration = (nextChange.time - prevChange.time) / (getStepCrotchet(prevChange.time) * 1000);
			}
			else{
				stepDuration = targetStep - currentStep + 1;
			}

			var endStep = currentStep + stepDuration;

			if(targetStep <= endStep){
				var stepInSection = targetStep - currentStep;
				time = prevChange.time + stepInSection * getStepCrotchet(prevChange.time) * 1000;
				break;
			}
			else{
				currentStep = endStep;
				if(nextChange != null){
					time = nextChange.time;
				}
			}
		}

		return time;
	}

	/**
	 * Converts a time in milliseconds to the corresponding step number.
	 * Accounts for BPM changes throughout the song.
	 */
	public static function getStepFromTime(targetTime:Float):Float{
		if(bpmChanges.length < 1 || targetTime <= 0){
			return 0;
		}
		
		var currentStep:Float = 0;
		var lastBPMChange = bpmChanges[bpmChanges.length - 1];
		
		for(i in 0...bpmChanges.length){
			var prevChange = bpmChanges[i];
			var nextChange = i + 1 < bpmChanges.length ? bpmChanges[i + 1] : null;
			
			if(nextChange != null){
				// we are not at the last BPM change yet
				if(targetTime < nextChange.time){
					var timeInSection = targetTime - prevChange.time;
					var stepInSection = timeInSection / (getStepCrotchet(prevChange.time) * 1000);
					return currentStep + stepInSection;
				}
				else{
					var sectionSteps = (nextChange.time - prevChange.time) / (getStepCrotchet(prevChange.time) * 1000);
					currentStep += sectionSteps;
				}
			}
			else{
				// we are at the last BPM change
				var timeInSection = targetTime - prevChange.time;
				var stepInSection = timeInSection / (getStepCrotchet(prevChange.time) * 1000);
				return currentStep + stepInSection;
			}
		}
		
		return currentStep;
	}

	/**
	 * Returns the time in seconds that a beat will last for at the specified BPM.
	 *
	 * @param `_factor`	The multiplier to apply to the hit zone timings.
	 */
	public static function recalculateHitZones(_factor:Float):Void{
		safeZoneOffset = defaultSafeZoneOffset * _factor;
		shitZone = defaultShitZone * _factor;
		badZone = defaultBadZone * _factor;
		goodZone = defaultGoodZone * _factor;
	}
	
	#if BACKWARD_COMPATIBILITY
	public static var crochet(get, never):Float; // beats in milliseconds
	static function get_crochet(){
		return getCrotchet() * 1000;
	}
	public static var stepCrochet(get, never):Float; // steps in milliseconds
	static function get_stepCrochet(){
		return crochet / 4;
	}
	
	public static function changeBPM(newBpm:Float):Void{
		setBPMChanges([{bpm: newBpm, step: 0, time: 0}]);
	}
	#end

}

