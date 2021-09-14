package;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class ComboPopup extends FlxSpriteGroup
{

	public var ratingPosition:Array<Float> = [0.0, 0.0];
	public var numberPosition:Array<Float> = [0.0, 0.0];
	public var breakPosition:Array<Float> = [0.0, 0.0];

	public var graphicScale:Float = 0.75;

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

	/**
		The info arrays should be filled with [FlxGraphicAsset, Frame Width, Frame Height, Antialiasing]
	**/
	public function new(_x:Float, _y:Float, _ratingInfo:Array<Dynamic>, _numberInfo:Array<Dynamic>, _comboBreakInfo:Array<Dynamic>, ?_scale:Float = 0.75)
	{
		super(_x, _y);

		ratingInfo = _ratingInfo;
		numberInfo = _numberInfo;
		comboBreakInfo = _comboBreakInfo;

		graphicScale = _scale;

		numberPosition[Y] += (numberInfo[HEIGHT] * graphicScale) * 1.6;
		breakPosition[Y] -= (comboBreakInfo[HEIGHT] * graphicScale) / 2;

	}

	override function update(elapsed:Float){

		super.update(elapsed);

	}

	/**
		
	**/
	public function comboPopup(_combo:Int){

		var combo:String = Std.string(_combo);

		for(i in 0...combo.length){

			var digit = new FlxSprite(numberPosition[X] + (numberInfo[WIDTH] * graphicScale * i), numberPosition[Y]).loadGraphic(numberInfo[GRAPHIC], true, numberInfo[WIDTH], numberInfo[HEIGHT]);
			digit.scale.set(graphicScale, graphicScale);
			digit.antialiasing = numberInfo[AA];
		
			digit.animation.add("digit", [Std.parseInt(combo.charAt(i))], 0, false);
			digit.animation.play("digit");

			add(digit);

			digit.acceleration.y = FlxG.random.int(150, 250);
			digit.velocity.y -= FlxG.random.int(100, 130);
			digit.velocity.x = FlxG.random.int(-5, 5);

			FlxTween.tween(digit, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween){
					digit.destroy();
				},
				startDelay: Conductor.crochet * 0.00075
			});

		}

		return;

	}

	/**
		
	**/
	public function ratingPopup(_rating:String){

		var rating = ratingList.indexOf(_rating);
		if(rating == -1){ return; }
		
		var ratingSprite = new FlxSprite(ratingPosition[X], ratingPosition[Y]).loadGraphic(ratingInfo[GRAPHIC], true, ratingInfo[WIDTH], ratingInfo[HEIGHT]);
		ratingSprite.scale.set(graphicScale, graphicScale);
		ratingSprite.antialiasing = ratingInfo[AA];
		
		ratingSprite.animation.add("rating", [rating], 0, false);
		ratingSprite.animation.play("rating");

		ratingSprite.acceleration.y = 250;
		ratingSprite.velocity.y -= FlxG.random.int(100, 130);
		ratingSprite.velocity.x -= FlxG.random.int(-5, 5);

		add(ratingSprite);

		FlxTween.tween(ratingSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween){
				ratingSprite.destroy();
			},
			startDelay: Conductor.crochet * 0.00075
		});

		return;

	}

	/**
		
	**/
	public function breakPopup(){

		var breakSprite = new FlxSprite(breakPosition[X], breakPosition[Y]).loadGraphic(comboBreakInfo[GRAPHIC]);
		breakSprite.scale.set(graphicScale, graphicScale);
		breakSprite.antialiasing = ratingInfo[AA];
		
		breakSprite.acceleration.y = 300;
		breakSprite.velocity.y -= FlxG.random.int(80, 130);
		breakSprite.velocity.x -= FlxG.random.int(-5, 5);

		add(breakSprite);

		FlxTween.tween(breakSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween){
				breakSprite.destroy();
			},
			startDelay: Conductor.crochet * 0.0015
		});

		return;

	}
}
