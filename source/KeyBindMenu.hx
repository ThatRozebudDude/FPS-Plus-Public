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

class KeyBindMenu extends MusicBeatState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    var defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
    var curSelected:Int = 0;

    var keys:Array<String> = [FlxG.save.data.leftBind,
                              FlxG.save.data.downBind,
                              FlxG.save.data.upBind,
                              FlxG.save.data.rightBind,
                              FlxG.save.data.killBind];

    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE"];

    var state:String = "select";

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

                if (FlxG.keys.justPressed.ENTER){
                    FlxG.sound.play('assets/sounds/scrollMenu.ogg');
                    state = "input";
                }
                else if(FlxG.keys.justPressed.ESCAPE || FlxG.gamepads.anyJustPressed(ANY)){
                    FlxG.sound.play('assets/sounds/cancelMenu.ogg');
                    quit();
                }
				else if (FlxG.keys.justPressed.BACKSPACE){
                    FlxG.sound.play('assets/sounds/cancelMenu.ogg');
                    reset();
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                textUpdate();
                state = "waiting";

            case "waiting":
                if(FlxG.keys.justPressed.ESCAPE){
                    keys[curSelected] = tempKey;
                    state = "select";
                    FlxG.sound.play('assets/sounds/cancelMenu.ogg');
                }
                else if(FlxG.keys.justPressed.ENTER){
                    addKey(defaultKeys[curSelected]);
                    save();
                    state = "select";
                }
                else if(FlxG.keys.justPressed.ANY){
                    addKey(FlxG.keys.getIsDown()[0].ID.toString());
                    save();
                    state = "select";
                }


            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

    function textUpdate(){

        keyTextDisplay.text = "\n\n";

        for(i in 0...4){

            var textStart = (i == curSelected) ? ">" : "  ";
            keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " + ") : "" ) + keyText[i] + " ARROW\n";

        }

        var textStart = (curSelected == 4) ? ">" : "  ";

        keyTextDisplay.text += textStart + "RESET: " + keys[4]  + "\n";

        keyTextDisplay.screenCenter();

    }

    function save(){

        FlxG.save.data.upBind = keys[2];
        FlxG.save.data.downBind = keys[1];
        FlxG.save.data.leftBind = keys[0];
        FlxG.save.data.rightBind = keys[3];
        FlxG.save.data.killBind = keys[4];

        FlxG.save.flush();

        PlayerSettings.player1.controls.loadKeyBinds();

    }

    function reset(){

        for(i in 0...5){
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

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 4)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 4;
    }
}
