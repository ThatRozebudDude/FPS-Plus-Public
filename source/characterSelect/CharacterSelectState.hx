package characterSelect;

import flixel.math.FlxPoint;
import config.Config;
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
import haxe.Json;

using StringTools;

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
	var camFollowFinal:FlxObject;
	var camFollow:FlxPoint = new FlxPoint(1280/2, 720/2);
	var camShift:FlxPoint = new FlxPoint();
	final camMoveDistance:Float = 8;

	var characterGroup:FlxSpriteGroup= new FlxSpriteGroup();

	var blockingSelection:Bool = false;
	var canAccept:Bool = false;
	var canReverse:Bool = false;
	var reverseTime:Float = 0;

	var characters:Map<String, CharacterSelectGroup> = new Map<String, CharacterSelectGroup>();
	var characterPositions:Map<String, String> = new Map<String, String>();
	var curCharacter:String = "";
	var characterTitle:FlxSprite;

	var characterGrid:CharacterGrid;

	var curGridPosition:Array<Int> = [1, 1];

	var gridWidth:Int = 3;
	var gridHeight:Int = 3;

	var denyCount:Int = 0;
	var skipIdleCount:Int = 0;
	var reverseCount:Int = 0;

	var removeList:Array<String> = [];

	var repeatDelayX:Int = 0;
	var repeatDelayY:Int = 0;

	var cursorMoveSoundLockout:Float = 0;

	static var persistentCharacter:String = "bf";

	public function new() {
		super();
	}

	override function create():Void{

		Config.setFramerate(144);

		countSteps = false;

		customTransIn = new transition.data.ScreenWipeInFlipped(0.8, FlxEase.quadOut);
		customTransOut = new transition.data.ScreenWipeOut(0.8, FlxEase.quadIn);

		camFollowFinal = new FlxObject(0, 0, 1, 1);
		add(camFollowFinal);
		camFollowFinal.screenCenter();

		camFollow.y -= 150;
		fadeShader.fadeVal = 0;
		FlxTween.tween(fadeShader, {fadeVal: 1}, 0.8, {ease: FlxEase.quadOut});
		FlxTween.tween(camFollow, {y: camFollow.y + 150}, 1.5, {ease: FlxEase.expoOut});

		// FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.follow(camFollowFinal, LOCKON);
		FlxG.camera.filters = [new ShaderFilter(fadeShader.shader)];

		addCharacter("locked", "LockedPlayerCharacterSelect", null, null, [-1, -1]);
		
		//addCharacter("bf", "BfPlayer", "GfPartner", "Boyfriend", [1, 1]);
		//addCharacter("pico", "PicoPlayer", "NenePartner", "Pico", [0, 1]);

		var usedPositions:Array<Array<Int>> = [];

		final MAX_GRID_WIDTH:Int = 3;

		var curGridPosX:Int = 0;
		var curGridPosY:Int = 0;

		for(file in Utils.readDirectory("assets/data/characterSelect/")){
			if(file.endsWith(".json")){
				var charJson = Json.parse(Utils.getText(Paths.json(file.split(".json")[0], "data/characterSelect")));
				if (charJson.id == null){ charJson.id = file.split(".json")[0].toLowerCase(); }
				var charPos = charJson.position;

				if(charPos[0] >= 3){ charPos[0] = 0; }
				if(charPos[1] >= 3){ charPos[1] = 0; }

				var repositionCharacter:Bool = false;

				for(usedPos in usedPositions){
					if(usedPos[0] == charPos[0] && usedPos[1] == charPos[1]){
						repositionCharacter = true;
						break;
					}
				}

				if(repositionCharacter){
					var repositioned:Bool = false;
					while(!repositioned){
						repositioned = true;
						for(usedPos in usedPositions){
							if(usedPos[0] == curGridPosX && usedPos[1] == curGridPosY){
								curGridPosX++;
								if(curGridPosX >= MAX_GRID_WIDTH){
									curGridPosX = 0;
									curGridPosY++;
									if(curGridPosY >= gridHeight){
										gridHeight++;
									}
								}
								repositioned = false;
								break;
							}
						}
					}
					charPos = [curGridPosX, curGridPosY];
				}

				usedPositions.push([charPos[0], charPos[1]]);

				addCharacter(charJson.id, charJson.playerCharacter, charJson.partnerCharacter, charJson.freeplayCharacter, charPos);
			}
		}

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

		characterGrid = new CharacterGrid(480, 200, gridWidth, gridHeight, characters);
		characterGrid.scrollFactor.set();

		switch(gridHeight){
			case 1 | 2 | 3:
			default:
				characterGrid.y -= 80;

				chooseDipshit.setGraphicSize(chooseDipshit.frameWidth, chooseDipshit.frameHeight + (110 * (gridHeight-4)));
				chooseDipshit.updateHitbox();

				dipshitBacking.scale.set(chooseDipshit.scale.x, chooseDipshit.scale.y);
				dipshitBacking.updateHitbox();

				dipshitBlur.scale.set(chooseDipshit.scale.x, chooseDipshit.scale.y);
				dipshitBlur.updateHitbox();

				dipshitDarkBack.scale.set(chooseDipshit.scale.x, chooseDipshit.scale.y);
				dipshitDarkBack.updateHitbox();
		}

		if(!characters.exists(persistentCharacter)){
			persistentCharacter = "bf";
		}

		characterGrid.y += 230;
		characterGrid.select(characters.get(persistentCharacter).position);
		FlxTween.tween(characterGrid, {y: characterGrid.y - 230}, 1, {ease: FlxEase.expoOut});
		add(characterGrid);

		curGridPosition = characters.get(persistentCharacter).position.copy();
		changeGridPos([0, 0], true);

		changeCharacter(persistentCharacter, true);

		new FlxTimer().start(0.5, function(t){
			canAccept = true;
		});

		super.create();
	}

	override function update(elapsed:Float):Void{

		Conductor.songPosition = FlxG.sound.music.time;

		if(!blockingSelection){
			if(Binds.justPressed("menuUp")){
				changeGridPos([0, -1]);
				changeCharacter(getCharacterFromPosition(curGridPosition));
				characterGrid.showNormalCursor();
				characterGrid.select(curGridPosition);
				repeatDelayY = 2;
				skipIdleCount = 0;
				playCursorMoveSound();
			}
			else if(Binds.justPressed("menuDown")){
				changeGridPos([0, 1]);
				changeCharacter(getCharacterFromPosition(curGridPosition));
				characterGrid.showNormalCursor();
				characterGrid.select(curGridPosition);
				repeatDelayY = 2;
				skipIdleCount = 0;
				playCursorMoveSound();
			}
			if(Binds.justPressed("menuLeft")){
				changeGridPos([-1, 0]);
				changeCharacter(getCharacterFromPosition(curGridPosition));
				characterGrid.showNormalCursor();
				characterGrid.select(curGridPosition);
				repeatDelayX = 2;
				skipIdleCount = 0;
				playCursorMoveSound();
			}
			else if(Binds.justPressed("menuRight")){
				changeGridPos([1, 0]);
				changeCharacter(getCharacterFromPosition(curGridPosition));
				characterGrid.showNormalCursor();
				characterGrid.select(curGridPosition);
				repeatDelayX = 2;
				skipIdleCount = 0;
				playCursorMoveSound();
			}
		}

		if(Binds.justPressed("menuAccept") && characters.get(curCharacter).freeplayClass != null && !blockingSelection && canAccept){
			acceptCharacter();
		}
		else if(Binds.justPressed("menuAccept") && characters.get(curCharacter).freeplayClass == null && !blockingSelection){
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

		if(Binds.justPressed("menuBack") && !blockingSelection && !canReverse){
			curGridPosition = characters.get(persistentCharacter).position.copy();
			changeGridPos([0, 0]);
			changeCharacter(getCharacterFromPosition(curGridPosition));
			characterGrid.select(curGridPosition, true);
			acceptCharacter();
		}
		else if(Binds.justPressed("menuBack") && canReverse){
			blockingSelection = false;
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

		if(cursorMoveSoundLockout > 0){
			cursorMoveSoundLockout -= elapsed;
		}

		camFollowFinal.setPosition(camFollow.x + camShift.x, camFollow.y + camShift.y);

		super.update(elapsed);
	}

	override function beatHit():Void{
		super.beatHit();

		if(skipIdleCount > 0){
			skipIdleCount--;
		}
		else{
			if(!blockingSelection){
				if(characters.get(curCharacter).player != null){
					characters.get(curCharacter).player.playIdle();
				}
				if(characters.get(curCharacter).partner != null){
					characters.get(curCharacter).partner.playIdle();
				}
			}
		}

		speakers.playAnim("bop");
	}

	override function stepHit():Void{
		if(!blockingSelection){
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
					changeCharacter(getCharacterFromPosition(curGridPosition));
					characterGrid.showNormalCursor();
					characterGrid.select(curGridPosition);
					playCursorMoveSound();
				}
			}
		}

		super.stepHit();
	}

	function acceptCharacter():Void{
		blockingSelection = true;
		canReverse = true;

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
				persistentCharacter = curCharacter;
				FreeplayState.djCharacter = characters.get(curCharacter).freeplayClass;
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

	function startSong():Void{
		FlxG.sound.playMusic(Paths.music(characterSelectSong), characterSelectSongVolume);
		Conductor.changeBPM(characterSelectSongBpm);
		Conductor.songPosition = 0;
		countSteps = true;
	}

	function addCharacter(name:String, playerClass:String, partnerClass:String, freeplayClass:String, position:Array<Int>):Void{
		var partner:CharacterSelectCharacter = null;
		if(partnerClass != null){
			partner = ScriptableCharacterSelectCharacter.init(partnerClass);
			partner.setup();
			partner.antialiasing = true;
		}

		//player cant be null because what would be the fucking point
		var player:CharacterSelectCharacter = ScriptableCharacterSelectCharacter.init(playerClass);
		player.setup();
		player.antialiasing = true;

		characters.set(name, {
			player: player,
			partner: partner,
			freeplayClass: freeplayClass,
			position: position,
		});

		characterPositions.set((""+position[0]) + ("|"+position[1]), name);
	}

	function getCharacterFromPosition(position:Array<Int>):String{
		return characterPositions.get((""+position[0]) + ("|"+position[1]));
	}

	function characterExistsAtPosition(position:Array<Int>):Bool{
		return characterPositions.exists((""+position[0]) + ("|"+position[1]));
	}

	var initialPlayerTimer:FlxTimer;
	var initialPartnerTimer:FlxTimer;

	function changeCharacter(changeCharacter:String, ?initial:Bool = false):Void{
		if(changeCharacter == null){ changeCharacter = "locked"; }

		if(changeCharacter == curCharacter){ return; }
		else if(!characters.exists(changeCharacter)){ return; }

		var leavingCharacter = curCharacter;
		curCharacter = changeCharacter;

		if(initialPlayerTimer != null){ initialPlayerTimer.destroy(); }
		if(initialPartnerTimer != null){ initialPartnerTimer.destroy(); }

		if(characters.get(curCharacter).player != null){
			if(initial){
				initialPlayerTimer = new FlxTimer().start(0.2, function(t){
					characters.get(curCharacter).player.playEnter();
					characterGroup.add(characters.get(curCharacter).player);
				});
			}
			else{
				characters.get(curCharacter).player.playEnter();
				characterGroup.add(characters.get(curCharacter).player);
			}
		}
		if(characters.get(curCharacter).partner != null){
			if(initial){
				initialPartnerTimer = new FlxTimer().start(0.2, function(t){
					characters.get(curCharacter).partner.playEnter();
					characterGroup.add(characters.get(curCharacter).partner);
				});
			}
			else{
				characters.get(curCharacter).partner.playEnter();
				characterGroup.add(characters.get(curCharacter).partner);
			}
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

	function changeGridPos(?change:Array<Int>, ?_instant:Bool = false):Void{
		if(change == null){ change = [0, 0]; }

		curGridPosition[0] += change[0];
		curGridPosition[1] += change[1];

		if(curGridPosition[0] >= gridWidth){ curGridPosition[0] = 0; }
		else if(curGridPosition[0] < 0){ curGridPosition[0] = gridWidth-1; }

		if(curGridPosition[1] >= gridHeight){ curGridPosition[1] = 0; }
		else if(curGridPosition[1] < 0){ curGridPosition[1] = gridHeight-1; }

		if(!_instant){
			FlxTween.cancelTweensOf(camShift);
			FlxTween.tween(camShift, {x: (curGridPosition[0] - 1) * camMoveDistance, y: (curGridPosition[1] - 1) * camMoveDistance}, 3, {ease: FlxEase.quartOut});
		}
		else{
			camShift.set((curGridPosition[0] - 1) * camMoveDistance, (curGridPosition[1] - 1) * camMoveDistance);
		}
		
	}

	function playCursorMoveSound():Void{
		if(cursorMoveSoundLockout > 0){ return; }
		FlxG.sound.play(Paths.sound("characterSelect/select"), 0.7);
		cursorMoveSoundLockout = 0.05;
	}

}

typedef CharacterSelectGroup = {
	player:CharacterSelectCharacter,
	partner:CharacterSelectCharacter,
	freeplayClass:String,
	position:Array<Int>
}