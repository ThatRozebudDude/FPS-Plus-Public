package;

import flixel.input.gamepad.lists.FlxGamepadAnalogList;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
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

class KeyBindMenuController extends MusicBeatState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    var defaultKeys:Array<String> = ["X", "A", "Y", "B"];
    var allowedKeys:Array<Int> = [];
    var curSelected:Int = 0;

    var keys:Array<String> = [FlxG.save.data.leftBindController,
                              FlxG.save.data.downBindController,
                              FlxG.save.data.upBindController,
                              FlxG.save.data.rightBindController];

    var tempKey:String = "";
    var blacklist:Array<String> = ["START", "BACK"];

    var state:String = "select";

	override function create()
	{	

        for(i in 0...42){
            allowedKeys[i] = i;
        }

        for(i in 19...30){
            allowedKeys.remove(i);
        }

		//FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuDesat.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF9766BE;
		add(bg);

        keyTextDisplay = new FlxText(0, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("assets/fonts/Funkin-Bold.otf", 72, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 3;
		keyTextDisplay.borderQuality = 1;
        add(keyTextDisplay);

        keyWarning = new FlxText(0, 580, 1280, "WARNING: BIND NOT SET, TRY ANOTHER KEY", 42);
		keyWarning.scrollFactor.set(0, 0);
		keyWarning.setFormat("assets/fonts/vcr.ttf", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        keyWarning.borderSize = 3;
		keyWarning.borderQuality = 1;
        keyWarning.screenCenter(X);
        keyWarning.alpha = 0;
        add(keyWarning);

        var backText = new FlxText(5, FlxG.height - 37, 0, "ESCAPE - Back to Menu\nBACKSPACE - Reset to Defaults\n", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(backText);

        warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0);

        textUpdate();

		super.create();
	}

	override function update(elapsed:Float)
	{

        var controller:FlxGamepad = FlxG.gamepads.lastActive;

        var pressedAny = false;

        for(x in allowedKeys){

            pressedAny = pressedAny || FlxG.gamepads.anyJustPressed(x);

        }

        switch(state){

            case "select":
                if (controls.UP_P)
				{
					FlxG.sound.play('assets/sounds/scrollMenu.ogg');
					changeItem(-1);
				}

				if (controls.DOWN_P)
				{
					FlxG.sound.play('assets/sounds/scrollMenu.ogg');
					changeItem(1);
				}

                if (controls.ACCEPT){
                    FlxG.sound.play('assets/sounds/scrollMenu.ogg');
                    state = "input";
                }
                else if(controls.PAUSE){
                    FlxG.sound.play('assets/sounds/cancelMenu.ogg');
                    quit();
                }
				else if (controls.RESET){
                    FlxG.sound.play('assets/sounds/cancelMenu.ogg');
                    reset();
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                textUpdate();
                state = "waiting";

            case "waiting":
                if(controls.PAUSE){
                    keys[curSelected] = tempKey;
                    state = "select";
                    FlxG.sound.play('assets/sounds/cancelMenu.ogg');
                }
                else if(controls.RESET){
                    addKey(defaultKeys[curSelected]);
                    save();
                    state = "select";
                }
                else if(pressedAny){
                    addKey(controller.firstJustPressedID());
                    save();
                    state = "select";
                }


            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.gamepads.anyJustPressed(ANY))
			textUpdate();

		super.update(elapsed);
		
	}

    function textUpdate(){

        keyTextDisplay.text = "\n\n";

        for(i in 0...4){

            var keyDisplay = keys[i];

            switch(keyDisplay){

                case "A":
                    keyDisplay = "A (CROSS)";
                case "B":
                    keyDisplay = "B (CIRCLE)";
                case "X":
                    keyDisplay = "X (SQUARE)";
                case "Y":
                    keyDisplay = "Y (TRIANGLE)";
                default:
                    keyDisplay = keyDisplay.replace("STICK_DIGITAL", "STICK").replace("_", " ");

            }

            var textStart = (i == curSelected) ? ">" : "  ";
            keyTextDisplay.text += textStart + keyText[i] + ": " + keyDisplay + "\n";

        }

        keyTextDisplay.screenCenter();

    }

    function save(){

        FlxG.save.data.upBindController = keys[2];
        FlxG.save.data.downBindController = keys[1];
        FlxG.save.data.leftBindController = keys[0];
        FlxG.save.data.rightBindController = keys[3];

        FlxG.save.flush();

    }

    function reset(){

        for(i in 0...4){
            keys[i] = defaultKeys[i];
        }
        quit();

    }

    function quit(){

        state = "exiting";

        save();

        ConfigMenu.startSong = false;
        FlxG.switchState(new ConfigMenu());

    }

	function addKey(r:String){

        trace(r);

        if(r == null){

            if(FlxG.gamepads.anyPressed(LEFT_TRIGGER)){
                r = "LEFT_TRIGGER";
            }
            else if(FlxG.gamepads.anyPressed(RIGHT_TRIGGER)){
                r = "RIGHT_TRIGGER";
            }
            else{
                r = "START";
            }
        }

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in keys){
            if(x != tempKey){notAllowed.push(x);}
        }

        for(x in blacklist){notAllowed.push(x);}

        if(curSelected != 4){

            for(x in keyText){
                if(x != keyText[curSelected]){notAllowed.push(x);}
            }
            
        }
        else {for(x in keyText){notAllowed.push(x);}}

        trace(notAllowed);

        for(x in notAllowed){if(x == r){shouldReturn = false;}}

        if(shouldReturn){
            keys[curSelected] = r;
            FlxG.sound.play('assets/sounds/scrollMenu.ogg');
        }
        else{
            keys[curSelected] = tempKey;
            FlxG.sound.play('assets/sounds/cancelMenu.ogg');
            keyWarning.alpha = 1;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }

        if(controls.DOWN_P || controls.UP_P)
            changeItem(0);

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 3)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 3;
    }
}
