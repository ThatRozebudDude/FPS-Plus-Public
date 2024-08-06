package;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class ComboPopup extends FlxSpriteGroup
{

	//public var ratingPosition:Array<Float> = [0.0, 0.0];
	//public var numberPosition:Array<Float> = [0.0, 0.0];
	//public var breakPosition:Array<Float> = [0.0, 0.0];

	//public var ratingScale:Float = 0.7;
	//public var numberScale:Float = 0.6;
	//public var breakScale:Float = 0.6;

	public var numberKerning:Float = 5;

	public var accelScale:Float = 1;
	public var velocityScale:Float = 1;

	public var ratingInfo:PopupInfo;
	public var numberInfo:PopupInfo;
	public var comboBreakInfo:PopupInfo;

	static final ratingList = ["sick", "good", "bad", "shit"];

	/**
		The info arrays should be filled with [FlxGraphicAsset, Frame Width, Frame Height, Antialiasing]
		Scales go in order of [Ratings, Numbers, Combo Break]
	**/
	public function new(_x:Float, _y:Float, _ratingInfo:PopupInfo, _numberInfo:PopupInfo, _comboBreakInfo:PopupInfo)
	{
		super(_x, _y);

		ratingInfo = _ratingInfo;
		numberInfo = _numberInfo;
		comboBreakInfo = _comboBreakInfo;

		/*if(_scale == null){
			_scale = [0.7, 0.6, 0.6];
		}

		setScales(_scale, false);*/

	}

	/**
		Sets the scales for all the elements and re-aligns them.
	**/
	/*public function setScales(_scale:Array<Float>, ?positionReset:Bool = true):Void{

		if(positionReset){
			numberPosition[Y] -= (numberInfo[HEIGHT] * numberScale) * 1.6;
			breakPosition[Y] += (comboBreakInfo[HEIGHT] * breakScale) / 2;
		}

		ratingScale = _scale[0];
		numberScale = _scale[1];
		breakScale = _scale[2];

		numberPosition[Y] += (numberInfo[HEIGHT] * numberScale) * 1.6;
		breakPosition[Y] -= (comboBreakInfo[HEIGHT] * breakScale) / 2;

	}*/

	/**
		Causes the combo count to pop up with the given integer. Returns without effect if the integer is less than 0.
	**/
	public function comboPopup(_combo:Int):Void{

		if(_combo < 0) { return; }

		var combo:String = Std.string(_combo);

		var numbersToAdd:Array<FlxSprite> = [];

		var totalWidth:Float = 0;
		for(i in 0...combo.length){

			var digit = new FlxSprite((numberInfo.position.x + totalWidth + (numberKerning * i)), numberInfo.position.y).loadGraphic(Paths.image(numberInfo.path + "/" + combo.charAt(i)), false);
			totalWidth += (digit.width * numberInfo.scale);
			digit.setGraphicSize(Std.int(digit.width * numberInfo.scale));
			digit.updateHitbox();
			digit.antialiasing = numberInfo.aa;

			digit.acceleration.y = FlxG.random.int(150, 250) * accelScale;
			digit.velocity.y -= FlxG.random.int(100, 130) * velocityScale;
			digit.velocity.x = FlxG.random.int(-5, 5) * velocityScale;

			PlayState.instance.tweenManager.tween(digit, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween){
					digit.destroy();
				},
				startDelay: Conductor.crochet * 0.00075
			});

			numbersToAdd.push(digit);

		}

		for(num in numbersToAdd){ add(num); }
		return;
	}

	/**
		Causes a note rating to pop up with the specified rating. Returns without effect if the rating isn't in `ratingList`.
	**/
	public function ratingPopup(_rating:String):Void{

		var rating = ratingList.indexOf(_rating);
		if(rating == -1){ return; }
		
		var ratingSprite = new FlxSprite(ratingInfo.position.x, ratingInfo.position.y).loadGraphic(Paths.image(ratingInfo.path + "/" + _rating), false);
		ratingSprite.setGraphicSize(Std.int(ratingSprite.width * ratingInfo.scale));
		ratingSprite.updateHitbox();
		ratingSprite.x -= ratingSprite.width/2;
		ratingSprite.y -= ratingSprite.height/2;
		ratingSprite.antialiasing = ratingInfo.aa;
		
		ratingSprite.acceleration.y = 250 * accelScale;
		ratingSprite.velocity.y -= FlxG.random.int(100, 130) * velocityScale;
		ratingSprite.velocity.x -= FlxG.random.int(-5, 5) * velocityScale;
		
		PlayState.instance.tweenManager.tween(ratingSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween){
				ratingSprite.destroy();
			},
			startDelay: Conductor.crochet * 0.00075
		});
		
		add(ratingSprite);
		return;
	}

	/**
		Causes the combo broken text to pop up.
	**/
	public function breakPopup():Void{

		var breakSprite = new FlxSprite(comboBreakInfo.position.x, comboBreakInfo.position.y).loadGraphic(Paths.image(comboBreakInfo.path), false);
		breakSprite.setGraphicSize(Std.int(breakSprite.width * comboBreakInfo.scale));
		breakSprite.updateHitbox();
		breakSprite.x -= breakSprite.width/2;
		breakSprite.y -= breakSprite.height/2;
		breakSprite.antialiasing = comboBreakInfo.aa;
		
		breakSprite.acceleration.y = 300 * accelScale;
		breakSprite.velocity.y -= FlxG.random.int(80, 130) * velocityScale;
		breakSprite.velocity.x -= FlxG.random.int(-5, 5) * velocityScale;
		
		PlayState.instance.tweenManager.tween(breakSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween){
				breakSprite.destroy();
			},
			startDelay: Conductor.crochet * 0.0015
		});
		
		add(breakSprite);
		return;
	}
}

typedef PopupInfo = {
	path:String,
	position:FlxPoint,
	aa:Bool,
	scale:Float
}