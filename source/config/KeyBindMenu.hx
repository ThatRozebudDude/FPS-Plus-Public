package config;

import config.KeyIcon.ControllerIcon;
import extensions.flixel.FlxUIStateExt;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
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
import extensions.flixel.FlxTextExt;


using StringTools;

class KeyBindMenu extends FlxUIStateExt
{

    var state:String = "selecting";
    var prevState:String = "selecting";

    var bg:FlxSprite;
    var controlBox:FlxSprite;
    var selectionBox:FlxSprite;

    var infoText:FlxTextExt;

    var selected:Int = 0;

    var selectedVisual:Int = 0;
    var selectionTop:Int = 0;

    var bindStrings:Array<String> = [];
    var bindIDs:Array<String> = [];
    var categoryNameIndecies:Array<Int> = [];
    var bindText:Array<FlxTextExt> = [];
    var bindsArray:Array<Array<FlxKey>> = [];
    var controllerBindsArray:Array<Array<FlxGamepadInputID>> = [];
    var bindSprites:FlxSpriteGroup;
    var selectionTimerText:FlxTextExt;
    var selectionTimer:Float = 0;

    var resetTimer:Float = 0;
    var didReset:Bool = false;

    var songLayer:FlxSound;

    var controllerMode:Bool = false;
    var currentController:FlxGamepad;
    var controllerButtonSkin:String = "";
    var prevControllerButtonSkin:String = "";

    //var testKeyThing:KeyIcon;

    override public function new(startInControllerMode:Bool = false) {
        super();
        controllerMode = startInControllerMode;
    }

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

        infoText = new FlxTextExt(5, FlxG.height - 21, 0, generateInfoString(), 16);
		infoText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

        generateCategories();

        if(controllerMode){ updateCurrentController(); }

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

        if(controllerMode){
            updateCurrentController();
        }

