package modding;

import config.ConfigOption;
import config.CacheReload;
import config.CacheConfig;
import config.Config;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import extensions.flixel.FlxTextExt;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import extensions.flixel.FlxUIStateExt;
import caching.*;

class ModManagerState extends FlxUIStateExt
{

	var curSelectedMod:Int = 0;
	var curSelectedButton:Int = 0;
	var curListPosition:Int = 0;
	var curListStartOffset:Int = 0;

	var selectionBg:FlxSprite;
	var selectionConfig:FlxSprite;

	var selectionBgTween:FlxTween;
	var selectionConfigTween:FlxTween;
	var selectionConfigMoveTween:FlxTween;

	var hasMods:Bool = true;

	var modList:Array<ModInfo> = [];
	var shownModList:Array<ModInfo> = [];
	var listStartIndex:Int = 0;

	var modNames:Array<FlxTextExt> = [];
	var modIcons:Array<FlxSprite> = [];

	var optionNames:Array<FlxTextExt> = [];
	var optionValues:Array<FlxTextExt> = [];
	var allowConfigInput:Bool = true;

	var bigInfoIcon:FlxSprite;
	var bigInfoName:FlxTextExt;
	var bigInfoDescription:FlxTextExt;
	var bigInfoVersion:FlxTextExt;

	var enableDisableButton:ModManagerButton;
	var moveUpButton:ModManagerButton;
	var moveDownButton:ModManagerButton;
	var configButton:ModManagerButton;
	var reloadButton:ModManagerButton;
	var openFolderButton:ModManagerButton;
	var menuButtons:Array<ModManagerButton> = [];

	var oldDisabled:Array<String>;
	var oldOrder:Array<String>;
	var oldLoadedModList:Array<String>;

	var state:String = "selecting";

	final bgSpriteColor:FlxColor = 0xFFB26DAF;
	final selectorColor:FlxColor = 0xFFFF9DE1;

	final disabledColor:FlxColor = 0xFFE25F5D;

	final listStart:FlxPoint = new FlxPoint(60, 60);
	final infoStart:FlxPoint = new FlxPoint(520, 60);
	final bottomStart:FlxPoint = new FlxPoint(477.5, 570);

