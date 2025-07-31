package ui;

import haxe.Json;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var id:Int;

	public var xOffset:Float; //Positive values always move opposite of the side the icon starts on. Ex. 10 on player moves 10 pixels left, 10 on opponent moves 10 pixels right.
	public var yOffset:Float; //This one is normal tho :]

	public var defualtIconScale:Float = 1;
	public var isPlayer:Bool = false;
	public var character:String = "face";

	static final defaultOffsets:Array<Float> = [10, -10];

	public function new(_character:String = 'face', _isPlayer:Bool = false, ?_id:Int = -1){
		
		super();

		isPlayer = _isPlayer;

		setIconCharacter(_character);

		id = _id;
		
		scrollFactor.set();
	}

	override function update(elapsed:Float){

		super.update(elapsed);

		if (sprTracker != null){
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}

	public function bop(_scale:Float, _time:Float, ?_ease:Null<flixel.tweens.EaseFunction>, ?_manager:Null<FlxTweenManager>){

		if(_ease == null){ _ease = FlxEase.linear; }
		if(_manager == null){ _manager = FlxTween.globalManager; }

		_manager.cancelTweensOf(scale);
		scale.set(_scale * defualtIconScale, _scale * defualtIconScale);
		if(_time > 0){
			_manager.tween(scale, {x: defualtIconScale, y: defualtIconScale}, _time, {ease: _ease});
		}
		else{
			scale.set(defualtIconScale, defualtIconScale);
		}

	}

	public function setIconCharacter(character:String){
		var icon = character;
		var subDir = "healthIcons"; //Doing this to make it backwards compatible because I am stupid.

		//Accidentally called the healthIcon folder "heathIcon" and released the modding API with that so I'm making it backwards compatible with the typo (and also the Foolhardy example mod). 
		//Please do not use heathIcon.
		if(!Utils.exists(Paths.file("ui/healthIcons/" + icon, "images", "png"))){
			if(!Utils.exists(Paths.file("ui/heathIcons/" + icon, "images", "png"))){
				trace("No icon exists at ui/healthIcons/" + character + ".png, defaulting to face.");
				icon = "face";
			}
			else{ subDir = "heathIcons"; }
		}

		this.character = icon;

		//This loads the image, gets it's dimensions, and reloads the image with animation based on cutting up the dimensions.
		//Basically you can have any size icon as long as it's evenly cut.

		var graphic = Paths.image("ui/" + subDir + "/" + icon);

		var graphicWidth = Std.int(graphic.width/3);
		var graphicHeight = Std.int(graphic.height);

		loadGraphic(graphic, true, graphicWidth, graphicHeight);
		animation.add("icon", [0, 1, 2], 0, false, isPlayer);
		animation.play("icon");

		xOffset = defaultOffsets[0];
		yOffset = defaultOffsets[1];
		antialiasing = true;
		defualtIconScale = 1;

		//Optional json
		if(Utils.exists("assets/images/ui/" + subDir + "/" + icon + ".json")){
			var iconJson = Json.parse(Utils.getText("assets/images/ui/" + subDir + "/" + icon + ".json"));
			
			if(iconJson.offset != null){
				xOffset = (iconJson.offset.x != null) ? iconJson.offset.x : defaultOffsets[0];
				yOffset = (iconJson.offset.y != null) ? iconJson.offset.y : defaultOffsets[1];
			}

			antialiasing = (iconJson.antialiasing != null) ? iconJson.antialiasing : true;

			defualtIconScale = (iconJson.scale != null) ? iconJson.scale : 1;
		}

		if(isPlayer){
			origin.set(0, frameHeight/2);
		}
		else{
			origin.set(frameWidth, frameHeight/2);
		}

		scale.set(defualtIconScale, defualtIconScale);
	}

}

/* DEFAULT VALUES AS JSON. This is how you format the json.
   If you wanna still use the base game style 150 x 150 icon you should set the x offset to 26 and y offset to 0. 

{
  "offset": {
	"x": 10,
	"y": -10
  },
  "antialiasing": true,
  "scale": 1
}

*/