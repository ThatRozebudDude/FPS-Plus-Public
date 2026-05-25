package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import config.Config;
import Chart.BPMDefinition;

class Conductor extends FlxBasic
{
	public static var bpm(get, never):Float;
	public static var songPosition:Float = 0;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;
	public static var countBeats:Bool = true;

	public static var step:Float = 0;
	public static var beat:Float = 0;

	//Reference variables
	static inline final DEFAULT_SAFE_ZONE:Float = 160;
	static inline final DEFAULT_SHIT_ZONE:Float = 135;
	static inline final DEFAULT_BAD_ZONE:Float = 90;
	static inline final DEFAULT_GOOD_ZONE:Float = 45;

	//Actual timing variables
	public static var safeZoneOffset:Float = 160;
	public static var shitZone:Float = 135;
	public static var badZone:Float = 90;
	public static var goodZone:Float = 45;

	public static var crochet(get, never):Float; // beats in milliseconds
	public static var stepCrochet(get, never):Float; // steps in milliseconds

	public static var onStepHit:FlxSignal = new FlxSignal();
	public static var onBeatHit:FlxSignal = new FlxSignal();

	public static var bpmChanges:Array<BPMDefinition> = [];

	public inline static function init():Void{
		FlxG.plugins.addPlugin(new Conductor());
	}

	public static function reset(){
		songPosition = 0;
		step = -1;
		beat = -1;
		offset = 0;
		countBeats = true;
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		if(Conductor.bpmChanges.length < 1 || (songPosition + offset) < 0 || !countBeats){
			return;
		}

		var prevStep = Math.floor(step);
		var prevBeat = Math.floor(beat);

		step = getStepFromTime();
		beat = step / 4;

		if(Math.floor(step) != prevStep){
			onStepHit.dispatch();
		}
		
		if(Math.floor(beat) != prevBeat){
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
		bpmChanges = [{bpm: bpm, time: 0}];
		trace("Clearing BPM Changes");
	}

	public static function getBPMDefine(?position:Float, ?bpmMap:Array<BPMDefinition>){
		if(position == null){ position = songPosition; }
		if(bpmMap == null)	{ bpmMap = bpmChanges; }

		var result = bpmMap[0];
		for(define in bpmMap){
			if(position >= define.time){
				result = define;
			}
		}

		return result;
	}
	
	public static inline function getCrotchet(?position:Float, ?bpmMap:Array<BPMDefinition>):Float{
		return 60 / getBPMDefine(position, bpmMap).bpm;
	}

	public static inline function getStepCrotchet(?position:Float, ?bpmMap:Array<BPMDefinition>):Float{
		return getCrotchet(position, bpmMap) / 4;
	}

	public static inline function getCrotchetMs(?position:Float, ?bpmMap:Array<BPMDefinition>):Float{
		return getCrotchet(position, bpmMap) * 1000;
	}

	public static inline function getStepCrotchetMs(?position:Float, ?bpmMap:Array<BPMDefinition>):Float{
		return getStepCrotchet(position, bpmMap) * 1000;
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
	public static function getStepFromTime(?targetTime:Float):Float{
		if(targetTime == null){ targetTime = songPosition; }
		if(bpmChanges.length < 1 || targetTime <= 0){ return 0; }
		
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
	 * Recalculates the hit window for notes when the song adjusts it's playback speed.
	 *
	 * @param `_factor`	The multiplier to apply to the hit zone timings.
	 */
	public static function recalculateHitZones(_factor:Float):Void{
		safeZoneOffset = DEFAULT_SAFE_ZONE * _factor;
		shitZone = DEFAULT_SHIT_ZONE * _factor;
		badZone = DEFAULT_BAD_ZONE * _factor;
		goodZone = DEFAULT_GOOD_ZONE * _factor;
	}
	
	static function get_crochet(){
		return getCrotchet() * 1000;
	}
	
	static function get_stepCrochet(){
		return crochet / 4;
	}
	
	public static inline function changeBPM(newBpm:Float):Void{
		setBPMChanges([{bpm: newBpm, time: 0}]);
	}

	static function get_bpm():Float{
		return getBPMDefine().bpm;
	}

	public static inline function getBeatTimeFromBpm(bpm:Float):Float{
		return getCrotchet(0, [{bpm: bpm, time: 0}]);
	}

	public static inline function getStepTimeFromBpm(bpm:Float):Float{
		return getStepCrotchet(0, [{bpm: bpm, time: 0}]);
	}
}

