package stages.data;

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

	var streetBlurMultiply:FlxSprite;
	var additionalLighten:FlxSprite;

	var abot:ABot;
	var allowAbotInit:Bool = false;
	var abotInit:Bool = false;

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

		//lightning here

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
		streetBlurMultiply.scrollFactor.set();
		additionalLighten.updateHitbox();
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
		extraCameraMovementAmount = 20;

		gf().scrollFactor.set(gfScroll, gfScroll);
		gf().color = 0xFF888888;
		abot.scrollFactor.set(gfScroll, gfScroll);
		abot.color = 0xFF888888;

		addExtraData("forceCenteredNotes",  true);
    }

	override function update(elapsed:Float) {
		/*if(FlxG.keys.anyJustPressed([FOUR])){
			trace(gf().getMidpoint());
		}*/

		if(FlxG.sound.music != null && FlxG.sound.music.playing && allowAbotInit && !abotInit){
			abot.setAudioSource(FlxG.sound.music);
			abot.startVisualizer();
			abotInit = true;
		}
	}

	override function beat(curBeat:Int) {
		if(curBeat == 0){
			new FlxTimer().start(1/24, function(t) {
				allowAbotInit = true;
			});
		}

		abot.bop();
	}
}