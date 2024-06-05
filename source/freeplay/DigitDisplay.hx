package freeplay;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

using StringTools;

class DigitDisplay extends FlxSpriteGroup
{
    var numString:String;
    var hideTrailingZeroes:Bool;
    var tweenValue:FlxTween;

    public var ease:Null<flixel.tweens.EaseFunction>;

    var digitScale:Float = 1;
    var spacing:Float = 0;
    var digitCount:Int = 1;
    var digits:Array<Digit> = [];

    public function new(_x:Float, _y:Float, _path:String, _digitCount:Int, ?_scale:Float = 1, ?_spacing:Float = 0, ?_startingNumber:Int = 0, ?_hideTrailingZeroes:Bool = false, ?_hasEmptyDigit:Bool = false) {
        super(_x, _y);
        digitCount = _digitCount;
        digitScale = _scale;
        spacing = _spacing;
        hideTrailingZeroes = _hideTrailingZeroes;

        ease = FlxEase.linear;
        
        tweenValue = FlxTween.tween(this, {}, 0);

        for(i in 0...digitCount){

            var digit:Digit = new Digit(0, 0, _path, _hasEmptyDigit);
            digits.push(digit);
            add(digit);

        }

        repositionDigits();
        setNumber(_startingNumber);
    }

    public function repositionDigits():Void{
        var totalDistance:Float = 0;
        for(digit in digits){
            digit.scale.set(digitScale, digitScale);
            digit.updateHitbox();
            digit.setOffset();
            digit.x = x + totalDistance;
            totalDistance += digit.width + (spacing * digitScale);
        }
    }

    public function setNumber(number:Int, ?forceAllDigitsToAnimate:Bool = false) {
        numString = ""+number;
        if(numString.length < digitCount){
            while(numString.length < digitCount){
                numString = "-" + numString;
            }
        }
        else if(numString.length > digitCount){
            numString = numString.substr(numString.length - digitCount);
        }
        
        for(i in 0...numString.length){
            digits[i].visible = true;
            if(digits[i].animation.curAnim.name != numString.charAt(i) || forceAllDigitsToAnimate){
                digits[i].animation.play(numString.charAt(i));
            }
            if(hideTrailingZeroes && numString.charAt(i) == "-"){
                digits[i].visible = false;
            }
        }
    }

    public function tweenNumber(newNumber:Int, tweenTime:Float, ?force:Bool = false) {
        tweenValue.cancel();
        var value = Std.parseFloat(numString.replace("-", "0"));
        tweenValue = FlxTween.num(value, newNumber, tweenTime, {ease: ease}, function(v){
            setNumber(Std.int(v), force);
        });
    }

    public function setDigitOffset(number:Int, offset:Float) {
        for(i in 0...numString.length){
            digits[i].offsetMap.set(""+number, offset);
            digits[i].setOffset();
        }
    }
}

class Digit extends FlxSprite
{

    static final numberString:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    public var offsetMap:Map<String, Float> = new Map<String, Float>();

    public function new(_x:Float, _y:Float, _path:String, _hasEmptyDigit:Bool) {
        super(_x, _y);
        frames = Paths.getSparrowAtlas(_path);
        
        for(i in 0...numberString.length){
            animation.addByPrefix(""+i, numberString[i], 24, false);
            offsetMap.set(""+i, 0);
        }
        //Whether the empty digit has a unique sprite or not.
        if(_hasEmptyDigit){ animation.addByPrefix("-", "DISABLED", 24, false); }
        else{ animation.addByPrefix("-", "ZERO", 24, false); }
        offsetMap.set("-", 0);

        animation.play(""+0, true);

        animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
            setOffset();
        }

        antialiasing = true;
    }

    public function setOffset():Void{
        centerOffsets();
        offset.x += offsetMap.get(animation.curAnim.name) * scale.x;
    }

}