package;

import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
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
import flixel.input.FlxKeyManager;

using StringTools;

class KeyBindQuick extends MusicBeatState
{

    var keyTextDisplay:FlxText;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT", "RESET"];
    var keyStep:Int = 0;
    var keyOut:Array<String> = [];

    var quitting:Bool = false;

	override function create()
	{	
	
		//FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

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

        keyTextDisplay = new FlxText(0, 0, 1280, "", 128);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("assets/fonts/Funkin-Bold.otf", 128, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 3;
		keyTextDisplay.borderQuality = 1;
        keyTextDisplay.screenCenter();
        add(keyTextDisplay);

		super.create();
	}

	override function update(elapsed:Float)
	{

        keyTextDisplay.text = keyText[keyStep];

        if(FlxG.keys.justPressed.ESCAPE && !quitting){

            quit();
            
        }

        if(FlxG.keys.justPressed.ANY && !quitting){

            addKey();
            
        }
        
        if(keyOut.length >= 5){

            exit();

        }

		super.update(elapsed);
		
	}

    function exit(){

        quitting = true;

        FlxG.save.data.upBind = keyOut[2];
        FlxG.save.data.downBind = keyOut[1];
        FlxG.save.data.leftBind = keyOut[0];
        FlxG.save.data.rightBind = keyOut[3];
        FlxG.save.data.killBind = keyOut[4];
        
        PlayerSettings.player1.controls.loadKeyBinds();

        ConfigMenu.startSong = false;
        FlxG.switchState(new ConfigMenu());

    }

    function quit(){

        quitting = true;

        ConfigMenu.startSong = false;
        FlxG.switchState(new ConfigMenu());

    }

	function addKey(){

        var r = FlxG.keys.getIsDown()[0].ID.toString();
        var shouldReturn:Bool = true;

        for(x in keyOut){if(x == r){shouldReturn = false;}}

        if(shouldReturn){
            keyOut.push(r);
            keyStep++;
        }
        

	}
}
