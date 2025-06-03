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

	var splash:FlxSprite;
	var loadingBar:FlxBar;
	var loadingText:FlxText;

	var currentLoaded:Int = 0;
	var loadTotal:Int = 0;
								
	//List of character graphics and some other stuff.
	//Just in case it want to do something with it later.
	var charactersCached:Bool;
	var startCachingCharacters:Bool = false;
	var charI:Int = 0;
	public static var characters:Array<String> =   ["BOYFRIEND", "BOYFRIEND_DEAD", "week4/bfCar", "week5/bfChristmas", "week6/bfPixel", "week6/bfPixelsDEAD", "week7/bfAndGF", "week7/bfHoldingGF-DEAD",
									"GF_assets", "week4/gfCar", "week5/gfChristmas", "week6/gfPixel", "week7/gfTankmen",
									"week1/DADDY_DEAREST", 
									"week2/spooky_kids_assets", "week2/Monster_Assets",
									"week3/Pico_FNF_assetss", "week7/picoSpeaker", "weekend1/pico_weekend1",  "weekend1/pico_death",  "weekend1/Pico_Death_Retry",  "weekend1/Pico_Intro",  "weekend1/picoBlazinDeathConfirm", 
									"week4/Mom_Assets", "week4/momCar",
									"week5/mom_dad_christmas_assets", "week5/monsterChristmas",
									"week6/senpai", "week6/spirit",
									"week7/tankmanCaptain",
									"weekend1/darnell",
									"weekend1/Nene", "weekend1/abot/*"];

	var graphicsCached:Bool;
	var startCachingGraphics:Bool = false;
	var gfxI:Int = 0;
	public static var graphics:Array<String> = ["logoBumpin", "titleEnter", "fpsPlus/title/*", 
									"week1/stageback", "week1/stagefront", "week1/stagecurtains",
									"week2/stage/*",
									"week3/philly/*",
									"week4/limo/*",
									"week5/christmas/*",
									"week6/weeb/*",
									"week7/stage/*",
									"weekend1/phillyStreets/*", "weekend1/phillyBlazin/*"];

	var cacheStart:Bool = false;

	public static var thing = false;

	public static var hasEe2:Bool;

	override function create()
	{

		//results.ResultsState.enableDebugControls = true;

		SaveManager.global();

		FlxG.mouse.visible = false;
		FlxG.sound.muteKeys = null;

		Config.configCheck();
		Config.reload();

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

		splash = new FlxSprite(0, 0);
		splash.frames = Paths.getSparrowAtlas('fpsPlus/rozeSplash');
		splash.animation.addByPrefix('start', 'Splash Start', 24, false);
		splash.animation.addByPrefix('end', 'Splash End', 24, false);
		add(splash);
		splash.animation.play("start");
		splash.updateHitbox();
		splash.screenCenter();

		for (mod in PolymodHandler.loadedModDirs)
		{
			var meta = haxe.Json.parse(sys.io.File.getContent("mods/" + mod + "/meta.json"));
			if (meta.preload != null && meta.preload.characters != null){
				characters = characters.concat(meta.preload.characters);
			}
			if (meta.preload != null && meta.preload.graphics != null){
				graphics = graphics.concat(meta.preload.graphics);
			}
		}

		loadTotal = (!charactersCached ? characters.length : 0) + (!graphicsCached ? graphics.length : 0);

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

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound("splashSound"));   
		});

		super.create();

	}

	override function update(elapsed):Void{

		FlxG.mouse.visible = false;
		
		if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "start" && !cacheStart){
			
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
		if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "end"){
			ImageCache.localCache.clear();
			Utils.gc();
			customTransOut = new FadeOut(0.3);
			switchState(nextState);  
		}

		if(charactersCached && graphicsCached && splash.animation.curAnim.finished && !(splash.animation.curAnim.name == "end")){
			splash.animation.play("end");
			splash.updateHitbox();
			splash.screenCenter();

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
			if(charI >= characters.length){
				loadingText.text = "Characters cached...";
				startCachingCharacters = false;
				charactersCached = true;
			}
			else{
				if (characters[charI].endsWith("/*")){
					for (f in Utils.listEveryFileInFolder("images/" + characters[charI].split("/*")[0], ".png")){
						if(Utils.exists('assets/images/${ characters[charI].split("/*")[0]}/' + f)){
							ImageCache.preload('assets/images/${ characters[charI].split("/*")[0]}/' + f);
						}else{
							trace("Graphic: File at " +  f + " not found, skipping cache.");
						}
					}
				}
				else if(Utils.exists(Paths.file( characters[charI], "images", "png"))){
					ImageCache.preload(Paths.file( characters[charI], "images", "png"));
				}
				else{
					trace("Graphic: File at " +  characters[charI] + " not found, skipping cache.");
				}
				charI++;
				currentLoaded++;
			}
		}

		if(startCachingGraphics){
			if(gfxI >= graphics.length){
				loadingText.text = "Graphics cached...";
				startCachingGraphics = false;
				graphicsCached = true;
			}
			else{
				if (graphics[gfxI].endsWith("/*")){
					for (f in Utils.listEveryFileInFolder("images/" + graphics[gfxI].split("/*")[0], ".png")){
						if(Utils.exists('assets/images/${graphics[gfxI].split("/*")[0]}/' + f)){
							ImageCache.preload('assets/images/${graphics[gfxI].split("/*")[0]}/' + f);
						}else{
							trace("Graphic: File at " + f + " not found, skipping cache.");
						}
					}
				}
				else if(Utils.exists(Paths.file(graphics[gfxI], "images", "png"))){
					ImageCache.preload(Paths.file(graphics[gfxI], "images", "png"));
				}
				else{
					trace("Graphic: File at " + graphics[gfxI] + " not found, skipping cache.");
				}
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

	function preloadCharacters(){
		for(x in characters){
			if (x.endsWith("/*")){
				for (f in Utils.listEveryFileInFolder("images/" + x.split("/*")[0], ".png")){
					trace("caching from: " + 'assets/images/${x.split("/*")[0]}/' + f);
					ImageCache.preload('assets/images/${x.split("/*")[0]}/' + f);
				}
			}else{
				ImageCache.preload(Paths.file(x, "images", "png"));
			}
			//trace("Chached " + x);
		}
		loadingText.text = "Characters cached...";
		charactersCached = true;
	}

	function preloadGraphics(){
		for(x in graphics){
			if (x.endsWith("/*")){
				for (f in Utils.listEveryFileInFolder("images/" + x.split("/*")[0], ".png")){
					trace("caching from: " + 'assets/images/${x.split("/*")[0]}/' + f);
					ImageCache.preload('assets/images/${x.split("/*")[0]}/' + f);
				}
			}else{
				ImageCache.preload(Paths.file(x, "images", "png"));
			}
		}
		loadingText.text = "Graphics cached...";
		graphicsCached = true;
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

}
