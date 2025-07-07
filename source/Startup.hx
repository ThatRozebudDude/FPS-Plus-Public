package;

import note.NoteType;
import events.Events;
import sys.FileSystem;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import openfl.media.Sound;
import title.*;
import config.*;
import transition.data.*;

import flixel.FlxState;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.system.System;
//import openfl.utils.Future;
//import flixel.addons.util.FlxAsyncLoop;
import extensions.flixel.FlxUIStateExt;
import caching.*;
import modding.*;

using StringTools;

class Startup extends FlxUIStateExt
{

	var nextState:FlxState = new TitleVideo();
	//var nextState:FlxState = new debug.AtlasScrub();
	//var nextState:FlxState = new results.ResultsState(null, "Results Test", "PicoResults");

	var splashHasSoundTrigger:Bool = false;
	var splash:AtlasSprite;
	var loadingBar:FlxBar;
	var loadingText:FlxText;

	var currentLoaded:Int = 0;
	var loadTotal:Int = 0;
								
	//List of character graphics and some other stuff.
	//Just in case it want to do something with it later.
	var charactersCached:Bool;
	var startCachingCharacters:Bool = false;
	var charI:Int = 0;

	var graphicsCached:Bool;
	var startCachingGraphics:Bool = false;
	var gfxI:Int = 0;

	var cacheStart:Bool = false;

	public static var thing = false;

	public static var hasEe2:Bool;

	override function create()
	{

		//results.ResultsState.enableDebugControls = true;

		SaveManager.global();

		FlxG.mouse.visible = false;
		FlxG.sound.muteKeys = null;

		Config.load();

		Binds.init();

		Highscore.load();

		ModConfig.load();

		SaveManager.global();
		
		//debug.ChartingState.loadLists();

		NoteType.initTypes();
		Events.initEvents();
		//trace(NoteType.types);
		//trace(NoteType.sustainTypes);

		Main.fpsDisplay.visible = Config.showFPS;
		FlxG.autoPause = Config.autoPause;

		FlxUIStateExt.defaultTransIn = ScreenWipeIn;
		FlxUIStateExt.defaultTransInArgs = [0.6];
		FlxUIStateExt.defaultTransOut = ScreenWipeOut;
		FlxUIStateExt.defaultTransOutArgs = [0.6];

		CacheConfig.check();
		charactersCached = !CacheConfig.characters;
		graphicsCached = !CacheConfig.graphics;

		hasEe2 = Utils.exists(Paths.inst("Lil-Buddies"));

		splash = new AtlasSprite(0, 0, Paths.getTextureAtlas("fpsPlus/splash"));
		splash.antialiasing = true;

		var labels = [];
		for(tempLabel in splash.anim.getFrameLabels()){ labels.push(tempLabel.name); }

		splash.addAnimationByLabel("start", "Start", 24, false);
		if(labels.contains("Trigger Sound")){
			splash.addAnimationByLabel("soundTrigger", "Trigger Sound", 24, false);
			splashHasSoundTrigger = true;
		}
		splash.addAnimationByLabel("end", "End", 24, false);
		splash.animationEndCallback = splashState;
		add(splash);

		CacheReload.buildPreloadList();

		loadTotal = (!charactersCached ? CacheReload.characterPreloadList.length : 0) + (!graphicsCached ? CacheReload.graphicsPreloadList.length : 0);

		if(loadTotal > 0){
			loadingBar = new FlxBar(0, 605, LEFT_TO_RIGHT, 600, 24, this, 'currentLoaded', 0, loadTotal);
			loadingBar.createFilledBar(0xFF333333, 0xFF95579A);
			loadingBar.screenCenter(X);
			loadingBar.visible = false;
			add(loadingBar);
		}

		loadingText = new FlxText(5, FlxG.height - 30, 0, "", 24);
		loadingText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingText);

		#if web
		FlxG.sound.play(Paths.sound("tick"), 0);   
		#end

		splash.playAnim("start");

		super.create();
	}

	override function update(elapsed):Void{

		FlxG.mouse.visible = false;

		if(charactersCached && graphicsCached && cacheStart && splash.curAnim != "end"){
			splash.playAnim("end");

			new FlxTimer().start(0.3, function(tmr:FlxTimer){
				loadingText.text = "Done!";
				if(loadingBar != null){
					FlxTween.tween(loadingBar, {alpha: 0}, 0.3);
				}
			});
		}

		if(!cacheStart){
			if(FlxG.keys.anyJustPressed([BACKSPACE, DELETE])){
				Binds.resetToDefaultControls();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			else if(FlxG.keys.justPressed.ESCAPE){
				openPreloadSettings();
			}
		}

		if(startCachingCharacters){
			if(charI >= CacheReload.characterPreloadList.length){
				loadingText.text = "Characters cached...";
				startCachingCharacters = false;
				charactersCached = true;
			}
			else{
				CacheReload.cacheCharacter(charI);
				charI++;
				currentLoaded++;
			}
		}

		if(startCachingGraphics){
			if(gfxI >= CacheReload.graphicsPreloadList.length){
				loadingText.text = "Graphics cached...";
				startCachingGraphics = false;
				graphicsCached = true;
			}
			else{
				CacheReload.cacheGraphic(gfxI);
				gfxI++;
				currentLoaded++;
			}
		}
		
		super.update(elapsed);

	}

	function preload(){

		loadingText.text = "Caching Assets...";
		
		if(loadingBar != null){
			loadingBar.visible = true;
		}

		/*if(!charactersCached){
			var i = 0;
			var charLoadLoop = new FlxAsyncLoop(characters.length, function(){
				ImageCache.add(Paths.file(characters[i], "images", "png"));
				i++;
			}, 1);
		}

		for(x in characters){
			
			//trace("Chached " + x);
		}
		loadingText.text = "Characters cached...";
		charactersCached = true;*/

		if(!charactersCached){
			startCachingCharacters = true;
		}

		if(!graphicsCached){
			startCachingGraphics = true;
		}

	}

	function openPreloadSettings(){
		#if desktop
		FlxG.sound.play(Paths.sound('cancelMenu'));
		CacheSettings.noFunMode = true;
		customTransOut = new FadeOut(0.3);
		switchState(new CacheSettings());
		CacheSettings.returnLoc = new Startup();
		#end
	}

	function splashState(anim:String):Void{
		switch(anim){
			case "start":
				FlxG.sound.play(Paths.sound("splashSound"));
				if(splashHasSoundTrigger){
					splash.playAnim("soundTrigger");
				}
				else{
					startCache();
				}

			case "soundTrigger":
				startCache();

			case "end":
				ImageCache.localCache.clear();
				Utils.gc();
				customTransOut = new FadeOut(0.3);
				switchState(nextState);

			default:
				trace("Something has gone horribly wrong... Fix it.");
		}
	}

	function startCache():Void{
		#if web
		loadingText.visible = false;
		charactersCached = false;
		graphicsCached = false;
		new FlxTimer().start(1, function(tmr:FlxTimer){
			charactersCached = true;
			graphicsCached = true;
		});
		#else
		if(!charactersCached || !graphicsCached){
			preload(); 
		}
		else{
			loadingText.visible = false;
			charactersCached = false;
			graphicsCached = false;
			new FlxTimer().start(1, function(tmr:FlxTimer){
				charactersCached = true;
				graphicsCached = true;
			});
		}
		#end
		cacheStart = true;
	}

}
