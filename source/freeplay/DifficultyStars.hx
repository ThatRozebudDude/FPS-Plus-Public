package freeplay;

import transition.data.FadeIn;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

class DifficultyStars extends FlxSpriteGroup
{

	var stars:Array<FlxSprite> = [];
	var flames:Array<FlxSprite> = [];

	static final starPositionOffset:FlxPoint = new FlxPoint(27, 5);
	static final flamePositionOffset:FlxPoint = new FlxPoint(-31, -120);
	
	public function new(_x:Float, _y:Float) {
		super(_x, _y);

		var prevRandomFpsStart = 0;
		var prevRandomFpsLoop = 0;
		for(i in 0...10){
			var star = new FlxSprite(starPositionOffset.x * i, starPositionOffset.y * i).loadGraphic(Paths.image("menu/freeplay/difficultyStar"), true, 56, 56);
			star.animation.add("on", [0], 0, false);
			star.animation.add("blue", [1], 0, false);
			star.animation.add("off", [2], 0, false);
			star.animation.play("off");
			star.antialiasing = true;
			stars.push(star);

			var randomFpsStart = FlxG.random.int(18, 30, [prevRandomFpsStart]);
			var randomFpsLoop = FlxG.random.int(22, 26, [prevRandomFpsLoop]);
			prevRandomFpsStart = randomFpsStart;
			prevRandomFpsLoop = randomFpsLoop;
			
			var flame = new FlxSprite((starPositionOffset.x * i) + flamePositionOffset.x, (starPositionOffset.y * i) + flamePositionOffset.y);
			flame.frames = Paths.getSparrowAtlas("menu/freeplay/freeplayFlame");
			flame.animation.addByIndices("start", "fire loop full instance 1", [0, 1], "", randomFpsStart, false);
			flame.animation.addByIndices("loop", "fire loop full instance 1", [2, 3, 4, 5, 6, 7, 8, 9], "", randomFpsLoop, true);
			flame.animation.play("loop");
			flame.visible = false;
			flame.antialiasing = true;
			flame.origin.set(60, 150);
			flame.scale.set(0.8, 0.8);
			flame.animation.finishCallback = function(name){
				if(name == "start") { 
					flame.animation.play("loop"); 
				} 
			};
			flames.push(flame);
		}

		for(x in flames){ add(x); }
		for(x in stars){ add(x); }

		setNumber(0);

	}

	public function setNumber(value:Int):Void{
		value = Std.int(Utils.clamp(value, 0, 20));

		for(x in flames){ x.visible = false; }

		var animName = "on";
		var scale:Float = 1;
		var delayAdd:Float = 0;
		final fastDelayTime:Float = 0.015;
		final delayTime:Float = 0.025;

		if(value > 10){
			animName = "blue";
			scale = 1.4;
			delayAdd = delayTime * 9;
			for(i in 0...stars.length){ 
				stars[i].animation.play("off");
				FlxTween.cancelTweensOf(stars[i].scale);
				stars[i].scale.set(1, 1);
				FlxTween.tween(stars[i].scale, {x: 0.7, y: 0.7}, delayAdd * 0.9, {startDelay: fastDelayTime * i, ease: FlxEase.quartOut, onStart: function(t) {
					stars[i].animation.play("on");
				}});
			}
		}
		else{
			for(x in stars){ 
				x.animation.play("off");
				FlxTween.cancelTweensOf(x.scale);
				x.scale.set(1, 1);
			}
		}
		
		if(value == 20 || value == 10){ value = 10; }
		else{ value = value % 10; }

		for(i in 0...value){
			FlxTween.tween(stars[i].scale, {x: 0.7, y: 0.7}, 0.4, {startDelay: (delayTime * i) + delayAdd, ease: FlxEase.quartOut, onStart: function(t) {
				stars[i].animation.play(animName);
				stars[i].scale.set(scale, scale);
				if(animName == "blue"){
					flames[i].animation.play("start");
					flames[i].visible = true;
					if(i == 0){ FlxG.sound.play(Paths.sound("freeplay/starIgnite"), 0.8); }
				}
			}});
		}
	}

	public function tweenIn(transitionTime:Float, randomVariation:Float, transitionEase:flixel.tweens.EaseFunction, staggerTime:Float):Void{
		final delayTime:Float = 0.01;
		for(i in 0...stars.length){
			stars[i].x += 1280;
			flames[i].x += 1280;
			FlxTween.tween(stars[i], {x: stars[i].x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: (staggerTime) + (delayTime * i)});
			FlxTween.tween(flames[i], {x: flames[i].x-1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: (staggerTime) + (delayTime * i)});
		}
	}

	public function tweenOut(transitionTime:Float, randomVariation:Float, transitionEase:flixel.tweens.EaseFunction, staggerTime:Float):Void{
		final delayTime:Float = 0.01;
		for(i in 0...stars.length){
			FlxTween.tween(stars[9-i], {x: stars[9-i].x+1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: (staggerTime) + (delayTime * i)});
			FlxTween.tween(flames[9-i], {x: flames[9-i].x+1280}, transitionTime + FlxG.random.float(-randomVariation, randomVariation), {ease: transitionEase, startDelay: (staggerTime) + (delayTime * i)});
		}
	}

}