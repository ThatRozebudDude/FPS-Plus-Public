package;

import flixel.tweens.FlxEase;
import extensions.flixel.FlxTextExt;
import haxe.Json;
import flixel.text.FlxText;
import flixel.FlxCamera;
import debug.ChartingState;
import flixel.tweens.FlxTween;
import config.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', "Options", 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var allowControllerPress:Bool = false;

	var camPause:FlxCamera;

	var songName:FlxTextExt;
	var songArtist:FlxTextExt;

	public function new(x:Float, y:Float){

		super();

		Config.setFramerate(144);

		PlayState.instance.tweenManager.active = false;

		camPause = new FlxCamera();
		camPause.bgColor.alpha = 0;
		FlxG.cameras.add(camPause, false);
		cameras = [camPause];
		
		if (PlayState.storyPlaylist.length > 1 && PlayState.isStoryMode){
			menuItems.insert(2, "Skip Song");
		}
		
		if (!PlayState.isStoryMode){
			menuItems.insert(2, "Chart Editor");
		}

		if (!PlayState.isStoryMode && PlayState.sectionStart){
			menuItems.insert(1, "Restart Section");
		}

		var pauseSongName = "pause/breakfast";

		if(Config.pauseMusicBehavior < 2){ //Only if breakfast only is off
			switch(PlayState.SONG.song.toLowerCase()){
				case "spookeez" | "south" | "monster" | "winter-horrorland" | "spookeez-erect" | "south-erect":
					if(Config.pauseMusicBehavior == 0) { pauseSongName = "pause/911825_woah_Loop"; }
				case "pico" | "philly" | "blammed" | "pico-erect" | "philly-erect" | "blammed-erect":
					if(Config.pauseMusicBehavior == 0) { pauseSongName = "pause/947670_hacker.07_Loop"; }
				case "satin-panties" | "high" | "milf" | "satin-panties-erect" | "high-erect":
					if(Config.pauseMusicBehavior == 0) { pauseSongName = "pause/1317505_RUN1N_Loop"; }
				case "cocoa" | "eggnog" | "eggnog-erect":
					if(Config.pauseMusicBehavior == 0) { pauseSongName = "pause/918379_Love-Emoji_Loop"; }
				case "senpai" | "roses" | "thorns" | "senpai-erect" | "roses-erect" | "thorns-erect":
					pauseSongName = "pause/breakfast-pixel";
				case "ugh" | "guns" | "stress":
					if(Config.pauseMusicBehavior == 0) { pauseSongName = "week7/distorto"; }
				case "darnell" | "lit-up" | "2hot" | "blazin":
					pauseSongName = "pause/breakfast-pico";
				case "lil-buddies" | "lil-buddies-erect":
					if(Config.pauseMusicBehavior == 0) { pauseSongName = "pause/1100059_skippingrecord_Loop"; }
			}
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseSongName), true, true);
		
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.fadeIn(16, 0, 0.7);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length){
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		if(PlayState.instance.metadata != null){
			var distance:Float = 32;

			songName = new FlxTextExt(16, 16, 1280-32, PlayState.instance.metadata.name, 40);
			songName.setFormat(Paths.font("vcr"), 40, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
			songName.borderSize = 3;
			songName.alpha = 0;

			songArtist = new FlxTextExt(16, 32 + 40, 1280-32, PlayState.instance.metadata.artist, 40);
			songArtist.setFormat(Paths.font("vcr"), 40, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
			songArtist.borderSize = 3;
			songArtist.alpha = 0;

			songName.y -= distance;
			songArtist.y -= distance;

			FlxTween.tween(songName, {alpha: 1, y: songName.y + distance}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(songArtist, {alpha: 1, y: songArtist.y + distance}, 0.6, {ease: FlxEase.quartOut, startDelay: 0.25});

			add(songName);
			add(songArtist);
		}

		changeSelection();

	}

	override function update(elapsed:Float){
			
		super.update(elapsed);

		if (Binds.justPressed("menuUp")){
			changeSelection(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
		}
		if (Binds.justPressed("menuDown")){
			changeSelection(1);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
		}

		if (Binds.justPressed("menuBack")){
			PlayState.instance.tweenManager.active = true;
			unpause();
		}

		if (!allowControllerPress ? Binds.justPressedKeyboardOnly("menuAccept") : Binds.justPressed("menuAccept")){

			PlayState.instance.tweenManager.active = true;

			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					unpause();
					
				case "Restart Song":
					PlayState.instance.tweenManager.clear();
					PlayState.instance.switchState(new PlayState());
					PlayState.sectionStart = false;
					PlayState.replayStartCutscene = false;
					pauseMusic.fadeOut(0.5, 0);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);

				case "Restart Section":
					PlayState.instance.tweenManager.clear();
					PlayState.instance.switchState(new PlayState());
					PlayState.replayStartCutscene = false;
					pauseMusic.fadeOut(0.5, 0);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);

				case "Chart Editor":
					PlayState.instance.tweenManager.clear();
					PlayState.instance.switchState(new ChartingState());
					pauseMusic.fadeOut(0.5, 0);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
					
				case "Skip Song":
					PlayState.instance.preventScoreSaving = true;
					PlayState.instance.tweenManager.clear();
					PlayState.instance.endSong();
					pauseMusic.fadeOut(0.5, 0);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
					
				case "Options":
					PlayState.instance.tweenManager.clear();
					PlayState.instance.switchState(new ConfigMenu());
					ConfigMenu.exitTo = PlayState;
					PlayState.replayStartCutscene = false;
					pauseMusic.fadeOut(0.5, 0);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);
					
				case "Exit to menu":
					PlayState.instance.tweenManager.clear();
					PlayState.sectionStart = false;
					PlayState.instance.returnToMenu();
					pauseMusic.fadeOut(0.5, 0);
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.8);
			}
		}

		//This is to work around a flixel issue that makes the controller input state reset on state/sub-state change. idk why it happens
		if(!allowControllerPress && Binds.justReleasedControllerOnly("pause")){
			allowControllerPress = true;
		}
	}

	function unpause(){
		Config.setFramerate(999);
		FlxG.cameras.remove(camPause, true);
		close();
	}

	override function destroy(){
		pauseMusic.fadeTween.cancel();
		pauseMusic.destroy();
		if(songName != null){
			FlxTween.cancelTweensOf(songName);
			FlxTween.cancelTweensOf(songArtist);
		}
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members){
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0){
				item.alpha = 1;
			}
		}
	}
}
