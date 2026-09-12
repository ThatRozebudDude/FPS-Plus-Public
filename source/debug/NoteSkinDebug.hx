package debug;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import haxe.Json;
import modding.PolymodHandler;
import note.Note;
import note.NoteHoldCover;
import note.NoteSplash;
import note.ScriptableNoteSkin;
import ui.HudNoteSkinBase;

using StringTools;

class NoteSkinDebug extends FlxState
{

	static final SKIN_NAME:String = "Default";
	static final STRUM_POSITION:Float = 720/2;
	static final STATE_ANIMATIONS:Array<String> = ["static", "pressed", "confirm"];
	static final BINDS:Array<FlxKey> = [A, S, W, D, LEFT, DOWN, UP, RIGHT];
	static final NOTE_MAX_LERP_OFFSET:Float = 450;
	static final NOTE_LERP_SPEED:Float = 1;
	
	var uiSkinNames:Dynamic;

	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var enemyStrums:FlxTypedGroup<FlxSprite>;
	public var playerCovers:FlxTypedGroup<NoteHoldCover>;
	public var enemyCovers:FlxTypedGroup<NoteHoldCover>;
	public var notes:FlxTypedGroup<Note>;

	var noteStates:Array<Int> = [0,0,0,0,0,0,0,0];
	var coverStates:Array<Bool> = [false,false,false,false,false,false,false,false];
	var noteMode:Int = 0;
	var noteLerp:Float = 1;
	
	var infoText:FlxText;
	var noteOffsets:Array<FlxPoint> = [FlxPoint.get(), FlxPoint.get(), FlxPoint.get(), FlxPoint.get()];
	var selectedOffset:Int = -1;

	override function create(){
		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		uiSkinNames = {
			comboPopup: "Default",
			countdown: "Default",
			note: "Default",
			playerNotes: "Default",
			opponentNotes: "Default"
		};

		var skinJson = Json.parse(Utils.getText(Paths.json(SKIN_NAME, "data/uiSkins")));

		if(skinJson.note != null){
			if(ScriptableNoteSkin.listScriptClasses().contains("noteskins."+skinJson.note)){ uiSkinNames.note = skinJson.note; }
			#if BACKWARD_COMPATIBILITY
			else if(ScriptableNoteSkin.listScriptClasses().contains(skinJson.note)){ uiSkinNames.note = skinJson.note; }
			#end
		}
		if(skinJson.comboPopup != null && Utils.exists(Paths.json(skinJson.comboPopup, "data/uiSkins/comboPopup"))){ uiSkinNames.comboPopup = skinJson.comboPopup; }
		if(skinJson.countdown != null && Utils.exists(Paths.json(skinJson.countdown, "data/uiSkins/countdown"))){ uiSkinNames.countdown = skinJson.countdown; }
		if(skinJson.playerNotes != null && Utils.exists(Paths.json(skinJson.playerNotes, "data/uiSkins/hudNote"))){ uiSkinNames.playerNotes = skinJson.playerNotes; }
		if(skinJson.opponentNotes != null && Utils.exists(Paths.json(skinJson.opponentNotes, "data/uiSkins/hudNote"))){ uiSkinNames.opponentNotes = skinJson.opponentNotes; }

		Note.defaultSkin = uiSkinNames.note;

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		add(playerStrums);
		add(enemyStrums);

		playerCovers = new FlxTypedGroup<NoteHoldCover>();
		enemyCovers = new FlxTypedGroup<NoteHoldCover>();

		notes = new FlxTypedGroup<Note>();
		add(notes);

		add(playerCovers);
		add(enemyCovers);

		infoText = new FlxText(24, 24, 0, "", 16);
		infoText.color = 0xFF4444FF;
		add(infoText);

		generateStaticArrows(0, true);
		generateStaticArrows(1, true);

		for(i in 0...8){
			var note = new Note(0, i%4, "", false, null, false);
			note.mustPress = i > 3;
			notes.add(note);
			@:privateAccess
			noteOffsets[i%4].set(notes.members[i%4].noteSkin.info.offsets[i%4].x, notes.members[i%4].noteSkin.info.offsets[i%4].y);
		}
		
		super.create();

		updateText();
	}

	override function update(elapsed:Float){
		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload();
		}

		super.update(elapsed);

