package ui;

import haxe.Json;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import metadata.ImageMetadata;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var id:Int;

	public var xOffset:Float; //Positive values always move opposite of the side the icon starts on. Ex. 10 on player moves 10 pixels left, 10 on opponent moves 10 pixels right.
	public var yOffset:Float; //This one is normal tho :]

	public var defualtIconScale:Float = 1;
	public var iconScale:Float = 1;
	public var iconSize:Float;
	public var isPlayer:Bool = false;
	public var character:String = "face";

	private var tween:FlxTween;

	static final defaultOffsets:Array<Float> = [10, -10];

	public function new(_character:String = 'face', _isPlayer:Bool = false, ?_id:Int = -1){
		
		super();

		isPlayer = _isPlayer;

		if(Utils.exists(Paths.file("ui/heathIcons/" + _character, "images", "png"))){
			character = _character;
		}
		else{
			trace("No icon exists at ui/heathIcons/" + _character + ".png, defaulting to face.");
		}

		setIconCharacter(character);

		iconSize = width;

		id = _id;
		
		scrollFactor.set();

		tween = FlxTween.tween(this, {}, 0);
	}

	override function update(elapsed:Float){

		super.update(elapsed);
		setGraphicSize(iconSize * iconScale);
		updateHitbox();

		if (sprTracker != null){
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}

	public function tweenToDefaultScale(_time:Float, _ease:Null<flixel.tweens.EaseFunction>){

		tween.cancel();
		tween = FlxTween.tween(this, {iconScale: this.defualtIconScale}, _time, {ease: _ease});

	}

	public function setIconCharacter(character:String){
		//This loads the image, gets it's dimensions, and reloads the image with animation based on cutting up the dimensions.
		//Basically you can have any size icon as long as it's evenly cut.

		loadGraphic(Paths.image("ui/heathIcons/" + character), false);

		var graphicWidth = Std.int(pixels.width/3);
		var graphicHeight = Std.int(pixels.height);

		loadGraphic(pixels, true, graphicWidth, graphicHeight);
		animation.add("icon", [0, 1, 2], 0, false, isPlayer);
		animation.play("icon");

		xOffset = defaultOffsets[0];
		yOffset = defaultOffsets[1];
		antialiasing = true;

		//Optional json
		var iconJson:ImageMetadata = new ImageMetadata("ui/heathIcons/" + character);
		xOffset = iconJson.offset[0];
		yOffset = iconJson.offset[0];

		antialiasing = iconJson.antialiasing;

		iconSize = width;
	}

}

/* DEFAULT VALUES AS JSON. This is how you format the json.
   If you wanna still use the base game style 150 x 150 icon you should set the x offset to 26 and y offset to 0. 

{
  "offset": {
    "x": 10,
    "y": -10
  },
  "antialiasing": true
}

*/