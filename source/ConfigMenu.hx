package;

import openfl.system.System;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;

using StringTools;

class ConfigMenu extends MusicBeatState
{

	public static var startSong = true;

	var configText:FlxText;
	var descText:FlxText;
	var tabDisplay:FlxText;
	var configSelected:Int = 0;
	
	var offsetValue:Float;
	var accuracyType:String;
	var accuracyTypeInt:Int;
	var accuracyTypes:Array<String> = ["none", "simple", "complex"];
	var healthValue:Int;
	var healthDrainValue:Int;
	var iconValue:Bool;
	var downValue:Bool;
	var glowValue:Bool;
	var randomTapValue:Int;
	var randomTapTypes:Array<String> = ["never", "not singing", "always"];
	var noCapValue:Bool;
	var scheme:Int;

	var tabKeys:Array<String> = [];
	
	var canChangeItems:Bool = true;

	var leftRightCount:Int = 0;
	
	var settingText:Array<String> = [
									"NOTE OFFSET", 
									"ACCURACY DISPLAY", 
									"UNCAP FRAMERATE",
									"ALLOW GHOST TAPPING",
									"HP GAIN MULTIPLIER",
									"HP DRAIN MULTIPLIER",
									"DOWNSCROLL",
									"NOTE GLOW",
									"IMPROVED HEALTH HEADS",
									"CONTROLLER SCHEME",
									"[EDIT KEY BINDS]"
									];
								
	var settingDesc:Array<String> = [
									"Adjust note timings.\nPress \"ENTER\" to start the offset calibration." + (FlxG.save.data.ee1?"\nHold \"SHIFT\" to force the pixel calibration.\nHold \"CTRL\" to force the normal calibration.":""), 
									"What type of accuracy calculation you want to use. Simple is just notes hit / total notes. Complex also factors in how early or late a note was.", 
									"Uncaps the framerate during gameplay.",
									"Prevents you from missing when you don't need to play.",
									"Modifies how much Health you gain when hitting a note.",
									"Modifies how much Health you lose when missing a note.",
									"Makes notes appear from the top instead the bottom.",
									"Makes note arrows glow if they are able to be hit.",
									"Adds low health icons for characters missing them and adds winning icons.\n[This disables modded health icons unless there is a version of the files included in the mod.]",
									"TEMP",
									"Change key binds."
									];

	var ghostTapDesc:Array<String> = [
									"Any key press that isn't for a valid note will cause you to miss.", 
									"You can only  miss while you need to sing.", 
									"You cannot miss unless you do not hit a note.\n[Note that this makes the game very easy and can remove a lot of the challenge.]"
									];					

	var controlSchemes:Array<String> = [
									"DEFAULT", 
									"ALT 1", 
									"ALT 2",
									"CUSTOM"
									];

	var controlSchemesDesc:Array<String> = [
									"LEFT: DPAD LEFT / X (SQUARE) / LEFT TRIGGER\nDOWN: DPAD DOWN / X (CROSS) / LEFT BUMPER\nUP: DPAD UP / Y (TRIANGLE) / RIGHT BUMPER\nRIGHT: DPAD RIGHT / B (CIRCLE) / RIGHT TRIGGER", 
									"LEFT: DPAD LEFT / DPAD DOWN / LEFT TRIGGER\nDOWN: DPAD UP / DPAD RIGHT / LEFT BUMPER\nUP: X (SQUARE) / Y (TRIANGLE) / RIGHT BUMPER\nRIGHT: A (CROSS) / B (CIRCLE) / RIGHT TRIGGER", 
									"LEFT: ALL DPAD DIRECTIONS\nDOWN: LEFT BUMPER / LEFT TRIGGER\nUP: RIGHT BUMPER / RIGHT TRIGGER\nRIGHT: ALL FACE BUTTONS",
									"HIT A (CROSS) TO CHANGE CONTROLLER BINDS"
									];

									


	override function create()
	{	
	
		if(startSong)
			FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);
		else
			startSong = true;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuDesat.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF5C6CA5;
		add(bg);
	
		// var magenta = new FlxSprite(-80).loadGraphic('assets/images/menuBGMagenta.png');
		// magenta.scrollFactor.x = 0;
		// magenta.scrollFactor.y = 0;
		// magenta.setGraphicSize(Std.int(magenta.width * 1.18));
		// magenta.updateHitbox();
		// magenta.screenCenter();
		// magenta.visible = false;
		// magenta.antialiasing = true;
		// add(magenta);
		// magenta.scrollFactor.set();
		
		Config.reload();
		
		offsetValue = Config.offset;
		accuracyType = Config.accuracy;
		accuracyTypeInt = accuracyTypes.indexOf(Config.accuracy);
		healthValue = Std.int(Config.healthMultiplier * 10);
		healthDrainValue = Std.int(Config.healthDrainMultiplier * 10);
		iconValue = Config.betterIcons;
		downValue = Config.downscroll;
		glowValue = Config.noteGlow;
		randomTapValue = Config.ghostTapType;
		noCapValue = Config.noFpsCap;
		scheme = Config.controllerScheme;
		
