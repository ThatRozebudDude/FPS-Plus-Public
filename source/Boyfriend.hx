package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

//we will not be using boyfriend.hx anymore hehehehehehe
//I'll probably delete it later but i wanna keep it for now just incase i fuck everything up
class Boyfriend extends Character
{

	public function new(x:Float, y:Float, ?char:String = 'bf'){
		super(x, y, char, true);
	}

	override function update(elapsed:Float){
		super.update(elapsed);
	}
}
