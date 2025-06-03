package config;

import openfl.media.Sound;
import title.*;
import config.*;
import transition.data.*;

import flixel.FlxState;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.system.System;
import caching.*;
import modding.*;

using StringTools;

class CacheReload extends FlxState
{

	public static var doGraphics = true;

	public static final defaultCharacterPreloadList:Array<String> = [
		"BOYFRIEND", "BOYFRIEND_DEAD", "week4/bfCar", "week5/bfChristmas", "week6/bfPixel", "week6/bfPixelsDEAD", "week7/bfAndGF", "week7/bfHoldingGF-DEAD",
		"GF_assets", "week4/gfCar", "week5/gfChristmas", "week6/gfPixel", "week7/gfTankmen",
		"week1/DADDY_DEAREST", 
		"week2/spooky_kids_assets", "week2/Monster_Assets",
		"week3/Pico_FNF_assetss", "week7/picoSpeaker", "weekend1/pico_weekend1",  "weekend1/pico_death",  "weekend1/Pico_Death_Retry",  "weekend1/Pico_Intro",  "weekend1/picoBlazinDeathConfirm", 
		"week4/Mom_Assets", "week4/momCar",
		"week5/mom_dad_christmas_assets", "week5/monsterChristmas",
		"week6/senpai", "week6/spirit",
		"week7/tankmanCaptain",
		"weekend1/darnell",
		"weekend1/Nene", "weekend1/abot/*"
	];

	public static final defaultGraphicsPreloadList:Array<String> = [
		"logoBumpin", "titleEnter", "fpsPlus/title/*", 
		"week1/stageback", "week1/stagefront", "week1/stagecurtains",
		"week2/stage/*",
		"week3/philly/*",
		"week4/limo/*",
		"week5/christmas/*",
		"week6/weeb/*", "!week6/weeb/pixelUI/*",
		"week7/stage/*",
		"weekend1/phillyStreets/*", "weekend1/phillyBlazin/*"
	];

	public static var characterPreloadList:Array<String> = [];
	public static var graphicsPreloadList:Array<String> = [];

	var nextState:FlxState;

	//var splash:FlxSprite;
	//var dummy:FlxSprite;
	var loadingText:FlxText;

	var charactersCached:Bool;
	var startCachingCharacters:Bool = false;
	var charI:Int = 0;

	var graphicsCached:Bool;
	var startCachingGraphics:Bool = false;
	var gfxI:Int = 0;

	var cacheStart:Bool = false;

	public function new(?_nextState:FlxState = null) {
		super();
		if(_nextState != null){ nextState = _nextState; }
		else{ nextState = new ConfigMenu(); }
	}

	override function create(){
		buildPreloadList();

		charactersCached = !CacheConfig.characters;
		graphicsCached = !CacheConfig.graphics;

		if(doGraphics){
			ImageCache.clearAll();
		}
		else{
			charactersCached = true;
			graphicsCached = true;
		}

		Utils.gc();

		var text = new FlxText(0, 0, 1280, "LOADING ASSETS...", 64);
		text.scrollFactor.set(0, 0);
		text.setFormat(Paths.font("vcr"), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 3;
		text.borderQuality = 1;
		text.screenCenter(XY);
		add(text);

		preload();
		cacheStart = true;

		super.create();

	}

	override function update(elapsed):Void{

		if(charactersCached && graphicsCached){
			ImageCache.localCache.clear();
			Utils.gc();
			FlxG.switchState(nextState);
		}

		if(startCachingCharacters){
			if(charI >= characterPreloadList.length){
				//loadingText.text = "Characters cached...";
				//FlxG.sound.play(Paths.sound("tick"), 1);
				startCachingCharacters = false;
				charactersCached = true;
			}
			else{
				cacheCharacter(charI);
				charI++;
			}
		}

		if(startCachingGraphics){
			if(gfxI >= graphicsPreloadList.length){
				//loadingText.text = "Graphics cached...";
				//FlxG.sound.play(Paths.sound("tick"), 1);
				startCachingGraphics = false;
				graphicsCached = true;
			}
			else{
				cacheGraphic(gfxI);
				gfxI++;
			}
		}
		
		super.update(elapsed);

	}

	function preload(){

		//loadingText.text = "Preloading Assets...";

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

	public static function buildPreloadList():Void{
		characterPreloadList = defaultCharacterPreloadList;
		graphicsPreloadList = defaultGraphicsPreloadList;

		for(mod in PolymodHandler.loadedModDirs){
			var meta = haxe.Json.parse(sys.io.File.getContent("mods/" + mod + "/meta.json"));
			if(meta.preload != null && meta.preload.characters != null){
				characterPreloadList = characterPreloadList.concat(meta.preload.characters);
			}
			if(meta.preload != null && meta.preload.graphics != null){
				graphicsPreloadList = graphicsPreloadList.concat(meta.preload.graphics);
			}
		}

		characterPreloadList = parsePreloadList(characterPreloadList);
		graphicsPreloadList = parsePreloadList(graphicsPreloadList);
	}

	public static function parsePreloadList(list:Array<String>):Array<String>{
		var finalArray:Array<String> = [];
		var excludes:Array<String> = [];

		for(file in list){
			if(file.endsWith("/*")){
				if(file.startsWith("!")){
					var thing = file.split("!")[1];
					for(f in Utils.listEveryFileInFolder("images/" + thing.split("/*")[0], ".png")){
						excludes.push(thing.split("/*")[0] + "/" + f.split(".png")[0]);
					}
				}
				else{
					for(f in Utils.listEveryFileInFolder("images/" + file.split("/*")[0], ".png")){
						finalArray.push(file.split("/*")[0] + "/" + f.split(".png")[0]);
					}
				}
			}
			else{
				if(file.startsWith("!")){
					excludes.push(file);
				}
				else{
					finalArray.push(file);
				}
			}	
		}

		for(file in finalArray){
			if(excludes.contains(file)){
				finalArray.remove(file);
			}
		}

		return finalArray;
	}

	public static function cacheCharacter(index:Int):Void{
		if(Utils.exists(Paths.file(characterPreloadList[index], "images", "png"))){
			ImageCache.preload(Paths.file(characterPreloadList[index], "images", "png"));
		}
		else{
			trace("Graphic: File at " + characterPreloadList[index] + " not found, skipping cache.");
		}
	}

	public static function cacheGraphic(index:Int):Void{
		if(Utils.exists(Paths.file(graphicsPreloadList[index], "images", "png"))){
			ImageCache.preload(Paths.file(graphicsPreloadList[index], "images", "png"));
		}
		else{
			trace("Graphic: File at " + graphicsPreloadList[index] + " not found, skipping cache.");
		}
	}

}
