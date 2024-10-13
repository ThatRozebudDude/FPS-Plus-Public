package characterSelect;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;
import shaders.BlueFadeShader;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import freeplay.FreeplayState;
import flixel.FlxG;
import flixel.FlxSprite;

class CharacterSelectState extends MusicBeatState
{

    final characterSelectSong:String = "stayFunky";
    final characterSelectSongVolume:Float = 1;
    final characterSelectSongBpm:Float = 90;

    var titleBar:AtlasSprite;

    var speakers:AtlasSprite;

    var dipshitDarkBack:FlxSprite;
    var dipshitBacking:FlxSprite;
    var chooseDipshit:FlxSprite;
    var dipshitBlur:FlxSprite;
    
    var fadeShader:BlueFadeShader = new BlueFadeShader(1);
    var camFollow:FlxObject;

    var characterGroup:FlxSpriteGroup= new FlxSpriteGroup();

    var startLeaving:Bool = false;
    var canAccept:Bool = false;
    var canReverse:Bool = false;
    var reverseTime:Float = 0;

    var characters:Map<String, CharacterSelectGroup> = new Map<String, CharacterSelectGroup>();
    var characterPositions:Map<String, String> = new Map<String, String>();
    var curCharacter:String = "";
    var characterTitle:FlxSprite;

    var characterGrid:CharacterGrid;

    final gridSize = 3;
    var curGridPosition:Array<Int> = [1, 1];

    var denyCount:Int = 0;
    var skipIdleCount:Int = 0;
    var reverseCount:Int = 0;

    var removeList:Array<String> = [];

    var repeatDelayX:Int = 0;
    var repeatDelayY:Int = 0;

    static var persistentCharacter:String = "bf";

    public function new() {
        super();
    }

    override function create():Void{
        customTransIn = new transition.data.ScreenWipeInFlipped(0.8, FlxEase.quadOut);
        customTransOut = new transition.data.ScreenWipeOut(0.8, FlxEase.quadIn);

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);
        camFollow.screenCenter();

        camFollow.y -= 150;
        fadeShader.fadeVal = 0;
		FlxTween.tween(fadeShader, {fadeVal: 1}, 0.8, {ease: FlxEase.quadOut});
        FlxTween.tween(camFollow, {y: camFollow.y + 150}, 1.5, {ease: FlxEase.expoOut});

        // FlxG.camera.follow(camFollow, LOCKON, 0.01);
        FlxG.camera.follow(camFollow, LOCKON);
        FlxG.camera.filters = [new ShaderFilter(fadeShader.shader)];

        addCharacter("locked", "LockedPlayer", null, null, [-1, -1]);
        addCharacter("bf", "BfPlayer", "GfPartner", "Boyfriend", [1, 1]);
        addCharacter("pico", "PicoPlayer", "NenePartner", "Pico", [0, 1]);

        startSong();

