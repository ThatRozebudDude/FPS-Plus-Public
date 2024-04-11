package;

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

	var menuItems:Array<String> = ['Resume', 'Restart Song', "Options",'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var allowControllerPress:Bool = false;

	var camPause:FlxCamera;

	public function new(x:Float, y:Float)
	{
		super();

		Config.setFramerate(144);

		FlxTween.globalManager.active = false;

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

		var pauseSongName = "breakfast";

		switch(PlayState.SONG.song.toLowerCase()){
			case "ugh" | "guns" | "stress":
				pauseSongName = "distorto";
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseSongName), true, true);
		
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.8)
			pauseMusic.volume += 0.05 * elapsed;

		super.update(elapsed);

		if (Binds.justPressed("menuUp"))
		{
			changeSelection(-1);
		}
		if (Binds.justPressed("menuDown"))
		{
			changeSelection(1);
		}

		if (!allowControllerPress ? Binds.justPressedKeyboardOnly("menuAccept") : Binds.justPressed("menuAccept")){

			FlxTween.globalManager.active = true;

			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					unpause();
					
				case "Restart Song":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new PlayState());
					PlayState.sectionStart = false;

				case "Restart Section":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new PlayState());

				case "Chart Editor":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new ChartingState());
					
				case "Skip Song":
					FlxTween.globalManager.clear();
					PlayState.instance.endSong();
					
				case "Options":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new ConfigMenu());
					ConfigMenu.exitTo = PlayState;
					
				case "Exit to menu":
					FlxTween.globalManager.clear();

					PlayState.sectionStart = false;

					switch(PlayState.returnLocation){
						case "freeplay":
							PlayState.instance.switchState(new FreeplayState());
						case "story":
							PlayState.instance.switchState(new StoryMenuState());
						default:
							PlayState.instance.switchState(new MainMenuState());
					}
					
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

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
