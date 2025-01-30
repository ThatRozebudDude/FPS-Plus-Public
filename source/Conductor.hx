package;

import Song.SwagSong;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

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

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new(){}

	public static function mapBPMChanges(song:SwagSong){
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float){
		bpm = newBpm;
		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
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

	/**
	 * Returns the time in seconds that a beat will last for at the specified BPM.
	 *
	 * @param `_bpm`	The BPM it will calculate the beat time for.
	 */
	public static inline function getBeatTimeFromBpm(_bpm:Float):Float{
		return ((60 / _bpm));
	}

}