        var bg:FlxSprite = new FlxSprite(-153, -140).loadGraphic(Paths.image("menu/characterSelect/charSelectBG"));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.1, 0.1);
        add(bg);
    
        var crowd:AtlasSprite = new AtlasSprite(0, 0, Paths.getTextureAtlas("menu/characterSelect/crowd"));
        crowd.antialiasing = true;
        crowd.scrollFactor.set(0.3, 0.3);
        crowd.addFullAnimation("idle", 24, true);
        crowd.playAnim("idle");
        add(crowd);
    
        var stageSpr:FlxSprite = new FlxSprite(-40, 391);
        stageSpr.frames = Paths.getSparrowAtlas("menu/characterSelect/charSelectStage");
        stageSpr.antialiasing = true;
        stageSpr.animation.addByPrefix("idle", "stage full instance 1", 24, true);
        stageSpr.animation.play("idle");
        add(stageSpr);
    
        var curtains:FlxSprite = new FlxSprite(-47, -49).loadGraphic(Paths.image("menu/characterSelect/curtains"));
        curtains.antialiasing = true;
        curtains.scrollFactor.set(1.4, 1.4);
        add(curtains);

        titleBar = new AtlasSprite(0, 0, Paths.getTextureAtlas("menu/characterSelect/bar"));
        titleBar.antialiasing = true;
        titleBar.scrollFactor.set();
        titleBar.addFullAnimation("loop", 24, true);
        titleBar.playAnim("loop");
        titleBar.blend = MULTIPLY;
        add(titleBar);

        titleBar.y += 80;
        FlxTween.tween(titleBar, {y: titleBar.y - 80}, 1.3, {ease: FlxEase.expoOut});

        var charLight:FlxSprite = new FlxSprite(800, 250).loadGraphic(Paths.image('menu/characterSelect/charLight'));
        charLight.antialiasing = true;
        add(charLight);

        var charLightGF:FlxSprite = new FlxSprite(180, 240).loadGraphic(Paths.image('menu/characterSelect/charLight'));
        charLightGF.antialiasing = true;
        add(charLightGF);

        add(characterGroup);
        new FlxTimer().start(0.2, function(t){
            changeCharacter(persistentCharacter);
        });

        speakers = new AtlasSprite(0, 0, Paths.getTextureAtlas("menu/characterSelect/charSelectSpeakers"));
        speakers.antialiasing = true;
        speakers.scrollFactor.set(1.8, 1.8);
        speakers.addFullAnimation("bop", 24, false);
        speakers.playAnim("bop");
        add(speakers);

        var fgBlur:FlxSprite = new FlxSprite(-125, 170).loadGraphic(Paths.image('menu/characterSelect/foregroundBlur'));
        fgBlur.antialiasing = true;
        fgBlur.blend = MULTIPLY;
        add(fgBlur);

        dipshitDarkBack = new FlxSprite(426, -13).loadGraphic(Paths.image('menu/characterSelect/dipshitDarkBack'));
        dipshitDarkBack.antialiasing = true;
        dipshitDarkBack.scrollFactor.set();
        dipshitDarkBack.y += 200;
        dipshitDarkBack.alpha = 0.5;
        FlxTween.tween(dipshitDarkBack, {y: dipshitDarkBack.y - 200}, 1, {ease: FlxEase.expoOut});
        add(dipshitDarkBack);

        dipshitBlur = new FlxSprite(419, -65);
        dipshitBlur.frames = Paths.getSparrowAtlas("menu/characterSelect/dipshitBlur");
        dipshitBlur.animation.addByPrefix('idle', "CHOOSE vertical offset instance 1", 24, true);
        dipshitBlur.blend = ADD;
        dipshitBlur.antialiasing = true;
        dipshitBlur.scrollFactor.set();
        dipshitBlur.animation.play("idle");
        dipshitBlur.y += 220;
        FlxTween.tween(dipshitBlur, {y: dipshitBlur.y - 220}, 1.2, {ease: FlxEase.expoOut});
        add(dipshitBlur);

        dipshitBacking = new FlxSprite(423, -17);
        dipshitBacking.frames = Paths.getSparrowAtlas("menu/characterSelect/dipshitBacking");
        dipshitBacking.animation.addByPrefix('idle', "CHOOSE horizontal offset instance 1", 24, true);
        dipshitBacking.blend = ADD;
        dipshitBacking.antialiasing = true;
        dipshitBacking.scrollFactor.set();
        dipshitBacking.animation.play("idle");
        dipshitBacking.y += 210;
        FlxTween.tween(dipshitBacking, {y: dipshitBacking.y - 210}, 1.1, {ease: FlxEase.expoOut});
        add(dipshitBacking);

        chooseDipshit = new FlxSprite(426, -13).loadGraphic(Paths.image('menu/characterSelect/chooseDipshit'));
        chooseDipshit.antialiasing = true;
        chooseDipshit.scrollFactor.set();
        chooseDipshit.y += 200;
        FlxTween.tween(chooseDipshit, {y: chooseDipshit.y - 200}, 1, {ease: FlxEase.expoOut});
        add(chooseDipshit);

        characterTitle = new FlxSprite();
        characterTitle.scrollFactor.set();
        updateCharacterTitle();
        characterTitle.y += 80;
        FlxTween.tween(characterTitle, {y: characterTitle.y - 80}, 1.3, {ease: FlxEase.expoOut});
        add(characterTitle);

        characterGrid = new CharacterGrid(480, 200, gridSize, characters);
        characterGrid.scrollFactor.set();
        characterGrid.y += 230;
        characterGrid.select(characters.get(persistentCharacter).position);
        //characterGrid.forceTrackPosition = characters.get(persistentCharacter).position.copy();
        FlxTween.tween(characterGrid, {y: characterGrid.y - 230}, 1, {ease: FlxEase.expoOut});
        add(characterGrid);

        curGridPosition = characters.get(persistentCharacter).position;

        new FlxTimer().start(0.5, function(t){
            canAccept = true;
        });

        super.create();
    }

    override function update(elapsed:Float):Void{

        Conductor.songPosition = FlxG.sound.music.time;

        if(!startLeaving){
            if(Binds.justPressed("menuUp")){
                changeGridPos([0, -1]);
                changeCharacter(getCharacterFromPosition());
                characterGrid.showNormalCursor();
                characterGrid.select(curGridPosition);
                repeatDelayY = 2;
                skipIdleCount = 0;
                FlxG.sound.play(Paths.sound("characterSelect/select"), 0.7);
            }
            else if(Binds.justPressed("menuDown")){
                changeGridPos([0, 1]);
                changeCharacter(getCharacterFromPosition());
                characterGrid.showNormalCursor();
                characterGrid.select(curGridPosition);
                repeatDelayY = 2;
                skipIdleCount = 0;
                FlxG.sound.play(Paths.sound("characterSelect/select"), 0.7);
            }
            if(Binds.justPressed("menuLeft")){
                changeGridPos([-1, 0]);
                changeCharacter(getCharacterFromPosition());
                characterGrid.showNormalCursor();
                characterGrid.select(curGridPosition);
                repeatDelayX = 2;
                skipIdleCount = 0;
                FlxG.sound.play(Paths.sound("characterSelect/select"), 0.7);
            }
            else if(Binds.justPressed("menuRight")){
                changeGridPos([1, 0]);
                changeCharacter(getCharacterFromPosition());
                characterGrid.showNormalCursor();
                characterGrid.select(curGridPosition);
                repeatDelayX = 2;
                skipIdleCount = 0;
                FlxG.sound.play(Paths.sound("characterSelect/select"), 0.7);
            }
        }

        if(Binds.justPressed("menuAccept") && characters.get(curCharacter).freeplayClass != null && !startLeaving && canAccept){
            startLeaving = true;
            canReverse = true;
            persistentCharacter = curCharacter;
            FreeplayState.djCharacter = characters.get(curCharacter).freeplayClass;

            characters.get(curCharacter).player.playConfirm();
            characters.get(curCharacter).partner.playConfirm();
            characterGrid.confirm(characters.get(curCharacter).position);

            FlxG.sound.play(Paths.sound("characterSelect/confirm"));

            reverseCount++;
            var reverseCheck = reverseCount;

            FlxG.sound.music.pitch = 1;
            FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.8, {ease: FlxEase.quadOut, onComplete: function(t){
                if(reverseCheck == reverseCount){
                    FlxG.sound.music.fadeOut(0.05);
                    canReverse = false;
                    new FlxTimer().start(0.3, function(t) {
                        switchState(new FreeplayState(fromCharacterSelect));
                        FlxTween.tween(camFollow, {y: camFollow.y - 150}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(titleBar, {y: titleBar.y + 80}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(characterTitle, {y: characterTitle.y + 80}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(dipshitBlur, {y: dipshitBlur.y + 220}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(dipshitBacking, {y: dipshitBacking.y + 210}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(chooseDipshit, {y: chooseDipshit.y + 200}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(dipshitDarkBack, {y: dipshitDarkBack.y + 200}, 0.8, {ease: FlxEase.backIn});
                        FlxTween.tween(characterGrid, {y: characterGrid.y + 230}, 0.8, {ease: FlxEase.backIn});
                        fadeShader.fadeVal = 1;
                        FlxTween.tween(fadeShader, {fadeVal: 0}, 0.8, {ease: FlxEase.quadIn});
                    });
                }
            }});
        }
        else if(Binds.justPressed("menuAccept") && characters.get(curCharacter).freeplayClass == null && !startLeaving){
            characterGrid.deny(curGridPosition);
            FlxG.sound.play(Paths.sound("characterSelect/deny"));
            denyCount++;
            var denyCheck = denyCount;
            new FlxTimer().start(6/24, function(t) {
                if(denyCheck ==  denyCount){
                    characterGrid.showNormalCursor();
                }
            });
        }

        if(Binds.justPressed("menuBack") && canReverse){
            startLeaving = false;
            canReverse = false;
            skipIdleCount = 1;
            reverseCount++;
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {pitch: 1}, reverseTime, {ease: FlxEase.quadIn});
            reverseTime = 0;
            characterGrid.showNormalCursor();
            characterGrid.reverseIcon(curGridPosition);
            characters.get(curCharacter).player.playCancel();
            if(characters.get(curCharacter).partner != null){
                characters.get(curCharacter).partner.playCancel();
            }
        }

        if(canReverse){
            reverseTime += elapsed;
        }

        super.update(elapsed);
    }

    override function beatHit():Void{
        super.beatHit();

        if(skipIdleCount > 0){
            skipIdleCount--;
        }
        else{
            if(!startLeaving){
                characters.get(curCharacter).player.playIdle();
                if(characters.get(curCharacter).partner != null){
                    characters.get(curCharacter).partner.playIdle();
                }
            }
        }

        speakers.playAnim("bop");
    }

    override function stepHit():Void{
        if(!startLeaving){
            var changeAmount = [0, 0];

            if(repeatDelayY > 0){
                repeatDelayY--;
            }
            else{
                if(Binds.pressed("menuUp")){
                    changeAmount[1]--;
                }
                if(Binds.pressed("menuDown")){
                    changeAmount[1]++;
                }
            }

            if(repeatDelayX > 0){
                repeatDelayX--;
            }
            else{
                if(Binds.pressed("menuLeft")){
                    changeAmount[0]--;
                }
                if(Binds.pressed("menuRight")){
                    changeAmount[0]++;
                }
            }

            if(changeAmount[0] != 0 || changeAmount[1] != 0){
                if(Binds.pressed("menuUp") || Binds.pressed("menuDown") || Binds.pressed("menuLeft") || Binds.pressed("menuRight")){
                    changeGridPos(changeAmount);
                    changeCharacter(getCharacterFromPosition());
                    characterGrid.showNormalCursor();
                    characterGrid.select(curGridPosition);
                    FlxG.sound.play(Paths.sound("characterSelect/select"), 0.7);
                }
            }
        }

        super.stepHit();
    }

    function startSong():Void{
		FlxG.sound.playMusic(Paths.music(characterSelectSong), characterSelectSongVolume);
		Conductor.changeBPM(characterSelectSongBpm);
		FlxG.sound.music.onComplete = function(){ 
			lastStep = -Conductor.stepCrochet;
		}
		lastBeat = 0;
		lastStep = 0;
		totalBeats = 0;
		totalSteps = 0;
		curStep = 0;
		curBeat = 0;
	}

    function addCharacter(name:String, playerClass:String, partnerClass:String, freeplayClass:String, position:Array<Int>):Void{
        var partner:CharacterSelectCharacter = null;
        if(partnerClass != null){
            var partnerClass = Type.resolveClass("characterSelect.characters." + partnerClass);
            if(partnerClass == null){ partnerClass = characterSelect.characters.GfPartner; }
            partner = Type.createInstance(partnerClass, []);
        }

        //player cant be null because what would be the fucking point
        var playerClass = Type.resolveClass("characterSelect.characters." + playerClass);
        if(playerClass == null){ playerClass = characterSelect.characters.BfPlayer; }
        var player:CharacterSelectCharacter = Type.createInstance(playerClass, []);

        characters.set(name, {
            player: player,
            partner: partner,
            freeplayClass: freeplayClass,
            position: position,
        });

        characterPositions.set((""+position[0]) + (""+position[1]), name);
    }

    function changeCharacter(changeCharacter:String):Void{
        if(changeCharacter == null){ changeCharacter = "locked"; }

        if(changeCharacter == curCharacter){ return; }
        else if(!characters.exists(changeCharacter)){ return; }

        var leavingCharacter = curCharacter;
        curCharacter = changeCharacter;

        characters.get(curCharacter).player.playEnter();
        if(characters.get(curCharacter).partner != null){
            characters.get(curCharacter).partner.playEnter();
        }

        characterGroup.add(characters.get(curCharacter).player);
        if(characters.get(curCharacter).partner != null){
            characterGroup.add(characters.get(curCharacter).partner);
        }

        updateCharacterTitle();
        removeList.remove(curCharacter);

        if(characters.exists(leavingCharacter)){
            characters.get(leavingCharacter).player.playExit();
            if(characters.get(leavingCharacter).partner != null){
                characters.get(leavingCharacter).partner.playExit();
            }
            //canChangeCharacters = false;

            removeList.push(leavingCharacter);

            new FlxTimer().start(2/24, function(t){
                if(removeList.contains(leavingCharacter)){
                    characterGroup.remove(characters.get(leavingCharacter).player, true);
                    if(characters.get(leavingCharacter).partner != null){
                        characterGroup.remove(characters.get(leavingCharacter).partner, true);
                    }
                    removeList.remove(leavingCharacter);
                }
                //canChangeCharacters = true;
            });
        }
    }

    function updateCharacterTitle():Void{
        FlxTween.cancelTweensOf(characterTitle);
        FlxTween.globalManager.update(0);
        
        if(Utils.exists(Paths.image("menu/characterSelect/characters/" + curCharacter + "/title", true))){
            characterTitle.loadGraphic(Paths.image("menu/characterSelect/characters/" + curCharacter + "/title"));
        }
        else{
            characterTitle.loadGraphic(Paths.image("menu/characterSelect/characters/locked/title"));
        }

        characterTitle.antialiasing = true;
        characterTitle.scale.set(0.75, 0.75);
        characterTitle.updateHitbox();

        characterTitle.setPosition(1280 * 4/5, 100);
        characterTitle.x -= characterTitle.width/2;
        characterTitle.y -= characterTitle.height/2;

        /*if(doTween){
            FlxTween.completeTweensOf(characterTitle);
            FlxTween.globalManager.update(0);
            characterTitle.y -= 10;
            FlxTween.tween(characterTitle, {y: characterTitle.y + 10}, 0.4, {ease: FlxEase.quintOut});
        }*/
    }

    function getCharacterFromPosition():String{
        //idk why this shit dont work
        /*for(key => val in characters){
            if(val.position[0] == curGridPosition[0] && val.position[1] == curGridPosition[1]){
                trace(key);
                trace(val.position);
                trace(curGridPosition);
                return key;
            }
        }
        return null;*/
        return characterPositions.get((""+curGridPosition[0]) + (""+curGridPosition[1]));
    }

    function changeGridPos(?change:Array<Int>):Void{
        if(change == null){ change = [0, 0]; }

        curGridPosition[0] += change[0];
        curGridPosition[1] += change[1];

        if(curGridPosition[0] >= gridSize){ curGridPosition[0] = 0; }
        else if(curGridPosition[0] < 0){ curGridPosition[0] = gridSize-1; }

        if(curGridPosition[1] >= gridSize){ curGridPosition[1] = 0; }
        else if(curGridPosition[1] < 0){ curGridPosition[1] = gridSize-1; }
    }

}

typedef CharacterSelectGroup = {
    player:CharacterSelectCharacter,
    partner:CharacterSelectCharacter,
    freeplayClass:String,
    position:Array<Int>
}