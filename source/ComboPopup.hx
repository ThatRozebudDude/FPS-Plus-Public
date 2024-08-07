package;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class ComboPopup extends FlxSpriteGroup
{

	public var numberKerning:Float = 5;

	public var accelScale:Float = 1;
	public var velocityScale:Float = 1;

	public var ratingInfo:PopupInfo;
	public var numberInfo:PopupInfo;
	public var comboBreakInfo:PopupInfo;

	public var limitSprites:Bool = false;

	static final ratingList = ["sick", "good", "bad", "shit"];

	public function new(_x:Float, _y:Float, _ratingInfo:PopupInfo, _numberInfo:PopupInfo, _comboBreakInfo:PopupInfo)
	{
		super(_x, _y);

		ratingInfo = _ratingInfo;
		numberInfo = _numberInfo;
		comboBreakInfo = _comboBreakInfo;

	}

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
			digit.ID = 0;

			digit.acceleration.y = FlxG.random.int(150, 250) * accelScale;
			digit.velocity.y -= FlxG.random.int(100, 130) * velocityScale;
			digit.velocity.x = FlxG.random.int(-5, 5) * velocityScale;

			PlayState.instance.tweenManager.tween(digit, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween){
					digit.destroy();
				},
				startDelay: (Conductor.crochet/1000) //* 0.75
			});

			numbersToAdd.push(digit);

		}

		if(limitSprites){
			for(obj in members){
				if(obj.ID == 0){
					PlayState.instance.tweenManager.cancelTweensOf(obj);
					obj.destroy();
				}
			}
		}
		for(num in numbersToAdd){ add(num); }
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
		ratingSprite.ID = 1;
		
		ratingSprite.acceleration.y = 250 * accelScale;
		ratingSprite.velocity.y -= FlxG.random.int(100, 130) * velocityScale;
		ratingSprite.velocity.x -= FlxG.random.int(-5, 5) * velocityScale;
		
		PlayState.instance.tweenManager.tween(ratingSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween){
				ratingSprite.destroy();
			},
			startDelay: (Conductor.crochet/1000) //* 0.75
		});
		
		if(limitSprites){
			for(obj in members){
				if(obj.ID == 1){
					PlayState.instance.tweenManager.cancelTweensOf(obj);
					obj.destroy();
				}
			}
		}
		add(ratingSprite);
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
		breakSprite.ID = 2;
		
		breakSprite.acceleration.y = 300 * accelScale;
		breakSprite.velocity.y -= FlxG.random.int(80, 130) * velocityScale;
		breakSprite.velocity.x -= FlxG.random.int(-5, 5) * velocityScale;
		
		PlayState.instance.tweenManager.tween(breakSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween){
				breakSprite.destroy();
			},
			startDelay: (Conductor.crochet/1000) * 1.5
		});
		
		if(limitSprites){
			for(obj in members){
				if(obj.ID == 2){
					PlayState.instance.tweenManager.cancelTweensOf(obj);
					obj.destroy();
				}
			}
		}
		add(breakSprite);
	}
}

typedef PopupInfo = {
	path:String,
	position:FlxPoint,
	aa:Bool,
	scale:Float
}