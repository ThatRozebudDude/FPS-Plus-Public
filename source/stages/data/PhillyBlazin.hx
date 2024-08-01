package stages.data;

import flixel.tweens.FlxTween;
import openfl.filters.ShaderFilter;
import shaders.RainShader;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class PhillyBlazin extends BaseStage
{
	var rainShader:RainShader;

	var scrollingSkyAdd:FlxSprite;
	var streetBlurMultiply:FlxSprite;
	var additionalLighten:FlxSprite;
	var lightning:FlxSprite;

	var abot:ABot;

	var lightningTimer:Float = 3;
	var lightningActive:Bool = true;

	final gfScroll:Float = 0.7;
	final gfPosOffset:FlxPoint = new FlxPoint(-225, -110);

    public override function init(){
        name = "phillyBlazin";
        startingZoom = 0.75;

		var scrollingSky = new FlxBackdrop(Paths.image("weekend1/phillyBlazin/skyBlur"), X);
		scrollingSky.setPosition(-600, -175);
		scrollingSky.scrollFactor.set();
		scrollingSky.scale.set(1.75, 1.75);
		scrollingSky.updateHitbox();
		scrollingSky.velocity.x = -35;
		scrollingSky.antialiasing = true;
		addToBackground(scrollingSky);

		scrollingSkyAdd = new FlxBackdrop(Paths.image("weekend1/phillyBlazin/skyBlur"), X);
		scrollingSkyAdd.setPosition(-600, -175);
		scrollingSkyAdd.scrollFactor.set();
		scrollingSkyAdd.scale.set(1.75, 1.75);
		scrollingSkyAdd.updateHitbox();
		scrollingSkyAdd.velocity.x = -35;
		scrollingSkyAdd.antialiasing = true;
		scrollingSkyAdd.blend = ADD;
		scrollingSkyAdd.visible = false;
		addToBackground(scrollingSkyAdd);

		lightning = new FlxSprite(50, -300);
		lightning.frames = Paths.getSparrowAtlas("weekend1/phillyBlazin/lightning");
		lightning.animation.addByPrefix("strike", "lightning", 24, false);
		lightning.scrollFactor.set();
		lightning.scale.set(1.75, 1.75);
		lightning.visible = false;
		lightning.updateHitbox();
		lightning.antialiasing = true;
		addToBackground(lightning);

		var streetBlur = new FlxSprite(-600 + 152, -175 + 70).loadGraphic(Paths.image("weekend1/phillyBlazin/streetBlur"));
		streetBlur.scrollFactor.set(0.2, 0.2);
		streetBlur.scale.set(1.75, 1.75);
		streetBlur.updateHitbox();
		streetBlur.antialiasing = true;
		addToBackground(streetBlur);

		streetBlurMultiply = new FlxSprite(-600 + 152, -175 + 70).loadGraphic(Paths.image("weekend1/phillyBlazin/streetBlur"));
		streetBlurMultiply.scrollFactor.set(0.2, 0.2);
		streetBlurMultiply.scale.set(1.75, 1.75);
		streetBlurMultiply.updateHitbox();
		streetBlurMultiply.antialiasing = true;
		streetBlurMultiply.blend = MULTIPLY;
		streetBlurMultiply.visible = false;
		addToBackground(streetBlurMultiply);

		additionalLighten = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		additionalLighten.scale.set(1280/startingZoom, 720/startingZoom);
		additionalLighten.scrollFactor.set();
		additionalLighten.updateHitbox();
		additionalLighten.screenCenter(XY);
		additionalLighten.visible = false;
		addToBackground(additionalLighten);

		useStartPoints = false;
		overrideGfStartPoints = true;
		boyfriend().setPosition(-237, -200);
		dad().setPosition(-237, -150);
		gfStart.set(1353 + gfPosOffset.x, 925 + gfPosOffset.y);

		abot = new ABot(gfStart.x - 365, gfStart.y - 165);
		abot.lookRight();
		addToBackground(abot);

		cameraMovementEnabled = false;
		cameraStartPosition = new FlxPoint(1390, 620);
		//extraCameraMovementAmount = 20;

		boyfriend().color = 0xFFDEDEDE;
		dad().color = 0xFFDEDEDE;

		gf().scrollFactor.set(gfScroll, gfScroll);
		gf().color = 0xFF888888;
		abot.scrollFactor.set(gfScroll, gfScroll);
		abot.color = 0xFF888888;
		
		rainShader = new RainShader(0.5, FlxG.height / 200);
		playstate().camGame.filters = [new ShaderFilter(rainShader.shader)];
		addToUpdate(rainShader);

		addExtraData("forceCenteredNotes",  true);

		addEvent("phillyBlazin-lightning", lightningStrike);
		addEvent("phillyBlazin-slowRain", slowRain);
		addEvent("phillyBlazin-normalRain", normalRain);
		addEvent("phillyBlazin-toggleLightning", toggleLightning);
    }

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(lightningActive && !playstate().inCutscene){
			lightningTimer -= FlxG.elapsed;
		}

		if (lightningTimer <= 0){
			lightningStrike();
			lightningTimer = FlxG.random.float(7, 15);
		}
	}

	override function songStart() {
		abot.setAudioSource(FlxG.sound.music);
		abot.startVisualizer();
	}

	override function beat(curBeat:Int) {
		abot.bop();
	}

	final LIGHTNING_FULL_DURATION = 1.5;
	final LIGHTNING_FADE_DURATION = 0.3;
	final LIGHTNING_HOLD_DURATION = 0.15;
	final CHARACTER_DARKEN_COLOR = 0xFF404040;
	function lightningStrike():Void{

		scrollingSkyAdd.visible = true;
		scrollingSkyAdd.alpha = 0.8;
		tween().tween(scrollingSkyAdd, {alpha: 0.0}, LIGHTNING_FULL_DURATION, {startDelay: LIGHTNING_HOLD_DURATION, onComplete: cleanupLightning});

		streetBlurMultiply.visible = true;
		streetBlurMultiply.alpha = 0.8;
		FlxTween.tween(streetBlurMultiply, {alpha: 0.0}, LIGHTNING_FULL_DURATION, {startDelay: LIGHTNING_HOLD_DURATION});

		additionalLighten.visible = true;
		additionalLighten.alpha = 0.5;
		FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION, {startDelay: LIGHTNING_HOLD_DURATION});

		lightning.visible = true;
		lightning.animation.play('strike');

		if(FlxG.random.bool(65)){
			lightning.x = FlxG.random.int(-250, 280);
		}else{
			lightning.x = FlxG.random.int(780, 900);
		}

		//darken characters
		boyfriend().color = CHARACTER_DARKEN_COLOR;
		dad().color = CHARACTER_DARKEN_COLOR;
		gf().color = CHARACTER_DARKEN_COLOR;
		tween().color(boyfriend(), LIGHTNING_FADE_DURATION, CHARACTER_DARKEN_COLOR, 0xFFDEDEDE, {startDelay: LIGHTNING_HOLD_DURATION});
		tween().color(dad(), LIGHTNING_FADE_DURATION, CHARACTER_DARKEN_COLOR, 0xFFDEDEDE, {startDelay: LIGHTNING_HOLD_DURATION});
		tween().color(gf(), LIGHTNING_FADE_DURATION, CHARACTER_DARKEN_COLOR, 0xFF888888, {startDelay: LIGHTNING_HOLD_DURATION});

		FlxG.sound.play(Paths.sound("weekend1/Lightning" + FlxG.random.int(1, 3)));
	}

	function cleanupLightning(t:FlxTween) {
		scrollingSkyAdd.visible = false;
		streetBlurMultiply.visible = false;
		additionalLighten.visible = false;
		lightning.visible = false;
	}

	function slowRain():Void{
		tween().tween(rainShader, {timeScale: 0.07}, 2.5, {ease: FlxEase.quadOut});
	}

	function normalRain():Void{
		tween().tween(rainShader, {timeScale: 1}, Conductor.crochet/1000, {ease: FlxEase.quadIn});
	}

	function toggleLightning():Void{
		lightningActive = !lightningActive;
	}
}