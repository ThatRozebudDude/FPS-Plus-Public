package config;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import transition.data.*;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;


using StringTools;

class ConfigMenu extends UIStateExt
{

    public static var exitTo:Class<Dynamic>;
    public static var startSong = true;
    public static var startInSubMenu:Int = -1;

    var curSelected:Int = 0;
    var curSelectedSub:Int = 0;

    var state:String = "topLevelMenu";

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

    var configText:FlxText;
    var descText:FlxText;

    var configOptions:Array<Array<ConfigOption>> = [];

    final genericOnOff:Array<String> = ["on", "off"];
    static var offsetValue:Float;
	static var accuracyType:String;
	static var accuracyTypeInt:Int;
	final accuracyTypes:Array<String> = ["none", "simple", "complex"];
	static var healthValue:Int;
	static var healthDrainValue:Int;
	static var comboValue:Int;
	final comboTypes:Array<String> = ["world", "hud", "off"];
	static var downValue:Bool;
	static var glowValue:Bool;
	static var randomTapValue:Int;
	final randomTapTypes:Array<String> = ["never", "not singing", "always"];
	static var noCapValue:Bool;
	static var scheme:Int;
	static var dimValue:Int;
	static var noteSplashValue:Int;
	final noteSplashTypes:Array<String> = ["off", "sick only", "always"];
    static var centeredValue:Bool;
    static var scrollSpeedValue:Int;
    static var showComboBreaksValue:Bool;

