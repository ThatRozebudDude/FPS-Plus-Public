package;

import extensions.flixel.FlxUIStateExt;

class MusicBeatState extends FlxUIStateExt
{
	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	override function create(){
		super.create();

		Conductor.onStepHit.add(onStep);
		Conductor.onBeatHit.add(onBeat);
	}

	override function update(elapsed:Float){
		super.update(elapsed);
	}

	private function onStep():Void{
		curStep = Math.floor(Conductor.step);
		stepHit();
	}

	private function onBeat():Void{
		curBeat = Math.floor(Conductor.beat);
		beatHit();
	}

	public function stepHit():Void{}

	public function beatHit():Void{}
	
	override public function destroy(){
		Conductor.onStepHit.remove(onStep);
		Conductor.onBeatHit.remove(onBeat);

		super.destroy();
	}
}