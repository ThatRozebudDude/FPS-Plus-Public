package config;

import extensions.flixel.FlxUIStateExt;
import extensions.flixel.FlxTextExt;
import flixel.sound.FlxSound;
import transition.data.*;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class CacheSettings extends FlxUIStateExt
{

    public static var noFunMode = false;

    var keyTextDisplay:FlxTextExt;
    var warning:FlxTextExt;
    var warningText:Array<String> = [
                                    "Enabling this will load the song instrumentals into RAM. This will decrease loading times and allow you to preview songs in the Freeplay menu at the cost of using more memory. Leave this disabled to reduce memory usage.",
                                    "Enabling this will load the character sprites into VRAM. This will decrease loading times. Disabling this will increase RAM usage slightly during gameplay.",
                                    "Enabling this will load most of the stage graphics into VRAM. This will decrease loading times. Disabling this will increase RAM usage during gameplay. If you don't have a decent GPU it might be best to leave this disabled.",
                                    ];

    public static var returnLoc:FlxState;
    public static var thing:Bool = false;

    var settings:Array<Bool>;
    var startingSettings:Array<Bool>;
    var names:Array<String> = ["MUSIC", "CHARACTERS", "GRAPHICS"];
    var onOff:Array<String> = ["off", "on"];

    var curSelected:Int = 0;

    var state:String = "select";

    var songLayer:FlxSound;

	override function create()
	{

        var bgColor:FlxColor = 0xFF9766BE;
        var font:String = Paths.font("Funkin-Bold", "otf");

        if(noFunMode){
            bgColor = 0xFF303030;
            font = "VCR OSD Mono";
        }

        if(!ConfigMenu.USE_MENU_MUSIC && ConfigMenu.USE_LAYERED_MUSIC && !noFunMode){
            songLayer = FlxG.sound.play(Paths.music(ConfigMenu.cacheSongTrack), 0, true);
            songLayer.time = FlxG.sound.music.time;
            songLayer.fadeIn(0.6);
        }

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = bgColor;
		add(bg);

        keyTextDisplay = new FlxTextExt(0, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(font, 72, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 4;
		keyTextDisplay.borderQuality = 1;
        add(keyTextDisplay);

        warning = new FlxTextExt(0, 540, 1120, warningText[curSelected], 32);
		warning.scrollFactor.set(0, 0);
		warning.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        warning.borderSize = 3;
		warning.borderQuality = 1;
        warning.screenCenter(X);
        add(warning);

        var binds = Binds.binds.get("menuBack").binds;
        var backBindsString = "";

        for(x in binds){
            backBindsString += x.toString() + "/";
        }

        if(backBindsString != ""){
            backBindsString = backBindsString.substr(0, backBindsString.length - 1);
        }
        else{
            backBindsString = "You can't leave I guess. Reset your game and press BACKSPACE or DELETE before the preload.";
        }

        var backText = new FlxTextExt(5, FlxG.height - 21, 0, backBindsString + " - Back to Menu", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(backText);

        if(!CacheConfig.check())
        {
            CacheConfig.music = false;
            CacheConfig.characters = true;
            CacheConfig.graphics = false;
        }

        settings = [CacheConfig.music, CacheConfig.characters, CacheConfig.graphics];
        startingSettings = [CacheConfig.music, CacheConfig.characters, CacheConfig.graphics];

        textUpdate();

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		super.create();
	}

	override function update(elapsed:Float){

        switch(state){

            case "select":
                if (Binds.justPressed("menuUp"))
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}

				if (Binds.justPressed("menuDown"))
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}

                if (Binds.justPressed("menuAccept") || Binds.justPressed("menuLeft") || Binds.justPressed("menuRight")){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    settings[curSelected] = !settings[curSelected];
                }
                else if(Binds.justPressed("menuBack")){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    quit();
                }

                if((FlxG.keys.justPressed.ANY || FlxG.gamepads.anyJustPressed(ANY)) && state != "exiting"){
                    textUpdate();
                }

            case "exiting":


            default:
                state = "select";

        }

        if(!noFunMode && state != "exiting" && !ConfigMenu.USE_MENU_MUSIC && ConfigMenu.USE_LAYERED_MUSIC && Math.abs(FlxG.sound.music.time - songLayer.time) > 20){
			resyncMusic();
		}

    }

    function textUpdate(){

        keyTextDisplay.clearFormats();
        if(!noFunMode){ keyTextDisplay.text = "\n"; }
        else{ keyTextDisplay.text = ""; }
        keyTextDisplay.text += "\n\nCACHE SETTINGS\n\n";

        for(i in 0...3){

            var sectionStart = keyTextDisplay.text.length;
            keyTextDisplay.text += names[i] + ": " + (settings[i]?onOff[1]:onOff[0]) + "\n";
            var sectionEnd = keyTextDisplay.text.length - 1;

            if(i == curSelected){
                keyTextDisplay.addFormat(new FlxTextFormat(0xFFFFFF00), sectionStart, sectionEnd);
            }

        }

        keyTextDisplay.text += "\n\n";

    }

    function save(){

        CacheConfig.music = settings[0];
        CacheConfig.characters = settings[1];
        CacheConfig.graphics = settings[2];

        FlxG.save.flush();

        //PlayerSettings.player1.controls.loadKeyBinds();

    }

    function quit(){

        state = "exiting";

        save();

        CacheReload.doMusic = true;
        CacheReload.doGraphics = true;

        if((startingSettings[0] != settings[0] || startingSettings[1] != settings[1] || startingSettings[2] != settings[2]) && !noFunMode){
            if(startingSettings[0] == settings[0]){
                CacheReload.doMusic = false;
            }
            if(startingSettings[1] == settings[1] && startingSettings[2] == settings[2]){
                CacheReload.doGraphics = false;
            }
            returnLoc = new CacheReload();
            ConfigMenu.startSong = false;
        }
        else if(!noFunMode){
            ConfigMenu.startSong = false;
        }

        if(!ConfigMenu.USE_MENU_MUSIC && ConfigMenu.USE_LAYERED_MUSIC && !noFunMode){
            songLayer.fadeOut(0.5, 0, function(x){
                songLayer.stop();
            });
        }

        noFunMode = false;

        switchState(returnLoc);

    }

    function changeItem(_amount:Int = 0){
        curSelected += _amount;
                
        if (curSelected > 2)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 2;

        switch(curSelected){}

        warning.text = warningText[curSelected];
    }

    function resyncMusic():Void {
        songLayer.pause();
        FlxG.sound.music.play();
        songLayer.time = FlxG.sound.music.time;
        songLayer.play();
    }
}