	override function create(){

        openfl.Lib.current.stage.frameRate = 144;

        if(exitTo == null){
			exitTo = MainMenuState;
		}

        if(startSong){
            FlxG.sound.playMusic(Paths.music('configurator'));
        }
		else{
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
		optionTitle.frames = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');
		optionTitle.animation.addByPrefix('selected', "options white", 24);
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
            text.x = icon.getGraphicMidpoint().x;
            text.y = 3/4 * 720;
            text.x -= text.frameWidth/2;
            titles.push(text);
            add(text);

        }

        configText = new FlxText(0, 0, 1280, "", 60);
		configText.scrollFactor.set(0, 0);
		configText.setFormat(Paths.font("Funkin-Bold", "otf"), configText.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		configText.borderSize = 3;
		configText.borderQuality = 1;
        subMenuGroup.add(configText);

        descText = new FlxText(320, 638, 640, "", 20);
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

        switch(state){

            case "topLevelMenu":
                if (controls.LEFT_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeSelected(-1);
                }
                else if(controls.RIGHT_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeSelected(1);
                }

                if (controls.BACK){
                    exit();
                }
                else if (controls.ACCEPT){
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    bringTextToTop(curSelected);
                    curSelectedSub = 0;
                    textUpdate();
                }

            case "subMenu":
                if (controls.BACK){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    backToCategories();
                }

                if (controls.UP_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeSubSelected(-1);
                }
                else if(controls.DOWN_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeSubSelected(1);
                }

                if(configOptions[curSelected][curSelectedSub].optionUpdate != null){
                    configOptions[curSelected][curSelectedSub].optionUpdate();
                }

                if(controls.UP_P || controls.DOWN_P || controls.LEFT_P || controls.RIGHT_P || controls.ACCEPT){
                    textUpdate();
                }

        }
        


	}

    function exit(){
        writeToConfig();
        FlxG.sound.music.stop();
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
        FlxTween.tween(titles[x], {x: optionTitle.getGraphicMidpoint().x - titles[x].width/2, y: optionTitle.getGraphicMidpoint().y - titles[x].height/2, alpha: 1}, menuTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(topLevelMenuGroup, {alpha: 0}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(subMenuGroup, {alpha: 1}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(descBar, {y: 720 - descBar.height}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
        FlxTween.color(bg, 1.75, 0xFF4961B8, 0xFF5C6CA5, {ease: FlxEase.quintOut});
        for(i in 0...titles.length){
            if(i != x){
                FlxTween.cancelTweensOf(titles[i]);
                FlxTween.tween(titles[i], {x: icons[i].getGraphicMidpoint().x - titles[i].frameWidth/2, y: 3/4 * 720, alpha: 0}, menuAlphaTweenTime, {ease: FlxEase.quintOut});
            }
        }
    }

    function instantBringTextToTop(x:Int){
        state = "subMenu";
        curSelected = x;
        startInSubMenu = -1;
        titles[x].x = optionTitle.getGraphicMidpoint().x - titles[x].width/2;
        titles[x].y = optionTitle.getGraphicMidpoint().y - titles[x].height/2;
        titles[x].alpha = 1;
        topLevelMenuGroup.alpha = 0;
        subMenuGroup.alpha = 1;
        descBar.y = 720 - descBar.height;
        for(i in 0...titles.length){
            if(i != x){
                titles[i].x = icons[i].getGraphicMidpoint().x - titles[i].frameWidth/2;
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
            FlxTween.tween(titles[i], {x: icons[i].getGraphicMidpoint().x - titles[i].frameWidth/2, y: 3/4 * 720, alpha: 1}, menuTweenTime, {ease: FlxEase.quintOut});
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
                splatter.setPosition(icons[i].getGraphicMidpoint().x, icons[i].getGraphicMidpoint().y);
                splatter.x -= splatter.width/2;
                splatter.y -= splatter.height/2;
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
		accuracyType = Config.accuracy;
		accuracyTypeInt = accuracyTypes.indexOf(Config.accuracy);
		healthValue = Std.int(Config.healthMultiplier * 10);
		healthDrainValue = Std.int(Config.healthDrainMultiplier * 10);
		comboValue = Config.comboType;
		downValue = Config.downscroll;
		glowValue = Config.noteGlow;
		randomTapValue = Config.ghostTapType;
		noCapValue = Config.noFpsCap;
		scheme = Config.controllerScheme;
		dimValue = Config.bgDim;
		noteSplashValue = Config.noteSplashType;
		centeredValue = Config.centeredNotes;
		scrollSpeedValue = Std.int(Config.scrollSpeedOverride * 10);

        //VIDEO

        var fpsCap = new ConfigOption("UNCAPPED FRAMERATE", #if desktop ": " + genericOnOff[noCapValue?0:1] #else ": disabled" #end, #if desktop "Uncaps the framerate during gameplay." #else "Disabled on Web builds." #end);
        fpsCap.optionUpdate = function(){
            #if desktop
			if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				noCapValue = !noCapValue;
			}
            fpsCap.setting = ": " + genericOnOff[noCapValue?0:1];
            #end
        };



        var bgDim = new ConfigOption("BACKGROUND DIM", ": " + (dimValue * 10) + "%", "Adjusts how dark the background is.\nIt is recommended that you use the HUD combo display with a high background dim.");
        bgDim.optionUpdate = function(){
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                dimValue += 1;
            }
                
            if (controls.LEFT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                dimValue -= 1;
            }
                
            if (dimValue > 10)
                dimValue = 0;
            if (dimValue < 0)
                dimValue = 10;

            bgDim.setting = ": " + (dimValue * 10) + "%";
        }



        var noteSplash = new ConfigOption("NOTE SPLASH", ": " + noteSplashTypes[noteSplashValue], "Adjusts how dark the background is.\nIt is recommended that you use the HUD combo display with a high background dim.");
        noteSplash.extraData[0] = "Note splashes are disabled.";
        noteSplash.extraData[1] = "Note splashes are created when you get a sick rating.";
        noteSplash.extraData[2] = "Note splashes are created every time you hit a note. \nWhy?";
        noteSplash.optionUpdate = function(){
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                noteSplashValue += 1;
            }
                
            if (controls.LEFT_P){
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
            if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                glowValue = !glowValue;
            }
            noteGlow.setting = ": " + genericOnOff[glowValue?0:1];
        }



        //INPUT



        var noteOffset = new ConfigOption("NOTE OFFSET", ": " + offsetValue, "Adjust note timings.\nPress \"ENTER\" to start the offset calibration." + (FlxG.save.data.ee1?"\nHold \"SHIFT\" to force the pixel calibration.\nHold \"CTRL\" to force the normal calibration.":""));
        noteOffset.extraData[0] = 0;
        noteOffset.optionUpdate = function(){
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                offsetValue += 1;
            }
                
            if (controls.LEFT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                offsetValue -= 1;
            }
                
            if (controls.RIGHT){
                noteOffset.extraData[0]++;
                    
                if(noteOffset.extraData[0] > 64) {
                    offsetValue += 1;
                    textUpdate();
                }
            }
                
            if (controls.LEFT){
                noteOffset.extraData[0]++;
                    
                if(noteOffset.extraData[0] > 64) {
                    offsetValue -= 1;
                    textUpdate();
                }
            }
                
            if(!controls.RIGHT && !controls.LEFT){
                noteOffset.extraData[0] = 0;
                textUpdate();
            }

            if(FlxG.keys.justPressed.ENTER){
                state = "transitioning";
                startInSubMenu = curSelected;
                FlxG.sound.music.fadeOut(0.3);
                writeToConfig();
                AutoOffsetState.forceEasterEgg = FlxG.keys.pressed.SHIFT ? 1 : (FlxG.keys.pressed.CONTROL ? -1 : 0);
                switchState(new AutoOffsetState());
            }

            noteOffset.setting = ": " + offsetValue;
        };



        var downscroll = new ConfigOption("DOWNSCROLL", ": " + genericOnOff[downValue?0:1], "Makes notes approach from the top instead the bottom.");
        downscroll.optionUpdate = function(){
            if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                downValue = !downValue;
            }
            downscroll.setting = ": " + genericOnOff[downValue?0:1];
        }



        var centeredNotes = new ConfigOption("CENTERED STRUM LINE", ": " + genericOnOff[centeredValue?0:1], "Makes the strum line centered instead of to the side.");
        centeredNotes.optionUpdate = function(){
            if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
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
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                randomTapValue += 1;
            }
                
            if (controls.LEFT_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                randomTapValue -= 1;
            }
                
            if (randomTapValue > 2)
                randomTapValue = 0;
            if (randomTapValue < 0)
                randomTapValue = 2;

            ghostTap.setting = ": " + randomTapTypes[randomTapValue];
            ghostTap.description = ": " + ghostTap.extraData[randomTapValue];
        }



        var keyBinds = new ConfigOption("[EDIT KEY BINDS]", "", "Press ENTER to change key binds.");
        keyBinds.optionUpdate = function(){
            if (controls.ACCEPT) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                state = "transitioning";
                startInSubMenu = curSelected;
                writeToConfig();
                switchState(new KeyBindMenu());
            }
        }



        var controllerBinds = new ConfigOption("CONTROLLER SCHEME", "", "");
        controllerBinds.extraData[0] = "DEFAULT";
        controllerBinds.extraData[1] = "ALT 1";
        controllerBinds.extraData[2] = "ALT 2";
        controllerBinds.extraData[3] = "[CUSTOM]";
        controllerBinds.extraData[4] = "LEFT: DPAD LEFT / X (SQUARE) / LEFT TRIGGER\nDOWN: DPAD DOWN / X (CROSS) / LEFT BUMPER\nUP: DPAD UP / Y (TRIANGLE) / RIGHT BUMPER\nRIGHT: DPAD RIGHT / B (CIRCLE) / RIGHT TRIGGER";
        controllerBinds.extraData[5] = "LEFT: DPAD LEFT / DPAD DOWN / LEFT TRIGGER\nDOWN: DPAD UP / DPAD RIGHT / LEFT BUMPER\nUP: X (SQUARE) / Y (TRIANGLE) / RIGHT BUMPER\nRIGHT: A (CROSS) / B (CIRCLE) / RIGHT TRIGGER";
        controllerBinds.extraData[6] = "LEFT: ALL DPAD DIRECTIONS\nDOWN: LEFT BUMPER / LEFT TRIGGER\nUP: RIGHT BUMPER / RIGHT TRIGGER\nRIGHT: ALL FACE BUTTONS";
        controllerBinds.extraData[7] = "Press A (CROSS) to change controller binds.";
        controllerBinds.setting = ": " + controllerBinds.extraData[scheme];
        controllerBinds.optionUpdate = function(){
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                scheme += 1;
            }
                
            if (controls.LEFT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                scheme -= 1;
            }
                
            if (scheme >= 4)
                scheme = 0;
            if (scheme < 0)
                scheme = 4 - 1;

            if (controls.ACCEPT && scheme == 4 - 1) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                state = "transitioning";
                startInSubMenu = curSelected;
                writeToConfig();
                switchState(new KeyBindMenuController());
            }

            controllerBinds.setting = ": " + controllerBinds.extraData[scheme];
            controllerBinds.description = controllerBinds.extraData[scheme+4];
        }



