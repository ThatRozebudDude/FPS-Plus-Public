package story;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	static final playerCharacterList = ["bf", "pico-player"];
	public var character:String = "";

	public function new(x:Float, y:Float, character:String = 'bf'){
		super(x, y);
		setCharacter(character);
		antialiasing = true;
	}

	public function setCharacter(_character:String):Void{
		if(character == _character) {return;}
		character = _character;
		frames = Paths.getSparrowAtlas("menu/story/characters/" + character);
		animation.addByPrefix("idle", "idle", 24);
		if(playerCharacterList.contains(character)){
			animation.addByPrefix("confirm", "confirm", 24, false);
		}
		animation.play("idle");
		centerOffsets();
	}
}
