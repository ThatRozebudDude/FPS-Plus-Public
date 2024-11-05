package modding;

import config.CacheReload;
import config.CacheConfig;
import config.Config;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import extensions.flixel.FlxTextExt;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import extensions.flixel.FlxUIStateExt;

class ModManagerState extends FlxUIStateExt
{

    var curSelectedMod:Int = 0;
    //var curListPosition:Int = 0;
    var curSelectedButton:Int = 0;

    var selectionBg:FlxSprite;

    var hasMods:Bool = true;

    var modList:Array<ModInfo> = [];
    var shownModList:Array<ModInfo> = [];
    var listStartIndex:Int = 0;

    var modNames:Array<FlxTextExt> = [];
    var modIcons:Array<FlxSprite> = [];

    var bigInfoIcon:FlxSprite;
    var bigInfoName:FlxTextExt;
    var bigInfoDescription:FlxTextExt;
    var bigInfoVersion:FlxTextExt;

    var enableDisableButton:ModManagerButton;
    var moveUpButton:ModManagerButton;
    var moveDownButton:ModManagerButton;
    var reloadButton:ModManagerButton;
    var openFolderButton:ModManagerButton;
    var menuButtons:Array<ModManagerButton> = [];

    var oldDisabled:Array<String>;
    var oldOrder:Array<String>;
    var oldLoadedModList:Array<String>;

    final bgSpriteColor:FlxColor = 0xFFB26DAF;
    final selectorColor:FlxColor = 0xFFFF9DE1;

    final listStart:FlxPoint = new FlxPoint(60, 60);
    final infoStart:FlxPoint = new FlxPoint(520, 60);
    final bottomStart:FlxPoint = new FlxPoint(520, 570);

