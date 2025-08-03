package;

import flixel.math.FlxMath;
import scripts.ScriptableState;
import scripts.ScriptedState;
import haxe.Json;
import modding.ModManagerState;
import modding.PolymodHandler;
import story.StoryMenuState;
import flixel.util.FlxTimer;
import flixel.system.debug.console.ConsoleUtil;
import flixel.math.FlxPoint;
import config.*;
import transition.data.*;
import title.TitleScreen;
import freeplay.FreeplayState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.text.FlxText;
import extensions.flixel.FlxTextExt;
import caching.*;

using StringTools;

@:hscriptClass
class ScriptedMainMenuState extends MainMenuState implements polymod.hscript.HScriptedClass{}

class MainMenuState extends MusicBeatState
{

	public static var curSelected:Int = 0;
	public static var scrolledAmount:Int = 0;
	var menuItemDistanceFinal:Float = MENU_ITEM_DISTANCE;
	
	public static var menuItemJsonNames:Array<String>;
	public static var menuItemJsonData:Array<Dynamic>;

	public static var previousMenuItemCount:Int = -1;

	inline public static final CAM_TARTGET_TOP:Float = 100;
	inline public static final CAM_TARTGET_BOTTOM:Float = 620;
	inline public static final MENU_ITEM_DISTANCE_EXPANDED:Float = 150;
	inline public static final MENU_ITEM_DISTANCE:Float = 160;
	inline public static final MENU_ITEM_TOP_OFFSET:Float = 120;
	
	var menuItems:Array<MainMenuButton> = [];
	public static var menuItemPosition:Float = MENU_ITEM_TOP_OFFSET;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camTarget:FlxPoint = new FlxPoint();
	
	var instantCamFollow:Bool = false;

	var versionText:FlxTextExt;
	var buildInfoText:FlxTextExt;
	var keyWarning:FlxTextExt;
	var canCancelWarning:Bool = true;

	public static var fromFreeplay:Bool = false;

	public static final lerpSpeed:Float = 0.0042;
	final warningDelay:Float = 15;

	inline public static final VERSION:String = "8.0.1";
	inline public static final NONFINAL_TAG:String = "(Non-Release Build)";
	inline public static final SHOW_BUILD_INFO:Bool = true; //Set this to false when making a release build.

	public static var buildDate:String = "";

