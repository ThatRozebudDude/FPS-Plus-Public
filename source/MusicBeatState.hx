package;

import Conductor.BPMChangeEvent;
import extensions.flixel.FlxUIStateExt;

class MusicBeatState extends FlxUIStateExt
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var trackedStep:Int = -1;
	private var trackedBeat:Int = -1;

	private var timeSinceLastStep:Float = 1000;
	private var timeSinceLastBeat:Float = 1000;

	private var countSteps:Bool = true;

	override function create(){
		super.create();
	}

	override function update(elapsed:Float){
		if(countSteps){
			var lastChange:BPMChangeEvent = {
				stepTime: 0,
				songTime: 0,
				bpm: 0
			}
			for (i in 0...Conductor.bpmChangeMap.length){
				if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime){
					lastChange = Conductor.bpmChangeMap[i];
				}
			}

			curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
			curBeat = Math.floor(curStep / 4);

			timeSinceLastStep += elapsed;
			timeSinceLastBeat += elapsed;

			if(curStep != trackedStep){
				trackedStep = curStep;
				if(timeSinceLastStep > (Conductor.stepCrochet/1000)/4){
					stepHit();
					timeSinceLastStep = 0;
				}
			}

			if(curBeat != trackedBeat){
				trackedBeat = curBeat;
				if(timeSinceLastBeat > (Conductor.stepCrochet/1000)/4){
					beatHit();
					timeSinceLastBeat = 0;
				}
			}
		}
		super.update(elapsed);
	}

	public function stepHit():Void{}

	public function beatHit():Void{}
	
}