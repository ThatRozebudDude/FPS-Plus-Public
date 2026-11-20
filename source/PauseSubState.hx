package;

import caching.*;
import config.*;
import editors.chart.ChartingState;
import extensions.flixel.FlxCameraExt;
import extensions.flixel.FlxTextExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import menus.config.*;
import utils.Constants;

class PauseSubState extends BasePauseSubState
{

	public var menuGroup:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ["Resume", "Restart Song", "Options", "Exit to menu"];
	var curSelected:Int = 0;
	var becomeUseless:Bool = false;

	public var pauseMusic:FlxSound;

	public var camPause:FlxCameraExt;

	public var songName:FlxTextExt;
	public var songArtist:FlxTextExt;

	public function new(playSoundOnOpen:Bool = true){
		if(playSoundOnOpen){
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
		}
		super();
	}

	override function create():Void{
		Config.setFramerate(Constants.MENU_FRAMERATE);

		//PlayState.instance.tweenManager.active = false;

		camPause = new FlxCameraExt();
		camPause.bgColor.alpha = 0;
		camPause.filters = [];
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
		if(PlayState.instance.metadata != null){
			pauseSongName = PlayState.instance.metadata.pauseMusic;
		}

		pauseMusic = FlxG.sound.play(Paths.music(pauseSongName), 0, true);
		pauseMusic.time = FlxG.random.int(0, Std.int(pauseMusic.length/2));
		pauseMusic.fadeIn(16, 0, 0.7);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		bg.scale.set(FlxG.width + 10, FlxG.height + 10);
		bg.updateHitbox();
		bg.screenCenter(XY);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		menuGroup = new FlxTypedGroup<Alphabet>();
		add(menuGroup);

		for (i in 0...menuItems.length){
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.targetY = i;
			songText.isMenuItem = true;
			menuGroup.add(songText);
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

		super.create();
	}

	override function update(elapsed:Float){
		if(!becomeUseless){
			if (Binds.justPressed("menuUp")){
				changeSelection(-1);
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
			}
			if (Binds.justPressed("menuDown")){
				changeSelection(1);
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
			}
	
			if (Binds.justPressed("menuBack")){
				//PlayState.instance.tweenManager.active = true;
				unpause();
			}
	
			if (Binds.justPressed("menuAccept")){
	
				//PlayState.instance.tweenManager.active = true;
	
				var daSelected:String = menuItems[curSelected];

				becomeUseless = true;
	
				switch (daSelected)
				{
					case "Resume":
						unpause();
						FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
						
					case "Restart Song":
						restartSong();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
	
					case "Restart Section":
						restartSection();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
	
					case "Chart Editor":
						openChartEditor();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
						
					case "Skip Song":
						skipStorySong();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
						
					case "Options":
						openOptionsMenu();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
						
					case "Exit to menu":
						exitToMenu();
						pauseMusic.fadeOut(0.5, 0);
						FlxG.sound.play(Paths.sound("cancelMenu"), 0.8);
				}
			}
		}

		super.update(elapsed);
	}

	override function unpause(){
		FlxG.cameras.remove(camPause, true);
		super.unpause();
	}

	override function destroy(){
		if(pauseMusic.fadeTween != null){ pauseMusic.fadeTween.cancel(); }
		pauseMusic.destroy();
		if(songName != null){
			FlxTween.cancelTweensOf(songName);
			FlxTween.cancelTweensOf(songArtist);
		}
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void{
		curSelected += change;

		if(curSelected < 0){ curSelected = menuItems.length - 1; }
		if(curSelected >= menuItems.length){ curSelected = 0; }

		var bullShit:Int = 0;

		for(item in menuGroup.members){
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0){
				item.alpha = 1;
			}
		}
	}
}

@:build(modding.GlobalScriptingTypesMacro.build())
class BasePauseSubState extends MusicBeatSubState
{

	public static var instance:BasePauseSubState;

	public function new(){
		instance = this;
		super();
	}

	override function create():Void{
		for(script in PlayState.instance.scripts){ script.pause(); }
		super.create();
		Utils.gc();
	}

	override function update(elapsed:Float){
		for(script in PlayState.instance.scripts){ script.pauseUpdate(elapsed); }
		super.update(elapsed);
	}

	override function destroy(){
		instance = null;
		super.destroy();
	}

	function unpause():Void{
		Config.setFramerate(999);
		for(script in PlayState.instance.scripts){ script.unpause(); }
		close();
	}
	
	function restartSong():Void{
		PlayState.instance.tweenManager.clear();
		ImageCache.refreshLocal();
		PlayState.instance.keepFromChartEditor = true;
		PlayState.sectionStart = false;
		PlayState.replayStartCutscene = false;
		if(PlayState.instance.instSong != null){
			PlayState.overrideInsturmental = PlayState.instance.instSong;
		}
		PlayState.instance.switchState(new PlayState());
	}
	
	function restartSection():Void{
		PlayState.instance.tweenManager.clear();
		ImageCache.refreshLocal();
		PlayState.instance.keepFromChartEditor = true;
		PlayState.replayStartCutscene = false;
		if(PlayState.instance.instSong != null){
			PlayState.overrideInsturmental = PlayState.instance.instSong;
		}
		PlayState.instance.switchState(new PlayState());
	}

	function openChartEditor():Void{
		PlayState.instance.tweenManager.clear();
		if(PlayState.instance.instSong != null){
			PlayState.overrideInsturmental = PlayState.instance.instSong;
		}
		PlayState.instance.switchState(new ChartingState());
	}

	function skipStorySong():Void{
		PlayState.instance.preventScoreSaving = true;
		PlayState.instance.tweenManager.clear();
		PlayState.instance.endSong();
	}

	function openOptionsMenu():Void{
		PlayState.instance.tweenManager.clear();
		PlayState.instance.keepFromChartEditor = true;
		ConfigMenu.exitTo = PlayState;
		PlayState.replayStartCutscene = false;
		if(PlayState.instance.instSong != null){
			PlayState.overrideInsturmental = PlayState.instance.instSong;
		}
		PlayState.instance.switchState(new ConfigMenu());
	}

	function exitToMenu():Void{
		PlayState.instance.tweenManager.clear();
		PlayState.sectionStart = false;
		PlayState.instance.returnToMenu();
	}

}

@:hscriptClass
class ScriptablePauseSubState extends BasePauseSubState implements polymod.hscript.HScriptedClass{}