package credits;

import haxe.Json;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class CreditIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(_path:String = 'face'){
		
		super();

		setIconSprite(_path);
		
		scrollFactor.set();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if (sprTracker != null){
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}
	
	public function setIconSprite(path:String){
		if(Utils.exists(Paths.image("menu/credits/" + path))){
			loadGraphic(Paths.image("menu/credits/" + path), false);
		} else {
			loadGraphic(Paths.image("menu/credits/face"), false);
		}
	}
}