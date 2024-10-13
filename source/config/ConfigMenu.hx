package config;

import openfl.utils.Assets;
import title.TitleScreen;
import flixel.sound.FlxSound;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import transition.data.*;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import extensions.flixel.FlxUIStateExt;
import extensions.flixel.FlxTextExt;


using StringTools;

class ConfigMenu extends FlxUIStateExt
{

    public static var USE_LAYERED_MUSIC:Bool = true;    //If you're not using a layered options theme, set this to false.
    public static var USE_MENU_MUSIC:Bool = false;      //Set this to true if you want to use the menu theme instead of a unique options song. Overrides USE_LAYERED_MUSIC.

    public static var exitTo:Class<Dynamic>;
    public static var startSong = true;
    public static var startInSubMenu:Int = -1;

    public static final baseSongTrack:String = "config/nuConfiguratorBase";
    public static final layerSongTrack:String = "config/nuConfiguratorDrums";
    public static final keySongTrack:String = "config/nuConfiguratorKey";
    public static final cacheSongTrack:String = "config/nuConfiguratorCache";

    var songLayer:FlxSound;

    final fpsCapInSettings:Int = 120;

    var curSelected:Int = 0;
    var curSelectedSub:Int = 0;

    var state:String = "topLevelMenu";
    var exiting:Bool = false;

    var icons:Array<FlxSprite> = [];
    var titles:Array<FlxSprite> = [];

    var bg:FlxSprite;
    var optionTitle:FlxSprite;
    var splatter:FlxSprite;
    var descBar:FlxSprite;

    var topLevelMenuGroup:FlxSpriteGroup = new FlxSpriteGroup();
    var subMenuGroup:FlxSpriteGroup = new FlxSpriteGroup();

    final options:Array<String> = ["video", "input", "misc"];
    final optionPostions:Array<Float> = [1/5, 1/2, 4/5];

    final menuTweenTime:Float = 0.6;
    final menuAlphaTweenTime:Float = 0.4;

    var configText:FlxTextExt;
    var descText:FlxTextExt;

    var configOptions:Array<Array<ConfigOption>> = [];

    var updateTextOnce:Bool = false;

    final genericOnOff:Array<String> = ["on", "off"];
    var offsetValue:Float;
	var healthValue:Int;
	var healthDrainValue:Int;
	var comboValue:Int;
	final comboTypes:Array<String> = ["world", "hud", "off"];
	var downValue:Bool;
	var glowValue:Bool;
	var randomTapValue:Int;
	final randomTapTypes:Array<String> = ["never", "not singing", "always"];
	final allowedFramerates:Array<Int> = [60, 120, 144, 240, 999];
	var framerateValue:Int;
	var dimValue:Int;
	var noteSplashValue:Int;
	final noteSplashTypes:Array<String> = ["off", "both", "partial", "hit only", "hold only"];
    var centeredValue:Bool;
    var scrollSpeedValue:Int;
    var showComboBreaksValue:Bool;
    var showFPSValue:Bool;
    var extraCamMovementValue:Bool;
    var camBopAmountValue:Int;
    final camBopAmountTypes:Array<String> = ["on", "reduced", "off"];
    var showCaptionsValue:Bool;
    var showAccuracyValue:Bool;
    var showMissesValue:Int;
    final showMissesTypes:Array<String> = ["off", "on", "combo breaks"];
    var enableVariationsValue:Bool;
    //final pauseMusicBehaviorTypes:Array<String> = ["unique", "base game", "breakfast only"];

    var pressUp:Bool = false;
    var pressDown:Bool = false;
    var pressLeft:Bool = false;
    var pressRight:Bool = false;
    var pressAccept:Bool = false;
    var pressBack:Bool = false;
    var holdUp:Bool = false;
    var holdDown:Bool = false;
    var holdLeft:Bool = false;
    var holdRight:Bool = false;

