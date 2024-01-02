package config;

import flixel.input.keyboard.FlxKey;
import transition.data.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;


using StringTools;

class KeyBindMenuNew extends MusicBeatState
{

    var state:String = "selecting";

    var controlBox:FlxSprite;
    var selectionBox:FlxSprite;

    var selectedBind:Int = 0;
    var selectedCategory:Int = 0;

    var selectedVisual:Int = 0;
    var selectionTop:Int = 0;

    var tempNames = ["Bind 1", "Bind 2", "Bind 3", "Bind 4", "Bind 5", "Bind 6"];
    var bindText:Array<FlxText> = [];

    var testKeyThing:KeyIcon;

	override function create() {

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF9766BE;
		add(bg);

        var controlText:FlxSprite = new FlxSprite(0, 40);
        controlText.frames = Paths.getSparrowAtlas("fpsPlus/config/controls/title");
        controlText.animation.addByPrefix("boil", "", 24);
        controlText.animation.play("boil");
		controlText.screenCenter(X);
		controlText.antialiasing = true;
		add(controlText);

        controlBox = new FlxSprite(65, 0).makeGraphic(1150, 400, FlxColor.WHITE);
        controlBox.y = (720 - 65) - controlBox.height;
        controlBox.alpha = 0.4;
        add(controlBox);

        selectionBox = new FlxSprite(65, controlBox.y).makeGraphic(1150, 100, FlxColor.WHITE);
        selectionBox.alpha = 0.4;
        add(selectionBox);

        for(i in 0...4){
            var text:FlxText = new FlxText();

            var text = new FlxText(controlBox.x + 10, controlBox.y + (100 * i) + 10, 1150, "", 80);
            text.setFormat(Paths.font("Funkin-Bold", "otf"), text.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.borderSize = 5;
            text.borderQuality = 1;
            add(text);

            bindText.push(text);
        }

		super.create();
	}

	override function update(elapsed:Float) {

		super.update(elapsed);

        if(FlxG.keys.anyJustPressed([ESCAPE])){
            ConfigMenu.startSong = false;
            switchState(new ConfigMenu());
        }

        switch(state){

            case "selecting":
                if(Binds.justPressed("menuUp")){
                    changeBindSelection(-1);
                }
                if(Binds.justPressed("menuDown")){
                    changeBindSelection(1);
                }

        }

        selectionBox.y = controlBox.y + (100 * selectedVisual);

        for(i in 0...4){
            bindText[i].text = tempNames[i + selectionTop];
        }

        if(FlxG.keys.anyJustPressed([ANY])){
            if(testKeyThing != null){
                testKeyThing.destroy();
                remove(testKeyThing);
            }
            testKeyThing = new KeyIcon(controlBox.x + 10, controlBox.y + 10, FlxG.keys.getIsDown()[0].ID);
            add(testKeyThing);
        }
		
	}

    function changeBindSelection(change:Int){
        selectedVisual += change;
        
        if(selectedVisual > 3 || selectedVisual < 0){
            selectionTop += change;
        }

        if(selectionTop < 0){ selectionTop = 0; }
        if(selectionTop > tempNames.length - 4){ selectionTop = tempNames.length - 4; }

        if(selectedVisual < 0){ selectedVisual = 0; }
        if(selectedVisual > 3){ selectedVisual = 3; }
    }

}