		var tex = FlxAtlasFrames.fromSparrow('assets/images/FNF_main_menu_assets.png', 'assets/images/FNF_main_menu_assets.xml');
		var optionTitle:FlxSprite = new FlxSprite(0, 55);
		optionTitle.frames = tex;
		optionTitle.animation.addByPrefix('selected', "options white", 24);
		optionTitle.animation.play('selected');
		optionTitle.scrollFactor.set();
		optionTitle.antialiasing = true;
		optionTitle.updateHitbox();
		optionTitle.screenCenter(X);
			
		add(optionTitle);
			
		
		configText = new FlxText(0, 215, 1280, "", 48);
		configText.scrollFactor.set(0, 0);
		configText.setFormat("assets/fonts/Funkin-Bold.otf", 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		configText.borderSize = 3;
		configText.borderQuality = 1;
		
		descText = new FlxText(320, 638, 640, "", 20);
		descText.scrollFactor.set(0, 0);
		descText.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//descText.borderSize = 3;
		descText.borderQuality = 1;

		tabDisplay = new FlxText(5, FlxG.height - 53, 0, Std.string(tabKeys), 16);
		tabDisplay.scrollFactor.set();
		tabDisplay.visible = false;
		tabDisplay.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		var backText = new FlxText(5, FlxG.height - 37, 0, "ESCAPE - Back to Menu\nBACKSPACE - Reset to Defaults\n", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(configText);
		add(descText);
		add(tabDisplay);
		add(backText);

		textUpdate();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

		
	
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(canChangeItems && !FlxG.keys.pressed.TAB){
			if (controls.UP_P)
				{
					FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
					changeItem(-1);
				}

				if (controls.DOWN_P)
				{
					FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
					changeItem(1);
				}
				
				switch(configSelected){
					case 0: //Offset
						if (controls.RIGHT_P)
						{
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							offsetValue += 1;
						}
						
						if (controls.LEFT_P)
						{
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							offsetValue -= 1;
						}
						
						if (controls.RIGHT)
						{
							leftRightCount++;
							
							if(leftRightCount > 64) {
								offsetValue += 1;
								textUpdate();
							}
						}
						
						if (controls.LEFT)
						{
							leftRightCount++;
							
							if(leftRightCount > 64) {
								offsetValue -= 1;
								textUpdate();
							}
						}
						
						if(!controls.RIGHT && !controls.LEFT)
						{
							leftRightCount = 0;
						}

						if(FlxG.keys.justPressed.ENTER){
							canChangeItems = false;
							FlxG.sound.music.fadeOut(0.3);
							Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, iconValue, downValue, glowValue, randomTapValue, noCapValue, scheme);
							AutoOffsetState.forceEasterEgg = FlxG.keys.pressed.SHIFT ? 1 : (FlxG.keys.pressed.CONTROL ? -1 : 0);
							FlxG.switchState(new AutoOffsetState());
						}
						
					case 1: //Accuracy
						if (controls.RIGHT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								accuracyTypeInt += 1;
							}
							
							if (controls.LEFT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								accuracyTypeInt -= 1;
							}
							
							if (accuracyTypeInt > 2)
								accuracyTypeInt = 0;
							if (accuracyTypeInt < 0)
								accuracyTypeInt = 2;
								
							accuracyType = accuracyTypes[accuracyTypeInt];
					case 2: //FPS Cap
						if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							noCapValue = !noCapValue;
						}
					case 3: //Random Tap 
						if (controls.RIGHT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								randomTapValue += 1;
							}
							
							if (controls.LEFT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								randomTapValue -= 1;
							}
							
							if (randomTapValue > 2)
								randomTapValue = 0;
							if (randomTapValue < 0)
								randomTapValue = 2;
					case 4: //Health Multiplier
						if (controls.RIGHT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								healthValue += 1;
							}
							
							if (controls.LEFT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								healthValue -= 1;
							}
							
							if (healthValue > 100)
								healthValue = 0;
							if (healthValue < 0)
								healthValue = 100;
								
						if (controls.RIGHT)
						{
							leftRightCount++;
							
							if(leftRightCount > 64 && leftRightCount % 10 == 0) {
								healthValue += 1;
								textUpdate();
							}
						}
						
						if (controls.LEFT)
						{
							leftRightCount++;
							
							if(leftRightCount > 64 && leftRightCount % 10 == 0) {
								healthValue -= 1;
								textUpdate();
							}
						}
						
						if(!controls.RIGHT && !controls.LEFT)
						{
							leftRightCount = 0;
						}
						
						if(!controls.RIGHT && !controls.LEFT)
						{
							leftRightCount = 0;
						}				
					case 5: //Health Drain Multiplier
						if (controls.RIGHT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								healthDrainValue += 1;
							}
							
							if (controls.LEFT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								healthDrainValue -= 1;
							}
							
							if (healthDrainValue > 100)
								healthDrainValue = 0;
							if (healthDrainValue < 0)
								healthDrainValue = 100;
								
						if (controls.RIGHT)
						{
							leftRightCount++;
							
							if(leftRightCount > 64 && leftRightCount % 10 == 0) {
								healthDrainValue += 1;
								textUpdate();
							}
						}
						
						if (controls.LEFT)
						{
							leftRightCount++;
							
							if(leftRightCount > 64 && leftRightCount % 10 == 0) {
								healthDrainValue -= 1;
								textUpdate();
							}
						}
						
						if(!controls.RIGHT && !controls.LEFT)
						{
							leftRightCount = 0;
						}
					case 6: //Downscroll
						if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							downValue = !downValue;
						}
					case 7: //Note Glow
						if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							glowValue = !glowValue;
						}
					case 8: //Heads
						if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							iconValue = !iconValue;
						}
					case 9: //Controller Stuff
						if (controls.RIGHT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								scheme += 1;
							}
							
							if (controls.LEFT_P)
							{
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								scheme -= 1;
							}
							
							if (scheme >= controlSchemes.length)
								scheme = 0;
							if (scheme < 0)
								scheme = controlSchemes.length - 1;

							if (controls.ACCEPT && scheme == controlSchemes.length - 1) {
								FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
								canChangeItems = false;
								Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, iconValue, downValue, glowValue, randomTapValue, noCapValue, scheme);
								FlxG.switchState(new KeyBindMenuController());
							}

					case 10: //Binds
						if (controls.ACCEPT) {
							FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
							canChangeItems = false;
							Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, iconValue, downValue, glowValue, randomTapValue, noCapValue, scheme);
							FlxG.switchState(new KeyBindMenu());
						}
					
			}
		}
		else if(FlxG.keys.pressed.TAB){
			if(FlxG.keys.justPressed.ANY){
				if(FlxG.keys.getIsDown()[0].ID.toString() != "TAB"){
					tabKeys.push(FlxG.keys.getIsDown()[0].ID.toString());
				}		
			}
		}

		if(FlxG.keys.justPressed.TAB){
			tabDisplay.visible = true;
		}

		if(FlxG.keys.justReleased.TAB){
			secretPresetTest(tabKeys);
			tabKeys = [];
			tabDisplay.visible = false;
		}

		if (controls.BACK)
		{
			Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, iconValue, downValue, glowValue, randomTapValue, noCapValue, scheme);
			exit();
		}

		if (FlxG.keys.justPressed.BACKSPACE)
		{
			Config.resetSettings();
			FlxG.save.data.ee1 = false;
			exit();
		}

		super.update(elapsed);
		
		if(controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT || FlxG.keys.justPressed.ANY)
			textUpdate();
		
	}

	function changeItem(huh:Int = 0)
	{
		configSelected += huh;
			
		if (configSelected > settingText.length - 1)
			configSelected = 0;
		if (configSelected < 0)
			configSelected = settingText.length - 1;
			
	}

	function textUpdate(){

        configText.text = "";

        for(i in 0...settingText.length - 1){

            var textStart = (i == configSelected) ? ">" : "  ";
            configText.text += textStart + settingText[i] + ": " + getSetting(i) + "\n";

        }

		var textStart = (configSelected == settingText.length - 1) ? ">" : "  ";
		configText.text += textStart + settingText[settingText.length - 1] +  "\n";

		switch(configSelected){

			case 3:
				descText.text = ghostTapDesc[randomTapValue];
				
			case 9:
				descText.text = controlSchemesDesc[scheme];

			default:
				descText.text = settingDesc[configSelected];

		}

		tabDisplay.text = Std.string(tabKeys);

    }

	function getSetting(r:Int):Dynamic{

		switch(r){

			case 0: return offsetValue;
			case 1: return accuracyType;
			case 2: return noCapValue;
			case 3: return randomTapTypes[randomTapValue];
			case 4: return healthValue / 10.0;
			case 5: return healthDrainValue / 10.0;
			case 6: return downValue;
			case 7: return glowValue;
			case 8: return iconValue;
			case 9: return controlSchemes[scheme];

		}

		return -1;

	}

	function exit(){
		canChangeItems = false;
		FlxG.sound.music.stop();
		FlxG.sound.play('assets/sounds/cancelMenu' + TitleState.soundExt);
		FlxG.switchState(new MainMenuState());
	}

	function secretPresetTest(_combo:Array<String>):Void{

		var combo:String = "";

		for(x in _combo){
			combo += x;
		}

		switch(combo){

			case "KADE":
				Config.write(offsetValue, "complex", 5, 5, iconValue, downValue, false, 2, noCapValue, scheme);
				exit();
			case "ROZE":
				Config.write(offsetValue, "simple", 1, 1, true, true, true, 0, noCapValue, scheme);
				exit();
			case "CVAL":
				Config.write(offsetValue, "simple", 1, 1, iconValue, false, glowValue, 1, noCapValue, scheme);
				exit();
			case "GOTOHELLORSOMETHING":
				System.exit(0); //I am very funny.

		}

	}

}
