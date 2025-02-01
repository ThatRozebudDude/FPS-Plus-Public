package title;

import transition.data.InstantTransition;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import freeplay.ScrollingText;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.FlxSprite;
import config.Config;
import flixel.FlxG;
import extensions.flixel.FlxUIStateExt;
import objects.WaveformSprite;

class TitleEasterEgg extends MusicBeatState
{

	var waveform:WaveformSprite;
	var circle:FlxSprite;
	var dj:FlxSprite;
	var topText:FlxBackdrop;
	var bottomText:FlxBackdrop;

	var ballin:Bool = true;

	var beatTime:Float = 0;

	override function create() {

		customTransIn = new InstantTransition();

		Config.setFramerate(144);

		FlxG.sound.playMusic(Paths.music("1326148"), 1, false);
		FlxG.sound.music.onComplete = exit;
		Conductor.changeBPM(183.48);

		waveform = new WaveformSprite(0, 0, 120, 640, FlxG.sound.music);
		waveform.angle = -90;
		waveform.waveformDrawStep = 4;
		waveform.waveformDrawNegativeSpace = 2;
		waveform.framerate = 24;
		waveform.waveformSampleLength = 0.1;
		waveform.scale.set(2, 2);
		waveform.screenCenter(XY);

		circle = new FlxSprite().loadGraphic(Paths.image("fpsPlus/circle"));
		circle.screenCenter(XY);

		dj = new FlxSprite().loadGraphic(Paths.image("fpsPlus/lildj"), true, 129, 123);
		dj.animation.add("idle", [0, 1, 2, 3], 12, false);
		dj.animation.play("idle", true);
		dj.screenCenter(XY);
		dj.scale.set(2, 2);

		var tempText = new FlxText(0, 0, 0, "LOOK AT HIM GO ");
		tempText.setFormat(Paths.font("5by7"), 80, 0xFFFFFFFF);

		topText = ScrollingText.createScrollingText(0, 50, tempText);
		topText.velocity.x = -50;

		tempText.text = "FUCK IT UP LIL' BF ";
		bottomText = ScrollingText.createScrollingText(0, 720 - 50 - 60, tempText);
		bottomText.velocity.x = 50;

		add(waveform);
		add(circle);
		add(topText);
		add(bottomText);
		add(dj);

		FlxG.camera.flash();

		super.create();
	}

	override function update(elapsed:Float) {

		if(ballin){
			Conductor.songPosition = FlxG.sound.music.time;

			if(Binds.justPressed("menuAccept")){
				if((beatTime + Conductor.crochet*2) >= FlxG.sound.music.length){
					FlxG.sound.music.onComplete = null;
					exit();
				}
				else{
					FlxG.sound.music.time = beatTime + Conductor.crochet*2;
					beatTime = FlxG.sound.music.time;
					djHit();
				}
			}

			if(Binds.justPressed("menuBack")){
				FlxG.sound.music.onComplete = null;
				exit();
			}
		}

		super.update(elapsed);
	}

	override function beatHit() {

		super.beatHit();

		if(curBeat % 2 == 0){
			beatTime = Conductor.songPosition;
			djHit();
		}

	}

	function djHit():Void{
		dj.animation.play("idle", true);

		var velSet = bottomText.velocity.x + 300;

		FlxTween.cancelTweensOf(topText.velocity);
		topText.velocity.x = -velSet;
		FlxTween.tween(topText.velocity, {x: -50}, Conductor.crochet/575, {ease: FlxEase.quadOut});

		FlxTween.cancelTweensOf(bottomText.velocity);
		bottomText.velocity.x = velSet;
		FlxTween.tween(bottomText.velocity, {x: 50}, Conductor.crochet/575, {ease: FlxEase.quadOut});
	}

	function exit() {
		ballin = false;
		if(FlxG.sound.music.playing){
			FlxG.sound.music.fadeOut(0.5, 0, function(t) {
				FlxG.sound.music.stop();
			});
		}
		else{
			FlxG.sound.music.stop();
		}
		switchState(new TitleScreen());
	}

}