	override function create(){

		Config.setFramerate(fpsCapInSettings);

        if(exitTo == null){
			exitTo = MainMenuState;
		}

        FlxG.sound.cache(Paths.music(baseSongTrack));
        if(USE_LAYERED_MUSIC){
            FlxG.sound.cache(Paths.music(layerSongTrack));
            FlxG.sound.cache(Paths.music(keySongTrack));
            FlxG.sound.cache(Paths.music(cacheSongTrack));
        }
        

        if(startSong){
            if(!USE_MENU_MUSIC){
                FlxG.sound.playMusic(Paths.music(baseSongTrack), 1);
                if(USE_LAYERED_MUSIC){
                    songLayer = FlxG.sound.play(Paths.music(layerSongTrack), 0, true);
                }
            }
            else{
                FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), TitleScreen.titleMusicVolume);
            }
        }
		else{
            if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
                songLayer = FlxG.sound.play(Paths.music(layerSongTrack), 0, true);
                songLayer.time = FlxG.sound.music.time;
            }
            startSong = true;
        }

        bg = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF5C6CA5;

		optionTitle = new FlxSprite(0, 40);
		optionTitle.frames = Paths.getSparrowAtlas("menu/main/options");
		optionTitle.animation.addByPrefix('selected', "selected", 24);
		optionTitle.animation.play('selected');
		optionTitle.scrollFactor.set();
		optionTitle.antialiasing = true;
		optionTitle.updateHitbox();
		optionTitle.screenCenter(X);

        descBar = new FlxSprite(0, 720).makeGraphic(1280, 89, 0x77000000);

        add(bg);
        add(descBar);
        topLevelMenuGroup.add(optionTitle);

        splatter = new FlxSprite();
        splatter.frames = Paths.getSparrowAtlas("fpsPlus/config/splatter");
        splatter.animation.addByPrefix("boil", "", 24);
        splatter.animation.play("boil");
        splatter.antialiasing = true;
        topLevelMenuGroup.add(splatter);

        add(subMenuGroup);
        add(topLevelMenuGroup);

        var iconTexture = Paths.getSparrowAtlas("fpsPlus/config/icons");
        var textTexture = Paths.getSparrowAtlas("fpsPlus/config/text");

        for(i in 0...options.length){
            var icon = new FlxSprite();
            icon.frames = iconTexture;
            icon.animation.addByPrefix("boil", options[i] + "Icon", 24);
            icon.animation.play("boil");
            icon.antialiasing = true;
            icon.screenCenter(Y);
            icon.x = optionPostions[i] * 1280;
            icon.x -= icon.frameWidth/2;
            icons.push(icon);
            topLevelMenuGroup.add(icon);

            var text = new FlxSprite();
            text.frames = textTexture;
            text.animation.addByIndices('active', options[i] + "Text", [0, 1, 2], "", 24, true);
            text.animation.addByIndices('inactive', options[i] + "Text", [3, 6, 9], "", 8, true);
            text.animation.play("inactive");
            text.antialiasing = true;
            text.x = Utils.oldGetGraphicMidpoint(icon).x;
            text.y = 3/4 * 720;
            text.x -= text.frameWidth/2;
            titles.push(text);
            add(text);

        }

        configText = new FlxTextExt(0, 0, 1280, "", 60);
		configText.scrollFactor.set(0, 0);
		configText.setFormat(Paths.font("Funkin-Bold", "otf"), configText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		configText.borderSize = 4;
		configText.borderQuality = 1;
        subMenuGroup.add(configText);

        descText = new FlxTextExt(320, 638, 640, "", 20);
		descText.scrollFactor.set(0, 0);
		descText.setFormat(Paths.font("vcr"), descText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//descText.borderSize = 3;
		descText.borderQuality = 1;
        subMenuGroup.add(descText);

        setupOptions();
        if(startInSubMenu > -1){
            instantBringTextToTop(startInSubMenu);
        }
        changeSelected(0);

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		super.create();

	}

	override function update(elapsed:Float){

		super.update(elapsed);

        pressUp = Binds.justPressed("menuUp");
        pressDown = Binds.justPressed("menuDown");
        pressLeft = Binds.justPressed("menuLeft");
        pressRight = Binds.justPressed("menuRight");
        pressAccept = Binds.justPressed("menuAccept");
        pressBack = Binds.justPressed("menuBack");
        holdUp = Binds.pressed("menuUp");
        holdDown = Binds.pressed("menuDown");
        holdLeft = Binds.pressed("menuLeft");
        holdRight = Binds.pressed("menuRight");

        if(USE_LAYERED_MUSIC){
            if (!exiting && (Math.abs(songLayer.time - (FlxG.sound.music.time)) > 20)){
                resyncLayers();
            }
        }

        if(!exiting){

            switch(state){

                case "topLevelMenu":
                    if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
                        songLayer.volume = 0;
                    }

                    if (pressLeft){
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeSelected(-1);
                    }
                    else if(pressRight){
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeSelected(1);
                    }

                    if (pressBack){
                        exit();
                    }
                    else if (pressAccept){
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                        bringTextToTop(curSelected);
                        curSelectedSub = 0;
                        textUpdate();
                    }

                    if(updateTextOnce){
                        updateTextOnce = false;
                    }

                case "subMenu":
                    if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
                        songLayer.volume = 1;
                    }

                    if (pressBack){
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                        backToCategories();
                    }

                    if (pressUp){
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeSubSelected(-1);
                    }
                    else if(pressDown){
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeSubSelected(1);
                    }

                    if(configOptions[curSelected][curSelectedSub].optionUpdate != null){
                        configOptions[curSelected][curSelectedSub].optionUpdate();
                    }

                    if(pressUp || pressDown || pressLeft || pressRight || pressAccept || !updateTextOnce){
                        textUpdate();
                        updateTextOnce = true;
                    }

            }

        }

	}

    function exit(){
        writeToConfig();
        exiting = true;
        if(!USE_MENU_MUSIC || exitTo != MainMenuState){
            FlxG.sound.music.stop();
            Assets.cache.removeSound(baseSongTrack);
        }
        if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
            songLayer.stop();
            songLayer.destroy();
            Assets.cache.removeSound(layerSongTrack);
            Assets.cache.removeSound(keySongTrack);
            Assets.cache.removeSound(cacheSongTrack);
        }
		FlxG.sound.play(Paths.sound('cancelMenu'));
		switchState(Type.createInstance(exitTo, []));
        exitTo = null;
    }

    function bringTextToTop(x:Int){
        state = "subMenu";
        FlxTween.cancelTweensOf(titles[x]);
        FlxTween.cancelTweensOf(topLevelMenuGroup);
        FlxTween.cancelTweensOf(subMenuGroup);
        FlxTween.cancelTweensOf(descBar);
        FlxTween.cancelTweensOf(bg);
        FlxTween.tween(titles[x], {x: Utils.getGraphicMidpoint(optionTitle).x - titles[x].width/2, y: Utils.getGraphicMidpoint(optionTitle).y - titles[x].height/2, alpha: 1}, menuTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(topLevelMenuGroup, {alpha: 0}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(subMenuGroup, {alpha: 1}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(descBar, {y: 720 - descBar.height}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.color(bg, 1.75, 0xFF4961B8, 0xFF5C6CA5, {ease: FlxEase.quintOut});
        for(i in 0...titles.length){
            if(i != x){
                FlxTween.cancelTweensOf(titles[i]);
                FlxTween.tween(titles[i], {x: Utils.oldGetGraphicMidpoint(icons[i]).x - titles[i].frameWidth/2, y: 3/4 * 720, alpha: 0}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
            }
        }
    }

    function instantBringTextToTop(x:Int){
        state = "subMenu";
        curSelected = x;
        startInSubMenu = -1;
        titles[x].x = Utils.getGraphicMidpoint(optionTitle).x - titles[x].width/2;
        titles[x].y = Utils.getGraphicMidpoint(optionTitle).y - titles[x].height/2;
        titles[x].alpha = 1;
        topLevelMenuGroup.alpha = 0;
        subMenuGroup.alpha = 1;
        descBar.y = 720 - descBar.height;
        for(i in 0...titles.length){
            if(i != x){
                titles[i].x = Utils.oldGetGraphicMidpoint(icons[i]).x - titles[i].frameWidth/2;
                titles[i].y = 3/4 * 720;
                titles[i].alpha = 0;
            }
        }
        textUpdate();
    }

    function backToCategories(){
        state = "topLevelMenu";
        FlxTween.cancelTweensOf(topLevelMenuGroup);
        FlxTween.cancelTweensOf(subMenuGroup);
        FlxTween.cancelTweensOf(descBar);
        for(i in 0...titles.length){
            FlxTween.cancelTweensOf(titles[i]);
            FlxTween.tween(titles[i], {x: Utils.oldGetGraphicMidpoint(icons[i]).x - titles[i].frameWidth/2, y: 3/4 * 720, alpha: 1}, menuTweenTime, {ease: FlxEase.quintOut});
        }   
        FlxTween.tween(descBar, {y: 720}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(topLevelMenuGroup, {alpha: 1}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(subMenuGroup, {alpha: 0}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
    }

    function changeSelected(change:Int){
        
        curSelected += change;

        if(curSelected < 0){
            curSelected = options.length - 1;
        }
        else if(curSelected >= options.length){
            curSelected = 0;
        }

        for(i in 0...options.length){
            if(i == curSelected){
                icons[i].scale.set(1, 1);
                titles[i].animation.play("active");
                splatter.setPosition(Utils.oldGetGraphicMidpoint(icons[i]).x, Utils.oldGetGraphicMidpoint(icons[i]).y);
                splatter.x -= splatter.width/2;
                splatter.y -= splatter.height/2;
                /*FlxTween.cancelTweensOf(splatter.scale);
                splatter.scale.set(1.075, 1.075);
                FlxTween.tween(splatter.scale, {x: 1, y: 1}, 0.6, {ease: FlxEase.quintOut});*/
            }
            else{
                icons[i].scale.set(0.85, 0.85);
                titles[i].animation.play("inactive");
            }
        }
    }

    function changeSubSelected(change:Int){
        
        curSelectedSub += change;

        if(curSelectedSub < 0){
            curSelectedSub = configOptions[curSelected].length - 1;
        }
        else if(curSelectedSub >= configOptions[curSelected].length){
            curSelectedSub = 0;
        }

    }

    function textUpdate(){

        configText.clearFormats();
        configText.text = "";

        for(i in 0...configOptions[curSelected].length){

            var sectionStart = configText.text.length;
            configText.text += configOptions[curSelected][i].name + configOptions[curSelected][i].setting + "\n";
			var sectionEnd = configText.text.length - 1;

            if(i == curSelectedSub){
                configText.addFormat(new FlxTextFormat(0xFFFFFF00), sectionStart, sectionEnd);
            }

        }

        configText.screenCenter(XY);
        configText.y += 30;

		configText.text += "\n";

        descText.text = configOptions[curSelected][curSelectedSub].description;

		//tabDisplay.text = Std.string(tabKeys);

    }

    function setupOptions(){

        offsetValue = Config.offset;
		healthValue = Std.int(Config.healthMultiplier * 10);
		healthDrainValue = Std.int(Config.healthDrainMultiplier * 10);
		comboValue = Config.comboType;
		downValue = Config.downscroll;
		glowValue = Config.noteGlow;
		randomTapValue = Config.ghostTapType;
		dimValue = Config.bgDim;
		noteSplashValue = Config.noteSplashType;
		centeredValue = Config.centeredNotes;
		scrollSpeedValue = Std.int(Config.scrollSpeedOverride * 10);
		showComboBreaksValue = Config.showComboBreaks;
		showFPSValue = Config.showFPS;
		extraCamMovementValue = Config.extraCamMovement;
		camBopAmountValue = Config.camBopAmount;
		showCaptionsValue = Config.showCaptions;
		showAccuracyValue = Config.showAccuracy;
		showMissesValue = Config.showMisses;
		enableVariationsValue = Config.enableVariations;

        framerateValue = allowedFramerates.indexOf(Config.framerate);
        if(framerateValue == -1){
            framerateValue = allowedFramerates.length - 1;
        }

        //VIDEO

        var fpsCap = new ConfigOption("FRAMERATE", #if desktop ": " + (allowedFramerates[framerateValue] == 999 ? "uncapped" : ""+allowedFramerates[framerateValue]) #else ": disabled" #end, #if desktop "Uncaps the framerate during gameplay.\n(Some menus will limit framerate but gameplay will always be at the specified framerate.)" #else "Disabled on Web builds." #end);
        fpsCap.optionUpdate = function(){
            #if desktop
			if (pressRight) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				framerateValue++;
			}
            else if (pressRight || pressLeft) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				framerateValue--;
			}

            if(framerateValue < 0){
                framerateValue = allowedFramerates.length - 1;
            }
            if(framerateValue >= allowedFramerates.length){
                framerateValue = 0;
            }

            Config.setFramerate(fpsCapInSettings, allowedFramerates[framerateValue]);

            fpsCap.setting = ": " + (allowedFramerates[framerateValue] == 999 ? "uncapped" : ""+allowedFramerates[framerateValue]);
            #end
        };



        var bgDim = new ConfigOption("BACKGROUND DIM", ": " + (dimValue * 10) + "%", "Adjusts how dark the background is.\nIt is recommended that you use the HUD combo display with a high background dim.");
        bgDim.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                dimValue += 1;
            }
                
            if (pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                dimValue -= 1;
            }
                
            if (dimValue > 10)
                dimValue = 0;
            if (dimValue < 0)
                dimValue = 10;

            bgDim.setting = ": " + (dimValue * 10) + "%";
        }



        var noteSplash = new ConfigOption("NOTE SPLASH", ": " + noteSplashTypes[noteSplashValue], "temp :]");
        noteSplash.extraData[0] = "All note splashes are disabled.";
        noteSplash.extraData[1] = "Both note splashes and hold covers are enabled.";
        noteSplash.extraData[2] = "Both note splashes and hold covers are enabled, but there is no hold release splash.";
        noteSplash.extraData[3] = "Only note splashes are enabled, not hold covers.";
        noteSplash.extraData[4] = "Only hold covers are enabled, not note splashes.";
        noteSplash.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                noteSplashValue += 1;
            }
                
            if (pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                noteSplashValue -= 1;
            }
                
            if (noteSplashValue >= noteSplashTypes.length)
                noteSplashValue = 0;
            if (noteSplashValue < 0)
                noteSplashValue = noteSplashTypes.length - 1;

            noteSplash.setting = ": " + noteSplashTypes[noteSplashValue];
            noteSplash.description = noteSplash.extraData[noteSplashValue];
        }



        var noteGlow = new ConfigOption("NOTE GLOW", ": " + genericOnOff[glowValue?0:1], "Makes note arrows glow if they are able to be hit.");
        noteGlow.optionUpdate = function(){
            if (pressRight || pressLeft || pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                glowValue = !glowValue;
            }
            noteGlow.setting = ": " + genericOnOff[glowValue?0:1];
        }



        var extraCamStuff = new ConfigOption("DYNAMIC CAMERA", ": " + genericOnOff[extraCamMovementValue?0:1] , "Moves the camera in the direction of hit notes.");
        extraCamStuff.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				extraCamMovementValue = !extraCamMovementValue;
			}
            extraCamStuff.setting = ": " + genericOnOff[extraCamMovementValue?0:1];
        };



        var camBopStuff = new ConfigOption("CAMERA BOP", ": " + camBopAmountTypes[camBopAmountValue] , "Adjust how much the camera zooms on beat.");
        camBopStuff.optionUpdate = function(){
			if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                camBopAmountValue += 1;
            }
                
            if (pressLeft)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                camBopAmountValue -= 1;
            }
                
            if (camBopAmountValue > 2)
                camBopAmountValue = 0;
            if (camBopAmountValue < 0)
                camBopAmountValue = 2;

            camBopStuff.setting = ": " + camBopAmountTypes[camBopAmountValue];
        };



        var captionsStuff = new ConfigOption("CAPTIONS", ": " + genericOnOff[showCaptionsValue?0:1] , "Enables captions for songs that have them.");
        captionsStuff.optionUpdate = function(){
			if (pressRight || pressLeft || pressAccept) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				showCaptionsValue = !showCaptionsValue;
			}
            captionsStuff.setting = ": " + genericOnOff[showCaptionsValue?0:1];
        };



        //INPUT



        var noteOffset = new ConfigOption("NOTE OFFSET", ": " + offsetValue, "Adjust note timings.\nPress \"ENTER\" to start the offset calibration." + (Config.ee1?"\nHold \"SHIFT\" to force the pixel calibration.\nHold \"CTRL\" to force the normal calibration.":""));
        noteOffset.extraData[0] = 0;
        noteOffset.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                offsetValue += 1;
            }
                
            if (pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                offsetValue -= 1;
            }
                
            if (holdRight){
                noteOffset.extraData[0]++;
                    
                if(noteOffset.extraData[0] > 64) {
                    offsetValue += 1;
                    textUpdate();
                }
            }
                
            if (holdLeft){
                noteOffset.extraData[0]++;
                    
                if(noteOffset.extraData[0] > 64) {
                    offsetValue -= 1;
                    textUpdate();
                }
            }
                
            if(!holdRight && !holdLeft && noteOffset.extraData[0] != 0){
                noteOffset.extraData[0] = 0;
                textUpdate();
            }

            if(FlxG.keys.justPressed.ENTER){
                state = "transitioning";
                startInSubMenu = curSelected;
                FlxG.sound.music.fadeOut(0.3);
                writeToConfig();
                AutoOffsetState.forceEasterEgg = FlxG.keys.pressed.SHIFT ? 1 : (FlxG.keys.pressed.CONTROL ? -1 : 0);
                if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
                    songLayer.fadeOut(0.3);
                }
                switchState(new AutoOffsetState());
            }

            noteOffset.setting = ": " + offsetValue;
        };



        var downscroll = new ConfigOption("DOWNSCROLL", ": " + genericOnOff[downValue?0:1], "Makes notes approach from the top instead the bottom.");
        downscroll.optionUpdate = function(){
            if (pressRight || pressLeft || pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                downValue = !downValue;
            }
            downscroll.setting = ": " + genericOnOff[downValue?0:1];
        }



        var centeredNotes = new ConfigOption("CENTERED STRUM LINE", ": " + genericOnOff[centeredValue?0:1], "Makes the strum line centered instead of to the side.");
        centeredNotes.optionUpdate = function(){
            if (pressRight || pressLeft || pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                centeredValue = !centeredValue;
            }
            centeredNotes.setting = ": " + genericOnOff[centeredValue?0:1];
        }



        var ghostTap = new ConfigOption("ALLOW GHOST TAPPING", ": " + randomTapTypes[randomTapValue], "");
        ghostTap.extraData[0] = "Any key press that isn't for a valid note will cause you to miss.";
        ghostTap.extraData[1] = "You can only  miss while you need to sing.";
        ghostTap.extraData[2] = "You cannot miss unless you do not hit a note.";
        ghostTap.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                randomTapValue += 1;
            }
                
            if (pressLeft)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                randomTapValue -= 1;
            }
                
            if (randomTapValue > 2)
                randomTapValue = 0;
            if (randomTapValue < 0)
                randomTapValue = 2;

            ghostTap.setting = ": " + randomTapTypes[randomTapValue];
            ghostTap.description = ghostTap.extraData[randomTapValue];
        }



        var keyBinds = new ConfigOption("[EDIT CONTROLS]", "", "Press ENTER to change key binds.");
        keyBinds.optionUpdate = function(){
            if (pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                state = "transitioning";
                startInSubMenu = curSelected;
                writeToConfig();
                if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
                    songLayer.fadeOut(0.3);
                }
                if(Binds.justPressedControllerOnly("menuAccept")){
                    switchState(new KeyBindMenu(true));
                }
                else{
                    switchState(new KeyBindMenu(false));
                }
            }
        }

        var showFPS = new ConfigOption("SHOW FPS", ": " + genericOnOff[showFPSValue?0:1], "Show or hide the game's framerate.");
        showFPS.optionUpdate = function(){
            if (pressRight || pressLeft || pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                showFPSValue = !showFPSValue;
                Main.fpsDisplay.visible = showFPSValue;
            }
            showFPS.setting = ": " + genericOnOff[showFPSValue?0:1];
        }



        //MISC



        /*var accuracyDisplay = new ConfigOption("ACCURACY DISPLAY", ": " + accuracyType, "What type of accuracy calculation you want to use. Simple is just notes hit / total notes. Complex also factors in how early or late a note was.");
        accuracyDisplay.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                accuracyTypeInt += 1;
            }
                
            if (pressLeft)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                accuracyTypeInt -= 1;
            }
                
            if (accuracyTypeInt > 2)
                accuracyTypeInt = 0;
            if (accuracyTypeInt < 0)
                accuracyTypeInt = 2;
                    
            accuracyType = accuracyTypes[accuracyTypeInt];
            
            accuracyDisplay.setting = ": " + accuracyType;
        };*/



        var showAccuracyDisplay = new ConfigOption("SHOW ACCURACY", ": " + genericOnOff[showAccuracyValue?0:1], "Shows the accuracy on the in-game HUD.");
        showAccuracyDisplay.optionUpdate = function(){
            if (pressRight || pressLeft || pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                showAccuracyValue = !showAccuracyValue;
            }
            showAccuracyDisplay.setting = ": " + genericOnOff[showAccuracyValue?0:1];
        }



        var comboDisplay = new ConfigOption("COMBO DISPLAY", ": " + comboTypes[comboValue], "");
        comboDisplay.extraData[0] = "Ratings and combo count are a part of the world and move around with the camera.";
        comboDisplay.extraData[1] = "Ratings and combo count are a part of the hud and stay in a static position.";
        comboDisplay.extraData[2] = "Ratings and combo count are hidden.";
        comboDisplay.optionUpdate = function(){
            if (pressRight)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                comboValue += 1;
            }
                
            if (pressLeft)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                comboValue -= 1;
            }
                
            if (comboValue >= comboTypes.length)
                comboValue = 0;
            if (comboValue < 0)
                comboValue = comboTypes.length - 1;
            
            comboDisplay.setting = ": " + comboTypes[comboValue];
            comboDisplay.description = comboDisplay.extraData[comboValue];
        };



        var hpGain = new ConfigOption("HP GAIN MULTIPLIER", ": " + healthValue / 10.0, "Modifies how much Health you gain when hitting a note.");
        hpGain.extraData[0] = 0;
        hpGain.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthValue += 1;
            }
                
            if (pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthValue -= 1;
            }
                
            if (healthValue > 100)
                healthValue = 0;
            if (healthValue < 0)
                healthValue = 100;
                    
            if (holdRight){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthValue += 1;
                    textUpdate();
                }
            }
            
            if (holdLeft){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthValue -= 1;
                    textUpdate();
                }
            }
            
            if(!holdRight && !holdLeft){
                hpGain.extraData[0] = 0;
                textUpdate();
            }
            
            hpGain.setting = ": " + healthValue / 10.0;
        };



        var hpDrain = new ConfigOption("HP LOSS MULTIPLIER", ": " + healthDrainValue / 10.0, "Modifies how much Health you lose when missing a note.");
        hpDrain.extraData[0] = 0;
        hpDrain.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthDrainValue += 1;
            }
                
            if (pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthDrainValue -= 1;
            }
                
            if (healthDrainValue > 100)
                healthDrainValue = 0;
            if (healthDrainValue < 0)
                healthDrainValue = 100;
                    
            if (holdRight){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthDrainValue += 1;
                    textUpdate();
                }
            }
            
            if (holdLeft){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthDrainValue -= 1;
                    textUpdate();
                }
            }
            
            if(!holdRight && !holdLeft){
                hpGain.extraData[0] = 0;
                textUpdate();
            }
            
            hpDrain.setting = ": " + healthDrainValue / 10.0;
        };



        var cacheSettings = new ConfigOption("[CACHE SETTINGS]", "", "Press ENTER to change what assets the game keeps cached.");
        cacheSettings.optionUpdate = function(){
            if (pressAccept) {
                #if desktop
                FlxG.sound.play(Paths.sound('scrollMenu'));
                state = "transitioning";
                startInSubMenu = curSelected;
                writeToConfig();
                if(USE_LAYERED_MUSIC && !USE_MENU_MUSIC){
                    songLayer.fadeOut(0.3);
                }
                switchState(new CacheSettings());
                CacheSettings.returnLoc = new ConfigMenu();
                #end
            }
        }



        var scrollSpeed = new ConfigOption("STATIC SCROLL SPEED", ": " + (scrollSpeedValue > 0 ? "" + (scrollSpeedValue / 10.0) : "[DISABLED]"), "");
        scrollSpeed.extraData[0] = 0;
        scrollSpeed.extraData[1] = "Press ENTER to enable.\nSets the song scroll speed to the set value instead of the song's default.";
        scrollSpeed.extraData[2] = "Press ENTER to disable.\nSets the song scroll speed to the set value instead of the song's default.";
        scrollSpeed.optionUpdate = function(){

            if(scrollSpeedValue != -10){
                if (pressRight){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue += 1;
                }
                    
                if (pressLeft){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue -= 1;
                }
                    
                if (scrollSpeedValue > 50)
                    scrollSpeedValue = 10;
                if (scrollSpeedValue < 10)
                    scrollSpeedValue = 50;
                        
                if (holdRight){
                    scrollSpeed.extraData[0]++;
                    
                    if(scrollSpeed.extraData[0] > 64 && scrollSpeed.extraData[0] % 10 == 0) {
                        scrollSpeedValue += 1;
                        textUpdate();
                    }
                }
                
                if (holdLeft){
                    scrollSpeed.extraData[0]++;
                    
                    if(scrollSpeed.extraData[0] > 64 && scrollSpeed.extraData[0] % 10 == 0) {
                        scrollSpeedValue -= 1;
                        textUpdate();
                    }
                }
                
                if(!holdRight && !holdLeft){
                    scrollSpeed.extraData[0] = 0;
                    textUpdate();
                }

                if(pressAccept){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue = -10;
                }
            }
            else{
                if(pressAccept){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue = 10;
                }
            }

            scrollSpeed.description = scrollSpeedValue > 0 ? scrollSpeed.extraData[2] : scrollSpeed.extraData[1];
            scrollSpeed.setting = ": " + (scrollSpeedValue > 0 ? "" + (scrollSpeedValue / 10.0) : "[DISABLED]");
        };



        /*var showComboBreaks = new ConfigOption("SHOW COMBO BREAKS", ": " + genericOnOff[showComboBreaksValue?0:1], "Show combo breaks instead of misses.\nMisses only happen when you actually miss a note.\nCombo breaks can happen in other instances like dropping hold notes.");
        showComboBreaks.optionUpdate = function(){
            if (pressRight || pressLeft || pressAccept) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                showComboBreaksValue = !showComboBreaksValue;
            }
            showComboBreaks.setting = ": " + genericOnOff[showComboBreaksValue?0:1];
        }*/



        var showMissesSetting = new ConfigOption("SHOW MISSES", ": " + showMissesTypes[showMissesValue], "TEMP");
        showMissesSetting.extraData[0] = "Misses are not shown on the in-game HUD.";
        showMissesSetting.extraData[1] = "Misses are shown on the in-game HUD.";
        showMissesSetting.extraData[2] = "Combo breaks are shown on the in-game HUD.";
        showMissesSetting.optionUpdate = function(){
            if (pressRight){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                showMissesValue += 1;
            }
                
            if (pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                showMissesValue -= 1;
            }
                
            if (showMissesValue > 2)
                showMissesValue = 0;
            if (showMissesValue < 0)
                showMissesValue = 2;
            
            showMissesSetting.setting = ": " + showMissesTypes[showMissesValue];
            showMissesSetting.description = showMissesSetting.extraData[showMissesValue];
        };



        var variationsSettings = new ConfigOption("SHOW SONG VARIATIONS", ": " + genericOnOff[enableVariationsValue?0:1], "Enable or disable playing song variations in Freeplay.");
        variationsSettings.optionUpdate = function(){
            if (pressRight || pressLeft){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                enableVariationsValue = !enableVariationsValue;
            }

            variationsSettings.setting = ": " + genericOnOff[enableVariationsValue?0:1];
        };



        configOptions = [
                            [fpsCap, noteSplash, noteGlow, extraCamStuff, camBopStuff, captionsStuff, bgDim, showFPS],
                            [noteOffset, downscroll, centeredNotes, ghostTap, keyBinds],
                            [showMissesSetting, showAccuracyDisplay, comboDisplay, variationsSettings, scrollSpeed, hpGain, hpDrain, cacheSettings]
                        ];

    }

    function writeToConfig(){
		Config.write(offsetValue, healthValue / 10.0, healthDrainValue / 10.0, comboValue, downValue, glowValue, randomTapValue, allowedFramerates[framerateValue], dimValue, noteSplashValue, centeredValue, scrollSpeedValue / 10.0, showComboBreaksValue, showFPSValue, extraCamMovementValue, camBopAmountValue, showCaptionsValue, showAccuracyValue, showMissesValue, enableVariationsValue);
	}

    function resyncLayers():Void {
		songLayer.pause();
		FlxG.sound.music.play();
		songLayer.time = FlxG.sound.music.time;
		songLayer.play();
    }

}

class ConfigOption
{

    public var name:String;
    public var setting:String;
    public var description:String;
    public var optionUpdate:Void->Void;
    public var extraData:Array<Dynamic> = [];

    public function new(_name:String, _setting:String, _description:String, ?initFunction:Void->Void){
        name = _name;
        setting = _setting;
        description = _description;
        if(initFunction != null){
            initFunction();
        }
    }

}