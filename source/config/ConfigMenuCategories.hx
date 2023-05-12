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

class ConfigMenuCategories extends UIStateExt
{

    public static var exitTo:Class<Dynamic>;

    var curSelected:Int = 0;
    var curSelectedSub:Int = 0;

    var state:String = "topLevelMenu";

    var icons:Array<FlxSprite> = [];
    var titles:Array<FlxSprite> = [];

    var optionTitle:FlxSprite;
    var splatter:FlxSprite;

    var topLevelMenuGroup:FlxSpriteGroup = new FlxSpriteGroup();
    var subMenuGroup:FlxSpriteGroup = new FlxSpriteGroup();

    final options:Array<String> = ["video", "input", "misc"];
    final optionPostions:Array<Float> = [1/5, 1/2, 4/5];
    final menuTweenTime:Float = 1;

    var configText:FlxText;
    var descText:FlxText;

    var configOptions:Array<Array<ConfigOption>> = [];

    static var offsetValue:Float;
	static var accuracyType:String;
	static var accuracyTypeInt:Int;
	var accuracyTypes:Array<String> = ["none", "simple", "complex"];
	static var healthValue:Int;
	static var healthDrainValue:Int;
	static var comboValue:Int;
	var comboTypes:Array<String> = ["world", "hud", "off"];
	static var downValue:Bool;
	static var glowValue:Bool;
	static var randomTapValue:Int;
	var randomTapTypes:Array<String> = ["never", "not singing", "always"];
	static var noCapValue:Bool;
	static var scheme:Int;
	static var dimValue:Int;
	static var noteSplashValue:Int;
	var noteSplashTypes:Array<String> = ["off", "sick only", "always"];

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
		
		optionTitle = new FlxSprite(0, 40);
		optionTitle.frames = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');
		optionTitle.animation.addByPrefix('selected', "options white", 24);
		optionTitle.animation.play('selected');
		optionTitle.scrollFactor.set();
		optionTitle.antialiasing = true;
		optionTitle.updateHitbox();
		optionTitle.screenCenter(X);
        

        add(bg);
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
        changeSelected(0);

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		super.create();

	}

	override function update(elapsed:Float){

		super.update(elapsed);

        switch(state){

            case "topLevelMenu":
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

                if (controls.ACCEPT){
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    bringTextToTop(curSelected);
                    curSelectedSub = 0;
                    state = "subMenu";
                }

            case "subMenu":
                if (controls.BACK){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    backToCategories();
                    state = "topLevelMenu";
                }

                if (controls.UP_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeSubSelected(-1);
                }
                else if(controls.DOWN_P){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeSubSelected(1);
                }

                textUpdate();

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
        FlxTween.cancelTweensOf(titles[x]);
        FlxTween.cancelTweensOf(topLevelMenuGroup);
        FlxTween.cancelTweensOf(subMenuGroup);
        FlxTween.tween(titles[x], {x: optionTitle.getGraphicMidpoint().x - titles[x].width/2, y: optionTitle.getGraphicMidpoint().y - titles[x].height/2, alpha: 1}, menuTweenTime, {ease: FlxEase.quintOut});
        FlxTween.tween(topLevelMenuGroup, {alpha: 0}, menuTweenTime/2, {ease: FlxEase.quintOut});
        FlxTween.tween(subMenuGroup, {alpha: 1}, menuTweenTime/2, {ease: FlxEase.quintOut});
        for(i in 0...titles.length){
            if(i != x){
                FlxTween.cancelTweensOf(titles[i]);
                FlxTween.tween(titles[i], {x: icons[i].getGraphicMidpoint().x - titles[i].frameWidth/2, y: 3/4 * 720, alpha: 0}, menuTweenTime/2, {ease: FlxEase.quintOut});
            }
        }
    }

    function backToCategories(){
        FlxTween.cancelTweensOf(topLevelMenuGroup);
        FlxTween.cancelTweensOf(subMenuGroup);
        for(i in 0...titles.length){
            FlxTween.cancelTweensOf(titles[i]);
            FlxTween.tween(titles[i], {x: icons[i].getGraphicMidpoint().x - titles[i].frameWidth/2, y: 3/4 * 720, alpha: 1}, menuTweenTime, {ease: FlxEase.quintOut});
        }   
        FlxTween.tween(topLevelMenuGroup, {alpha: 1}, menuTweenTime/2, {ease: FlxEase.quintOut});
        FlxTween.tween(subMenuGroup, {alpha: 0}, menuTweenTime/2, {ease: FlxEase.quintOut});
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

        //VIDEO

        var vidOption1 = new ConfigOption("videoTest", ": value", "testDesc", 
        function(){

        },
        function(){
            
        });

        var vidOption2 = new ConfigOption("videoTest2", ": value", "testDesc", 
        function(){

        },
        function(){
            
        });

        //INPUT

        var inputOption1 = new ConfigOption("inputTest", ": value", "testDesc", 
        function(){

        },
        function(){

        });

        var inputOption2 = new ConfigOption("inputTest2", ": value", "testDesc", 
        function(){

        },
        function(){

        });

        //MISC

        var miscOption1 = new ConfigOption("miscTest", ": value", "testDesc", 
        function(){

        },
        function(){
            
        });

        var miscOption2 = new ConfigOption("miscTest2", ": value", "testDesc", 
        function(){

        },
        function(){
            
        });

        configOptions = [
                            [vidOption1, vidOption2],
                            [inputOption1, inputOption2],
                            [miscOption1, miscOption2]
                        ];

    }

    function writeToConfig(){
		Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, comboValue, downValue, glowValue, randomTapValue, noCapValue, scheme, dimValue, noteSplashValue);
	}

}

class ConfigOption
{

    public var name:String;
    public var setting:String;
    public var description:String;
    public var optionUpdate:Void->Void;

    public function new(_name:String, _setting:String, _description:String, initFunction:Void->Void, _optionUpdate:Void->Void){
        name = _name;
        setting = _setting;
        description = _description;
        optionUpdate = _optionUpdate;
        initFunction();
    }

}