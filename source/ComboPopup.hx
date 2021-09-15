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

	public var ratingScale:Float = 0.7;
	public var numberScale:Float = 0.6;
	public var breakScale:Float = 0.6;

	public var accelScale:Float = 1;
	public var velocityScale:Float = 1;

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
	public function new(_x:Float, _y:Float, _ratingInfo:Array<Dynamic>, _numberInfo:Array<Dynamic>, _comboBreakInfo:Array<Dynamic>, ?_scale:Array<Float>)
	{
		super(_x, _y);

		ratingInfo = _ratingInfo;
		numberInfo = _numberInfo;
		comboBreakInfo = _comboBreakInfo;

		if(_scale == null){
			_scale = [0.7, 0.6, 0.6];
		}

		setScales(_scale);

	}

	public function setScales(_scale:Array<Float>){

		ratingScale = _scale[0];
		numberScale = _scale[1];
		breakScale = _scale[2];

		numberPosition[Y] = 0 + (numberInfo[HEIGHT] * numberScale) * 1.6;
		breakPosition[Y] = 0 - (comboBreakInfo[HEIGHT] * breakScale) / 2;

	}

	/**
		
	**/
	public function comboPopup(_combo:Int){

		var combo:String = Std.string(_combo);

		for(i in 0...combo.length){

			var digit = new FlxSprite(numberPosition[X] + (numberInfo[WIDTH] * numberScale * i), numberPosition[Y]).loadGraphic(numberInfo[GRAPHIC], true, numberInfo[WIDTH], numberInfo[HEIGHT]);
			digit.setGraphicSize(Std.int(digit.width * numberScale));
			digit.antialiasing = numberInfo[AA];
		
			digit.animation.add("digit", [Std.parseInt(combo.charAt(i))], 0, false);
			digit.animation.play("digit");

			add(digit);

			digit.acceleration.y = FlxG.random.int(150, 250) * accelScale;
			digit.velocity.y -= FlxG.random.int(100, 130) * velocityScale;
			digit.velocity.x = FlxG.random.int(-5, 5) * velocityScale;

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
		ratingSprite.setGraphicSize(Std.int(ratingSprite.width * ratingScale));
		ratingSprite.antialiasing = ratingInfo[AA];
		
		ratingSprite.animation.add("rating", [rating], 0, false);
		ratingSprite.animation.play("rating");

		ratingSprite.acceleration.y = 250 * accelScale;
		ratingSprite.velocity.y -= FlxG.random.int(100, 130) * velocityScale;
		ratingSprite.velocity.x -= FlxG.random.int(-5, 5) * velocityScale;

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
		breakSprite.setGraphicSize(Std.int(breakSprite.width * breakScale));
		breakSprite.antialiasing = ratingInfo[AA];
		
		breakSprite.acceleration.y = 300 * accelScale;
		breakSprite.velocity.y -= FlxG.random.int(80, 130) * velocityScale;
		breakSprite.velocity.x -= FlxG.random.int(-5, 5) * velocityScale;

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
