package editors.chart;

import editors.ui.*;
import flixel.sound.FlxSound;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxSort;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.misc.ColorTween;
import flixel.tweens.FlxTween;
import ui.HealthIcon;
import extensions.flixel.FlxTextExt;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import config.*;

using StringTools;

typedef GridParts = {
	var grid:FlxBackdrop;
	var gridOverlay:FlxBackdrop;
	var topFade:FlxSprite;
	var bottomFade:FlxSprite;
}

class ChartingState extends MusicBeatState
{

	public static inline final GRID_POSITION:Float = 200;
	public static inline final GRID_SIZE:Float = 40;
	public static inline final GRID_SPACING:Float = 5;
	public static inline final GRID_COUNT:Int = 3;

	public static inline final PLAYBACK_POSITION:Float = 160;

	public static inline final PLAYBACK_INFO_PADDING:Float = 5;

	public static inline final BACKGROUND_COLOR:FlxColor = 0xFF282434;
	public static inline final GRID_OVERLAY_COLOR:FlxColor = 0xFFB4A3CC;

	public static inline final TEXT_UPDATE_RATE:Float = 1/24;

	var notes:FlxTypedGroup<ChartingNote>;
	
	var vocals:FlxSound;
	var vocalsOther:FlxSound;

	var panel:Panel;
	var hotbar:Hotbar;

	var timeBox:Box;
	var timeBoxLeftText:FlxBitmapText;
	var timeBoxRightText:FlxBitmapText;
	var timeBoxShowTimecode:Bool = true;

	var beatBox:Box;
	var beatBoxLeftText:FlxBitmapText;
	var beatBoxRightText:FlxBitmapText;
	
	var stepBox:Box;
	var stepBoxLeftText:FlxBitmapText;
	var stepBoxRightText:FlxBitmapText;
	
	var textUpdateTimer:Float = 0;

	var grids:Array<GridParts> = [];
	var gridCursor:FlxSprite;
	var gridCursorIndex:Int = 0;

	var playerIcon:HealthIcon;
	var opponentIcon:HealthIcon;
	var eventIcon:FlxSprite;

	var camFollow:FlxObject;

	var previousReportedSongTime:Float = 0;

