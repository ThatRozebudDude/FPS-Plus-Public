package characterSelect;

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

    var dipshitBacking:FlxSprite;
    var chooseDipshit:FlxSprite;
    var dipshitBlur:FlxSprite;
    
    var fadeShader:BlueFadeShader = new BlueFadeShader(1);
    var camFollow:FlxObject;

    var playerCharacter:CharacterSelectCharacter;
    var playerPartner:CharacterSelectCharacter;

    var startLeaving:Bool = false;

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

        var partnerClass = Type.resolveClass("characterSelect.characters." + "NenePartner");
		if(partnerClass == null){ partnerClass = characterSelect.characters.GfPartner; }
        playerPartner = Type.createInstance(partnerClass, []);
        playerPartner.visible = false;
        new FlxTimer().start(0.2, function(t){
            playerPartner.playEnter();
            playerPartner.visible = true;
        });
        add(playerPartner);

        var playerClass = Type.resolveClass("characterSelect.characters." + "PicoPlayer");
		if(playerClass == null){ playerClass = characterSelect.characters.BfPlayer; }
        playerCharacter = Type.createInstance(playerClass, []);
        playerCharacter.visible = false;
        new FlxTimer().start(0.2, function(t){
            playerCharacter.playEnter();
            playerCharacter.visible = true;
        });
        add(playerCharacter);

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

        dipshitBlur = new FlxSprite(419, -65);
        dipshitBlur.frames = Paths.getSparrowAtlas("menu/characterSelect/dipshitBlur");
        dipshitBlur.animation.addByPrefix('idle', "CHOOSE vertical offset instance 1", 24, true);
        dipshitBlur.blend = ADD;
        dipshitBlur.antialiasing = true;
        dipshitBlur.animation.play("idle");
        dipshitBlur.y += 220;
        FlxTween.tween(dipshitBlur, {y: dipshitBlur.y - 220}, 1.2, {ease: FlxEase.expoOut});
        add(dipshitBlur);

        dipshitBacking = new FlxSprite(423, -17);
        dipshitBacking.frames = Paths.getSparrowAtlas("menu/characterSelect/dipshitBacking");
        dipshitBacking.animation.addByPrefix('idle', "CHOOSE horizontal offset instance 1", 24, true);
        dipshitBacking.blend = ADD;
        dipshitBacking.antialiasing = true;
        dipshitBacking.animation.play("idle");
        dipshitBacking.y += 210;
        FlxTween.tween(dipshitBacking, {y: dipshitBacking.y - 210}, 1.1, {ease: FlxEase.expoOut});
        add(dipshitBacking);

        chooseDipshit = new FlxSprite(426, -13).loadGraphic(Paths.image('menu/characterSelect/chooseDipshit'));
        chooseDipshit.antialiasing = true;
        chooseDipshit.y += 200;
        FlxTween.tween(chooseDipshit, {y: chooseDipshit.y - 200}, 1, {ease: FlxEase.expoOut});
        add(chooseDipshit);

        chooseDipshit.scrollFactor.set();
        dipshitBacking.scrollFactor.set();
        dipshitBlur.scrollFactor.set();

        super.create();
    }

    override function update(elapsed:Float):Void{

        Conductor.songPosition = FlxG.sound.music.time;

        if(FlxG.keys.anyJustPressed([SPACE])){
            startLeaving = true;
            playerCharacter.playConfirm();
            playerPartner.playConfirm();
            FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.sound.music.pitch = 1;
			FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4, {ease: FlxEase.quadOut, onComplete: function(t){
				FlxG.sound.music.fadeOut(0.05);
                new FlxTimer().start(0.3, function(t) {
					switchState(new FreeplayState(fromCharacterSelect));
                    FlxTween.tween(camFollow, {y: camFollow.y - 150}, 0.8, {ease: FlxEase.backIn});
                    FlxTween.tween(titleBar, {y: titleBar.y + 80}, 0.8, {ease: FlxEase.backIn});
                    FlxTween.tween(dipshitBlur, {y: dipshitBlur.y + 220}, 0.8, {ease: FlxEase.backIn});
                    FlxTween.tween(dipshitBacking, {y: dipshitBacking.y + 210}, 0.8, {ease: FlxEase.backIn});
                    FlxTween.tween(chooseDipshit, {y: chooseDipshit.y + 200}, 0.8, {ease: FlxEase.backIn});
                    fadeShader.fadeVal = 1;
		            FlxTween.tween(fadeShader, {fadeVal: 0}, 0.8, {ease: FlxEase.quadIn});
				});
			}});
        }

        super.update(elapsed);
    }

    override function beatHit():Void{
        super.beatHit();

        if(!startLeaving){
            playerCharacter.playIdle();
            playerPartner.playIdle();
        }

        speakers.playAnim("bop");
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

}