package;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class ComboPopup extends FlxSpriteGroup
{

	public var ratingPosition:Array<Float> = [0,0];
	public var scorePosition:Array<Float> = [0,0];
	public var breakPosition:Array<Float> = [0,0];

	var ratingInfo:Array<Dynamic>;
	var numberInfo:Array<Dynamic>;
	var comboBreakInfo:Array<Dynamic>;


	private static final GRAPHIC = 0;
	private static final WIDTH = 1;
	private static final HEIGHT = 2;
	private static final AA = 3;

	private static final X = 0;
	private static final Y = 1;

	private static final ratingList = ["sick", "good", "bad", "shit"];

	public function new(_x:Float, _y:Float, _ratingInfo:Array<Dynamic>, _numberInfo:Array<Dynamic>, _comboBreak:FlxGraphicAsset)
	{
		super(_x, _y);
	}

	override function update(elapsed:Float){

		super.update(elapsed);

	}

	public function comboPopup(_combo:Int){

		var combo:String = Std.string(_combo);

		for(i in 0...combo.length){
			
		}

		return;

	}

	public function ratingPopup(_rating:String){

		if(!ratingList.contains(_rating)){ return; }
		
		var ratingSprite = new FlxSprite(ratingPosition[X], ratingPosition[Y]).loadGraphic(ratingInfo[GRAPHIC], true, ratingInfo[WIDTH], ratingInfo[HEIGHT]);
		ratingSprite.antialiasing = ratingInfo[AA];
		
		ratingSprite.animation.add("sick", [0], 0, false);
		ratingSprite.animation.add("good", [1], 0, false);
		ratingSprite.animation.add("bad", [2], 0, false);
		ratingSprite.animation.add("shit", [3], 0, false);

		ratingSprite.animation.play(_rating);
		ratingSprite.acceleration.y = 550;
		ratingSprite.velocity.y -= FlxG.random.int(140, 175);
		ratingSprite.velocity.x -= FlxG.random.int(0, 10);

		return;

	}

	public function broken(){

		return;

	}
}