	override function create() {
		
		Config.setFramerate(120);

		oldDisabled = PolymodHandler.disabledModDirs;
		oldOrder = PolymodHandler.allModDirs;
		oldLoadedModList = PolymodHandler.loadedModDirs;
		

		var bg = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		bg.scale.set(1.18, 1.18);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = bgSpriteColor;

		var uiBg = new FlxSprite().loadGraphic(Paths.image("menu/modMenu/ui"));

		selectionBgTween = FlxTween.tween(this, {}, 0);
		selectionConfigTween = FlxTween.tween(this, {}, 0);
		selectionConfigMoveTween = FlxTween.tween(this, {}, 0);
		
		selectionBg = new FlxSprite(listStart.x + 4, listStart.y + 4).loadGraphic(Paths.image("menu/modMenu/selector"));
		selectionBg.color = selectorColor;
		selectionBg.antialiasing = true;
		
		selectionConfig = new FlxSprite(521, 160).loadGraphic(Paths.image("menu/modMenu/selectorConfig"));
		selectionConfig.color = selectorColor;
		selectionConfig.antialiasing = true;
		selectionConfig.alpha = 0;

		/*var iconTest = new FlxSprite(listStart.x + 10, listStart.y + 10).loadGraphic(Paths.image("menu/modMenu/defaultModIcon"));
		iconTest.antialiasing = true;

		var textTest = new FlxTextExt(listStart.x + 100, listStart.y + 50, 290, "Test Mod Name", 36);
		textTest.setFormat(Paths.font("Funkin-Bold", "otf"), 36, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		textTest.y -= textTest.height/2;
		textTest.borderSize = 2;*/

		bigInfoIcon = new FlxSprite(infoStart.x + 10, infoStart.y + 10).loadGraphic(Paths.image("menu/modMenu/defaultModIcon"));
		bigInfoIcon.antialiasing = true;

		bigInfoName = new FlxTextExt(infoStart.x + 100, infoStart.y + 50, 590, "Test Mod Name", 48);
		bigInfoName.setFormat(Paths.font("Funkin-Bold", "otf"), 48, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		bigInfoName.y -= bigInfoName.height/2;
		bigInfoName.borderSize = 3;

		bigInfoDescription = new FlxTextExt(infoStart.x + 10, infoStart.y + 110, 680, "This is where the mod description will go. I need this text to be long to make sure it wraps properly and doesn't go outside of the text box. Hurray! Fabs is on base. Game!", 36);
		bigInfoDescription.setFormat(Paths.font("Funkin-Bold", "otf"), 36, 0xFFFFFFFF, FlxTextAlign.LEFT);

		bigInfoVersion = new FlxTextExt(infoStart.x + 695, infoStart.y + 445, 0, "API Version: 1.0.0\nMod Version: 1.0.0\nUID: None", 20);
		bigInfoVersion.setFormat(Paths.font("Funkin-Bold", "otf"), 20, 0xFFFFFFFF, FlxTextAlign.RIGHT);
		bigInfoVersion.color = 0xFF999999;
		bigInfoVersion.y -= bigInfoVersion.height;
		bigInfoVersion.x -= bigInfoVersion.width;

		for(i in 0...7){
			var configText = new FlxTextExt(521 + 12, 160 + 12 + (50*i), 674, "Setting Option Thing GRAAHHHHH " + i + "\n\n", 28);
			configText.setFormat(Paths.font("Funkin-Bold", "otf"), configText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			configText.borderSize = 2;
			configText.borderQuality = 1;
			configText.alpha = 0;
			optionNames.push(configText);
		}

		for(i in 0...7){
			var valueText = new FlxTextExt(521 + 12, 160 + 12 + (50*i), 674, "< VALUE " + i + " >\n\n", 28);
			valueText.setFormat(Paths.font("Funkin-Bold", "otf"), valueText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			valueText.borderSize = 2;
			valueText.borderQuality = 1;
			valueText.alpha = 0;
			optionValues.push(valueText);
		}

		var enableDisableButtonTween:flixel.tweens.misc.ColorTween;
		enableDisableButton = new ModManagerButton(bottomStart.x + 60, bottomStart.y + 5);
		enableDisableButton.loadGraphic(Paths.image("menu/modMenu/enableDisableButton"), true, 240, 80);
		enableDisableButton.antialiasing = true;
		enableDisableButton.animation.add("selected", [2], 0, false);
		enableDisableButton.animation.add("deselected", [0], 0, false);
		enableDisableButton.animation.add("selected-disabled", [3], 0, false);
		enableDisableButton.animation.add("deselected-disabled", [1], 0, false);
		enableDisableButton.pressFunction = function(){
			if(hasMods && !modList[curSelectedMod].malformed){
				modList[curSelectedMod].enabled = !modList[curSelectedMod].enabled;
				FlxG.sound.play(Paths.sound("scrollMenu"));
				updateMenuButtons();
				buildShownModList();
			}
			else{
				FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
				if(enableDisableButtonTween != null) { enableDisableButtonTween.cancel(); }
				enableDisableButtonTween = FlxTween.color(enableDisableButton, 0.8, disabledColor, 0xFFFFFFFF, {ease: FlxEase.quartOut});
			}
		}

		var moveUpButtonTween:flixel.tweens.misc.ColorTween;
		moveUpButton = new ModManagerButton(bottomStart.x + 60 + 245, bottomStart.y + 5);
		moveUpButton.loadGraphic(Paths.image("menu/modMenu/moveUpButton"), true, 80, 80);
		moveUpButton.antialiasing = true;
		moveUpButton.animation.add("selected", [1], 0, false);
		moveUpButton.animation.add("deselected", [0], 0, false);
		moveUpButton.pressFunction = function(){
			if(hasMods && curSelectedMod > 0){
				var temp = modList[curSelectedMod-1];
				modList[curSelectedMod-1] = modList[curSelectedMod];
				modList[curSelectedMod] = temp;
				buildShownModList();
				changeModSelection(-1, false);
				FlxG.sound.play(Paths.sound("scrollMenu"));
			}
			else{
				FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
				if(moveUpButtonTween != null) { moveUpButtonTween.cancel(); }
				moveUpButtonTween = FlxTween.color(moveUpButton, 0.8, disabledColor, 0xFFFFFFFF, {ease: FlxEase.quartOut});
			}
		}

		var moveDownButtonTween:flixel.tweens.misc.ColorTween;
		moveDownButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85, bottomStart.y + 5);
		moveDownButton.loadGraphic(Paths.image("menu/modMenu/moveDownButton"), true, 80, 80);
		moveDownButton.antialiasing = true;
		moveDownButton.animation.add("selected", [1], 0, false);
		moveDownButton.animation.add("deselected", [0], 0, false);
		moveDownButton.pressFunction = function(){
			if(hasMods && curSelectedMod < modList.length-1){
				var temp = modList[curSelectedMod+1];
				modList[curSelectedMod+1] = modList[curSelectedMod];
				modList[curSelectedMod] = temp;
				buildShownModList();
				changeModSelection(1, false);
				FlxG.sound.play(Paths.sound("scrollMenu"));
			}
			else{
				FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
				if(moveDownButtonTween != null) { moveDownButtonTween.cancel(); }
				moveDownButtonTween = FlxTween.color(moveDownButton, 0.8, disabledColor, 0xFFFFFFFF, {ease: FlxEase.quartOut});
			}
		}
		
		var configButtonTween:flixel.tweens.misc.ColorTween;
		configButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85 + 85, bottomStart.y + 5);
		configButton.loadGraphic(Paths.image("menu/modMenu/configButton"), true, 80, 80);
		configButton.antialiasing = true;
		configButton.animation.add("selected", [1], 0, false);
		configButton.animation.add("deselected", [0], 0, false);
		configButton.pressFunction = function(){
			if(modList[curSelectedMod].config != null){
				FlxG.sound.play(Paths.sound("characterSelect/confirm"), 0.5);
				switchToConfigEdit();
			}
			else{
				FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
				if(configButtonTween != null) { configButtonTween.cancel(); }
				configButtonTween = FlxTween.color(configButton, 0.8, disabledColor, 0xFFFFFFFF, {ease: FlxEase.quartOut});
			}
		}

		reloadButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85 + 85 + 85, bottomStart.y + 5);
		reloadButton.loadGraphic(Paths.image("menu/modMenu/reloadButton"), true, 80, 80);
		reloadButton.antialiasing = true;
		reloadButton.animation.add("selected", [1], 0, false);
		reloadButton.animation.add("deselected", [0], 0, false);
		reloadButton.pressFunction = function(){
			if(curSelectedMod == modList.length-1 && modList.length > 6){ listStartIndex--; }
			save();
			PolymodHandler.buildModDirectories();
			ModConfig.load();
			SaveManager.global();
			buildFullModList();
			if(modList.length <= 6 ){ listStartIndex = 0; }
			changeModSelection(0, false);
			FlxG.sound.play(Paths.sound("scrollMenu"));
		}

		openFolderButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85 + 85 + 85 + 85, bottomStart.y + 5);
		openFolderButton.loadGraphic(Paths.image("menu/modMenu/folderButton"), true, 80, 80);
		openFolderButton.antialiasing = true;
		openFolderButton.animation.add("selected", [1], 0, false);
		openFolderButton.animation.add("deselected", [0], 0, false);
		openFolderButton.pressFunction = function(){
			FlxG.sound.play(Paths.sound("scrollMenu"));
			//Currently this is Windows only, if anyone wants to add opening mod folder support for other OSes be my guest.
			Sys.command("explorer.exe /n, /e, \"" + Sys.getCwd().substring(0, Sys.getCwd().length-1) + "\\mods\"");
		};