        //MISC



        var accuracyDisplay = new ConfigOption("ACCURACY DISPLAY", ": " + accuracyType, "What type of accuracy calculation you want to use. Simple is just notes hit / total notes. Complex also factors in how early or late a note was.");
        accuracyDisplay.optionUpdate = function(){
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                accuracyTypeInt += 1;
            }
                
            if (controls.LEFT_P)
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
        };



        var comboDisplay = new ConfigOption("COMBO DISPLAY", ": " + comboTypes[comboValue], "");
        comboDisplay.extraData[0] = "Ratings and combo count are a part of the world and move around with the camera.";
        comboDisplay.extraData[1] = "Ratings and combo count are a part of the hud and stay in a static position.";
        comboDisplay.extraData[2] = "Ratings and combo count are hidden.";
        comboDisplay.optionUpdate = function(){
            if (controls.RIGHT_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                comboValue += 1;
            }
                
            if (controls.LEFT_P)
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
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthValue += 1;
            }
                
            if (controls.LEFT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthValue -= 1;
            }
                
            if (healthValue > 100)
                healthValue = 0;
            if (healthValue < 0)
                healthValue = 100;
                    
            if (controls.RIGHT){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthValue += 1;
                    textUpdate();
                }
            }
            
            if (controls.LEFT){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthValue -= 1;
                    textUpdate();
                }
            }
            
            if(!controls.RIGHT && !controls.LEFT){
                hpGain.extraData[0] = 0;
                textUpdate();
            }
            
            hpGain.setting = ": " + healthValue / 10.0;
        };



        var hpDrain = new ConfigOption("HP LOSS MULTIPLIER", ": " + healthDrainValue / 10.0, "Modifies how much Health you lose when missing a note.");
        hpDrain.extraData[0] = 0;
        hpDrain.optionUpdate = function(){
            if (controls.RIGHT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthDrainValue += 1;
            }
                
            if (controls.LEFT_P){
                FlxG.sound.play(Paths.sound('scrollMenu'));
                healthDrainValue -= 1;
            }
                
            if (healthDrainValue > 100)
                healthDrainValue = 0;
            if (healthDrainValue < 0)
                healthDrainValue = 100;
                    
            if (controls.RIGHT){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthDrainValue += 1;
                    textUpdate();
                }
            }
            
            if (controls.LEFT){
                hpGain.extraData[0]++;
                
                if(hpGain.extraData[0] > 64 && hpGain.extraData[0] % 10 == 0) {
                    healthDrainValue -= 1;
                    textUpdate();
                }
            }
            
            if(!controls.RIGHT && !controls.LEFT){
                hpGain.extraData[0] = 0;
                textUpdate();
            }
            
            hpDrain.setting = ": " + healthDrainValue / 10.0;
        };



        var cacheSettings = new ConfigOption("[CACHE SETTINGS]", "", "Press ENTER to change what assets the game keeps cached.");
        cacheSettings.optionUpdate = function(){
            if (controls.ACCEPT) {
                #if desktop
                FlxG.sound.play(Paths.sound('scrollMenu'));
                state = "transitioning";
                startInSubMenu = curSelected;
                writeToConfig();
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
                if (controls.RIGHT_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue += 1;
                }
                    
                if (controls.LEFT_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue -= 1;
                }
                    
                if (scrollSpeedValue > 50)
                    scrollSpeedValue = 10;
                if (scrollSpeedValue < 10)
                    scrollSpeedValue = 50;
                        
                if (controls.RIGHT){
                    scrollSpeed.extraData[0]++;
                    
                    if(scrollSpeed.extraData[0] > 64 && scrollSpeed.extraData[0] % 10 == 0) {
                        scrollSpeedValue += 1;
                        textUpdate();
                    }
                }
                
                if (controls.LEFT){
                    scrollSpeed.extraData[0]++;
                    
                    if(scrollSpeed.extraData[0] > 64 && scrollSpeed.extraData[0] % 10 == 0) {
                        scrollSpeedValue -= 1;
                        textUpdate();
                    }
                }
                
                if(!controls.RIGHT && !controls.LEFT){
                    scrollSpeed.extraData[0] = 0;
                    textUpdate();
                }

                if(controls.ACCEPT){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue = -10;
                }
            }
            else{
                if(controls.ACCEPT){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    scrollSpeedValue = 10;
                }
            }

            scrollSpeed.description = scrollSpeedValue > 0 ? scrollSpeed.extraData[2] : scrollSpeed.extraData[1];
            scrollSpeed.setting = ": " + (scrollSpeedValue > 0 ? "" + (scrollSpeedValue / 10.0) : "[DISABLED]");
        };



        var showComboBreaks = new ConfigOption("SHOW COMBO BREAKS", ": " + genericOnOff[showComboBreaksValue?0:1], "Show combo breaks instead of misses.\nMisses only happen when you actually miss a note.\nCombo breaks can happen in other instances like dropping hold notes.");
        showComboBreaks.optionUpdate = function(){
            if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                showComboBreaksValue = !showComboBreaksValue;
            }
            showComboBreaks.setting = ": " + genericOnOff[showComboBreaksValue?0:1];
        }



        configOptions = [
                            [fpsCap, noteSplash, noteGlow, bgDim],
                            [noteOffset, downscroll, centeredNotes, ghostTap, controllerBinds, keyBinds],
                            [accuracyDisplay, showComboBreaks, comboDisplay, scrollSpeed, hpGain, hpDrain, cacheSettings]
                        ];

    }

    function writeToConfig(){
		Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, comboValue, downValue, glowValue, randomTapValue, noCapValue, scheme, dimValue, noteSplashValue, centeredValue, scrollSpeedValue / 10.0, showComboBreaksValue);
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