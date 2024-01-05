package config;

import Binds.Keybind;
import flixel.sound.FlxSound;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import transition.data.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;


using StringTools;

class KeyBindMenu extends MusicBeatState
{

    var state:String = "selecting";
    var prevState:String = "selecting";

    var bg:FlxSprite;
    var controlBox:FlxSprite;
    var selectionBox:FlxSprite;

    var selected:Int = 0;

    var selectedVisual:Int = 0;
    var selectionTop:Int = 0;

    var bindStrings:Array<String> = [];
    var bindIDs:Array<String> = [];
    var categoryNameIndecies:Array<Int> = [];
    var bindText:Array<FlxTextExt> = [];
    var bindsArray:Array<Array<FlxKey>> = [];
    var bindSprites:FlxSpriteGroup;
    var selectionTimerText:FlxTextExt;
    var selectionTimer:Float = 0;

    var resetTimer:Float = 0;
    var didReset:Bool = false;

    var songLayer:FlxSound;

    //var testKeyThing:KeyIcon;

	override function create() {

        customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

        if(!ConfigMenu.USE_MENU_MUSIC && ConfigMenu.USE_LAYERED_MUSIC){
            songLayer = FlxG.sound.play(Paths.music(ConfigMenu.keySongTrack), 0, true);
            songLayer.time = FlxG.sound.music.time;
            songLayer.fadeIn(0.6);
        }

        bg = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuDesat'));
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
            var text:FlxTextExt = new FlxTextExt();

            var text = new FlxTextExt(controlBox.x + 10, controlBox.y + (100 * i) + 10, 1130, "", 80);
            text.setFormat(Paths.font("Funkin-Bold", "otf"), text.textField.defaultTextFormat.size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.borderSize = 5;
            text.borderQuality = 1;
            add(text);

            bindText.push(text);
        }

        selectionTimerText = new FlxTextExt(controlBox.x + 10, controlBox.y + 10, 1130, "", 80);
        selectionTimerText.setFormat(Paths.font("Funkin-Bold", "otf"), selectionTimerText.textField.defaultTextFormat.size, FlxColor.BLACK, FlxTextAlign.RIGHT);
        selectionTimerText.visible = false;
        add(selectionTimerText);

        bindSprites = new FlxSpriteGroup();
        add(bindSprites);

        var infoText = new FlxTextExt(5, FlxG.height - 21, 0, "Press BACKSPACE to remove a bind. Hold DELETE to reset all binds.", 16);
		infoText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

        generateCategories();
        updateBindList();

        changeBindSelection(0);

		super.create();
	}

	override function update(elapsed:Float) {

		super.update(elapsed);

        if(prevState != state){
            prevState = state;
            switch(state){
                case "selecting":
                    updateBindList();
                    selectionTimerText.visible = false;
                case "enteringKey":
                    updateBindList(selectedVisual);
                    selectionTimer = 3;
                    selectionTimerText.visible = true;
            }
        }

        switch(state){

            case "selecting":
                if(Binds.justPressed("menuUp")){
                    changeBindSelection(-1);
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                }
                else if(Binds.justPressed("menuDown")){
                    changeBindSelection(1);
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                }
                else if(Binds.justPressed("menuAccept")){
                    state = "enteringKey";
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                }
                else if(FlxG.keys.anyJustPressed([ESCAPE])){
                    exit();
                }
                else if(FlxG.keys.anyJustPressed([BACKSPACE])){
                    removeBind();
                    updateBindList();
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFFA784BA, 0xFF9766BE, {ease: FlxEase.quintOut});
                }

                if(FlxG.keys.anyPressed([DELETE])){
                    resetTimer += elapsed;
                }
                else{
                    resetTimer = 0;
                    didReset = false;
                }

                if(resetTimer >= 1.5 && !didReset){
                    Binds.resetToDefaultControls();
                    generateCategories();
                    updateBindList();
                    didReset = true;
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFFA784BA, 0xFF9766BE, {ease: FlxEase.quintOut});
                }

            case "enteringKey":
                selectionTimerText.text = ""+Math.ceil(selectionTimer);
                selectionTimer -= elapsed;

