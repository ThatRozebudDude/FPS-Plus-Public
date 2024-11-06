package debug;

import modding.PolymodHandler;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class PolymodReloadDebug extends FlxState
{

	public function new() {
		super();
	}

	override function create() {
		super.create();
	}

	override function update(elapsed:Float) {
		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload();
		}

		super.update(elapsed);
	}
}
