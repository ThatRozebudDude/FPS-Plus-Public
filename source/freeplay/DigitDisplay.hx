package freeplay;

import flixel.util.FlxColor;
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

    public var digitColor(default, set):FlxColor = 0xFFFFFFFF;

    var digitScale:Float = 1;
    var spacing:Float = 0;
    var digitCount:Int = 1;
    var digits:Array<Digit> = [];
    var digitPath:String;
    var hasEmptyDigit:Bool;

    public var callback:(String)->Void;

    var totalDistance:Float = 0;
    var offsetMap:Map<String, Float> = new Map<String, Float>();

    public function new(_x:Float, _y:Float, _path:String, _digitCount:Int, ?_scale:Float = 1, ?_spacing:Float = 0, ?_startingNumber:Int = 0, ?_hideTrailingZeroes:Bool = false, ?_hasEmptyDigit:Bool = false) {
        super(_x, _y);
        digitCount = _digitCount;
        digitScale = _scale;
        spacing = _spacing;
        hideTrailingZeroes = _hideTrailingZeroes;
        digitPath = _path;
        hasEmptyDigit = _hasEmptyDigit;

        ease = FlxEase.linear;
        
        tweenValue = FlxTween.tween(this, {}, 0);

        var addDigitCount = digitCount >= 1 ? digitCount : 1;
        for(i in 0...addDigitCount){
            addDigit();
        }

        repositionDigits();
        setNumber(_startingNumber);
    }

    function addDigit():Void{
        var digit:Digit = new Digit(0, 0, digitPath, hasEmptyDigit);
        digit.color = digitColor;
        digits.push(digit);
        add(digit);
    }

    public function repositionDigits():Void{
        for(digit in digits){
            if(digit.ready) { continue; }
            digit.scale.set(digitScale, digitScale);
            digit.updateHitbox();
            digit.setOffset();
            digit.x = x + totalDistance;
            digit.ready = true;
            totalDistance += digit.width + (spacing * digitScale);
        }
    }

    public function setNumber(number:Int, ?forceAllDigitsToAnimate:Bool = false, ?dontExitOnSameNumber:Bool = false) {
        var newNumber = ""+number;

        if(digitCount >= 0){
            if(newNumber.length < digitCount){
                while(newNumber.length < digitCount){
                    newNumber = "-" + newNumber;
                }
            }
            else if(newNumber.length > digitCount){
                newNumber = newNumber.substr(newNumber.length - digitCount);
            }
        }
        else{
            if(newNumber.length < digits.length){
                while(newNumber.length < digits.length){
                    newNumber = "-" + newNumber;
                }
            }
            else{
                while(newNumber.length > digits.length){
                    addDigit();
                }
                for(key => value in offsetMap){
                    setDigitOffset(key, value);
                }
                repositionDigits();
            }
        }

        if(newNumber == numString && !dontExitOnSameNumber){ return; }
        else{ numString = newNumber; }

        if(callback != null){ callback(numString); }
        
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

    public function setDigitOffset(number:String, offset:Float) {
        for(i in 0...digits.length){
            offsetMap.set(number, offset);
            digits[i].offsetMap.set(number, offset);
            digits[i].setOffset();
        }
    }

    function set_digitColor(value:FlxColor):FlxColor {
        digitColor = value;
        for(digit in digits){ digit.color = value; }
        return value;
    }
}

class Digit extends FlxSprite
{

    static final numberString:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    public var offsetMap:Map<String, Float> = new Map<String, Float>();
    public var ready:Bool = false;

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