		menuButtons = [enableDisableButton, moveUpButton, moveDownButton, configButton, reloadButton, openFolderButton];

		buildFullModList();

		add(bg);
		add(uiBg);
		add(selectionBg);
		add(selectionConfig);

		add(bigInfoIcon);
		add(bigInfoName);
		add(bigInfoDescription);
		add(bigInfoVersion);

		for(i in 0...optionNames.length){
			add(optionNames[i]);
			add(optionValues[i]);
		}

		for(button in menuButtons){
			add(button);
		}

		buildShownModList();

		changeModSelection(0, false);
		changeButtonSelection(0);

		super.create();
	}

	var canDoThings:Bool = true;

	override function update(elapsed:Float) {

		if(canDoThings){
			switch(state){
				case "selecting":
					if(Binds.justPressed("menuUp") && hasMods){
						changeModSelection(-1);
						FlxG.sound.play(Paths.sound("scrollMenu"));
					}
					else if(Binds.justPressed("menuDown") && hasMods){
						changeModSelection(1);
						FlxG.sound.play(Paths.sound("scrollMenu"));
					}
			
					if(Binds.justPressed("menuLeft")){
						changeButtonSelection(-1);
						FlxG.sound.play(Paths.sound("scrollMenu"));
					}
					else if(Binds.justPressed("menuRight")){
						changeButtonSelection(1);
						FlxG.sound.play(Paths.sound("scrollMenu"));
					}
					if(Binds.justPressed("menuAccept")){
						menuButtons[curSelectedButton].press();
					}
			
					if(Binds.justPressed("menuBack")){
						FlxG.sound.play(Paths.sound("cancelMenu"));
						canDoThings = false;
						save();
						FlxG.signals.preStateSwitch.addOnce(function() { 
							PolymodHandler.reInit();
						});
						if(CacheConfig.music || CacheConfig.characters || CacheConfig.graphics){
							switchState(new CacheReload(new MainMenuState()));
						}
						else{
							switchState(new MainMenuState());
						}
						Utils.gc();
					}

				case "config":
					if(Binds.justPressed("menuBack")){
						FlxG.sound.play(Paths.sound("cancelMenu"));
						switchToSelecting();
					}
					else if(Binds.justPressed("menuDown")){
						if(curListStartOffset + curListPosition < modList[curSelectedMod].config.length-1){
							if(curListPosition == 6){
								curListStartOffset++;
							}
							else{
								curListPosition++;
							}
							FlxG.sound.play(Paths.sound("scrollMenu"));
							selectionConfigMoveTween.cancel();
							selectionConfigMoveTween = FlxTween.tween(selectionConfig, {y: 160 + (50*curListPosition)}, 0.2, {ease: FlxEase.expoOut});
							textUpdate();
						}
					}
					else if(Binds.justPressed("menuUp")){
						if(curListStartOffset + curListPosition > 0){
							if(curListPosition == 0){
								curListStartOffset--;
							}
							else{
								curListPosition--;
							}
							FlxG.sound.play(Paths.sound("scrollMenu"));
							selectionConfigMoveTween.cancel();
							selectionConfigMoveTween = FlxTween.tween(selectionConfig, {y: 160 + (50*curListPosition)}, 0.2, {ease: FlxEase.expoOut});
							textUpdate();
						}
					}

					if(state == "config"){
						modList[curSelectedMod].config[curListStartOffset + curListPosition].optionUpdate();
					}

					if(Binds.justPressed("menuLeft") || Binds.justPressed("menuRight")){
						textUpdate();
					}
			}
		}

		super.update(elapsed);
	}

	final FADE_TIME:Float = 0.25;

	function switchToConfigEdit():Void{
		state = "config";
		curListPosition = 0;
		curListStartOffset = 0;

		selectionBgTween.cancel();
		selectionConfigTween.cancel();

		selectionBgTween = FlxTween.tween(selectionBg, {alpha: 0}, FADE_TIME, {ease: FlxEase.quintOut});
		selectionConfigTween = FlxTween.tween(selectionConfig, {alpha: 1}, FADE_TIME, {ease: FlxEase.quintOut});

		FlxTween.cancelTweensOf(bigInfoDescription);
		FlxTween.tween(bigInfoDescription, {alpha: 0}, FADE_TIME, {ease: FlxEase.quintOut});
		
		FlxTween.cancelTweensOf(bigInfoVersion);
		FlxTween.tween(bigInfoVersion, {alpha: 0}, FADE_TIME, {ease: FlxEase.quintOut});

		for(i in 0...optionNames.length){
			FlxTween.cancelTweensOf(optionNames[i]);
			FlxTween.cancelTweensOf(optionValues[i]);

			FlxTween.tween(optionNames[i], {alpha: 1}, FADE_TIME, {ease: FlxEase.quintOut});
			FlxTween.tween(optionValues[i], {alpha: 1}, FADE_TIME, {ease: FlxEase.quintOut});
		}

		for(i in 0...menuButtons.length){
			menuButtons[i].deselect();
		}

		selectionConfigMoveTween.cancel();
		selectionConfig.y = 160 + (50*curListPosition);

		allowConfigInput = false;
		for(setting in modList[curSelectedMod].config){
			setting.optionUpdate();
		}
		allowConfigInput = true;
		textUpdate();
	}

	function switchToSelecting():Void{
		state = "selecting";

		selectionBgTween.cancel();
		selectionConfigTween.cancel();

		selectionBgTween = FlxTween.tween(selectionBg, {alpha: 1}, FADE_TIME, {ease: FlxEase.quintOut});
		selectionConfigTween = FlxTween.tween(selectionConfig, {alpha: 0}, FADE_TIME, {ease: FlxEase.quintOut});

		FlxTween.cancelTweensOf(bigInfoDescription);
		FlxTween.tween(bigInfoDescription, {alpha: 1}, FADE_TIME, {ease: FlxEase.quintOut});

		FlxTween.cancelTweensOf(bigInfoVersion);
		FlxTween.tween(bigInfoVersion, {alpha: 1}, FADE_TIME, {ease: FlxEase.quintOut});

		for(i in 0...optionNames.length){
			FlxTween.cancelTweensOf(optionNames[i]);
			FlxTween.cancelTweensOf(optionValues[i]);

			FlxTween.tween(optionNames[i], {alpha: 0}, FADE_TIME, {ease: FlxEase.quintOut});
			FlxTween.tween(optionValues[i], {alpha: 0}, FADE_TIME, {ease: FlxEase.quintOut});
		}

		updateMenuButtons();
	}

	function changeModSelection(change:Int, ?doTween:Bool = true) {
		if(!hasMods){ return; }

		curSelectedMod += change;

		if(curSelectedMod < 0){ curSelectedMod = 0; }
		if(curSelectedMod >= modList.length){ curSelectedMod = modList.length-1; }

		var curListPosition = curSelectedMod - listStartIndex;
		while(curListPosition >= 6){
			curListPosition--;
			listStartIndex++;
		}
		while(curListPosition < 0){
			curListPosition++;
			listStartIndex--;
		}

		FlxTween.cancelTweensOf(selectionBg);
		if(doTween){ FlxTween.tween(selectionBg, {y: listStart.y + 4 + (100 * curListPosition)}, 0.4, {ease: FlxEase.expoOut}); }
		else{ selectionBg.y = listStart.y + 4 + (100 * curListPosition); }

		updateBigInfo();
		updateMenuButtons();
		buildShownModList();
	}

	function changeButtonSelection(change:Int) {
		curSelectedButton += change;
		
		if(curSelectedButton < 0){ curSelectedButton = 0; }
		if(curSelectedButton >= menuButtons.length){ curSelectedButton = menuButtons.length-1; }

		updateMenuButtons();
	}

	function updateBigInfo():Void{
		bigInfoName.text = modList[curSelectedMod].name;
		bigInfoName.setPosition(infoStart.x + 100, infoStart.y + 50);
		bigInfoName.y -= bigInfoName.height/2;
		bigInfoName.text += "\n\n";

		bigInfoIcon.loadGraphic(modList[curSelectedMod].icon);
		bigInfoIcon.antialiasing = true;
		bigInfoIcon.setGraphicSize(80, 80);
		bigInfoIcon.updateHitbox();

		bigInfoDescription.text = modList[curSelectedMod].description + "\n\n";

		bigInfoVersion.text = "API Version: " + modList[curSelectedMod].apiVersion + "\nMod Version: " + modList[curSelectedMod].modVersion + "\nUID: " + modList[curSelectedMod].uid;
		bigInfoVersion.setPosition(infoStart.x + 695, infoStart.y + 445);
		bigInfoVersion.y -= bigInfoVersion.height;
		bigInfoVersion.x -= bigInfoVersion.width;
		bigInfoVersion.text += "\n\n";
	}

	function showbigInfoNoMods():Void{
		bigInfoName.text = "No Mods Installed";
		bigInfoName.setPosition(infoStart.x + 100, infoStart.y + 50);
		bigInfoName.y -= bigInfoName.height/2;
		bigInfoName.text += "\n\n";

		bigInfoIcon.loadGraphic(Paths.image("menu/modMenu/noModIcon"));
		bigInfoIcon.antialiasing = true;
		bigInfoIcon.setGraphicSize(80, 80);
		bigInfoIcon.updateHitbox();

		bigInfoDescription.text = "There are currently no mods installed in the mods folder. To install a mod download an FPS Plus compatable mod and drag it into the mods folder in your FPS Plus install then hit the refresh button in the mod manager or re-launch the game.\n\n";

		bigInfoVersion.text = "";
	}

	function updateMenuButtons() {
		if(!hasMods || !modList[curSelectedMod].enabled || modList[curSelectedMod].malformed){
			enableDisableButton.animSet = "disabled";
			enableDisableButton.toggleState = true;
		}
		else{
			enableDisableButton.animSet = "";
			enableDisableButton.toggleState = false;
		}

		for(i in 0...menuButtons.length){
			if(i == curSelectedButton){
				menuButtons[i].select();
			}
			else{
				menuButtons[i].deselect();
			}
		}
	}

	function getModIcon(mod:String):BitmapData{
		if(FileSystem.exists("mods/" + mod + "/icon.png")){
			return BitmapData.fromFile("mods/" + mod + "/icon.png");
		}
		return BitmapData.fromFile(Paths.image("menu/modMenu/defaultModIcon", true));
	}

	function buildFullModList():Void{
		modList = [];
		hasMods = true;

		if(PolymodHandler.allModDirs.length <= 0){
			hasMods = false;
			curSelectedMod = 0;
			listStartIndex = 0;
			showbigInfoNoMods();
			buildShownModList();
			updateMenuButtons();
			curSelectedButton = 3;
			changeButtonSelection(0);
			return;
		}

		for(dir in PolymodHandler.allModDirs){
			var info:ModInfo = {
				dir: dir,
				name: null,
				description: null,
				icon: null,
				apiVersion: null,
				modVersion: null,
				uid: null,
				enabled: true,
				config: null,
				malformed: false
			};

			if(PolymodHandler.malformedMods.exists(dir)){
				switch(PolymodHandler.malformedMods.get(dir)){
					case MISSING_META_JSON:
						info.name = dir;
						info.description = "This mod is missing a meta.json file.";
						info.icon = getModIcon(dir);
						info.apiVersion = "None";
						info.modVersion = "None";
						info.uid = "None";
					case MISSING_VERSION_FIELDS:
						var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
						if(json.title != null){ info.name = json.title; }
						else{ info.name = dir; }
						info.description = "This mod is missing some required field(s) in the meta.json file.";
						info.icon = getModIcon(dir);
						if(json.api_version != null){ info.apiVersion = json.api_version; }
						else{ info.apiVersion = "None"; }
						if(json.mod_version != null){ info.modVersion = json.mod_version; }
						else{ info.modVersion = "None"; }
						if(json.uid != null){ info.uid = json.uid; }
						else{ info.uid = "None"; }
					case MISSING_UID:
						var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
						if(json.title != null){ info.name = json.title; }
						else{ info.name = dir; }
						info.description = "This mod is missing a \"uid\" field in the meta.json file. This is required for all mods on API version 1.4.0 and onwards.";
						info.icon = getModIcon(dir);
						info.apiVersion = json.api_version;
						info.modVersion = json.mod_version;
						info.uid = "None";
					case API_VERSION_TOO_OLD:
						var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
						if(json.title != null){ info.name = json.title; }
						else{ info.name = dir; }
						info.description = "This mod was made for an older version of FPS Plus that uses a version of the modding API that is no longer supported.";
						info.icon = getModIcon(dir);
						info.apiVersion = json.api_version;
						info.modVersion = json.mod_version;
						info.uid = json.uid;
					case API_VERSION_TOO_NEW:
						var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
						if(json.title != null){ info.name = json.title; }
						else{ info.name = dir; }
						info.description = "This mod was made for an API version higher than what this version of FPS Plus supports. You may need to update your version of FPS Plus or the API version is set incorrectly for the mod.";
						info.icon = getModIcon(dir);
						info.apiVersion = json.api_version;
						info.modVersion = json.mod_version;
						info.uid = json.uid;
					default:
				}

				info.enabled = false;
				info.malformed = true;
			}
			else{
				var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
				var modAPIVersion:Array<Int> = [Std.parseInt(json.api_version.split(".")[0]), Std.parseInt(json.api_version.split(".")[1]), Std.parseInt(json.api_version.split(".")[2])];
				if(json.title != null){ info.name = json.title; }
				else{ info.name = dir; }
				if(json.description != null){ info.description = json.description; }
				else{ info.description = "No description."; }
				info.icon = getModIcon(dir);
				info.apiVersion = json.api_version;
				info.modVersion = json.mod_version;
				if(json.uid != null){ info.uid = json.uid; }
				else{ info.uid = "None"; }
				info.config = modAPIVersion[1] >= 4 ? buildModConfig(dir) : null;
				info.enabled = !PolymodHandler.disabledModDirs.contains(dir);
			}

			modList.push(info);
		}

		if(curSelectedMod >= modList.length){
			curSelectedMod = modList.length - 1;
		}
	}

	function buildShownModList():Void{
		for(modIcon in modIcons){ 
			remove(modIcon); 
			//modIcon.destroy();
		}
		for(modName in modNames){ 
			remove(modName);
			modName.destroy();
		}

		modIcons = [];
		modNames = [];

		if(!hasMods){
			selectionBg.visible = false;
			return;
		}

		selectionBg.visible = true;
		
		for(i in 0...Std.int(Math.min(6, modList.length))){
			var modIcon = new FlxSprite(listStart.x + 10, listStart.y + 10 + (100 * i)).loadGraphic(modList[i + listStartIndex].icon);
			modIcon.setGraphicSize(80, 80);
			modIcon.updateHitbox();
			modIcon.antialiasing = true;

			var modName = new FlxTextExt(listStart.x + 100, listStart.y + 50 + (100 * i), 290, modList[i + listStartIndex].name, 36);
			modName.setFormat(Paths.font("Funkin-Bold", "otf"), 36, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
			modName.y -= modName.height/2;
			modName.borderSize = 2;
			modName.text += "\n\n";

			if(modList[i + listStartIndex].malformed){
				modIcon.color = disabledColor;
				modName.color = disabledColor;
			}
			else if(!modList[i + listStartIndex].enabled){
				modIcon.color = 0xFF999999;
				modName.color = 0xFF999999;
			}

			modIcons.push(modIcon);
			modNames.push(modName);
		}

		for(modIcon in modIcons){ add(modIcon); }
		for(modName in modNames){ add(modName); }
	}
	
	function buildModConfig(dir:String):Array<ConfigOption>{
		if(!FileSystem.exists("mods/" + dir + "/config.json")){
			return null;
		}

		var meta = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
		var json = Json.parse(File.getContent("mods/" + dir + "/config.json"));

		var r:Array<ConfigOption> = [];

		for(i in 0...json.config.length){

			var setting:ConfigOption = null;

			switch(json.config[i].type){
				case "bool":
					var value:Bool = ModConfig.get(meta.uid, json.config[i].name);
					var trueName:String = (json.config[i].properties.trueName != null) ? json.config[i].properties.trueName : "true";
					var falseName:String = (json.config[i].properties.falseName != null) ? json.config[i].properties.falseName : "false";
					setting = new ConfigOption(json.config[i].name, "", "");
					setting.extraData[0] = value;
					setting.optionUpdate = function(){
						if(allowConfigInput){
							if(Binds.justPressed("menuLeft") || Binds.justPressed("menuRight")){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								value = !value;
							}
						}
						setting.setting = value ? trueName : falseName;
						setting.extraData[0] = value;
					};

				case "int":
					var value:Int = Std.int(ModConfig.get(meta.uid, json.config[i].name));
					var increment:Int = Std.int(json.config[i].properties.increment);
					var minValue:Int = Std.int(json.config[i].properties.range[0]);
					var maxValue:Int = Std.int(json.config[i].properties.range[1]);
					setting = new ConfigOption(json.config[i].name, "", "");
					setting.extraData[0] = value;
					setting.optionUpdate = function(){
						if(allowConfigInput){
							if(Binds.justPressed("menuLeft") && value > minValue){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								value -= increment;
							}
							else if(Binds.justPressed("menuRight") && value < maxValue){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								value += increment;
							}
						}

						if(value < minValue){
							value = minValue;
						}
						if(value > maxValue){
							value = maxValue;
						}

						setting.setting = ""+value;
						setting.extraData[0] = value;
					}

				case "float":
					var value:Float = ModConfig.get(meta.uid, json.config[i].name);
					var increment:Float = json.config[i].properties.increment;
					var tracker:Int = 0;
					var minValue:Float = json.config[i].properties.range[0];
					var maxValue:Float = json.config[i].properties.range[1];
					var startingValue:Float = cast(json.config[i].properties.defaultValue, Float);

					//:face_holding_back_tears:
					if(value != startingValue){
						var tempValue:Float = startingValue;
						var tempTracker:Int = 0;
						var resetValue:Bool = true;
						while(tempValue < maxValue && resetValue){
							tempTracker++;
							tempValue = startingValue + (tempTracker * increment);
							if(tempValue > maxValue){ tempValue = maxValue; }
							if(tempValue == value){ resetValue = false; }
						}
						if(resetValue){
							tempValue = startingValue;
							tempTracker = 0;
						}
						while(tempValue > minValue && resetValue){
							tempTracker--;
							tempValue = startingValue + (tempTracker * increment);
							if(tempValue < minValue){ tempValue = minValue; }
							if(tempValue == value){ resetValue = false; }
						}
	
						if(resetValue){ value = startingValue; }
						else{ tracker = tempTracker; }
					}
					
					setting = new ConfigOption(json.config[i].name, "", "");
					setting.extraData[0] = value;
					setting.optionUpdate = function(){
						if(allowConfigInput){
							if(Binds.justPressed("menuLeft") && value > minValue){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								tracker--;
								value = startingValue + (tracker * increment);
							}
							else if(Binds.justPressed("menuRight") && value < maxValue){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								tracker++;
								value = startingValue + (tracker * increment);
							}
						}

						if(value < minValue){ value = minValue; }
						if(value > maxValue){ value = maxValue; }

						setting.setting = ""+value;
						setting.extraData[0] = value;
					}

				case "list":
					var value:String = ModConfig.get(meta.uid, json.config[i].name);
					var values:Array<String> = json.config[i].properties.values;
					var index:Int = values.indexOf(value);
					setting = new ConfigOption(json.config[i].name, "", "");
					setting.extraData[0] = value;
					setting.optionUpdate = function(){
						if(allowConfigInput){
							if(Binds.justPressed("menuLeft")){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								index--;
							}
							else if(Binds.justPressed("menuRight")){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								index++;
							}
						}

						if(index < 0){
							index = values.length-1;
						}
						else if(index >= values.length){
							index = 0;
						}

						value = values[index];

						setting.setting = value;
						setting.extraData[0] = value;
					}

				default:
					trace("Unknown config type \"" + json.config[i].type + "\", skipping.");
			}

			if(setting != null){
				r.push(setting);
			}
		
		}

		return r;
	}

	function textUpdate():Void{
		for(i in 0...optionNames.length){
			textUpdateSingle(i);
		}
	}

	function textUpdateSingle(index:Int):Void{
		optionNames[index].text = "";
		optionValues[index].text = "";

		var optionPosition = curListStartOffset + index;
		if(optionPosition >= modList[curSelectedMod].config.length){ return; }

		optionNames[index].text = modList[curSelectedMod].config[optionPosition].name + "\n\n";
		optionValues[index].text = modList[curSelectedMod].config[optionPosition].setting;

		if(index == curListPosition){
			optionValues[index].text = "< " + optionValues[index].text + " >\n\n";
		}
		else{
			optionValues[index].text = optionValues[index].text + "\n\n";
		}
	}

	function save():Void{
		var newDisabledList:Array<String> = [];
		for(mod in modList){
			if(!mod.enabled && (!mod.malformed || PolymodHandler.disabledModDirs.contains(mod.dir))){
				newDisabledList.push(mod.dir);
			}
		}

		var newOrder:Array<String> = [];
		for(i in 0...modList.length){
			newOrder.push(modList[i].dir);
		}

		PolymodHandler.disabledModDirs = newDisabledList;
		PolymodHandler.allModDirs = newOrder;

		var write:String = "";
		for(mod in PolymodHandler.disabledModDirs){
			write += mod+"\n";
		}
		sys.io.File.saveContent("mods/disabled", write);

		write = "";
		for(mod in PolymodHandler.allModDirs){
			write += mod+"\n";
		}
		sys.io.File.saveContent("mods/order", write);

		trace(PolymodHandler.disabledModDirs);
		trace(PolymodHandler.allModDirs);

		for(i in 0...modList.length){
			if(PolymodHandler.malformedMods.exists(modList[i].dir) || modList[i].config == null){
				continue;
			}
			for(j in 0...modList[i].config.length){
				ModConfig.configMap.get(modList[i].uid).get(modList[i].config[j].name).value = modList[i].config[j].extraData[0];
			}
		}
		ModConfig.save();
		//trace(ModConfig.configMap);
	}

}

typedef ModInfo = {
	var dir:String;
	var name:String;
	var description:String;
	var icon:BitmapData;
	var apiVersion:String;
	var modVersion:String;
	var uid:String;
	var enabled:Bool;
	var config:Array<ConfigOption>;
	var malformed:Bool;
}

class ModManagerButton extends FlxSprite
{
	
	public var toggleState:Bool = false;
	public var animSet:String = "";

	public var pressFunction:()->Void;
	
	public function select():Void{
		var suffix:String = (animSet.length > 0) ? "-" + animSet : "";
		animation.play("selected" + suffix, true);
	}

	public function deselect():Void{
		var suffix:String = (animSet.length > 0) ? "-" + animSet : "";
		animation.play("deselected" + suffix, true);
	}

	public function press():Void{
		toggleState = !toggleState;
		if(pressFunction != null){ pressFunction(); }
		FlxTween.cancelTweensOf(scale);
		scale.set(0.85, 0.85);
		FlxTween.tween(scale, {x: 1, y: 1}, 1, {ease: FlxEase.elasticOut});
	}
}