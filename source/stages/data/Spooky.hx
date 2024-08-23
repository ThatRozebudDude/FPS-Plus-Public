package stages.data;

import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class Spooky extends BaseStage
{

	var halloweenBG:FlxSprite;

	var wall:FlxSprite;
	var shadows:FlxSprite;
	var window:FlxSprite;
	var light:FlxSprite;

	var dummyWall:FlxSprite = new FlxSprite();
	var dummyShadows:FlxSprite = new FlxSprite();
	var dummyLight:FlxSprite = new FlxSprite();

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lightningSound:FlxSound = new FlxSound();
	var unpauseSoundCheck:Bool = false;

	final wallColor:FlxColor = 0xFF32325A;
	final wallFlashColors:Array<FlxColor> = [0xFF4D4D75, 0xFF12123D, 0xFF090937];

	final shadowColor:FlxColor = 0xFF242336;
	final shadowFlashColors:Array<FlxColor> = [0xFF0C0B1E, 0xFF0A0925, 0xFF000000];

	final windowLightColor:FlxColor = 0xFF4646AD;
	final windowLightFlashColors:Array<FlxColor> = [0xFFFFFFFF, 0xFF12123D, 0xFFD5D5FF];

    public override function init(){
        name = "spooky";

		wall = Utils.makeColoredSprite(1280*2, 720*2, 0xFFFFFFFF);
		wall.screenCenter(XY);
		wall.scrollFactor.set();
		wall.color = wallColor;
		addToBackground(wall);

		shadows = new FlxSprite(-191, -100);

		light = new FlxSprite(shadows.x + 539, shadows.y + 748);
		light.frames = Paths.getSparrowAtlas("week2/stage/windowLightWhite");
		light.antialiasing = true;
		light.animation.addByPrefix("flash", "Window Light Flash", 24, false);
		light.animation.play("flash", true, false, 29);
		light.color = windowLightColor;
		light.animation.callback = floorLightCallback;
		addToBackground(light);

		shadows.loadGraphic(Paths.image("week2/stage/shadowsWhite"));
		shadows.antialiasing = true;
		shadows.color = shadowColor;
		addToBackground(shadows);

		window = new FlxSprite(shadows.x + 434, shadows.y + 161);
		window.frames = Paths.getSparrowAtlas("week2/stage/window");
		window.antialiasing = true;
		window.animation.addByPrefix("flash", "Window Flash", 24, false);
		window.animation.play("flash", true, false, 29);
		addToBackground(window);

		dadStart.set(346, 849);
		bfCameraOffset.set(0, -40);
    }

	public override function beat(curBeat:Int){
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset){
			lightningStrikeShit(curBeat);
		}
	}

	public override function pause() {
		if(lightningSound.playing){
			unpauseSoundCheck = true;
			lightningSound.pause();
		}
	}

	public override function unpause() {
		if(unpauseSoundCheck){
			unpauseSoundCheck = false;
			lightningSound.play(false);
		}
	}

	function lightningStrikeShit(curBeat:Int):Void{
		lightningSound = FlxG.sound.play(Paths.sound("week2/thunder_" + FlxG.random.int(1, 2)));

		light.animation.play("flash");
		window.animation.play("flash");

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim("scared", true);
		gf.playAnim("scared", true);
	}

	function floorLightCallback(anim:String, frame:Int, index:Int):Void{
		switch(frame){
			case 0 | 1:
				wall.color = wallFlashColors[frame];
				shadows.color = shadowFlashColors[frame];
				light.color = windowLightFlashColors[frame];

			case 2:
				wall.color = wallFlashColors[2];
				shadows.color = shadowFlashColors[2];
				light.color = windowLightFlashColors[2];

				tween.cancelTweensOf(dummyWall);
				tween.cancelTweensOf(dummyShadows);
				tween.cancelTweensOf(dummyLight);

				tween.color(dummyWall, 27/24, wallFlashColors[2], wallColor, {ease: FlxEase.quadIn});
				tween.color(dummyShadows, 27/24, shadowFlashColors[2], shadowColor, {ease: FlxEase.quadIn});
				tween.color(dummyLight, 27/24, windowLightFlashColors[2], windowLightColor, {ease: FlxEase.quadIn});

			case 29:
				wall.color = wallColor;
				shadows.color = shadowColor;
				light.color = windowLightColor;

			default:
				wall.color = dummyWall.color;
				shadows.color = dummyShadows.color;
				light.color = dummyLight.color;

		}
	}
}