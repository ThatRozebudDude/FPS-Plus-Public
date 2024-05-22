package freeplay;

import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class DigitDisplay extends FlxSpriteGroup
{
    var numString:String;
    var hideTrailingZeroes:Bool;
    var tweenValue:FlxTween;

    var digitScale:Float = 1;
    var spacing:Float = 0;
    var digitCount:Int = 1;
    var digits:Array<Digit> = [];

    public function new(_x:Float, _y:Float, _path:String, _digitCount:Int, ?_scale:Float = 1, ?_spacing:Float = 0, ?_startingNumber:Int = 0, ?_hideTrailingZeroes:Bool = false) {
        super(_x, _y);
        digitCount = _digitCount;
        digitScale = _scale;
        spacing = _spacing;
        hideTrailingZeroes = _hideTrailingZeroes;

        tweenValue = FlxTween.tween(this, {}, 0);

        for(i in 0...digitCount){

            var digit:Digit = new Digit(0, 0, _path);
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
                numString = "0" + numString;
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
            if(hideTrailingZeroes && i != (numString.length - 1) && numString.charAt(i) == "0"){
                if(i > 0){
                    digits[i].visible = (numString.charAt(i-1) != "0");
                }
                else{
                    digits[i].visible = false;
                }
            }
        }
    }

    public function tweenNumber(newNumber:Int, tweenTime:Float, ?force:Bool = false) {
        tweenValue.cancel();
        var value = Std.parseFloat(numString);
        tweenValue = FlxTween.num(value, newNumber, tweenTime, {}, function(v){
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

typedef TweenValue = {
    value:Int
}

class Digit extends FlxSprite
{

    static final numberString:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    public var offsetMap:Map<String, Float> = new Map<String, Float>();

    public function new(_x:Float, _y:Float, _path:String) {
        super(_x, _y);
        frames = Paths.getSparrowAtlas(_path);
        
        for(i in 0...numberString.length){
            animation.addByPrefix(""+i, numberString[i], 24, false);
            offsetMap.set(""+i, 0);
        }
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