	override function create(){

		Config.setFramerate(144);

		if(!FlxG.sound.music.playing){	
			playMenuMusic();
		}

		persistentUpdate = persistentDraw = true;

		if(fromFreeplay){
			fromFreeplay = false;
			customTransIn = new InstantTransition();
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image("menu/menuBG"));
		bg.scrollFactor.set(0, 0.18);
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
	
		magenta = new FlxSprite(-80).loadGraphic(Paths.image("menu/menuBGMagenta"));
		magenta.scrollFactor.set(0, 0.18);
		magenta.setGraphicSize(Std.int(magenta.width * 1.18));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		add(magenta);
		// magenta.scrollFactor.set();
		
		getMenuItems();

		menuItemDistanceFinal = (menuItemJsonData.length < 5) ? MENU_ITEM_DISTANCE : MENU_ITEM_DISTANCE_EXPANDED;

		for(i in 0...menuItemJsonData.length){
			var menuItem:MainMenuButton = new MainMenuButton(menuItemJsonData[i]);
			menuItem.listPositionOffset = i * menuItemDistanceFinal;
			menuItem.screenCenter(X);
			menuItem.scrollFactor.set();

			menuItems.push(menuItem);
			add(menuItem);
		}

		if(menuItems.length >= 5){
			menuItemDistanceFinal -= 30/(menuItems.length-4);
		}

		if(menuItems.length != previousMenuItemCount){
			curSelected = 0;
		}
		scrolledAmount = 0;
		previousMenuItemCount = menuItems.length;

		FlxG.camera.follow(camFollow);

		versionText = new FlxTextExt(5, FlxG.height - 21, 0, "FPS Plus: v" + VERSION + " | Mod API: v" + PolymodHandler.API_VERSION_STRING, 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		if(SHOW_BUILD_INFO){
			versionText.text = "FPS Plus: v" + VERSION + " " + NONFINAL_TAG + " | Mod API: v" + PolymodHandler.API_VERSION_STRING;

			buildDate = CompileTime.buildDateString();

			buildInfoText = new FlxTextExt(1280 - 5, FlxG.height - 37, 0, "Build Date: " + buildDate + "\n" + GitCommit.getGitBranch() +  " (" + GitCommit.getGitCommitHash() + ")", 16);
			buildInfoText.scrollFactor.set();
			buildInfoText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			buildInfoText.x -= buildInfoText.width;
			add(buildInfoText);
		}

		add(versionText);

		keyWarning = new FlxTextExt(5, FlxG.height - 21 + 16, 0, "If your controls aren't working, try pressing CTRL + BACKSPACE to reset them.", 16);
		keyWarning.scrollFactor.set();
		keyWarning.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyWarning.alpha = 0;
		add(keyWarning);

		FlxTween.tween(versionText, {y: versionText.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: warningDelay});
		FlxTween.tween(keyWarning, {alpha: 1, y: keyWarning.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: warningDelay});

		new FlxTimer().start(warningDelay, function(t){
			canCancelWarning = false;
		});

		instantCamFollow = true;

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float){

		if(canCancelWarning && (Binds.justPressed("menuUp") || Binds.justPressed("menuDown")) || Binds.justPressed("menuAccept")){
			canCancelWarning = false;
			FlxTween.cancelTweensOf(versionText);
			FlxTween.cancelTweensOf(keyWarning);
		}
	
		if (!selectedSomethin){
			if (Binds.justPressed("menuUp")){
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeItem(-1);
			}
			else if (Binds.justPressed("menuDown")){
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeItem(1);
			}

			if (FlxG.keys.justPressed.BACKSPACE && FlxG.keys.pressed.CONTROL){
				Binds.resetToDefaultControls();
				FlxG.sound.play(Paths.sound("cancelMenu"));
			}
			else if (Binds.justPressed("menuBack") && !FlxG.keys.pressed.CONTROL){
				selectedSomethin = true;
				switchState(new TitleScreen());
				FlxG.sound.play(Paths.sound("cancelMenu"));
			}

			if (Binds.justPressed("menuAccept")){
				selectedSomethin = true;
				doButtonTransition(menuItems[curSelected]);
			}
		}

		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload();
		}

		if(!instantCamFollow){
			camFollow.x = Utils.fpsAdjustedLerp(camFollow.x, camTarget.x, lerpSpeed, 144);
			camFollow.y = Utils.fpsAdjustedLerp(camFollow.y, camTarget.y, lerpSpeed, 144);
			menuItemPosition = Utils.fpsAdjustedLerp(menuItemPosition, MENU_ITEM_TOP_OFFSET - (menuItemDistanceFinal * scrolledAmount), 0.14);
		}
		else{
			camFollow.x = camTarget.x;
			camFollow.y = camTarget.y;
			menuItemPosition = MENU_ITEM_TOP_OFFSET - (menuItemDistanceFinal * scrolledAmount);
			instantCamFollow = false;
		}

		for(item in menuItems){
			item.y = menuItemPosition + item.listPositionOffset;
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0){
		curSelected += huh;

		if (curSelected >= menuItems.length){
			curSelected = 0;
		}
 		if (curSelected < 0){
			curSelected = menuItems.length - 1;
		}

		if(curSelected < scrolledAmount){
			scrolledAmount = curSelected;
		}
		else if(curSelected > scrolledAmount + 3){
			scrolledAmount = curSelected - 3;
		}
		
		for(i in 0...menuItems.length){
			if(i == curSelected){ 
				menuItems[i].animation.play("selected");
				remove(menuItems[i], true);
				add(menuItems[i]);
				if(buildInfoText != null){
					remove(buildInfoText, true);
					add(buildInfoText);
				}
				remove(versionText, true);
				remove(keyWarning, true);
				add(versionText);
				add(keyWarning);
			}
			else{ menuItems[i].animation.play("idle"); }
			menuItems[i].updateHitbox();
			menuItems[i].screenCenter(X);
			menuItems[i].offset.y = menuItems[i].frameHeight/2;
		}

		if(menuItems.length > 1){
			camTarget.set(640, FlxMath.lerp(CAM_TARTGET_TOP, CAM_TARTGET_BOTTOM, curSelected/(menuItems.length-1)));
		}
		else{
			camTarget.set(640, FlxMath.lerp(CAM_TARTGET_TOP, CAM_TARTGET_BOTTOM, 0.5));
		}
		//trace(camTarget);
	}

	function doButtonTransition(button:MainMenuButton):Void{
		if(button.transition.sound != null){
			FlxG.sound.play(Paths.sound(button.transition.sound));
		}
		
		if(button.transition.stopMusic){
			FlxG.sound.music.stop();
		}

		if(!button.transition.instant){
			if(Config.flashingLights){ FlxFlicker.flicker(magenta, 1.1, 0.15, false); }

			for(i in 0...menuItems.length){
				if (i != curSelected){
					FlxTween.cancelTweensOf(menuItems[i]);
					FlxTween.tween(menuItems[i], {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
				else{
					FlxFlicker.flicker(menuItems[i], 1, 0.06, false, false, function(flick:FlxFlicker){
						menuItems[i].visible = true;
						doButtonAction(button);
					});
				}
			}
		}
		else{ doButtonAction(button); }
	}

	function doButtonAction(button:MainMenuButton):Void{
		switch (button.action.type){
			case "story":
				StoryMenuState.curWeek = 0;
				switchState(new StoryMenuState());

			case "freeplay":
				customTransOut = new InstantTransition();
				FreeplayState.curSelected = 0;
				FreeplayState.curCategory = 0;
				switchState(new FreeplayState(fromMainMenu, camFollow.getPosition()));

			case "modManager":
				switchState(new ModManagerState(), false);

			case "config":
				if(FlxG.sound.music.playing){ ConfigMenu.startSong = false; }
				switchState(new ConfigMenu());

			case "customState":
				switchState(ScriptedState.init(button.action.state));
				
			case "playSong":
				PlayState.setupSong(button.action.song, button.action.difficulty, false, "mainMenu", null);
				ImageCache.forceClearOnTransition = true;
				switchState(new PlayState());
				if(FlxG.sound.music.playing){
					FlxG.sound.music.fadeOut(0.3);
				}

			default:
				if(!button.transition.instant){
					for(i in 0...menuItems.length){
						if (i != curSelected){
							FlxTween.cancelTweensOf(menuItems[i]);
							FlxTween.tween(menuItems[i], {alpha: 1}, 0.4, {ease: FlxEase.quadOut});
						}
					}
				}
				if(!FlxG.sound.music.playing){	
					playMenuMusic();
				}
				selectedSomethin = false;
				trace("Unrecognized action type.");
		}
	}

	public static function playMenuMusic():Void{
		var info = Json.parse(Utils.getText(Paths.json("music", "data/mainMenu")));
		FlxG.sound.playMusic(Paths.music(info.path), info.volume);
		Conductor.changeBPM(info.bpm);
	}

	public static function getMenuItems():Void{
		menuItemJsonNames = Utils.readDirectory("assets/data/mainMenu/items");
		menuItemJsonNames = menuItemJsonNames.filter(function(element){ return element.endsWith(".json"); });
		menuItemJsonData = [];
		for(item in menuItemJsonNames){ 
			item = item.split(".json")[0];
			var data = Json.parse(Utils.getText(Paths.json(item, "data/mainMenu/items")));
			menuItemJsonData.push(data);
		}
		menuItemJsonData.sort(function(a, b):Int{
			return ((a.sort != null) ? a.sort : 0) - ((b.sort != null) ? b.sort : 0);
		});
	}
}



class MainMenuButton extends FlxSprite
{
	public var listPositionOffset:Float = 0;

	public var action:Dynamic = null;
	public var sortOrder:Float = 0;
	public var transition = {
		instant: false,
		sound: null,
		stopMusic: false
	}

	public function new(params:Dynamic){
		super();

		if(params.sort != null){
			sortOrder = params.sort;
		}
		
		if(params.action != null){
			action = params.action;
		}

		if(params.transition != null){
			if(params.transition.instant != null)	{ transition.instant = params.transition.instant; }
			if(params.transition.sound != null)		{ transition.sound = params.transition.sound; }
			if(params.transition.stopMusic != null)	{ transition.stopMusic = params.transition.stopMusic; }
		}

		frames = Paths.getSparrowAtlas(params.graphic);
		animation.addByPrefix("idle", "idle", 24);
		animation.addByPrefix("selected", "selected", 24);
		animation.play("idle");

		antialiasing = true;
	}

}