                if(FlxG.keys.anyJustPressed([ANY])){
                    addBind(FlxG.keys.getIsDown()[0].ID);
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    state = "selecting";
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFF9850D3, 0xFF9766BE, {ease: FlxEase.quintOut});

                }

                if(selectionTimer <= 0 ){
                    state = "selecting";
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFFA784BA, 0xFF9766BE, {ease: FlxEase.quintOut});
                }
        }

        /*if(FlxG.keys.anyJustPressed([ANY])){
            if(testKeyThing != null){
                testKeyThing.destroy();
                remove(testKeyThing);
            }
            testKeyThing = new KeyIcon(controlBox.x + 10, controlBox.y + 10, FlxG.keys.getIsDown()[0].ID);
            add(testKeyThing);
        }*/
		
	}

    function changeBindSelection(change:Int, updateList:Bool = true){

        selected += change;
        if(selected < 0){ selected = 0; }
        if(selected > bindStrings.length - 1){ selected = bindStrings.length - 1; }

        selectedVisual += change;
        
        if(selectedVisual > 3 || selectedVisual < 0){
            selectionTop += change;
        }

        if(selectionTop < 0){ selectionTop = 0; }
        if(selectionTop > bindStrings.length - 4){ selectionTop = bindStrings.length - 4; }

        if(selectedVisual < 0){ selectedVisual = 0; }
        if(selectedVisual > 3){ selectedVisual = 3; }

        if(categoryNameIndecies.contains(selected)){
            changeBindSelection(change < 0 ? (selected > 1 ? -1 : 1) : (selected < bindStrings.length - 1 ? 1 : -1), false);
        }

        if(updateList) { updateBindList(); }

    }

    function generateCategories(){

        bindStrings = [];
        bindIDs = [];
        categoryNameIndecies = [];
        bindsArray = [];

        var categories = [];
        var index:Int = 0;

        for(x in Binds.binds.keys){
            var b = Binds.binds.get(x);
            if(!categories.contains(b.category)){
                categories.push(b.category);
                bindStrings.push(b.category);
                bindIDs.push("");
                categoryNameIndecies.push(index);
                bindsArray.push([]);
                index++;
            }
            bindStrings.push(b.name);
            bindIDs.push(x);
            bindsArray.push(b.binds);
            index++;
        }

    }

    function updateBindList(?setOptionToSelecting:Int = -1){
        selectionBox.y = controlBox.y + (100 * selectedVisual);

        bindSprites.forEachAlive(function(x){
            bindSprites.remove(x);
            x.destroy();
        });

        for(i in 0...4){
            if(i != setOptionToSelecting){
                var index = i + selectionTop;
                bindText[i].text = bindStrings[index].toUpperCase();
                bindText[i].text += "\n\n";
                if(categoryNameIndecies.contains(index)){
                    bindText[i].alignment = FlxTextAlign.CENTER;
                    bindText[i].color = FlxColor.YELLOW;
                }
                else{
                    bindText[i].alignment = FlxTextAlign.LEFT;
                    bindText[i].color = FlxColor.WHITE;
                }
    
                var bindPos = controlBox.x + controlBox.width - 10;
                for(x in  bindsArray[index]){
                    var key = new KeyIcon(bindPos, bindText[i].y, x);
                    key.x -= key.iconWidth;
                    bindPos -= key.iconWidth + 10;
                    bindSprites.add(key);
                }
            }
            else{
                bindText[i].text = "PRESS ANY KEY\n\n";
                bindText[i].alignment = FlxTextAlign.LEFT;
                bindText[i].color = FlxColor.WHITE;
                selectionTimerText.y = controlBox.y + (100 * i) + 10;
            }
        }

    }

    function exit() {
        if(!ConfigMenu.USE_MENU_MUSIC && ConfigMenu.USE_LAYERED_MUSIC){
            songLayer.fadeOut(0.5, 0, function(x){
                songLayer.stop();
            });
        }
        ConfigMenu.startSong = false;
        switchState(new ConfigMenu());
        FlxG.sound.play(Paths.sound('cancelMenu'));
    }

    function addBind(key:FlxKey) {
        var minCheckIndex:Int = 0;
        var maxCheckIndex:Int = bindsArray.length;

        for(x in categoryNameIndecies){
            if(selected > x) { minCheckIndex = x; }
            if(selected < x) { 
                maxCheckIndex = x;
                break;
            }
        }

        for(i in minCheckIndex...maxCheckIndex){
            if(bindsArray[i].remove(key)){
                modifyBind(i);
            }
        }

        bindsArray[selected].push(key);
        modifyBind(selected);

    }

    function removeBind() {
        bindsArray[selected].pop();
        modifyBind(selected);
    }

    function modifyBind(index:Int) {
        var k:Keybind = Binds.binds.get(bindIDs[index]);
        k.binds = bindsArray[index];
        Binds.binds.set(bindIDs[index], k);
        Binds.saveControls();
    }

}