        switch(state){

            case "selecting":
                if(FlxG.keys.anyPressed([ANY]) && controllerMode){
                    controllerMode = false;
                    infoText.text = generateInfoString();
                    updateBindList();
                }
                else if(FlxG.gamepads.anyJustPressed(ANY) && !controllerMode){
                    controllerMode = true;
                    updateCurrentController();
                    infoText.text = generateInfoString();
                    updateBindList();
                }

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
                else if((FlxG.keys.anyJustPressed([ESCAPE]) && !controllerMode) || (FlxG.gamepads.anyJustPressed(B) && controllerMode)){
                    exit();
                }
                else if(FlxG.keys.anyJustPressed([BACKSPACE]) && !controllerMode){
                    removeBind();
                    updateBindList();
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFFA784BA, 0xFF9766BE, {ease: FlxEase.quintOut});
                }
                else if(FlxG.gamepads.anyJustPressed(X)  && controllerMode){
                    removeBindController();
                    updateBindList();
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFFA784BA, 0xFF9766BE, {ease: FlxEase.quintOut});
                }

                if(FlxG.keys.anyPressed([DELETE]) || FlxG.gamepads.anyPressed(BACK)){
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

                if(FlxG.keys.anyJustPressed([ANY]) && !controllerMode){
                    addBind(FlxG.keys.getIsDown()[0].ID);
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    state = "selecting";
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFF9850D3, 0xFF9766BE, {ease: FlxEase.quintOut});
                }
                else if(FlxG.gamepads.anyJustPressed(ANY) && controllerMode){
                    var key:FlxGamepadInputID = currentController.firstJustPressedID();
                    if(key.toString() != null){
                        addBindController(key);
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                        state = "selecting";
                        FlxTween.cancelTweensOf(bg);
                        FlxTween.color(bg, 1.75, 0xFF9850D3, 0xFF9766BE, {ease: FlxEase.quintOut});
                    }
                }

                if(selectionTimer <= 0 ){
                    state = "selecting";
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    FlxTween.cancelTweensOf(bg);
                    FlxTween.color(bg, 1.75, 0xFFA784BA, 0xFF9766BE, {ease: FlxEase.quintOut});
                }
        }

        if(!ConfigMenu.USE_MENU_MUSIC && ConfigMenu.USE_LAYERED_MUSIC && Math.abs(FlxG.sound.music.time - songLayer.time) > 20){
			resyncMusic();
		}
		
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
        controllerBindsArray = [];

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
                controllerBindsArray.push([]);
                index++;
            }
            bindStrings.push(b.name);
            bindIDs.push(x);
            bindsArray.push(b.binds);
            controllerBindsArray.push(b.controllerBinds);
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

                //Keyboard icons
                if(!controllerMode){
                    for(x in  bindsArray[index]){
                        var key = new KeyIcon(bindPos, bindText[i].y, x);
                        key.x -= key.iconWidth;
                        bindPos -= key.iconWidth + 10;
                        bindSprites.add(key);
                    }
                }
                //Controller icons
                else{
                    for(x in  controllerBindsArray[index]){
                        var key = new ControllerIcon(bindPos, bindText[i].y, x, controllerButtonSkin);
                        key.x -= key.iconWidth;
                        key.y += (80 - key.iconHeight)/2;
                        bindPos -= key.iconWidth + 10;
                        bindSprites.add(key);
                    } 
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

    function addBindController(key:FlxGamepadInputID) {
        var minCheckIndex:Int = 0;
        var maxCheckIndex:Int = controllerBindsArray.length;

        for(x in categoryNameIndecies){
            if(selected > x) { minCheckIndex = x; }
            if(selected < x) { 
                maxCheckIndex = x;
                break;
            }
        }

        for(i in minCheckIndex...maxCheckIndex){
            if(controllerBindsArray[i].remove(key)){
                modifyBindController(i);
            }
        }

        controllerBindsArray[selected].push(key);
        modifyBindController(selected);

    }

    function removeBind() {
        bindsArray[selected].pop();
        modifyBind(selected);
    }

    function removeBindController() {
        controllerBindsArray[selected].pop();
        modifyBindController(selected);
    }

    function modifyBind(index:Int) {
        var k:Keybind = Binds.binds.get(bindIDs[index]);
        k.binds = bindsArray[index];
        Binds.binds.set(bindIDs[index], k);
        Binds.saveControls();
    }

    function modifyBindController(index:Int) {
        var k:Keybind = Binds.binds.get(bindIDs[index]);
        k.controllerBinds = controllerBindsArray[index];
        Binds.binds.set(bindIDs[index], k);
        Binds.saveControls();
    }

    function updateCurrentController() {
        currentController = FlxG.gamepads.lastActive;
            switch(currentController.model){
                case PS4:
                    controllerButtonSkin = "ps";
                case XINPUT:
                    controllerButtonSkin = "x";
                case SWITCH_PRO:
                    controllerButtonSkin = "nin";
                default:
                    controllerButtonSkin = "";
            }
        if(prevControllerButtonSkin != controllerButtonSkin){
            prevControllerButtonSkin = controllerButtonSkin;
            infoText.text = generateInfoString();
        }
    }

    function generateInfoString():String {
        var removeKey:String = "BACKSPACE";
        var resetKey:String = "DELETE";

        if(controllerMode){
            switch(controllerButtonSkin){
                case "ps":
                    removeKey = "SQUARE";
                    resetKey = "SELECT";
                case "x":
                    removeKey = "X";
                    resetKey = "VIEW";
                case "nin":
                    removeKey = "Y";
                    resetKey = "MINUS";
                default:
                    removeKey = "X";
                    resetKey = "BACK";
            }
        }

        return 'Press $removeKey to remove a bind. Hold $resetKey to reset all binds.';
    }

    function resyncMusic():Void {
        songLayer.pause();
        FlxG.sound.music.play();
        songLayer.time = FlxG.sound.music.time;
        songLayer.play();
    }

}