		var notesToUpdate:Array<Bool> = [];
		for(i in 0...8){
			notesToUpdate.push((noteStates[i] < 1 ? FlxG.keys.anyJustPressed([BINDS[i]]) : FlxG.keys.anyJustReleased([BINDS[i]])) || (FlxG.keys.anyPressed([BINDS[i]]) && FlxG.keys.anyPressed([TAB])));
		}

		for(i in 0...8){
			if(notesToUpdate[i]){
				if(noteStates[i] < 2 && FlxG.keys.anyPressed([SHIFT])){
					noteStates[i] = 2;
					createNoteSplash(i);
					if(coverStates[i]){
						stopHoldCover(i);
						coverStates[i] = false;
					}
				}
				else if(FlxG.keys.anyPressed([CONTROL])){
					if(!coverStates[i]){
						startHoldCover(i);
						noteStates[i] = 2;
					}
					else{
						stopHoldCover(i);
						noteStates[i] = 0;
					}
					coverStates[i] = !coverStates[i];
				}
				else{
					noteStates[i] += 1;
					if(noteStates[i] > 1){ noteStates[i] = 0; }
					if(coverStates[i]){
						stopHoldCover(i);
						coverStates[i] = false;
					}
				}

				if(i > 3){
					playerStrums.members[i%4].animation.play(STATE_ANIMATIONS[noteStates[i]], true);
				}
				else{
					enemyStrums.members[i%4].animation.play(STATE_ANIMATIONS[noteStates[i]], true);
				}
			}
		}

		final moveAmount:Float = 1 * (FlxG.keys.anyPressed([SHIFT]) ? 10 : 1) * (FlxG.keys.anyPressed([CONTROL]) ? 0.5 : 1);

		if(FlxG.keys.anyJustPressed([I])){
			updateNoteOffset(0, -moveAmount, selectedOffset);
		}
		if(FlxG.keys.anyJustPressed([J])){
			updateNoteOffset(-moveAmount, 0, selectedOffset);
		}
		if(FlxG.keys.anyJustPressed([K])){
			updateNoteOffset(0, moveAmount, selectedOffset);
		}
		if(FlxG.keys.anyJustPressed([L])){
			updateNoteOffset(moveAmount, 0, selectedOffset);
		}

		if(FlxG.keys.anyJustPressed([ONE])){
			selectedOffset = selectedOffset == 0 ? -1 : 0;
		}
		else if(FlxG.keys.anyJustPressed([TWO])){
			selectedOffset = selectedOffset == 1 ? -1 : 1;
		}
		else if(FlxG.keys.anyJustPressed([THREE])){
			selectedOffset = selectedOffset == 2 ? -1 : 2;
		}
		else if(FlxG.keys.anyJustPressed([FOUR])){
			selectedOffset = selectedOffset == 3 ? -1 : 3;
		}
		
		if(FlxG.keys.anyJustPressed([SPACE])){
			noteMode = FlxMath.wrap(noteMode+1, 0, 3);
			noteLerp = 1;
		}

		noteLerp -= noteLerp > 0 ? elapsed * NOTE_LERP_SPEED : elapsed;
		if(noteLerp < -0.2){ noteLerp = 1; }
		updateNote();

