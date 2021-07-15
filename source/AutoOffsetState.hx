package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class AutoOffsetState extends MusicBeatState
{

	var easterEgg:Bool = FlxG.random.bool(1);
	public static var forceEasterEgg:Int = 0;
	var font:Array<String> = ["assets/fonts/Funkin-Bold.otf", "assets/fonts/vcr.ttf"];

	var hitBeats:Int = 0;
	var offsetCalc:Int = 0;
	var offsetTotal:Int = 0;

	var offsetText:FlxText;
	var previousText:FlxText;
	var descText:FlxText;

	var started:Bool = false;
	var endOfSong:Bool = false;
	var ending:Bool = false;
	var canExit:Bool = false;

	var bg:FlxSprite;
	var speakers:FlxSprite = new FlxSprite(0, 0);

	override function create() {	
	
		//Setup Conductor
		Conductor.changeBPM(100);
		Conductor.songPosition = 0;

		FlxG.sound.music.volume = 0;

		//Cache the 3 2 1 go
		FlxG.sound.cache('assets/sounds/intro3' + (easterEgg?"-pixel":"") + TitleState.soundExt);
		FlxG.sound.cache('assets/sounds/intro2' + (easterEgg?"-pixel":"") + TitleState.soundExt);
		FlxG.sound.cache('assets/sounds/intro1' + (easterEgg?"-pixel":"") + TitleState.soundExt);
		FlxG.sound.cache('assets/sounds/introGo' + (easterEgg?"-pixel":"") + TitleState.soundExt);

		//Easter egg check
		switch(forceEasterEgg){
			case 1:
				easterEgg = true;
			case -1:
				easterEgg = false;
		}

		if(!easterEgg){
			//Init BG
			bg = new FlxSprite(0, 0).loadGraphic('assets/images/fpsPlus/offsetBG.png');
			bg.antialiasing = true;
			bg.active = true;
			bg.screenCenter();
			add(bg);

			//Init Speakers
			speakers.frames = FlxAtlasFrames.fromSparrow('assets/images/fpsPlus/speaker.png', 'assets/images/fpsPlus/speaker.xml');
			speakers.antialiasing = true;
			speakers.animation.addByPrefix('idle', 'IDLE', 24, false);
			speakers.animation.addByPrefix('bump', 'BUMP', 24, false);
			speakers.animation.play("idle");
			speakers.screenCenter();
			//speakers.x -= speakers.width / 2;
			//speakers.y -= speakers.height / 2;
			add(speakers);
		}

		else{
			FlxG.save.data.ee1 = true;

			//Init BG
			bg = new FlxSprite(0, 0).loadGraphic('assets/images/fpsPlus/offsetBG-pixel.png');
			bg.antialiasing = false;
			bg.active = true;
			bg.setGraphicSize(Std.int(bg.width * 6));
			bg.updateHitbox();
			bg.screenCenter();
			add(bg);

			//Init Speakers
			speakers = new FlxSprite(0, 0).loadGraphic('assets/images/fpsPlus/speaker-pixel.png', true, 102, 52);
			speakers.antialiasing = false;
			speakers.animation.add('idle',  [0], 0, false);
			speakers.animation.add('bump', [2, 2, 1, 0], 24, false);
			speakers.animation.play("idle");
			speakers.setGraphicSize(Std.int(speakers.width * 7));
			speakers.updateHitbox();
			speakers.screenCenter();
			//speakers.x -= speakers.width / 2;
			//speakers.y -= speakers.height / 2;
			add(speakers);
		}


		//Init Text
		offsetText = new FlxText(0, 235, 1280, "", 58);
		offsetText.scrollFactor.set(0, 0);
		offsetText.setFormat(font[easterEgg?1:0], 58, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetText.borderSize = 3;
		offsetText.borderQuality = 1;
		offsetText.alpha = 0;

		previousText = new FlxText(0, 400, 1280, "", 58);
		previousText.scrollFactor.set(0, 0);
		previousText.setFormat(font[easterEgg?1:0], 58, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		previousText.borderSize = 3;
		previousText.borderQuality = 1;
		previousText.alpha = 0;

		descText = new FlxText(320, 540, 640, "Tap any key to the beat of the music!\n", 40);
		descText.scrollFactor.set(0, 0);
		descText.setFormat("assets/fonts/vcr.ttf", 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;
		descText.borderQuality = 1;
		descText.alpha = 0;
		
		add(offsetText);
		add(previousText);
		add(descText);

		offsetText.text = "OFFSET\n" + offsetCalc + "ms\n";
		previousText.text = "PREVIOUS\n0ms\n";

		FlxG.camera.fade(FlxColor.BLACK, 0.5, true, function(){
			FlxG.sound.music.volume = 1;
			FlxG.sound.playMusic("assets/music/offsetSong" + (easterEgg?"-pixel":"") + TitleState.soundExt, 1, false);
			FlxG.sound.music.onComplete = exit;

			started = true;

			offsetText.y -= 10;
			offsetText.alpha = 0;
			FlxTween.tween(offsetText, {y: offsetText.y + 10, alpha: 1}, 0.4, {ease: FlxEase.circOut, startDelay: 0});

			previousText.y -= 10;
			previousText.alpha = 0;
			FlxTween.tween(previousText, {y: previousText.y + 10, alpha: 1}, 0.4, {ease: FlxEase.circOut, startDelay: 0.6});

			descText.y -= 10;
			descText.alpha = 0;
			FlxTween.tween(descText, {y: descText.y + 10, alpha: 1}, 0.4, {ease: FlxEase.circOut, startDelay: 1.2});
		});

	}

	override function update(elapsed:Float) {
		
		super.update(elapsed);

		if(started){

			Conductor.songPosition = FlxG.sound.music.time;
			//trace(Conductor.songPosition);

			if((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) && canExit){
				endOfSong = true;
				endSong();
			}

			if (FlxG.keys.justPressed.ANY && (Conductor.songPosition >= 4500 && Conductor.songPosition <= 43500) && !(ending || endOfSong)){
				hitBeat();
			}

			if(!canExit && Conductor.songPosition >= 2400){
				canExit = true;
				countdown();
			}

		}

		if(Conductor.songPosition >= 43200 && !endOfSong){

			new FlxTimer().start(2.4, function(tmr:FlxTimer)
			{
				endOfSong = true;
				endSong();
			});

		}

	}

	//Cues the 3, 2, 1, GO! sound effects
	function countdown(){

		FlxG.sound.play('assets/sounds/intro3' + (easterEgg?"-pixel":"") + TitleState.soundExt, 0.6);
		speakers.animation.play("bump", true);

		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			FlxG.sound.play('assets/sounds/intro2' + (easterEgg?"-pixel":"") + TitleState.soundExt, 0.6);
			speakers.animation.play("bump", true);
		});

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			FlxG.sound.play('assets/sounds/intro1' + (easterEgg?"-pixel":"") + TitleState.soundExt, 0.6);
			speakers.animation.play("bump", true);
		});

		new FlxTimer().start(1.8, function(tmr:FlxTimer)
		{
			FlxG.sound.play('assets/sounds/introGo' + (easterEgg?"-pixel":"") + TitleState.soundExt, 0.6);
			speakers.animation.play("bump", true);
		});

	}

	function hitBeat():Void {

		hitBeats++;
		var offsetAdd = Std.int(Conductor.songPosition % 600);
		offsetAdd = (offsetAdd >= 300) ? offsetAdd - 600 : offsetAdd;
		offsetTotal += offsetAdd;

		offsetCalc = Std.int(offsetTotal / hitBeats);

		offsetText.text = "OFFSET\n" + offsetCalc + "ms\n";
		previousText.text = "PREVIOUS\n" + offsetAdd + "ms\n";

		speakers.animation.play("bump", true);

		trace("Add: " + offsetAdd + "\nTotal: " + offsetTotal + "\noffsetCalc: " + offsetCalc);

	}

	function updateOverrideText():Void {

		offsetText.text = "OFFSET\n" + offsetCalc;

	}

	function endSong():Void {
		FlxTween.tween(offsetText, {y: offsetText.y - 10, alpha: 0}, 0.4, {ease: FlxEase.circOut, startDelay: 0.6});
		FlxTween.tween(previousText, {y: previousText.y - 10, alpha: 0}, 0.4, {ease: FlxEase.circOut, startDelay: 0.3});
		FlxTween.tween(descText, {y: descText.y - 10, alpha: 0}, 0.4, {ease: FlxEase.circOut, startDelay: 0});
		new FlxTimer().start(0.9, function(tmr:FlxTimer)
		{
			exit();
		});
	}

	function exit():Void {
		FlxG.sound.music.fadeOut(0.4);
		ending = true;
		Config.write(offsetCalc, Config.accuracy, Config.healthMultiplier, Config.healthDrainMultiplier, Config.betterIcons, Config.downscroll, Config.noteGlow, Config.ghostTapType, Config.noFpsCap, Config.controllerScheme);
		FlxG.switchState(new ConfigMenu());
	}
}