	override function create():Void{
		Config.setFramerate(120);
		FlxG.mouse.visible = true;

		final songName:String = "Fresh";

		if(Utils.exists(Paths.voices(songName, "Player"))){
			vocals = Utils.createPausedSound(Paths.voices(songName, "Player"));
			vocalsOther = Utils.createPausedSound(Paths.voices(songName, "Opponent"));
			
		}
		else if(Utils.exists(Paths.voices(songName))){
			vocals = Utils.createPausedSound(Paths.voices(songName));
			vocalsOther = new FlxSound();
		}
		else{
			vocals = new FlxSound();
			vocalsOther = new FlxSound();
		}

		FlxG.sound.playMusic(Paths.inst(songName), 0, false);
		FlxG.sound.music.pause();
		FlxG.sound.music.time = 0;
		FlxG.sound.music.volume = 1;

		Conductor.resetBPMChanges();
		Conductor.changeBPM(120);

		notes = new FlxTypedGroup<ChartingNote>();
		Paths.image("ui/notes/NOTE_assets");

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		bg.screenCenter();
		bg.color = BACKGROUND_COLOR;
		bg.scrollFactor.set(0, 0);

		var gridsUnderlay:FlxSprite = Utils.makeColoredSprite((GRID_COUNT * GRID_SIZE * 4) + (GRID_SPACING * (GRID_COUNT + 1)), 720, 0xFF8C8C8C);
		gridsUnderlay.x = GRID_POSITION - GRID_SPACING;
		gridsUnderlay.color = BACKGROUND_COLOR;
		gridsUnderlay.scrollFactor.set(0, 0);

		for(i in 0...GRID_COUNT){
			var gridParts:GridParts = {grid: null, gridOverlay: null, topFade: null, bottomFade: null};

			gridParts.grid = new FlxBackdrop(Paths.image("fpsPlus/editors/chart/grid"), Y);
			gridParts.grid.x = GRID_POSITION + (i * GRID_SIZE * 4) + (i * GRID_SPACING);
			gridParts.grid.antialiasing = false;
			gridParts.grid.scale.set(GRID_SIZE, GRID_SIZE);
			gridParts.grid.updateHitbox();
			gridParts.grid.scrollFactor.set(0, 1);
	
			gridParts.gridOverlay = new FlxBackdrop(Paths.image("fpsPlus/editors/chart/gridOverlay"), Y);
			gridParts.gridOverlay.x = gridParts.grid.x;
			gridParts.gridOverlay.y = (i%2) * GRID_SIZE * 4;
			gridParts.gridOverlay.antialiasing = false;
			gridParts.gridOverlay.color = GRID_OVERLAY_COLOR;
			gridParts.gridOverlay.blend = MULTIPLY;
			gridParts.gridOverlay.scale.set(gridParts.grid.width, gridParts.grid.width);
			gridParts.gridOverlay.updateHitbox();
			gridParts.gridOverlay.scrollFactor.set(0, 1);

			gridParts.topFade = new FlxSprite(gridParts.grid.x, 0).loadGraphic(Paths.image("fpsPlus/editors/chart/gridFade"));
			gridParts.topFade.scrollFactor.set(0, 0);

			gridParts.bottomFade = new FlxSprite(gridParts.grid.x, 720).loadGraphic(Paths.image("fpsPlus/editors/chart/gridFade"));
			gridParts.bottomFade.flipY = true;
			gridParts.bottomFade.y -= gridParts.bottomFade.height;
			gridParts.bottomFade.scrollFactor.set(0, 0);

			grids.push(gridParts);
		}

		var gridsBarSeperator:FlxBackdrop = new FlxBackdrop(Utils.makeColoredSprite(1, 1, 0xFF8C8C8C).graphic, Y, 0, (GRID_SIZE * 4) - 1);
		gridsBarSeperator.x = GRID_POSITION - GRID_SPACING;
		gridsBarSeperator.y -= 2;
		gridsBarSeperator.color = BACKGROUND_COLOR;
		gridsBarSeperator.scale.set((GRID_COUNT * GRID_SIZE * 4) + (GRID_SPACING * (GRID_COUNT + 1)), 4);
		gridsBarSeperator.updateHitbox();

		var gridsTopCover:FlxSprite = Utils.makeColoredSprite((GRID_COUNT * GRID_SIZE * 4) + (GRID_SPACING * (GRID_COUNT + 1)), (GRID_COUNT * GRID_SIZE * 8), 0xFF8C8C8C);
		gridsTopCover.x = GRID_POSITION - GRID_SPACING;
		gridsTopCover.y = -gridsTopCover.height;
		gridsTopCover.color = BACKGROUND_COLOR;

		playerIcon = new HealthIcon("bf", true);
		playerIcon.scrollFactor.set(0, 0);
		playerIcon.centerOrigin();
		playerIcon.scale.set(playerIcon.scale.x/2, playerIcon.scale.y/2);
		playerIcon.setPosition(grids[1].grid.x + grids[1].grid.width/2 - playerIcon.width/2, GRID_SIZE - playerIcon.height/2);

		opponentIcon = new HealthIcon("dad", false);
		opponentIcon.scrollFactor.set(0, 0);
		opponentIcon.centerOrigin();
		opponentIcon.scale.set(opponentIcon.scale.x/2, opponentIcon.scale.y/2);
		opponentIcon.setPosition(grids[0].grid.x + grids[0].grid.width/2 - opponentIcon.width/2, GRID_SIZE - opponentIcon.height/2);

		eventIcon = new FlxSprite().loadGraphic(Paths.image("chartEditor/event/genericEvent"));
		eventIcon.scrollFactor.set(0, 0);
		eventIcon.setPosition(grids[2].grid.x + grids[2].grid.width/2 - eventIcon.width/2, GRID_SIZE - eventIcon.height/2);

		gridCursor = Utils.makeColoredSprite(GRID_SIZE, GRID_SIZE, 0xFFFFFFFF);
		gridCursor.visible = false;

		var playbackBar:FlxSliceSprite = new FlxSliceSprite(Paths.image("fpsPlus/editors/chart/playbackBar"), new FlxRect(20, 20, 1, 20), 40 + (GRID_SIZE * 4 * GRID_COUNT) + (GRID_SPACING * (GRID_COUNT - 1)), 20);
		playbackBar.setPosition(GRID_POSITION-20, PLAYBACK_POSITION-10);
		playbackBar.color = UIColors.SELECTED_COLOR;
		playbackBar.scrollFactor.set(0, 0);

		var panelDropShadow:FlxSprite = new FlxSprite(805, 10).loadGraphic(Paths.image("fpsPlus/editors/chart/panelDropShadow"));
		panelDropShadow.alpha = 0.65;
		panelDropShadow.scrollFactor.set(0, 0);

		var toolbarDropShadow:FlxSprite = new FlxSprite(0, 30).loadGraphic(Paths.image("fpsPlus/editors/chart/toolbarDropShadow"));
		toolbarDropShadow.alpha = 0.65;
		toolbarDropShadow.scrollFactor.set(0, 0);

		panel = new Panel(835, 40, 400, 612, ["Song", "Notes", "Events", "Tools"], 40);
		panel.scrollFactor.set(0, 0);

		hotbar = new Hotbar(0, 60, 60, 60, 10, Y);
		hotbar.scrollFactor.set(0, 0);

		timeBox = new Box(panel.x, panel.y + panel.height - Box.BORDER_SIZE, 164, 30);
		timeBox.scrollFactor.set(0, 0);
		timeBox.onClick.add(function(){
			timeBoxShowTimecode = !timeBoxShowTimecode;
			FlxTween.color(null, 0.75, UIColors.SELECTED_COLOR, UIColors.FILL_COLOR, {ease: FlxEase.quadOut, onUpdate: function(tween:FlxTween){
				timeBox.fillColor = cast(tween, ColorTween).color;
			}});
		});
		timeBoxLeftText = new FlxBitmapText(timeBox.x + PLAYBACK_INFO_PADDING, timeBox.getMidpoint().y + 1, "Time:", FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		timeBoxLeftText.y -= timeBoxLeftText.height/2;
		timeBoxLeftText.scrollFactor.set(0, 0);
		timeBoxRightText = new FlxBitmapText(timeBox.x + PLAYBACK_INFO_PADDING, timeBox.getMidpoint().y + 1, "00000000000000000", FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		timeBoxRightText.y -= timeBoxLeftText.height/2;
		timeBoxRightText.scrollFactor.set(0, 0);

		beatBox = new Box(timeBox.x + timeBox.width - Box.BORDER_SIZE, panel.y + panel.height - Box.BORDER_SIZE, 120, 30);
		beatBox.scrollFactor.set(0, 0);
		beatBoxLeftText = new FlxBitmapText(beatBox.x + PLAYBACK_INFO_PADDING, beatBox.getMidpoint().y + 1, "Beat:", FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		beatBoxLeftText.y -= timeBoxLeftText.height/2;
		beatBoxLeftText.scrollFactor.set(0, 0);
		beatBoxRightText = new FlxBitmapText(beatBox.x + PLAYBACK_INFO_PADDING, beatBox.getMidpoint().y + 1, "00000000000000000", FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		beatBoxRightText.y -= timeBoxLeftText.height/2;
		beatBoxRightText.scrollFactor.set(0, 0);

		stepBox = new Box(beatBox.x + beatBox.width - Box.BORDER_SIZE, panel.y + panel.height - Box.BORDER_SIZE, 120, 30);
		stepBox.scrollFactor.set(0, 0);
		stepBoxLeftText = new FlxBitmapText(stepBox.x + PLAYBACK_INFO_PADDING, stepBox.getMidpoint().y + 1, "Step:", FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		stepBoxLeftText.y -= timeBoxLeftText.height/2;
		stepBoxLeftText.scrollFactor.set(0, 0);
		stepBoxRightText = new FlxBitmapText(stepBox.x + PLAYBACK_INFO_PADDING, stepBox.getMidpoint().y + 1, "00000000000000000", FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		stepBoxRightText.y -= timeBoxLeftText.height/2;
		stepBoxRightText.scrollFactor.set(0, 0);

		updateText();

		var testToggle:Toggle = new Toggle(5, 5, false, "Test Toggle");
		testToggle.onToggle.add(function(state:Bool){
			trace(state);
		});

		var testButton:Button = new Button(5, testToggle.y + testToggle.height + 5, 120, "Button");
		testButton.onPress.add(function(){
			trace("pressed");
		});

		panel.addToTab("Song", testToggle);
		panel.addToTab("Song", testButton);

		add(bg);
		add(gridsUnderlay);

		for(gridParts in grids){
			add(gridParts.grid);
			add(gridParts.gridOverlay);
		}

		add(gridCursor);

		add(gridsBarSeperator);
		add(notes);
		
		for(gridParts in grids){
			add(gridParts.topFade);
			add(gridParts.bottomFade);
		}
		
		add(gridsTopCover);

		add(playerIcon);
		add(opponentIcon);
		add(eventIcon);

		add(playbackBar);

		add(panelDropShadow);
		add(toolbarDropShadow);

		add(panel);
		add(hotbar);

		add(timeBox);
		add(timeBoxLeftText);
		add(timeBoxRightText);
		add(beatBox);
		add(beatBoxLeftText);
		add(beatBoxRightText);
		add(stepBox);
		add(stepBoxLeftText);
		add(stepBoxRightText);

		camFollow = new FlxObject(1280/2, 720/2, 0, 0);
		camFollow.y -= PLAYBACK_POSITION;
		camFollow.velocity.y = 0;
		FlxG.camera.follow(camFollow);

		add(camFollow);

		super.create();
	}

	override public function update(elapsed:Float):Void{

		//Update conductor.
		if(previousReportedSongTime != FlxG.sound.music.time){
			Conductor.songPosition = FlxG.sound.music.time;
			previousReportedSongTime = FlxG.sound.music.time;
		}
		else if(FlxG.sound.music.playing){
			Conductor.songPosition += FlxG.elapsed * 1000;
		}

		camFollow.y = getYFromSongPosition(Conductor.songPosition) + (720/2 - PLAYBACK_POSITION);

		//Check if the cursor is on a grid.
		gridCursor.visible = false;
		gridCursorIndex = -1;
		for(i in 0...grids.length){
			if(FlxG.mouse.x >= grids[i].grid.x && FlxG.mouse.x < grids[i].grid.x + grids[i].grid.width){
				gridCursorIndex = i;
			}
		}

		//Update the grid cursor position and do note place checks.
		if(gridCursorIndex >= 0){
			gridCursor.visible = true;
			var gridLane:Int = Math.floor((FlxG.mouse.x - grids[gridCursorIndex].grid.x) / GRID_SIZE);
			gridCursor.x = grids[gridCursorIndex].grid.x + gridLane * GRID_SIZE;

			if(FlxG.keys.anyPressed([SHIFT])){
				gridCursor.y = FlxG.mouse.y;
			}
			else if(FlxG.keys.anyPressed([CONTROL])){
				gridCursor.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / 2)) * (GRID_SIZE / 2);
			}
			else{
				gridCursor.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
			}


			if(gridCursorIndex < 2){ //Placing notes.
				if(FlxG.mouse.justPressed){
					addNote(getSongPositionFromY(gridCursor.y), gridLane, gridCursorIndex == 1);
				}
				else if(FlxG.mouse.justPressedRight){
					removeNotesInProximity(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridLane, gridCursorIndex == 1, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
				}
			}
			else{ //Placing events.
				if(FlxG.mouse.justPressed){
					trace("Event\t" + getSongPositionFromY(gridCursor.y));
				}
			}
		}

		//Play/pause music.
		if(FlxG.keys.anyJustPressed([SPACE])){
			if(!FlxG.sound.music.playing){
				playMusic();
			}
			else{
				pauseMusic();
			}
		}

		//Scroll with W and S
		if(FlxG.keys.anyPressed([W, S])){
			pauseMusic();
			final scrollAmount:Float = (FlxG.keys.anyPressed([SHIFT]) ? 2500 : 1000) * FlxG.elapsed;
			FlxG.sound.music.time += ((FlxG.keys.anyPressed([W]) ? -1 : 0) + (FlxG.keys.anyPressed([S]) ? 1 : 0)) * scrollAmount;
			musicBoundsCheck();
		}

		//Scroll through the song with mouse wheel.
		if(FlxG.mouse.wheel != 0){
			pauseMusic();
			final wheelSpin = FlxG.mouse.wheel;
			FlxG.sound.music.time = Math.round(FlxG.sound.music.time / (Conductor.stepCrochet/2)) * (Conductor.stepCrochet/2); //Snap to nearest half step.
			FlxG.sound.music.time -= (wheelSpin * Conductor.stepCrochet * 0.5);
			musicBoundsCheck();
		}

		//Hotbar shortcuts.
		if(FlxG.keys.anyJustPressed([ONE]))		{ hotbar.selectSlot(0); }
		if(FlxG.keys.anyJustPressed([TWO]))		{ hotbar.selectSlot(1); }
		if(FlxG.keys.anyJustPressed([THREE]))	{ hotbar.selectSlot(2); }
		if(FlxG.keys.anyJustPressed([FOUR]))	{ hotbar.selectSlot(3); }
		if(FlxG.keys.anyJustPressed([FIVE]))	{ hotbar.selectSlot(4); }
		if(FlxG.keys.anyJustPressed([SIX]))		{ hotbar.selectSlot(5); }
		if(FlxG.keys.anyJustPressed([SEVEN]))	{ hotbar.selectSlot(6); }
		if(FlxG.keys.anyJustPressed([EIGHT]))	{ hotbar.selectSlot(7); }
		if(FlxG.keys.anyJustPressed([NINE]))	{ hotbar.selectSlot(8); }
		if(FlxG.keys.anyJustPressed([ZERO]))	{ hotbar.selectSlot(9); }

		if(FlxG.keys.anyJustPressed([TAB]))	{ panel.changeTab((panel.selectedTab + 1) % panel.tabs.length); }

		super.update(elapsed);

		textUpdateTimer += elapsed;
		if(textUpdateTimer >= TEXT_UPDATE_RATE){
			updateText();
			textUpdateTimer = 0;
		}
	};

	override function beatHit():Void{
		super.beatHit();
	}

	override function stepHit():Void{
		super.stepHit();
	}

	function addNote(strumTime:Float, direction:Int, player:Bool):Void{
		removeNotesInProximity(strumTime, direction, player);

		var newNote:ChartingNote = new ChartingNote(gridCursor.x, gridCursor.y, direction, strumTime, player);
		notes.add(newNote);
		trace("adding " + newNote.time);

		notes.members.sort(sortNotes);
	}

	function sortNotes(a:ChartingNote, b:ChartingNote):Int{
		var r:Int = 0;
		r = FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		if(r == 0){
			r = FlxSort.byValues(FlxSort.ASCENDING, a.direction, b.direction);
		}
		if(r == 0){
			r = FlxSort.byValues(FlxSort.ASCENDING, a.player ? 1 : 0, b.player ? 1 : 0);
		}
		return r;
	}

	function removeNotesInProximity(strumTime:Float, direction:Int, player:Bool, region:Float = 5){
		var removeList:Array<ChartingNote> = [];
		for(note in notes.members){
			if(note.player == player && note.direction == direction){
				if(Utils.inRange(note.time, strumTime, region)){
					removeList.push(note);
				}
			}
		}
		for(note in removeList){
			trace("removing " + note.time);
			notes.remove(note, true);
			note.destroy();
		}
	}

	function updateText():Void{
		var textToUpdate:String = Math.floor(Conductor.songPosition/1000) + "/" + Math.floor(FlxG.sound.music.length/1000);
		if(timeBoxShowTimecode){
			textToUpdate = convertSecondsToTime(Conductor.songPosition/1000);
		}
		if(fixRightAlignText(textToUpdate) != timeBoxRightText.text){
			timeBoxRightText.text = fixRightAlignText(textToUpdate);
			timeBoxRightText.x = timeBox.x + timeBox.width + PLAYBACK_INFO_PADDING - timeBoxRightText.width;
		}
		var textToUpdate:String = ""+curBeat;
		if(fixRightAlignText(textToUpdate) != beatBoxRightText.text){
			beatBoxRightText.text = fixRightAlignText(textToUpdate);
			beatBoxRightText.x = beatBox.x + beatBox.width + PLAYBACK_INFO_PADDING - beatBoxRightText.width;
		}
		var textToUpdate:String = ""+curStep;
		if(fixRightAlignText(textToUpdate) != stepBoxRightText.text){
			stepBoxRightText.text = fixRightAlignText(textToUpdate);
			stepBoxRightText.x = stepBox.x + stepBox.width + PLAYBACK_INFO_PADDING - stepBoxRightText.width;
		}
	}

	inline function pauseMusic():Void{
		FlxG.sound.music.pause();
		vocals.pause();
		vocalsOther.pause();
	}

	inline function playMusic():Void{
		vocals.time = FlxG.sound.music.time;
		vocalsOther.time = FlxG.sound.music.time;
		FlxG.sound.music.play();
		vocals.play();
		vocalsOther.play();
	}

	//To fix weird text alignment issues I made ~ invisible and use it as a padding character. Yay.
	inline function fixRightAlignText(string:String):String{
		return string + "~";
	}

	//TODO: Make it support BPM changes.
	function getSongPositionFromY(yPos:Float):Float{
		return (yPos / GRID_SIZE) * Conductor.stepCrochet;
	}

	//TODO: Make it support BPM changes.
	function getYFromSongPosition(songPosition:Float):Float{
		return (songPosition / Conductor.stepCrochet) * GRID_SIZE;
	}

	function musicBoundsCheck():Void{
		if(FlxG.sound.music.time < 0){ FlxG.sound.music.time = 0; }
		if(FlxG.sound.music.time > FlxG.sound.music.length){ FlxG.sound.music.time = FlxG.sound.music.length; }
	}

	function convertSecondsToTime(time:Float):String{
		var minutes:String = ""+Math.floor(time/60);
		var seconds:String = ""+Math.floor(time%60);
		var decimal:String = ""+truncateFloat(time - Math.floor(time), 2);

		if(decimal.contains(".")){
			decimal = decimal.split(".")[1];
			while(decimal.length < 2){ decimal += "0"; }
		}
		else{
			decimal = "00";
		}

		var r:String = "";
		if(minutes != "0"){
			r += minutes + ":";
			while(seconds.length < 2){ seconds = "0"+seconds; }
		}
		r += '$seconds.$decimal';

		return r;
	}

	function truncateFloat( number:Float, precision:Int):Float{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num)/Math.pow(10, precision);
		return num;
	}
	
}