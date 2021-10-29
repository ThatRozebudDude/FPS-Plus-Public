package config;

import transition.data.*;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class CacheSettings extends MusicBeatState
{

    public static var noFunMode = false;

    var keyTextDisplay:FlxText;

    public static var returnLoc:FlxState;
    public static var thing:Bool = false;

    var settings:Array<Bool>;
    var names:Array<String> = ["MUSIC", "CHARACTERS", "GRAPHICS"];
    var onOff:Array<String> = ["off", "on"];

    var curSelected:Int = 0;

    var state:String = "select";

	override function create()
	{

        var bgColor:FlxColor = 0xFF9766BE;
        var font:String = Paths.font("Funkin-Bold", "otf");

        if(noFunMode){
            bgColor = 0xFF303030;
            font = "VCR OSD Mono";
            noFunMode = false;
        }

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = bgColor;
		add(bg);

        keyTextDisplay = new FlxText(0, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(font, 72, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 3;
		keyTextDisplay.borderQuality = 1;
        add(keyTextDisplay);

        var backText = new FlxText(5, FlxG.height - 21, 0, "ESCAPE - Back to Menu", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(backText);

        if( FlxG.save.data.musicPreload == null ||
            FlxG.save.data.charPreload == null ||
            FlxG.save.data.graphicsPreload == null)
        {
            FlxG.save.data.musicPreload = true;
            FlxG.save.data.charPreload = true;
            FlxG.save.data.graphicsPreload = true;
        }

        settings = [FlxG.save.data.musicPreload, FlxG.save.data.charPreload, FlxG.save.data.graphicsPreload];

        textUpdate();

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		super.create();
	}

	override function update(elapsed:Float)
	{

        switch(state){

            case "select":
                if (controls.UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}

				if (controls.DOWN_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}

                if (controls.ACCEPT || controls.LEFT_P || controls.RIGHT_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    settings[curSelected] = !settings[curSelected];
                }
                else if(controls.BACK){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    quit();
                }

            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY)
            textUpdate();

    }

    function textUpdate(){

        keyTextDisplay.clearFormats();
        keyTextDisplay.text = "\n\nPRELOAD SETTINGS\n\n";

        for(i in 0...3){

            var sectionStart = keyTextDisplay.text.length;
            keyTextDisplay.text += names[i] + ": " + (settings[i]?onOff[1]:onOff[0]) + "\n";
            var sectionEnd = keyTextDisplay.text.length - 1;

            if(i == curSelected){
                keyTextDisplay.addFormat(new FlxTextFormat(0xFFFFFF00), sectionStart, sectionEnd);
            }

        }

        keyTextDisplay.screenCenter();

    }

    function save(){

        FlxG.save.data.musicPreload = settings[0];
        FlxG.save.data.charPreload = settings[1];
        FlxG.save.data.graphicsPreload = settings[2];

        FlxG.save.flush();

        //PlayerSettings.player1.controls.loadKeyBinds();

    }

    function quit(){

        state = "exiting";

        save();

        ConfigMenu.startSong = false;
        switchState(returnLoc);

    }

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 2)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 2;
    }
}