		if(FlxG.keys.anyJustPressed([ANY])){
			updateText();
		}
	}

	function updateText(){
		infoText.text = "";
		infoText.text += (selectedOffset == 0 ? "> " : "") + "Left: [" + noteOffsets[0].x + ", " + noteOffsets[0].y + "]\n";
		infoText.text += (selectedOffset == 1 ? "> " : "") + "Down: [" + noteOffsets[1].x + ", " + noteOffsets[1].y + "]\n";
		infoText.text += (selectedOffset == 2 ? "> " : "") + "Up: [" + noteOffsets[2].x + ", " + noteOffsets[2].y + "]\n";
		infoText.text += (selectedOffset == 3 ? "> " : "") + "Right: [" + noteOffsets[3].x + ", " + noteOffsets[3].y + "]\n";
	}

	//Grabbed straight out of PlayState.
	public function generateStaticArrows(player:Int, ?instant:Bool = false, ?skin:String):Void{
		if(skin == null){ 
			if(player == 0){ skin = uiSkinNames.opponentNotes; }
			else{ skin = uiSkinNames.playerNotes; }
		}

		var hudNoteSkinName:String = skin;
		var hudNoteSkin:HudNoteSkinBase = new HudNoteSkinBase(hudNoteSkinName);

		var hudNoteSkinInfo = hudNoteSkin.info;

		var totalWidth:Float = 0;

		for (i in 0...4){
			var babyArrow:FlxSprite = new FlxSprite(i > 0 ? totalWidth + hudNoteSkinInfo.spacing : 0, STRUM_POSITION);

			switch(hudNoteSkinInfo.noteFrameLoadType){
				case sparrow:
					babyArrow.frames = Paths.getSparrowAtlas(hudNoteSkinInfo.notePath);
				//case packer:
				//	babyArrow.frames = Paths.getPackerAtlas(hudNoteSkinInfo.notePath);
				case load(fw, fh):
					babyArrow.loadGraphic(Paths.image(hudNoteSkinInfo.notePath), true, fw, fh);
				default:
					trace("not supported, sorry :[");
			}

			switch(hudNoteSkinInfo.arrowInfo[i].staticInfo.type){
				case prefix:
					babyArrow.animation.addByPrefix("static", hudNoteSkinInfo.arrowInfo[i].staticInfo.data.prefix, hudNoteSkinInfo.arrowInfo[i].staticInfo.data.framerate, true, hudNoteSkinInfo.arrowInfo[i].staticInfo.data.flipX, hudNoteSkinInfo.arrowInfo[i].staticInfo.data.flipY);
				case frame:
					babyArrow.animation.add("static", hudNoteSkinInfo.arrowInfo[i].staticInfo.data.frames, hudNoteSkinInfo.arrowInfo[i].staticInfo.data.framerate, true, hudNoteSkinInfo.arrowInfo[i].staticInfo.data.flipX, hudNoteSkinInfo.arrowInfo[i].staticInfo.data.flipY);
			}

			switch(hudNoteSkinInfo.arrowInfo[i].pressedInfo.type){
				case prefix:
					babyArrow.animation.addByPrefix("pressed", hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.prefix, hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.framerate, false, hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.flipX, hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.flipY);
				case frame:
					babyArrow.animation.add("pressed", hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.frames, hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.framerate, false, hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.flipX, hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.flipY);
			}

			switch(hudNoteSkinInfo.arrowInfo[i].confrimedInfo.type){
				case prefix:
					babyArrow.animation.addByPrefix("confirm", hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.prefix, hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.framerate, false, hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.flipX, hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.flipY);
				case frame:
					babyArrow.animation.add("confirm", hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.frames, hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.framerate, false, hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.flipX, hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.flipY);
			}

			babyArrow.scale.set(hudNoteSkinInfo.scale, hudNoteSkinInfo.scale);
			babyArrow.updateHitbox();
			babyArrow.antialiasing = hudNoteSkinInfo.antialiasing;

			var noteCover:NoteHoldCover = new NoteHoldCover(babyArrow, i, hudNoteSkinInfo.coverPath);
			noteCover.ID = i;
			NoteHoldCover.defaultSkin = hudNoteSkinInfo.coverPath;

			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			if(player == 1) {
				playerStrums.add(babyArrow);
				playerCovers.add(noteCover);

			}
			else {
				enemyStrums.add(babyArrow);
				enemyCovers.add(noteCover);
			}

			babyArrow.y -= babyArrow.height/2;

			babyArrow.animation.onFrameChange.add(function(name:String, frame:Int, index:Int) {
				if(frame == 0){
					babyArrow.centerOffsets();
					switch(name){
						case "static":
							babyArrow.offset.x += hudNoteSkinInfo.arrowInfo[i].staticInfo.data.offset[0];
							babyArrow.offset.y += hudNoteSkinInfo.arrowInfo[i].staticInfo.data.offset[1];
						case "pressed":
							babyArrow.offset.x += hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.offset[0];
							babyArrow.offset.y += hudNoteSkinInfo.arrowInfo[i].pressedInfo.data.offset[1];
						case "confirm":
							babyArrow.offset.x += hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.offset[0];
							babyArrow.offset.y += hudNoteSkinInfo.arrowInfo[i].confrimedInfo.data.offset[1];
					}
				}
			});

			babyArrow.animation.play("static");

			totalWidth = babyArrow.x + babyArrow.width;
		}

		if(player == 1){
			//Prevents the game from lagging at first note splash.
			NoteSplash.skinName = hudNoteSkinInfo.splashClass;
			var preloadSplash = new NoteSplash(-2000, -2000, 0, true);

			playerStrums.forEach(function(arrow:FlxSprite){
				arrow.x += (1280/2) + (((1280/2) - totalWidth)/2);
			});
		}
		else{
			enemyStrums.forEach(function(arrow:FlxSprite){
				arrow.x += ((1280/2) - totalWidth)/2;
			});
		}
	}

	private function createNoteSplash(direction:Int){
		var noteSplash:NoteSplash;
		if(direction > 3){
			noteSplash = new NoteSplash(playerStrums.members[direction%4].getMidpoint().x, playerStrums.members[direction%4].getMidpoint().y, direction%4, false, null);
		}
		else{
			noteSplash = new NoteSplash(enemyStrums.members[direction%4].getMidpoint().x, enemyStrums.members[direction%4].getMidpoint().y, direction%4, false, null);
		}
		add(noteSplash);
	}

	private function startHoldCover(direction:Int){
		if(direction > 3){
			playerCovers.forEachAlive(function(cover:NoteHoldCover){
				if(cover.ID == direction%4){
					cover.start();
				}
			});
		}
		else{
			enemyCovers.forEachAlive(function(cover:NoteHoldCover){
				if(cover.ID == direction%4){
					cover.start();
				}
			});
		}
	}

	private function stopHoldCover(direction:Int){
		if(direction > 3){
			playerCovers.forEachAlive(function(cover:NoteHoldCover){
				if(cover.ID == direction%4){
					cover.end(true);
				}
			});
		}
		else{
			enemyCovers.forEachAlive(function(cover:NoteHoldCover){
				if(cover.ID == direction%4){
					cover.end(false);
				}
			});
		}
	}

	function updateNote(){
		switch(noteMode){
			case 1: //Static
				notes.forEachAlive(function(note:Note){
					final targetStrum:FlxSprite = note.mustPress ? (playerStrums.members[Math.floor(Math.abs(note.direction))]) : (enemyStrums.members[Math.floor(Math.abs(note.direction))]);
					note.visible = true;
					note.y = targetStrum.y + note.yOffset;
					note.x = targetStrum.x + note.xOffset;
				});
			case 2:	//Upscroll
				notes.forEachAlive(function(note:Note){
					final targetStrum:FlxSprite = note.mustPress ? (playerStrums.members[Math.floor(Math.abs(note.direction))]) : (enemyStrums.members[Math.floor(Math.abs(note.direction))]);
					note.visible = true;
					note.y = targetStrum.y + note.yOffset + (FlxMath.lerp(0, NOTE_MAX_LERP_OFFSET, FlxMath.bound(noteLerp, 0, 1)));
					note.x = targetStrum.x + note.xOffset;
				});
			case 3: //Downscroll
				notes.forEachAlive(function(note:Note){
					final targetStrum:FlxSprite = note.mustPress ? (playerStrums.members[Math.floor(Math.abs(note.direction))]) : (enemyStrums.members[Math.floor(Math.abs(note.direction))]);
					note.visible = true;
					note.y = targetStrum.y + note.yOffset - (FlxMath.lerp(0, NOTE_MAX_LERP_OFFSET, FlxMath.bound(noteLerp, 0, 1)));
					note.x = targetStrum.x + note.xOffset;
				});
			default: //Hidden
				notes.forEachAlive(function(note:Note){
					note.visible = false;
				});
		}
	}

	function updateNoteOffset(deltaX:Float, deltaY:Float, direction:Int):Void{
		@:privateAccess
		for(note in notes.members){
			if(note.direction == direction || direction < 0){
				note.xOffset -= note.noteSkin.info.offsets[note.direction].x;
				note.yOffset -= note.noteSkin.info.offsets[note.direction].y;
			}
		}

		for(i in 0...noteOffsets.length){
			if(i == direction || direction < 0){
				noteOffsets[i].x += deltaX;
				noteOffsets[i].y += deltaY;
			}
		}

		for(note in notes.members){
			if(note.direction == direction || direction < 0){
				note.xOffset += deltaX;
				note.yOffset += deltaY;
			}
		}
	}

}