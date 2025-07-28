package freeplay;

import transition.data.FadeIn;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

class DifficultyIndicator extends FlxSpriteGroup
{

	public var count:Int = 0;
	var dots:Array<FlxSprite> = [];
	var difficultyToIndexMap:Map<String, Int> = new Map<String, Int>();
	
	public function new(_x:Float, _y:Float) {
		super(_x, _y);

		for(i in 0...3){
			var dot = new FlxSprite(20 * i, 0).loadGraphic(Paths.image("menu/freeplay/difficultyIndicator"));
			dot.antialiasing = true;
			dots.push(dot);
			add(dot);
		}

		count = 3;
	}

	public function setIndicator(diff:String, doTween:Bool = true):Void{
		var index = -1;
		if(difficultyToIndexMap.exists(diff)){index = difficultyToIndexMap.get(diff);}
		for(i in 0...dots.length){
			if(i == index){
				FlxTween.cancelTweensOf(dots[i]);
				if(doTween){
					FlxTween.color(dots[i], 0.2, dots[i].color, 0xFFFFFFFF, {ease: FlxEase.quintOut});
				}
				else{
					dots[i].color = 0xFFFFFFFF;
				}
			}
			else{
				FlxTween.cancelTweensOf(dots[i]);
				if(doTween){
					FlxTween.color(dots[i], 0.4, dots[i].color, 0xFF41374D, {ease: FlxEase.quintOut});
				}
				else{
					dots[i].color = 0xFF41374D;
				}
			}
		}
	}

	public function setDifficulties(diffList:Array<Int>):Void{
		difficultyToIndexMap.clear();
		for(dot in dots){ dot.visible = false; }
		for(i in 0...diffList.length){
			difficultyToIndexMap.set(FreeplayState.diffNumberToDiffName(diffList[i]), i);
			dots[i].visible = true;
		}
		count = diffList.length;
	}

}