    override function create() {

        Config.setFramerate(144);

        oldDisabled = PolymodHandler.disabledModDirs;
        oldOrder = PolymodHandler.allModDirs;
        oldLoadedModList = PolymodHandler.loadedModDirs;

        var bg = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
        bg.scale.set(1.18, 1.18);
        bg.updateHitbox();
		bg.screenCenter();
        bg.color = bgSpriteColor;

        var uiBg = new FlxSprite().loadGraphic(Paths.image("menu/modMenu/ui"));
        
        selectionBg = new FlxSprite(listStart.x + 4, listStart.y + 4).loadGraphic(Paths.image("menu/modMenu/selector"));
        selectionBg.color = selectorColor;
        selectionBg.antialiasing = true;

        /*var iconTest = new FlxSprite(listStart.x + 10, listStart.y + 10).loadGraphic(Paths.image("menu/modMenu/defaultModIcon"));
        iconTest.antialiasing = true;

        var textTest = new FlxTextExt(listStart.x + 100, listStart.y + 50, 290, "Test Mod Name", 36);
        textTest.setFormat(Paths.font("Funkin-Bold", "otf"), 36, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        textTest.y -= textTest.height/2;
        textTest.borderSize = 2;*/

        bigInfoIcon = new FlxSprite(infoStart.x + 10, infoStart.y + 10).loadGraphic(Paths.image("menu/modMenu/defaultModIcon"));
        bigInfoIcon.antialiasing = true;

        bigInfoName = new FlxTextExt(infoStart.x + 100, infoStart.y + 50, 590, "Test Mod Name", 48);
        bigInfoName.setFormat(Paths.font("Funkin-Bold", "otf"), 48, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        bigInfoName.y -= bigInfoName.height/2;
        bigInfoName.borderSize = 3;

        bigInfoDescription = new FlxTextExt(infoStart.x + 10, infoStart.y + 110, 680, "This is where the mod description will go. I need this text to be long to make sure it wraps properly and doesn't go outside of the text box. Hurray! Fabs is on base. Game!", 36);
        bigInfoDescription.setFormat(Paths.font("Funkin-Bold", "otf"), 36, 0xFFFFFFFF, FlxTextAlign.LEFT);

        bigInfoVersion = new FlxTextExt(infoStart.x + 695, infoStart.y + 445, 0, "API Version: 1.0.0\nMod Version: 1.0.0", 20);
        bigInfoVersion.setFormat(Paths.font("Funkin-Bold", "otf"), 20, 0xFFFFFFFF, FlxTextAlign.RIGHT);
        bigInfoVersion.color = 0xFF999999;
        bigInfoVersion.y -= bigInfoVersion.height;
        bigInfoVersion.x -= bigInfoVersion.width;

        var enableDisableButtonTween:flixel.tweens.misc.ColorTween;
        enableDisableButton = new ModManagerButton(bottomStart.x + 60, bottomStart.y + 5);
        enableDisableButton.loadGraphic(Paths.image("menu/modMenu/enableDisableButton"), true, 240, 80);
        enableDisableButton.antialiasing = true;
        enableDisableButton.animation.add("selected", [2], 0, false);
        enableDisableButton.animation.add("deselected", [0], 0, false);
        enableDisableButton.animation.add("selected-disabled", [3], 0, false);
        enableDisableButton.animation.add("deselected-disabled", [1], 0, false);
        enableDisableButton.pressFunction = function(){
            if(hasMods && !modList[curSelectedMod].malformed){
                modList[curSelectedMod].enabled = !modList[curSelectedMod].enabled;
                FlxG.sound.play(Paths.sound("scrollMenu"));
                updateMenuButtons();
                buildShownModList();
            }
            else{
                FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
                if(enableDisableButtonTween != null) { enableDisableButtonTween.cancel(); }
                enableDisableButtonTween = FlxTween.color(enableDisableButton, 0.8, 0xFFE25F5D, 0xFFFFFFFF, {ease: FlxEase.quartOut});
            }
        }

        var moveUpButtonTween:flixel.tweens.misc.ColorTween;
        moveUpButton = new ModManagerButton(bottomStart.x + 60 + 245, bottomStart.y + 5);
        moveUpButton.loadGraphic(Paths.image("menu/modMenu/moveUpButton"), true, 80, 80);
        moveUpButton.antialiasing = true;
        moveUpButton.animation.add("selected", [1], 0, false);
        moveUpButton.animation.add("deselected", [0], 0, false);
        moveUpButton.pressFunction = function(){
            if(hasMods && curSelectedMod > 0){
                var temp = modList[curSelectedMod-1];
                modList[curSelectedMod-1] = modList[curSelectedMod];
                modList[curSelectedMod] = temp;
                buildShownModList();
                changeModSelection(-1, false);
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
            else{
                FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
                if(moveUpButtonTween != null) { moveUpButtonTween.cancel(); }
                moveUpButtonTween = FlxTween.color(moveUpButton, 0.8, 0xFFE25F5D, 0xFFFFFFFF, {ease: FlxEase.quartOut});
            }
        }

        var moveDownButtonTween:flixel.tweens.misc.ColorTween;
        moveDownButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85, bottomStart.y + 5);
        moveDownButton.loadGraphic(Paths.image("menu/modMenu/moveDownButton"), true, 80, 80);
        moveDownButton.antialiasing = true;
        moveDownButton.animation.add("selected", [1], 0, false);
        moveDownButton.animation.add("deselected", [0], 0, false);
        moveDownButton.pressFunction = function(){
            if(hasMods && curSelectedMod < modList.length-1){
                var temp = modList[curSelectedMod+1];
                modList[curSelectedMod+1] = modList[curSelectedMod];
                modList[curSelectedMod] = temp;
                buildShownModList();
                changeModSelection(1, false);
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
            else{
                FlxG.sound.play(Paths.sound("characterSelect/deny"), 0.5);
                if(moveDownButtonTween != null) { moveDownButtonTween.cancel(); }
                moveDownButtonTween = FlxTween.color(moveDownButton, 0.8, 0xFFE25F5D, 0xFFFFFFFF, {ease: FlxEase.quartOut});
            }
        }

        reloadButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85 + 85, bottomStart.y + 5);
        reloadButton.loadGraphic(Paths.image("menu/modMenu/reloadButton"), true, 80, 80);
        reloadButton.antialiasing = true;
        reloadButton.animation.add("selected", [1], 0, false);
        reloadButton.animation.add("deselected", [0], 0, false);
        reloadButton.pressFunction = function(){
            if(curSelectedMod == modList.length-1 && modList.length > 6){ listStartIndex--; }
            save();
            PolymodHandler.buildModDirectories();
            buildFullModList();
            if(modList.length <= 6 ){ listStartIndex = 0; }
            changeModSelection(0, false);
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        openFolderButton = new ModManagerButton(bottomStart.x + 60 + 245 + 85 + 85 + 85, bottomStart.y + 5);
        openFolderButton.loadGraphic(Paths.image("menu/modMenu/folderButton"), true, 80, 80);
        openFolderButton.antialiasing = true;
        openFolderButton.animation.add("selected", [1], 0, false);
        openFolderButton.animation.add("deselected", [0], 0, false);
        openFolderButton.pressFunction = function(){
            FlxG.sound.play(Paths.sound("scrollMenu"));
            //Currently this is Windows only, if anyone wants to add opening mod folder support for other OSes be my guest.
            Sys.command("explorer.exe /n, /e, \"" + Sys.getCwd().substring(0, Sys.getCwd().length-1) + "\\mods\"");
        };

        menuButtons = [enableDisableButton, moveUpButton, moveDownButton, reloadButton, openFolderButton];

        buildFullModList();

        add(bg);
        add(uiBg);
        add(selectionBg);

        add(bigInfoIcon);
        add(bigInfoName);
        add(bigInfoDescription);
        add(bigInfoVersion);

        for(button in menuButtons){
            add(button);
        }

        buildShownModList();

        changeModSelection(0, false);
        changeButtonSelection(0);

        super.create();
    }

    var canDoThings:Bool = true;

    override function update(elapsed:Float) {

        if(canDoThings){
            if(Binds.justPressed("menuUp") && hasMods){
                changeModSelection(-1);
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
            else if(Binds.justPressed("menuDown") && hasMods){
                changeModSelection(1);
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
    
            if(Binds.justPressed("menuLeft")){
                changeButtonSelection(-1);
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
            else if(Binds.justPressed("menuRight")){
                changeButtonSelection(1);
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
            if(Binds.justPressed("menuAccept")){
                menuButtons[curSelectedButton].press();
            }
    
            if(Binds.justPressed("menuBack")){
                FlxG.sound.play(Paths.sound("cancelMenu"));
                canDoThings = false;
                save();
                FlxG.signals.preStateSwitch.addOnce(function() { 
                    PolymodHandler.reInit();
                });
                if(CacheConfig.music || CacheConfig.characters || CacheConfig.graphics){
                    switchState(new CacheReload(new MainMenuState()));
                }
                else{
                    switchState(new MainMenuState());
                }
            }
        }

        super.update(elapsed);
    }

    function changeModSelection(change:Int, ?doTween:Bool = true) {
        if(!hasMods){ return; }

        curSelectedMod += change;

        if(curSelectedMod < 0){ curSelectedMod = 0; }
        if(curSelectedMod >= modList.length){ curSelectedMod = modList.length-1; }

        var curListPosition = curSelectedMod - listStartIndex;
        while(curListPosition >= 6){
            curListPosition--;
            listStartIndex++;
        }
        while(curListPosition < 0){
            curListPosition++;
            listStartIndex--;
        }

        FlxTween.cancelTweensOf(selectionBg);
        if(doTween){ FlxTween.tween(selectionBg, {y: listStart.y + 4 + (100 * curListPosition)}, 0.4, {ease: FlxEase.expoOut}); }
        else{ selectionBg.y = listStart.y + 4 + (100 * curListPosition); }

        updateBigInfo();
        updateMenuButtons();
        buildShownModList();
    }

    function changeButtonSelection(change:Int) {
        curSelectedButton += change;
        
        if(curSelectedButton < 0){ curSelectedButton = 0; }
        if(curSelectedButton >= menuButtons.length){ curSelectedButton = menuButtons.length-1; }

        updateMenuButtons();
    }

    function updateBigInfo():Void{
        bigInfoName.text = modList[curSelectedMod].name;
        bigInfoName.setPosition(infoStart.x + 100, infoStart.y + 50);
        bigInfoName.y -= bigInfoName.height/2;
        bigInfoName.text += "\n\n";

        bigInfoIcon.loadGraphic(modList[curSelectedMod].icon);
        bigInfoIcon.antialiasing = true;
        bigInfoIcon.setGraphicSize(80, 80);
        bigInfoIcon.updateHitbox();

        bigInfoDescription.text = modList[curSelectedMod].description + "\n\n";

        bigInfoVersion.text = "API Version: " + modList[curSelectedMod].apiVersion + "\nMod Version: " + modList[curSelectedMod].modVersion;
        bigInfoVersion.setPosition(infoStart.x + 695, infoStart.y + 445);
        bigInfoVersion.y -= bigInfoVersion.height;
        bigInfoVersion.x -= bigInfoVersion.width;
        bigInfoVersion.text += "\n\n";
    }

    function showbigInfoNoMods():Void{
        bigInfoName.text = "No Mods Installed";
        bigInfoName.setPosition(infoStart.x + 100, infoStart.y + 50);
        bigInfoName.y -= bigInfoName.height/2;
        bigInfoName.text += "\n\n";

        bigInfoIcon.loadGraphic(Paths.image("menu/modMenu/noModIcon"));
        bigInfoIcon.antialiasing = true;
        bigInfoIcon.setGraphicSize(80, 80);
        bigInfoIcon.updateHitbox();

        bigInfoDescription.text = "There are currently no mods installed in the mods folder. To install a mod download an FPS Plus compatable mod and drag it into the mods folder in your FPS Plus install then hit the refresh button in the mod manager or re-launch the game.\n\n";

        bigInfoVersion.text = "";
    }

    function updateMenuButtons() {
        if(!hasMods || !modList[curSelectedMod].enabled || modList[curSelectedMod].malformed){
            enableDisableButton.animSet = "disabled";
            enableDisableButton.toggleState = true;
        }
        else{
            enableDisableButton.animSet = "";
            enableDisableButton.toggleState = false;
        }

        for(i in 0...menuButtons.length){
            if(i == curSelectedButton){
                menuButtons[i].select();
            }
            else{
                menuButtons[i].deselect();
            }
        }
    }

    function getModIcon(mod:String):BitmapData{
        if(FileSystem.exists("mods/" + mod + "/icon.png")){
            return BitmapData.fromFile("mods/" + mod + "/icon.png");
        }
        return BitmapData.fromFile(Paths.image("menu/modMenu/defaultModIcon", true));
    }

    function buildFullModList():Void{
        modList = [];
        hasMods = true;

        if(PolymodHandler.allModDirs.length <= 0){
            hasMods = false;
            curSelectedMod = 0;
            listStartIndex = 0;
            showbigInfoNoMods();
            buildShownModList();
            updateMenuButtons();
            curSelectedButton = 3;
            changeButtonSelection(0);
            return;
        }

        for(dir in PolymodHandler.allModDirs){
            var info:ModInfo = {
                dir: dir,
                name: null,
                description: null,
                icon: null,
                apiVersion: null,
                modVersion: null,
                enabled: true,
                malformed: false
            };

            if(PolymodHandler.malformedMods.exists(dir)){
                switch(PolymodHandler.malformedMods.get(dir)){
                    case MISSING_META_JSON:
                        info.name = dir;
                        info.description = "This mod is missing a meta.json file.";
                        info.icon = getModIcon(dir);
                        info.apiVersion = "None";
                        info.modVersion = "None";
                    case MISSING_META_FIELDS:
                        var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
                        if(json.title != null){ info.name = json.title; }
                        else{ info.name = dir; }
                        info.description = "This mod is missing some required field(s) in the meta.json file.";
                        info.icon = getModIcon(dir);
                        if(json.api_version != null){ info.apiVersion = json.api_version; }
                        else{ info.apiVersion = "None"; }
                        if(json.mod_version != null){ info.modVersion = json.mod_version; }
                        else{ info.modVersion = "None"; }
                    case API_VERSION_TOO_OLD:
                        var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
                        if(json.title != null){ info.name = json.title; }
                        else{ info.name = dir; }
                        info.description = "This mod was made for an older version of FPS Plus that uses a version of the modding API that is no longer supported.";
                        info.icon = getModIcon(dir);
                        info.apiVersion = json.api_version;
                        info.modVersion = json.mod_version;
                    case API_VERSION_TOO_NEW:
                        var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
                        if(json.title != null){ info.name = json.title; }
                        else{ info.name = dir; }
                        info.description = "This mod was made for an API version higher than what this version of FPS Plus supports. You may need to update your version of FPS Plus or the API version is set incorrectly for the mod.";
                        info.icon = getModIcon(dir);
                        info.apiVersion = json.api_version;
                        info.modVersion = json.mod_version;
                    default:
                }

                info.enabled = false;
                info.malformed = true;
            }
            else{
                var json = Json.parse(File.getContent("mods/" + dir + "/meta.json"));
                if(json.title != null){ info.name = json.title; }
                else{ info.name = dir; }
                if(json.description != null){ info.description = json.description; }
                else{ info.description = "No description."; }
                info.icon = getModIcon(dir);
                info.apiVersion = json.api_version;
                info.modVersion = json.mod_version;
                info.enabled = !PolymodHandler.disabledModDirs.contains(dir);
            }

            modList.push(info);
        }

        if(curSelectedMod >= modList.length){
            curSelectedMod = modList.length - 1;
        }
    }

    function buildShownModList():Void{
        for(modIcon in modIcons){ remove(modIcon); }
        for(modName in modNames){ remove(modName); }

        modIcons = [];
        modNames = [];

        if(!hasMods){
            selectionBg.visible = false;
            return;
        }

        selectionBg.visible = true;
        
        for(i in 0...Std.int(Math.min(6, modList.length))){
            var modIcon = new FlxSprite(listStart.x + 10, listStart.y + 10 + (100 * i)).loadGraphic(modList[i + listStartIndex].icon);
            modIcon.setGraphicSize(80, 80);
            modIcon.updateHitbox();
            modIcon.antialiasing = true;

            var modName = new FlxTextExt(listStart.x + 100, listStart.y + 50 + (100 * i), 290, modList[i + listStartIndex].name, 36);
            modName.setFormat(Paths.font("Funkin-Bold", "otf"), 36, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
            modName.y -= modName.height/2;
            modName.borderSize = 2;
            modName.text += "\n\n";

            if(modList[i + listStartIndex].malformed){
                modIcon.color = 0xFFE25F5D;
                modName.color = 0xFFE25F5D;
            }
            else if(!modList[i + listStartIndex].enabled){
                modIcon.color = 0xFF999999;
                modName.color = 0xFF999999;
            }

            modIcons.push(modIcon);
            modNames.push(modName);
        }

        for(modIcon in modIcons){ add(modIcon); }
        for(modName in modNames){ add(modName); }
    }

    function save():Void{
        var newDisabledList:Array<String> = [];
        for(mod in modList){
            if(!mod.enabled && (!mod.malformed || PolymodHandler.disabledModDirs.contains(mod.dir))){
                newDisabledList.push(mod.dir);
            }
        }

        var newOrder:Array<String> = [];
        for(i in 0...modList.length){
            newOrder.push(modList[i].dir);
        }

        PolymodHandler.disabledModDirs = newDisabledList;
        PolymodHandler.allModDirs = newOrder;

        var write:String = "";
        for(mod in PolymodHandler.disabledModDirs){
            write += mod+"\n";
        }
        sys.io.File.saveContent("mods/disabled", write);

        write = "";
        for(mod in PolymodHandler.allModDirs){
            write += mod+"\n";
        }
        sys.io.File.saveContent("mods/order", write);

        trace(PolymodHandler.disabledModDirs);
        trace(PolymodHandler.allModDirs);
    }

}

typedef ModInfo = {
    var dir:String;
    var name:String;
    var description:String;
    var icon:BitmapData;
    var apiVersion:String;
    var modVersion:String;
    var enabled:Bool;
    var malformed:Bool;
}

class ModManagerButton extends FlxSprite
{
    
    public var toggleState:Bool = false;
    public var animSet:String = "";

    public var pressFunction:()->Void;
    
    public function select():Void{
        var suffix:String = (animSet.length > 0) ? "-" + animSet : "";
        animation.play("selected" + suffix, true);
    }

    public function deselect():Void{
        var suffix:String = (animSet.length > 0) ? "-" + animSet : "";
        animation.play("deselected" + suffix, true);
    }

    public function press():Void{
        toggleState = !toggleState;
        if(pressFunction != null){ pressFunction(); }
        FlxTween.cancelTweensOf(scale);
        scale.set(0.85, 0.85);
        FlxTween.tween(scale, {x: 1, y: 1}, 1, {ease: FlxEase.elasticOut});
    }
}