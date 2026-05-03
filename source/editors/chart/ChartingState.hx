package editors.chart;

import characters.ScriptableCharacter;
import modding.ScriptingUtil.BlendMode;
import Chart.ChartFormat;
import Chart.NoteDefinition;
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
import caching.*;

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

	public static inline final PANEL_SPACING:Float = 5;
	public static inline final PANEL_EXTRA_SPACING:Float = 22;

	public var chart:ChartFormat;
	var startPosition:Float = 0;

	var notes:FlxTypedGroup<ChartingNote>;
	
	var vocals:FlxSound;
	var vocalsOther:FlxSound;
	var previousSongPosition:Float = 0;

	var allowGridScroll:Bool = true;
	var panel:Panel;
	var hotbar:Hotbar;
	var editorCursor:Cursor;

	var timeBox:Box;
	var timeBoxLeftText:UIText;
	var timeBoxRightText:UIText;
	var timeBoxShowTimecode:Bool = true;

	var beatBox:Box;
	var beatBoxLeftText:UIText;
	var beatBoxRightText:UIText;
	
	var stepBox:Box;
	var stepBoxLeftText:UIText;
	var stepBoxRightText:UIText;
	
	var textUpdateTimer:Float = 0;

	var grids:Array<GridParts> = [];
	var gridCursor:FlxSprite;
	var gridCursorIndex:Int = -1;
	var lastGridCursorIndex:Int = -1;
	var gridCursorLane:Int = -1;
	var lastGridCursorLane:Int = -1;

	var playerIcon:HealthIcon;
	var opponentIcon:HealthIcon;
	var eventIcon:FlxSprite;

	var camFollow:FlxObject;

	var previousReportedSongTime:Float = -1;

	var placedNoteHold:Bool = false;
	var selectedNotes:Array<ChartingNote> = [];

	var selectionBoxOpen:Bool = false;
	var selectionBox:Box;
	var selectionStartY:Float = 0;
	var startingGrid:Int = -1;
	var selectingBoth:Bool = false;

	var copiedNoteData:Array<NoteDefinition> = [];
	var copyingBoth:Bool = false;

	var playerHitSoundToggle:Toggle;
	var opponentHitSoundToggle:Toggle;

	var lilBuddiesEnabled:Bool = false;
	var lilGuy:Character;
	var lilBf:Character;

	override public function new(_startPosition:Float = 0){
		super();
		startPosition = Math.max(_startPosition, 0);
	}

	override function create():Void{
		Config.setFramerate(120);
		FlxG.mouse.visible = false;

		if(PlayState.chart == null){
			PlayState.chart = Chart.getEmptyChart();
		}

		chart = PlayState.chart;

		notes = new FlxTypedGroup<ChartingNote>();
		Paths.image("ui/notes/NOTE_assets");

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		bg.screenCenter();
		bg.color = BACKGROUND_COLOR;
		bg.scrollFactor.set(0, 0);

		editorCursor = new Cursor();

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

		selectionBox = new Box(GRID_POSITION, 0, GRID_SIZE * 4, GRID_SIZE);
		selectionBox.fillColor = UIColors.SELECTED_COLOR;
		selectionBox.borderColor = 0xFF0078D7;
		selectionBox.alpha = 0.3;
		selectionBox.blend = BlendMode.MULTIPLY;
		selectionBox.visible = false;

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
		panel.onOverlap.add(function(){ allowGridScroll = false; });
		panel.onOverlapStop.add(function(){ allowGridScroll = true; });
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
		timeBoxLeftText = new UIText(timeBox.x + PLAYBACK_INFO_PADDING, timeBox.getMidpoint().y, "Time:");
		timeBoxLeftText.y -= timeBoxLeftText.height/2;
		timeBoxLeftText.scrollFactor.set(0, 0);
		timeBoxRightText = new UIText(timeBox.x + PLAYBACK_INFO_PADDING, timeBox.getMidpoint().y, "");
		timeBoxRightText.y -= timeBoxLeftText.height/2;
		timeBoxRightText.scrollFactor.set(0, 0);

		beatBox = new Box(timeBox.x + timeBox.width - Box.BORDER_SIZE, panel.y + panel.height - Box.BORDER_SIZE, 120, 30);
		beatBox.scrollFactor.set(0, 0);
		beatBoxLeftText = new UIText(beatBox.x + PLAYBACK_INFO_PADDING, beatBox.getMidpoint().y, "Beat:");
		beatBoxLeftText.y -= timeBoxLeftText.height/2;
		beatBoxLeftText.scrollFactor.set(0, 0);
		beatBoxRightText = new UIText(beatBox.x + PLAYBACK_INFO_PADDING, beatBox.getMidpoint().y, "");
		beatBoxRightText.y -= timeBoxLeftText.height/2;
		beatBoxRightText.scrollFactor.set(0, 0);

		stepBox = new Box(beatBox.x + beatBox.width - Box.BORDER_SIZE, panel.y + panel.height - Box.BORDER_SIZE, 120, 30);
		stepBox.scrollFactor.set(0, 0);
		stepBoxLeftText = new UIText(stepBox.x + PLAYBACK_INFO_PADDING, stepBox.getMidpoint().y, "Step:");
		stepBoxLeftText.y -= timeBoxLeftText.height/2;
		stepBoxLeftText.scrollFactor.set(0, 0);
		stepBoxRightText = new UIText(stepBox.x + PLAYBACK_INFO_PADDING, stepBox.getMidpoint().y, "");
		stepBoxRightText.y -= timeBoxLeftText.height/2;
		stepBoxRightText.scrollFactor.set(0, 0);

		loadChart();
		FlxG.sound.music.time = startPosition;

		updateText();

		setupSongTab();
		setupNotesTab();
		setupEventsTab();
		setupToolsTab();

		add(bg);
		add(gridsUnderlay);

		for(gridParts in grids){
			add(gridParts.grid);
			add(gridParts.gridOverlay);
		}

		add(gridCursor);

		add(gridsBarSeperator);
		add(notes);
		add(selectionBox);
		
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

		add(editorCursor);
	}

	function setupSongTab():Void{
		var songNameInput:TextInput = new TextInput(PANEL_SPACING, PANEL_SPACING, 192, chart.meta.song, "Song Name");
		var baseBpmInput:Stepper = new Stepper(PANEL_SPACING, songNameInput.y + songNameInput.elementHeight + PANEL_SPACING, 120, chart.meta.bpm[0].bpm, 1, 1, null, true, "Song BPM");

		var opponentDropdown:Dropdown = new Dropdown(5, baseBpmInput.y + baseBpmInput.elementHeight + PANEL_EXTRA_SPACING, 192, ["Bf", "Dad", "Gf", "Pico"], "Dad", "Opponent");
		var playerDropown:Dropdown = new Dropdown(5, opponentDropdown.y + opponentDropdown.elementHeight + PANEL_SPACING, 192, ["Bf", "Dad", "Gf", "Pico"], "Bf", "Player");
		var speakerDropdown:Dropdown = new Dropdown(5, playerDropown.y + playerDropown.elementHeight + PANEL_SPACING, 192, ["Bf", "Dad", "Gf", "Pico"], "Gf", "Partner");

		panel.addToTab("Song", songNameInput);
		panel.addToTab("Song", baseBpmInput);
		panel.addToTab("Song", opponentDropdown);
		panel.addToTab("Song", playerDropown);
		panel.addToTab("Song", speakerDropdown);
	}

	function setupNotesTab():Void{
		var testToggle:Toggle = new Toggle(PANEL_SPACING, PANEL_SPACING, false, "Note Toggle");
		testToggle.onToggle.add(function(state:Bool){
			trace(state);
		});

		panel.addToTab("Notes", testToggle);
	}
	
	function setupEventsTab():Void{
		var testToggle:Toggle = new Toggle(PANEL_SPACING, PANEL_SPACING, false, "Test Toggle");
		testToggle.onToggle.add(function(state:Bool){
			trace(state);
		});

		var testButton:Button = new Button(PANEL_SPACING, testToggle.y + testToggle.elementHeight + PANEL_SPACING, 144, "Button");
		testButton.onPress.add(function(){
			trace("pressed");
		});

		var testDropdown:Dropdown = new Dropdown(PANEL_SPACING, testButton.y + testButton.elementHeight + PANEL_SPACING, 144, ["Bf", "Dad", "Gf", "Pico", "Pico2", "Pico3", "Pico4", "Pico5", "Pico6", "Pico7", "Pico8", "Pico9", "Pico10"], "Bf", "Test Dropdown");

		var testDropdown2:Dropdown = new Dropdown(PANEL_SPACING, testDropdown.y + testDropdown.elementHeight + PANEL_SPACING, 144, ["Bf", "Dad", "Gf", "Pico"], "Dad", "Test Dropdown 2");

		var testStepper:Stepper = new Stepper(PANEL_SPACING, testDropdown2.y + testDropdown2.elementHeight + PANEL_SPACING, 144, 120, 1, 1, null, true, "Test Stepper");

		var testStepper2:Stepper = new Stepper(PANEL_SPACING, testStepper.y + testStepper.elementHeight + PANEL_SPACING, 144, 80, 0.5, 70, 90, false, "Test Stepper 2");

		var testTextInput:TextInput = new TextInput(PANEL_SPACING, testStepper2.y + testStepper2.elementHeight + PANEL_SPACING, 144, "Fresh", "Test Text Input");
		testTextInput.onValueChanged.add(function(v:String){
			trace("value changed to " + v);
		});
		
		var testTextInput2:TextInput = new TextInput(PANEL_SPACING, testTextInput.y + testTextInput.elementHeight + PANEL_SPACING, 144, "Text", "Test Text Input 2");
		testTextInput2.onValueChanged.add(function(v:String){
			trace("value changed 2  " + v);
		});

		panel.addToTab("Events", testToggle);
		panel.addToTab("Events", testButton);
		panel.addToTab("Events", testDropdown);
		panel.addToTab("Events", testDropdown2);
		panel.addToTab("Events", testStepper);
		panel.addToTab("Events", testStepper2);
		panel.addToTab("Events", testTextInput);
		panel.addToTab("Events", testTextInput2);
	}

	function setupToolsTab():Void{
		opponentHitSoundToggle = new Toggle(PANEL_SPACING, PANEL_SPACING, false, "Opponent Hitsound");
		playerHitSoundToggle = new Toggle(PANEL_SPACING, opponentHitSoundToggle.y + opponentHitSoundToggle.height + PANEL_SPACING, false, "Player Hitsound");
		
		var instrumentalToggle:Toggle = new Toggle(PANEL_SPACING, playerHitSoundToggle.y + playerHitSoundToggle.height + PANEL_EXTRA_SPACING, true, "Instrumental");
		instrumentalToggle.onToggle.add(function(value:Bool){ FlxG.sound.music.volume = value ? 1 : 0; });

		var playerVoxToggle:Toggle = new Toggle(PANEL_SPACING, instrumentalToggle.y + instrumentalToggle.height + PANEL_SPACING, true, "Player Vocals");
		playerVoxToggle.onToggle.add(function(value:Bool){ vocals.volume = value ? 1 : 0; });

		var opponentVoxToggle:Toggle = new Toggle(PANEL_SPACING, playerVoxToggle.y + playerVoxToggle.height + PANEL_SPACING, true, "Opponent Vocals");
		opponentVoxToggle.onToggle.add(function(value:Bool){ vocalsOther.volume = value ? 1 : 0; });

		var playbackRate:Stepper = new Stepper(PANEL_SPACING, opponentVoxToggle.y + opponentVoxToggle.height + PANEL_EXTRA_SPACING, 100, 1, 0.1, 0.1, 1, true, "Playback Rate");
		playbackRate.onValueChanged.add(function(value:Float){
			FlxG.sound.music.pitch = value;
			vocals.pitch = value;
			vocalsOther.pitch = value;
			syncMusic();
		});

		panel.addToTab("Tools", opponentHitSoundToggle);
		panel.addToTab("Tools", playerHitSoundToggle);
		panel.addToTab("Tools", instrumentalToggle);
		panel.addToTab("Tools", playerVoxToggle);
		panel.addToTab("Tools", opponentVoxToggle);
		panel.addToTab("Tools", playbackRate);
		
		if(ScriptableCharacter.listScriptClasses().contains("characters.BfLil") && ScriptableCharacter.listScriptClasses().contains("characters.GuyLil")){
			lilBuddiesEnabled = true;

			var lilStage:FlxSprite = new FlxSprite(139, 314).loadGraphic(Paths.image("chartEditor/lilStage"));
			lilStage.antialiasing = false;
			lilGuy = new Character(139, 314, "GuyLil", false, false);
			lilBf = new Character(139, 314, "BfLil", false, false);
			lilBf.setFlipX(false);
			lilBf.swapLeftAndRightAnimations();
			
			panel.addToTab("Tools", lilStage);
			panel.addToTab("Tools", lilGuy);
			panel.addToTab("Tools", lilBf);
		}
	}

	override public function update(elapsed:Float):Void{
		FlxG.mouse.visible = false;

		//Update conductor.
		if(previousReportedSongTime != FlxG.sound.music.time){
			Conductor.songPosition = FlxG.sound.music.time;
			previousReportedSongTime = FlxG.sound.music.time;
		}
		else if(FlxG.sound.music.playing){
			Conductor.songPosition += FlxG.elapsed * 1000 * FlxG.sound.music.pitch;
		}

		camFollow.y = Conductor.step * GRID_SIZE + (720/2 - PLAYBACK_POSITION);

		/*if(FlxG.keys.anyPressed([SHIFT])){
			editorCursor.selection();
		}
		else{
			editorCursor.idle();
		}*/

		//Check if the cursor is on a grid.
		gridCursor.visible = false;
		gridCursorIndex = -1;
		for(i in 0...grids.length){
			if(FlxG.mouse.x >= grids[i].grid.x && FlxG.mouse.x < grids[i].grid.x + grids[i].grid.width){
				gridCursorIndex = i;
				lastGridCursorIndex = gridCursorIndex;
			}
		}

		//Update the grid cursor position and do note place checks.
		gridCursorLane = -1;
		if(gridCursorIndex >= 0){
			gridCursor.visible = true && !selectionBoxOpen;
			gridCursorLane = Math.floor((FlxG.mouse.x - grids[gridCursorIndex].grid.x) / GRID_SIZE);
			lastGridCursorLane = gridCursorLane;
			gridCursor.x = grids[gridCursorIndex].grid.x + gridCursorLane * GRID_SIZE;

			/*if(FlxG.keys.anyPressed([SHIFT])){
				gridCursor.y = FlxG.mouse.y;
			}*/
			if(FlxG.keys.anyPressed([CONTROL])){
				gridCursor.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / 2)) * (GRID_SIZE / 2);
			}
			else{
				gridCursor.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
			}

			if(gridCursorIndex < 2){ //Placing notes.
				if(FlxG.mouse.justPressed && !FlxG.keys.anyPressed([SHIFT]) && !panel.isAnythingFocused()){
					var newNote = addNote(getSongPositionFromY(gridCursor.y), gridCursorLane, gridCursorIndex == 1);
					selectedNotes = [newNote];
					placedNoteHold = true;
				}
				else if(FlxG.mouse.justPressedRight && !FlxG.keys.anyPressed([SHIFT])  && !panel.isAnythingFocused()){
					removeNotesInProximity(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, gridCursorIndex == 1, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
					selectedNotes = [];
				}
				else if(FlxG.mouse.justPressedMiddle && !panel.isAnythingFocused()){
					if(!FlxG.keys.anyPressed([SHIFT])){ selectedNotes = []; }
					var note:ChartingNote = getNoteUnderCursor();
					if(note != null && !selectedNotes.contains(note)){ selectedNotes.push(note); }
					else if(note != null && selectedNotes.contains(note)){ selectedNotes.remove(note); }
				}
			}
			else{ //Placing events.
				if(FlxG.mouse.justPressed && !panel.isAnythingFocused()){
					trace("Event\t" + getSongPositionFromY(gridCursor.y));
				}
			}
		}

		if(placedNoteHold && !FlxG.mouse.released && selectedNotes.length > 0){
			var sustainLength:Int = FlxMath.maxInt(Math.floor((gridCursor.y - selectedNotes[0].y) / GRID_SIZE), 0);
			if(selectedNotes[0].sustainLength != sustainLength){ selectedNotes[0].sustainLength = sustainLength; }
		}
		else{
			placedNoteHold = false;
		}

		if(!selectionBoxOpen && FlxG.mouse.justPressed && FlxG.keys.anyPressed([SHIFT]) && !panel.isAnythingFocused() && gridCursorIndex >= 0){
			selectionBoxOpen = true;
			startingGrid = gridCursorIndex;
			selectionBox.x = grids[startingGrid].grid.x;
			selectionStartY = FlxG.mouse.y;
			selectionBox.y = selectionStartY;
			selectionBox.visible = true;
		}
		else if(selectionBoxOpen && FlxG.mouse.justReleased){
			selectionBoxOpen = false;
			selectionBox.visible = false;
			selectedNotes = [];
			var selectionStartTime:Float = getSongPositionFromY(selectionBox.y - GRID_SIZE);
			var selectionEndTime:Float = getSongPositionFromY(selectionBox.y + selectionBox.height);
			
			if(startingGrid < 2){
				for(note in notes){
					if(note.time > selectionEndTime){ break; }
					else if(note.time >= selectionStartTime){
						if(selectingBoth || ((!note.player && startingGrid == 0) || (note.player && startingGrid == 1)))
						selectedNotes.push(note);
					}
				}
			}
			else{
				//Event stuff later.
			}
		}

		if(selectionBoxOpen){
			var boxHeight:Float = FlxG.mouse.y - selectionStartY;
			selectionBox.y = boxHeight >= 0 ? selectionStartY : FlxG.mouse.y;
			selectionBox.height = Math.max(1, Math.abs(boxHeight));

			if(startingGrid < 2){
				if((startingGrid == 0 && lastGridCursorIndex > startingGrid) || lastGridCursorIndex < startingGrid){
					selectingBoth = true;
					selectionBox.x = GRID_POSITION;
					selectionBox.width = GRID_SIZE * 8 + GRID_SPACING;
				}
				else{
					selectingBoth = false;
					selectionBox.x = grids[startingGrid].grid.x;
					selectionBox.width = GRID_SIZE * 4;
				}
			}
			else{
				selectionBox.width = GRID_SIZE * 4;
			}
		}

		//Play/pause music.
		if(FlxG.keys.anyJustPressed([SPACE]) && !panel.isAnythingFocused()){
			if(!FlxG.sound.music.playing){
				playMusic();
			}
			else{
				pauseMusic();
			}
		}

		//Scroll with W and S
		if(FlxG.keys.anyPressed([W, S]) && !panel.isAnythingFocused()){
			pauseMusic();
			final scrollAmount:Float = (FlxG.keys.anyPressed([SHIFT]) ? 2500 : 1000) * FlxG.elapsed;
			FlxG.sound.music.time += ((FlxG.keys.anyPressed([W]) ? -1 : 0) + (FlxG.keys.anyPressed([S]) ? 1 : 0)) * scrollAmount;
			musicBoundsCheck();
		}

		//Scroll through the song with mouse wheel.
		if(FlxG.mouse.wheel != 0 && allowGridScroll && !panel.isAnythingFocused()){
			pauseMusic();
			final wheelSpin = FlxG.mouse.wheel;
			FlxG.sound.music.time = Math.round(FlxG.sound.music.time / (Conductor.getStepCrotchetMs()/2)) * (Conductor.getStepCrotchetMs()/2); //Snap to nearest half step.
			FlxG.sound.music.time -= (wheelSpin * Conductor.getStepCrotchetMs() * 0.5);
			musicBoundsCheck();
		}

		//Playtest song on PlayState.
		if(FlxG.keys.anyJustPressed([ENTER]) && !panel.isAnythingFocused()){
			pauseMusic();
			generateChart();
			
			if(FlxG.keys.pressed.CONTROL){
				PlayState.sectionStart = true;
				PlayState.sectionStartTime = FlxG.sound.music.time;
			}

			PlayState.setSong(chart, PlayState.events);
			PlayState.fromChartEditor = true;
			ImageCache.refreshLocal();
			switchState(new PlayState());
		}

		if(!panel.isAnythingFocused()){ checkShortcuts(); }

		for(note in notes){
			if(selectedNotes.contains(note)){
				note.select();
			}
			else{
				note.deselect();
			}
		}

		if(FlxG.sound.music.playing){
			for(note in notes){
				if(note.time >= previousSongPosition && note.time < Conductor.songPosition){
					if((note.player && playerHitSoundToggle.state) || (!note.player && opponentHitSoundToggle.state)){
						var tickSound:FlxSound = FlxG.sound.play(Paths.sound("tick"), 0.8);
						tickSound.pan = (playerHitSoundToggle.state && opponentHitSoundToggle.state) ? 0.15 * (note.player ? 1 : -1) : 0;
					}

					if(lilBuddiesEnabled){
						var character:Character = note.player ? lilBf : lilGuy;
						switch(note.direction){
							case 0:
								character.singAnim("singLEFT", true);
							case 1:
								character.singAnim("singDOWN", true);
							case 2:
								character.singAnim("singUP", true);
							case 3:
								character.singAnim("singRIGHT", true);
						}
					}
				}
			}
		}

		super.update(elapsed);

		textUpdateTimer += elapsed;
		if(textUpdateTimer >= TEXT_UPDATE_RATE){
			updateText();
			textUpdateTimer = 0;
		}

		previousSongPosition = Conductor.songPosition;
	};

	function loadChart():Void{
		if(Utils.exists(Paths.voices(chart.meta.song, "Player"))){
			vocals = Utils.createPausedSound(Paths.voices(chart.meta.song, "Player"));
			vocalsOther = Utils.createPausedSound(Paths.voices(chart.meta.song, "Opponent"));
		}
		else if(Utils.exists(Paths.voices(chart.meta.song))){
			vocals = Utils.createPausedSound(Paths.voices(chart.meta.song));
			vocalsOther = new FlxSound();
		}
		else{
			vocals = new FlxSound();
			vocalsOther = new FlxSound();
		}

		FlxG.sound.playMusic(Paths.inst(chart.meta.song), 0, false);
		FlxG.sound.music.pause();
		FlxG.sound.music.volume = 1;

		Conductor.resetBPMChanges();
		Conductor.setBPMChanges(chart.meta.bpm);

		notes.forEach(function(note:ChartingNote){
			note.destroy();
		});
		notes.clear();

		for(noteData in chart.notes){
			var newNote = addNote(noteData.time, noteData.direction, noteData.player, noteData.tag);
			newNote.sustainLength = noteData.length;
		}
	}

	override function beatHit():Void{
		super.beatHit();
	}

	override function stepHit():Void{
		super.stepHit();
	}

	function checkShortcuts():Void{
		//To top of section/song.
		if(FlxG.keys.anyJustPressed([R])){
			if(FlxG.sound.music.playing){ pauseMusic(); }
			if(FlxG.keys.anyPressed([CONTROL])){
				FlxG.sound.music.time = 0;
			}
			else{
				FlxG.sound.music.time = getSongPositionFromY(Math.floor(getYFromSongPosition(FlxG.sound.music.time) / (GRID_SIZE * 16)) * (GRID_SIZE * 16));
			}
		}

		//Hotbar select.
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

		//Delete selected notes.
		if(FlxG.keys.anyJustPressed([DELETE])){
			while(selectedNotes.length > 0){
				removeNotesInProximity(selectedNotes[0].time, selectedNotes[0].direction, selectedNotes[0].player, 1);
			}
			selectedNotes = [];
		}

		//Cycle panel tabs.
		if(FlxG.keys.anyJustPressed([TAB]))		{ panel.changeTab((panel.selectedTab + 1) % panel.tabs.length); }

		//Undo Redo
		if(FlxG.keys.anyJustPressed([Z]) && FlxG.keys.anyPressed([CONTROL])){
			//gulp
		}
		else if(FlxG.keys.anyJustPressed([Y]) && FlxG.keys.anyPressed([CONTROL])){
			//gulp
		}

		//Copy Cut Paste
		if(FlxG.keys.anyJustPressed([C]) && FlxG.keys.anyPressed([CONTROL])){
			if(gridCursorIndex < 2){
				copyNotes();
			}
			else{
				//Event stuff later
			}
		}
		else if(FlxG.keys.anyJustPressed([X]) && FlxG.keys.anyPressed([CONTROL])){
			if(gridCursorIndex < 2){
				copyNotes();
				while(selectedNotes.length > 0){
					removeNotesInProximity(selectedNotes[0].time, selectedNotes[0].direction, selectedNotes[0].player, 1);
				}
				selectedNotes = [];
			}
			else{
				//Event stuff later
			}
		}
		else if(FlxG.keys.anyJustPressed([V]) && FlxG.keys.anyPressed([CONTROL]) && gridCursorIndex >= 0){
			if(gridCursorIndex < 2){
				if(copiedNoteData.length > 0){
					selectedNotes = [];
					for(noteData in copiedNoteData){
						if(!copyingBoth){
							var newNote = addNote(noteData.time + getSongPositionFromY(gridCursor.y), noteData.direction, gridCursorIndex == 1);
							newNote.sustainLength = noteData.length;
							selectedNotes.push(newNote);
						}
						else{
							var newNote = addNote(noteData.time + getSongPositionFromY(gridCursor.y), noteData.direction, noteData.player);
							newNote.sustainLength = noteData.length;
							selectedNotes.push(newNote);
						}
					}
				}
			}
			else{
				//Event stuff later
			}
		}

		//Adjust Sustain Length
		if(FlxG.keys.anyJustPressed([E])){
			for(note in selectedNotes){
				var sustainLength:Int = note.sustainLength;
				sustainLength = FlxMath.maxInt(sustainLength+1, 0);
				note.sustainLength = sustainLength;
			}
		}
		else if(FlxG.keys.anyJustPressed([Q])){
			for(note in selectedNotes){
				var sustainLength:Int = note.sustainLength;
				sustainLength = FlxMath.maxInt(sustainLength-1, 0);
				note.sustainLength = sustainLength;
			}
		}
	}

	function addNote(strumTime:Float, direction:Int, player:Bool, tag:String = ""):ChartingNote{
		removeNotesInProximity(strumTime, direction, player);

		var newNote:ChartingNote = new ChartingNote(grids[player?1:0].grid.x + (GRID_SIZE * direction), getYFromSongPosition(strumTime), direction, strumTime, player, tag);
		notes.add(newNote);
		notes.members.sort(sortNotes);
		
		return newNote;
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

	function getNotesInRegion(strumTime:Float, direction:Null<Int>, player:Null<Bool>, region:Float = 5):Array<ChartingNote>{
		var r:Array<ChartingNote> = [];
		for(note in notes.members){
			if(note.time > strumTime + region){ break; }
			if((player == null || note.player == player) && (direction == null || note.direction == direction)){
				if(Utils.inRange(note.time, strumTime, region)){ r.push(note); }
			}
		}
		return r;
	}

	function removeNotesInProximity(strumTime:Float, direction:Int, player:Bool, region:Float = 5):Void{
		var removeList:Array<ChartingNote> = getNotesInRegion(strumTime, direction, player, region);
		for(note in removeList){
			if(selectedNotes.contains(note)){ selectedNotes.remove(note); }
			trace("removing " + note.time);
			notes.remove(note, true);
			note.destroy();
		}
	}

	function getNoteUnderCursor():ChartingNote{
		var eligibleNotes:Array<ChartingNote> = getNotesInRegion(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, gridCursorIndex > 0, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
		if(eligibleNotes.length == 0){ return null; }
		eligibleNotes.sort(function(a:ChartingNote, b:ChartingNote):Int{
			return Math.abs(a.time - getSongPositionFromY(FlxG.mouse.y)) < Math.abs(b.time - getSongPositionFromY(FlxG.mouse.y)) ? -1 : 1;
		});
		return eligibleNotes[0];
	}

	function copyNotes():Void{
		var hasPlayer:Bool = false;
		var hasOpponent:Bool = false;
		copiedNoteData = [];
		for(note in selectedNotes){
			hasPlayer = hasPlayer || note.player;
			hasOpponent = hasOpponent || !note.player;
			copiedNoteData.push(note.generateNoteDefiniton());
		}
		var startTime = copiedNoteData[0].time;
		for(data in copiedNoteData){
			data.time -= startTime;
		}
		copyingBoth = hasPlayer && hasOpponent;
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
		syncMusic();
		FlxG.sound.music.play();
		vocals.play();
		vocalsOther.play();
	}

	inline function syncMusic():Void{
		vocals.time = FlxG.sound.music.time;
		vocalsOther.time = FlxG.sound.music.time;
	}

	//To fix weird text alignment issues I made ~ invisible and use it as a padding character. Yay.
	inline function fixRightAlignText(string:String):String{
		return string + "~";
	}

	function getSongPositionFromY(yPos:Float):Float{
		var stepNum:Float = yPos / GRID_SIZE;
		return Conductor.getTimeFromStep(stepNum);
	}

	function getYFromSongPosition(songPosition:Float):Float{
		var stepNum = Conductor.getStepFromTime(songPosition);
		return stepNum * GRID_SIZE;
	}

	function musicBoundsCheck():Void{
		if(FlxG.sound.music.time < 0){ FlxG.sound.music.time = 0; }
		if(FlxG.sound.music.time > FlxG.sound.music.length){ FlxG.sound.music.time = FlxG.sound.music.length; }
	}

	function convertSecondsToTime(time:Float):String{
		var minutes:String = ""+Math.floor(time/60);
		var seconds:String = ""+Math.floor(time%60);
		var decimal:String = ""+Utils.truncateFloat(time - Math.floor(time), 2);

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

	function generateChart():Void{
		chart.notes = [];
		notes.forEach(function(note:ChartingNote){
			chart.notes.push(note.generateNoteDefiniton());
		});
	}
	
}