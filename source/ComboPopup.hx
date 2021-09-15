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

	@:noCompletion public var ratingInfo:Array<Dynamic>;
	@:noCompletion public var numberInfo:Array<Dynamic>;
	@:noCompletion public var comboBreakInfo:Array<Dynamic>;


	@:noCompletion public static final GRAPHIC = 0;
	@:noCompletion public static final WIDTH = 1;
	@:noCompletion public static final HEIGHT = 2;
	@:noCompletion public static final AA = 3;

	@:noCompletion public static final X = 0;
	@:noCompletion public static final Y = 1;

	@:noCompletion public static final ratingList = ["sick", "good", "bad", "shit"];

	/**
		The info arrays should be filled with [FlxGraphicAsset, Frame Width, Frame Height, Antialiasing]
		Scales go in order of [Ratings, Numbers, Combo Break]
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

		setScales(_scale, false);

	}

	/**
		Sets the scales for all the elements and re-aligns them.
	**/
	public function setScales(_scale:Array<Float>, ?positionReset:Bool = true):Void{

		if(positionReset){
			numberPosition[Y] -= (numberInfo[HEIGHT] * numberScale) * 1.6;
			breakPosition[Y] += (comboBreakInfo[HEIGHT] * breakScale) / 2;
		}

		ratingScale = _scale[0];
		numberScale = _scale[1];
		breakScale = _scale[2];

		numberPosition[Y] += (numberInfo[HEIGHT] * numberScale) * 1.6;
		breakPosition[Y] -= (comboBreakInfo[HEIGHT] * breakScale) / 2;

	}

	/**
		Causes the combo count to pop up with the given integer. Returns without effect if the integer is less than 0.
	**/
	public function comboPopup(_combo:Int):Void{

		if(_combo < 0) { return; }

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
		Causes a note rating to pop up with the specified rating. Returns without effect if the rating isn't in `ratingList`.
	**/
	public function ratingPopup(_rating:String):Void{

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
		Causes the combo broken text to pop up.
	**/
	public function breakPopup():Void{

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
