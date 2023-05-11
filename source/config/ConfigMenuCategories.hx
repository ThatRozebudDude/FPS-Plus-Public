package config;

import transition.data.*;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;


using StringTools;

class ConfigMenuCategories extends UIStateExt
{

    public static var exitTo:Class<Dynamic>;

    var curSelected:Int = 0;

    var icons:Array<FlxSprite> = [];
    var titles:Array<FlxSprite> = [];

    var splatter:FlxSprite;

    final options:Array<String> = ["video", "input", "misc"];
    final optionPostions:Array<Float> = [1/5, 1/2, 4/5];

	override function create(){

        openfl.Lib.current.stage.frameRate = 144;

        if(exitTo == null){
			exitTo = MainMenuState;
		}

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF5C6CA5;
		
		var optionTitle:FlxSprite = new FlxSprite(0, 55);
		optionTitle.frames = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');
		optionTitle.animation.addByPrefix('selected', "options white", 24);
		optionTitle.animation.play('selected');
		optionTitle.scrollFactor.set();
		optionTitle.antialiasing = true;
		optionTitle.updateHitbox();
		optionTitle.screenCenter(X);

        add(bg);
        add(optionTitle);

        splatter = new FlxSprite();
        splatter.frames = Paths.getSparrowAtlas("fpsPlus/config/splatter");
        splatter.animation.addByPrefix("boil", "", 24);
        splatter.animation.play("boil");
        splatter.antialiasing = true;
        add(splatter);

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
            add(icon);

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

        changeSelected(0);

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		super.create();

	}

	override function update(elapsed:Float){

		super.update(elapsed);

        if (controls.BACK){
			exit();
		}

        if (controls.LEFT_P){
            FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelected(-1);
		}
        else if(controls.RIGHT_P){
            FlxG.sound.play(Paths.sound('scrollMenu'));
            changeSelected(1);
        }

	}

    function exit(){
        FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('cancelMenu'));
		switchState(Type.createInstance(exitTo, []));
        exitTo = null;
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

}
