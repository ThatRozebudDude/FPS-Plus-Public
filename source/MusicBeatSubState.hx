package;

import Chart.BPMDefinition;
import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState
{
	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	override function create(){
		super.create();

		Conductor.onStepHit.add(stepHit);
		Conductor.onBeatHit.add(beatHit);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		#if BACKWARD_COMPATIBILITY
		curStep = Std.int(Conductor.step);
		curBeat = Std.int(Conductor.beat);
		#end
	}

	public function stepHit():Void{}

	public function beatHit():Void{}

	override public function destroy(){
		Conductor.onStepHit.remove(stepHit);
		Conductor.onBeatHit.remove(beatHit);

		super.destroy();
	}

}