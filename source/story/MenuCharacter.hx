package story;

import haxe.Json;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String = "";
	var offsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

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
		animation.addByPrefix("confirm", "confirm", 24, false);
		animation.play("idle");

		offsets.clear();
		if(Utils.exists(Paths.json(character, "images/menu/story/characters"))){
			var jsonData = Json.parse(Utils.getText(Paths.json(character, "images/menu/story/characters")));
			if(jsonData.offsets != null){
				for(i in 0...jsonData.offsets.length){
					offsets.set(jsonData.offsets[i].name, jsonData.offsets[i].offset);
				}
			}
		}
	}

	public function playAnim(name:String, ?force:Bool = false):Void{
		animation.play(name, force);

		if(offsets.exists(name)){
			offset.x = offsets.get(name)[0];
			offset.y = offsets.get(name)[1];
		}
		else{
			offset.set(0, 0);
		}
	}
}
