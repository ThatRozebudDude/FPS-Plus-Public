package;

import extensions.flixel.system.frontEnds.SoundFrontEndExt;
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

	var songsCached:Bool;
	public static final songs:Array<String> =   ["Tutorial", 
								"Bopeebo", "Fresh", "Dadbattle", 
								"Spookeez", "South", "Monster",
								"Pico", "Philly", "Blammed", 
								"Satin-Panties", "High", "Milf", 
								"Cocoa", "Eggnog", "Winter-Horrorland", 
								"Senpai", "Roses", "Thorns",
								"Ugh", "Guns", "Stress",
								"Darnell", "Lit-Up", "2hot", "Blazin",
								"Lil-Buddies"];
								
	//List of character graphics and some other stuff.
	//Just in case it want to do something with it later.
	var charactersCached:Bool;
	var startCachingCharacters:Bool = false;
	var charI:Int = 0;
	public static final characters:Array<String> =   ["BOYFRIEND", "BOYFRIEND_DEAD", "week4/bfCar", "week5/bfChristmas", "week6/bfPixel", "week6/bfPixelsDEAD", "week7/bfAndGF", "week7/bfHoldingGF-DEAD",
									"GF_assets", "week4/gfCar", "week5/gfChristmas", "week6/gfPixel", "week7/gfTankmen",
									"week1/DADDY_DEAREST", 
									"week2/spooky_kids_assets", "week2/Monster_Assets",
									"week3/Pico_FNF_assetss", "week7/picoSpeaker", "weekend1/pico_weekend1",  "weekend1/pico_death",  "weekend1/Pico_Death_Retry",  "weekend1/Pico_Intro",  "weekend1/picoBlazinDeathConfirm", 
									"week4/Mom_Assets", "week4/momCar",
									"week5/mom_dad_christmas_assets", "week5/monsterChristmas",
									"week6/senpai", "week6/spirit",
									"week7/tankmanCaptain",
									"weekend1/darnell",
									"weekend1/Nene", "weekend1/abot/aBotViz", "weekend1/abot/stereoBG"];

	var graphicsCached:Bool;
	var startCachingGraphics:Bool = false;
	var gfxI:Int = 0;
	public static final graphics:Array<String> =	["logoBumpin", "titleEnter", "fpsPlus/title/backgroundBf", "fpsPlus/title/barBottom", "fpsPlus/title/barTop", "fpsPlus/title/gf", "fpsPlus/title/glow", 
									"week1/stageback", "week1/stagefront", "week1/stagecurtains",
									"week2/stage/shadowsWhite", "week2/stage/window", "week2/stage/windowLightWhite",
									"week3/philly/sky", "week3/philly/city", "week3/philly/behindTrain", "week3/philly/train", "week3/philly/street", "week3/philly/windowWhite", "week3/philly/windowWhiteGlow",
									"week4/limo/bgLimo", "week4/limo/fastCarLol", "week4/limo/limoDancer", "week4/limo/limoDrive", "week4/limo/limoSunset",
									"week5/christmas/bgWalls", "week5/christmas/upperBop", "week5/christmas/bgEscalator", "week5/christmas/christmasTree", "week5/christmas/bottomBop", "week5/christmas/fgSnow", "week5/christmas/santa",
									"week5/christmas/evilBG", "week5/christmas/evilTree", "week5/christmas/evilSnow",
									"week6/weeb/sky", "week6/weeb/farBackTrees", "week6/weeb/school", "week6/weeb/ground", "week6/weeb/backTrees", "week6/weeb/weebTrees", "week6/weeb/petals", "week6/weeb/bgFreaks",
									"week6/weeb/animatedEvilSchool", "week6/weeb/senpaiCrazy",
									"week7/stage/tank0", "week7/stage/tank1", "week7/stage/tank2", "week7/stage/tank3", "week7/stage/tank4", "week7/stage/tank5", "week7/stage/tankmanKilled1", 
									"week7/stage/smokeLeft", "week7/stage/smokeRight", "week7/stage/tankBuildings", "week7/stage/tankClouds", "week7/stage/tankGround", "week7/stage/tankMountains", "week7/stage/tankRolling", "week7/stage/tankRuins", "week7/stage/tankSky", "week7/stage/tankWatchtower",
									"weekend1/phillyStreets/phillyCars","weekend1/phillyStreets/phillyConstruction","weekend1/phillyStreets/phillyForeground","weekend1/phillyStreets/phillyForegroundCity","weekend1/phillyStreets/phillyHighway","weekend1/phillyStreets/phillyHighwayLights","weekend1/phillyStreets/phillyHighwayLights_lightmap","weekend1/phillyStreets/phillySkybox","weekend1/phillyStreets/phillySkyline","weekend1/phillyStreets/phillySmog","weekend1/phillyStreets/phillyTraffic","weekend1/phillyStreets/phillyTraffic_lightmap","weekend1/phillyStreets/SpraycanPile",  
									"weekend1/phillyBlazin/lightning", "weekend1/phillyBlazin/skyBlur", "weekend1/phillyBlazin/streetBlur"];

	var cacheStart:Bool = false;

	public static var thing = false;

	public static var hasEe2:Bool;

	override function create()
	{

		//results.ResultsState.enableDebugControls = true;

		SaveManager.global();

		#if FLX_SOUND_SYSTEM
		@:privateAccess{
			FlxG.sound = new SoundFrontEndExt();
		}
		#end

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

		/*if (FlxG.save.data.weekUnlocked != null)
		{

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}*/

		if(!CacheConfig.check()){
			CacheConfig.music = false;
			CacheConfig.characters = false;
			CacheConfig.graphics = false;
		}
		else{
			songsCached = !CacheConfig.music;
			charactersCached = !CacheConfig.characters;
			graphicsCached = !CacheConfig.graphics;
		}

		hasEe2 = Utils.exists(Paths.inst("Lil-Buddies"));

		splash = new FlxSprite(0, 0);
		splash.frames = Paths.getSparrowAtlas('fpsPlus/rozeSplash');
		splash.animation.addByPrefix('start', 'Splash Start', 24, false);
		splash.animation.addByPrefix('end', 'Splash End', 24, false);
		add(splash);
		splash.animation.play("start");
		splash.updateHitbox();
		splash.screenCenter();

		loadTotal = (!songsCached ? songs.length : 0) + (!charactersCached ? characters.length : 0) + (!graphicsCached ? graphics.length : 0);

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
			songsCached = false;
			new FlxTimer().start(1, function(tmr:FlxTimer){
				songsCached = true;
				charactersCached = true;
				graphicsCached = true;
			});
			#else
			if(!songsCached || !charactersCached || !graphicsCached){
				preload(); 
			}
			else{
				loadingText.visible = false;
				songsCached = false;
				new FlxTimer().start(1, function(tmr:FlxTimer){
					songsCached = true;
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

		if(songsCached && charactersCached && graphicsCached && splash.animation.curAnim.finished && !(splash.animation.curAnim.name == "end")){
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
				if(Utils.exists(Paths.file(characters[charI], "images", "png"))){
					ImageCache.add(Paths.file(characters[charI], "images", "png"));
				}
				else{
					trace("Character: File at " + characters[charI] + " not found, skipping cache.");
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
				if(Utils.exists(Paths.file(graphics[gfxI], "images", "png"))){
					ImageCache.add(Paths.file(graphics[gfxI], "images", "png"));
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
		
		if(!songsCached){ 
			#if sys sys.thread.Thread.create(() -> { #end
				preloadMusic();
			#if sys }); #end
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

	function preloadMusic(){
		for(x in songs){
			if(Utils.exists(Paths.inst(x))){
				FlxG.sound.cache(Paths.inst(x));
			}
			else if(Utils.exists(Paths.music(x))){
				FlxG.sound.cache(Paths.music(x));
			}
			currentLoaded++;
		}
		loadingText.text = "Songs cached...";
		songsCached = true;
	}

	function preloadCharacters(){
		for(x in characters){
			ImageCache.add(Paths.file(x, "images", "png"));
			//trace("Chached " + x);
		}
		loadingText.text = "Characters cached...";
		charactersCached = true;
	}

	function preloadGraphics(){
		for(x in graphics){
			ImageCache.add(Paths.file(x, "images", "png"));
			//trace("Chached " + x);
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
