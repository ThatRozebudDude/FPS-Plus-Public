package editors.chart;

import Chart.EventFormat;
import openfl.Assets;
import stages.ScriptableStage;
import characters.CharacterInfoBase;
import characters.ScriptableCharacter;
import modding.ScriptingUtil.BlendMode;
import Chart.ChartFormat;
import Chart.NoteDefinition;
import Chart.EventDefinition;
import Chart.BPMDefinition;
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

//Used for undo/redo stuff.
typedef ChartSnapshot = {
	var notes:Array<NoteDefinition>;
	var events:Array<EventDefinition>;
	var bpmChanges:Array<BPMDefinition>;
	var action:UndoAction;
}

//All the different actions that can be captured by the chart snapshot.
enum UndoAction {
	NONE; //Used for the intial state or when the action type isn't needed like building the inital chart.
	PLACE_NOTES(count:Int);
	REMOVE_NOTES(count:Int);
	CUT;
	PASTE;
	CHANGE_HOLD_DURATION;
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

	public static inline final POPUP_SPACING:Float = 12;

	var characterList:Array<String> = [];
	var gfList:Array<String> = [];
	var stageList:Array<String> = [];

	public var chart:ChartFormat;
	public var chartEvents:EventFormat;

	var startPosition:Float = 0;

	var notes:FlxTypedGroup<ChartingNote>;
	var events:FlxTypedGroup<ChartingEvent>;
	
	var previousSong:String = null;
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
	var gridSnapDivisor:Null<Float> = 1;
	var gridCenterPosition:Float = 0;

	var playerIcon:HealthIcon;
	var opponentIcon:HealthIcon;
	var eventIcon:FlxSprite;

	var camFollow:FlxObject;

	var previousReportedSongTime:Float = -1;

	var placedNoteHold:Bool = false;
	var selectedNotes:Array<ChartingNote> = [];

	var selectedEvents:Array<ChartingEvent> = [];

	var selectionBoxOpen:Bool = false;
	var selectionBox:Box;
	var selectionStartY:Float = 0;
	var startingGrid:Int = -1;
	var selectingBoth:Bool = false;

	var copiedNoteData:Array<NoteDefinition> = [];
	var copyingBoth:Bool = false;

	var playerHitSoundToggle:Toggle;
	var opponentHitSoundToggle:Toggle;

	var gridSnapDropdown:Dropdown;

	var lilBuddiesEnabled:Bool = false;
	var lilGuy:Character;
	var lilBf:Character;

	var noteTypeInput:TextInput;

	var popupGroup:FlxTypedGroup<Popup>;
	
	var undoHistory:Array<ChartSnapshot> = [];
	var redoHistory:Array<ChartSnapshot> = [];
	var currentState:ChartSnapshot;

	override public function new(_startPosition:Float = 0){
		super();
		startPosition = Math.max(_startPosition, 0);
	}

	override function create():Void{
		Config.setFramerate(120);
		FlxG.mouse.visible = false;

		generateLists();

		if(PlayState.chart == null){
			PlayState.chart = Chart.getEmptyChart();
		}
		chart = PlayState.chart;

		if(PlayState.events == null){
			PlayState.events = Chart.getEmptyEvents();
		}
		chartEvents = PlayState.events;

		notes = new FlxTypedGroup<ChartingNote>();
		Paths.image("ui/notes/NOTE_assets");

		events = new FlxTypedGroup<ChartingEvent>();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		bg.screenCenter();
		bg.color = BACKGROUND_COLOR;
		bg.scrollFactor.set(0, 0);

		editorCursor = new Cursor();

		var gridsUnderlay:FlxSprite = Utils.makeColoredSprite((GRID_COUNT * GRID_SIZE * 4) + (GRID_SPACING * (GRID_COUNT + 1)), 720, 0xFF8C8C8C);
		gridsUnderlay.x = GRID_POSITION - GRID_SPACING;
		gridsUnderlay.color = BACKGROUND_COLOR;
		gridsUnderlay.scrollFactor.set(0, 0);

		gridCenterPosition = gridsUnderlay.getMidpoint().x;

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

		popupGroup = new FlxTypedGroup<Popup>();

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
		add(events);
		add(selectionBox);
		
		for(gridParts in grids){
			add(gridParts.topFade);
			add(gridParts.bottomFade);
		}
		
		add(gridsTopCover);

		add(playerIcon);
		add(opponentIcon);
		add(eventIcon);

		add(popupGroup);

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
		updateHealthIcons(chart.meta.opponent, chart.meta.player, true);
		setCurrentState(NONE);
		
		super.create();

		add(editorCursor);
	}

	function setupSongTab():Void{
		var songNameInput:TextInput = new TextInput(PANEL_SPACING, PANEL_SPACING, 192, chart.meta.song, "Song");
		songNameInput.onValueChanged.add(function(v:String){
			if(v == previousSong){ return; }
			pauseMusic();
			if(setMusic(v)){
				chart.meta.song = v;
			}
			else{
				songNameInput.value = previousSong;
			}
		});
		var baseBpmInput:Stepper = new Stepper(PANEL_SPACING, songNameInput.y + songNameInput.elementHeight + PANEL_SPACING, 120, chart.meta.bpm[0].bpm, 1, 1, null, true, "Song BPM");

		var opponentDropdown:Dropdown = new Dropdown(PANEL_SPACING, baseBpmInput.y + baseBpmInput.elementHeight + PANEL_EXTRA_SPACING, 192, characterList, chart.meta.opponent, "Opponent");
		opponentDropdown.onSelect.add(function(v:String){
			updateHealthIcons(v, chart.meta.player);
			chart.meta.opponent = v;
		});
		var playerDropown:Dropdown = new Dropdown(PANEL_SPACING, opponentDropdown.y + opponentDropdown.elementHeight + PANEL_SPACING, 192, characterList, chart.meta.player, "Player");
		playerDropown.onSelect.add(function(v:String){
			updateHealthIcons(chart.meta.opponent, v);
			chart.meta.player = v;
		});
		var speakerDropdown:Dropdown = new Dropdown(PANEL_SPACING, playerDropown.y + playerDropown.elementHeight + PANEL_SPACING, 192, gfList, chart.meta.speaker, "Partner");
		speakerDropdown.onSelect.add(function(v:String){ chart.meta.speaker = v; });
		var stageDropdown:Dropdown = new Dropdown(PANEL_SPACING, speakerDropdown.y + speakerDropdown.elementHeight + PANEL_EXTRA_SPACING, 192, stageList, chart.meta.stage, "Stage");
		stageDropdown.onSelect.add(function(v:String){ chart.meta.stage = v; });

		panel.addToTab("Song", songNameInput);
		panel.addToTab("Song", baseBpmInput);
		panel.addToTab("Song", opponentDropdown);
		panel.addToTab("Song", playerDropown);
		panel.addToTab("Song", speakerDropdown);
		panel.addToTab("Song", stageDropdown);
	}

	function setupNotesTab():Void{
		//Temp for now, just so it exists.
		noteTypeInput = new TextInput(PANEL_SPACING, PANEL_SPACING, 336, "", "Tag");

		panel.addToTab("Notes", noteTypeInput);
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
		playerHitSoundToggle = new Toggle(PANEL_SPACING, opponentHitSoundToggle.y + opponentHitSoundToggle.elementHeight + PANEL_SPACING, false, "Player Hitsound");
		
		var instrumentalToggle:Toggle = new Toggle(PANEL_SPACING, playerHitSoundToggle.y + playerHitSoundToggle.elementHeight + PANEL_EXTRA_SPACING, true, "Instrumental");
		instrumentalToggle.onToggle.add(function(value:Bool){ FlxG.sound.music.volume = value ? 1 : 0; });

		var playerVoxToggle:Toggle = new Toggle(PANEL_SPACING, instrumentalToggle.y + instrumentalToggle.elementHeight + PANEL_SPACING, true, "Player Vocals");
		playerVoxToggle.onToggle.add(function(value:Bool){ vocals.volume = value ? 1 : 0; });

		var opponentVoxToggle:Toggle = new Toggle(PANEL_SPACING, playerVoxToggle.y + playerVoxToggle.elementHeight + PANEL_SPACING, true, "Opponent Vocals");
		opponentVoxToggle.onToggle.add(function(value:Bool){ vocalsOther.volume = value ? 1 : 0; });

		//idk if this is the way i want to do this or not yet
		gridSnapDropdown = new Dropdown(PANEL_SPACING, opponentVoxToggle.y + opponentVoxToggle.elementHeight + PANEL_EXTRA_SPACING, 196, ["1/16th Note", "1/32nd Note", "1/64th Note", "1/16th Triplet", "1/32nd Triplet", "1/64th Triplet", "Free"], "1/16th Note", "Grid Snap");
		gridSnapDropdown.onSelect.add(function(v:String){ setGridSnap(v); });

		var playbackRate:Stepper = new Stepper(PANEL_SPACING, gridSnapDropdown.y + gridSnapDropdown.elementHeight + PANEL_EXTRA_SPACING, 100, 1, 0.1, 0.1, 1, true, "Playback Rate");
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
		panel.addToTab("Tools", gridSnapDropdown);
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
			if(gridSnapDivisor != null){
				gridCursor.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / gridSnapDivisor)) * (GRID_SIZE / gridSnapDivisor);
			}
			else{
				gridCursor.y = FlxG.mouse.y;
			}

			if(gridCursorIndex < 2){ //Placing notes.
				if(FlxG.mouse.justPressed && !FlxG.keys.anyPressed([SHIFT]) && !panel.isAnythingFocused()){
					var newNote = addNote(getSongPositionFromY(gridCursor.y), gridCursorLane, gridCursorIndex == 1, noteTypeInput.value);
					selectedNotes = [newNote];
					placedNoteHold = true;
				}
				else if(FlxG.mouse.justPressedRight && !FlxG.keys.anyPressed([SHIFT])  && !panel.isAnythingFocused()){
					var deleteCount:Int = removeNotesInProximity(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, gridCursorIndex == 1, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
					selectedNotes = [];
					if(deleteCount > 0){ createSnapshot(REMOVE_NOTES(deleteCount)); }
				}
				else if(FlxG.mouse.justPressedMiddle && !panel.isAnythingFocused()){
					if(!FlxG.keys.anyPressed([SHIFT])){ selectedNotes = []; }
					var note:ChartingNote = getNoteUnderCursor();
					if(note != null && !selectedNotes.contains(note)){
						selectedNotes.push(note);
						noteTypeInput.value = note.tag;
					}
					else if(note != null && selectedNotes.contains(note)){ selectedNotes.remove(note); }
					else if(note == null){
						noteTypeInput.value = "";
					}
				}
			}
			else{ //Placing events.
				if(FlxG.mouse.justPressed && !panel.isAnythingFocused()){
					trace("Event\t" + getSongPositionFromY(gridCursor.y));
				}
			}
		}

		if(placedNoteHold && !FlxG.mouse.released && selectedNotes.length > 0){
			var sustainLength:Int = FlxMath.maxInt(Math.round((gridCursor.y - selectedNotes[0].y) / GRID_SIZE), 0);
			if(selectedNotes[0].sustainLength != sustainLength){ selectedNotes[0].sustainLength = sustainLength; }
		}
		else if(placedNoteHold){
			placedNoteHold = false;
			createSnapshot(PLACE_NOTES(1));
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
				notes.forEachAlive(function(note:ChartingNote){
					if(note.time >= selectionStartTime && note.time < selectionEndTime){
						if(selectingBoth || ((!note.player && startingGrid == 0) || (note.player && startingGrid == 1))){
							selectedNotes.push(note);
						}
					}
				});
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

		notes.forEachAlive(function(note:ChartingNote){
			if(selectedNotes.contains(note)){ note.select(); }
			else{ note.deselect(); }
		});

		if(FlxG.sound.music.playing){
			notes.forEachAlive(function(note:ChartingNote){
				if(note.time >= previousSongPosition && note.time < Conductor.songPosition){
					if((note.player && playerHitSoundToggle.state) || (!note.player && opponentHitSoundToggle.state)){
						var tickSound:FlxSound = FlxG.sound.play(Paths.sound("tick"), 1);
						tickSound.pan = (playerHitSoundToggle.state && opponentHitSoundToggle.state) ? 0.2 * (note.player ? 1 : -1) : 0;
						tickSound.pitch = (playerHitSoundToggle.state && opponentHitSoundToggle.state) ? (note.player ? 1.15 : 0.85) : 1;
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
			});
		}

		popupGroup.forEachDead(function(popup:Popup):Void{
			popupGroup.remove(popup, true);
		});

		for(i in 0...popupGroup.members.length){
			popupGroup.members[i].wantedY = 720 - (popupGroup.members[i].elementHeight + POPUP_SPACING) * (popupGroup.members.length - i);
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
		setMusic(chart.meta.song);

		Conductor.resetBPMChanges();
		Conductor.setBPMChanges(chart.meta.bpm);

		var snapshot:ChartSnapshot = {notes: chart.notes, events: chartEvents.events, bpmChanges: chart.meta.bpm, action: NONE};
		rebuildChartFromSnapshot(snapshot);
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

		//Next/previous section.
		if(FlxG.keys.anyJustPressed([D])){
			if(FlxG.sound.music.playing){ pauseMusic(); }
			FlxG.sound.music.time = getSongPositionFromY((Math.floor(getYFromSongPosition(FlxG.sound.music.time) / (GRID_SIZE * 16)) * (GRID_SIZE * 16)) + (GRID_SIZE * 16));
			musicBoundsCheck();
		}
		if(FlxG.keys.anyJustPressed([A])){
			if(FlxG.sound.music.playing){ pauseMusic(); }
			FlxG.sound.music.time = getSongPositionFromY((Math.floor(getYFromSongPosition(FlxG.sound.music.time) / (GRID_SIZE * 16)) * (GRID_SIZE * 16)) - (GRID_SIZE * 16));
			musicBoundsCheck();
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
			var deleteCount:Int = 0;
			while(selectedNotes.length > 0){
				removeNotesInProximity(selectedNotes[0].time, selectedNotes[0].direction, selectedNotes[0].player, 1);
				deleteCount++;
			}
			selectedNotes = [];
			if(deleteCount > 0){
				createPopup("Deleted " + deleteCount + " note" + (deleteCount==1?".":"s."));
				createSnapshot(REMOVE_NOTES(deleteCount));
			}
		}

		//Cycle panel tabs.
		if(FlxG.keys.anyJustPressed([TAB]))		{ panel.changeTab((panel.selectedTab + 1) % panel.tabs.length); }

		//Grid snap.
		if(FlxG.keys.anyJustPressed([LEFT])){
			gridSnapDropdown.currentIndex -= 1;
			if(gridSnapDropdown.currentIndex < 0){ gridSnapDropdown.currentIndex = gridSnapDropdown.values.length-1; }
			setGridSnap(gridSnapDropdown.values[gridSnapDropdown.currentIndex]);
		}
		if(FlxG.keys.anyJustPressed([RIGHT])){
			gridSnapDropdown.currentIndex += 1;
			if(gridSnapDropdown.currentIndex >= gridSnapDropdown.values.length){ gridSnapDropdown.currentIndex = 0; }
			setGridSnap(gridSnapDropdown.values[gridSnapDropdown.currentIndex]);
		}

		//Undo Redo
		if(FlxG.keys.anyJustPressed([Z]) && FlxG.keys.anyPressed([CONTROL]))		{ undo(); }
		else if(FlxG.keys.anyJustPressed([Y]) && FlxG.keys.anyPressed([CONTROL]))	{ redo(); }

		//Copy Cut Paste
		if(FlxG.keys.anyJustPressed([C]) && FlxG.keys.anyPressed([CONTROL])){
			if(gridCursorIndex < 2){
				copyNotes();
				createPopup("Copied " + copiedNoteData.length + " note" + (copiedNoteData.length==1?".":"s."));
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
				createPopup("Cut " + copiedNoteData.length + " note" + (copiedNoteData.length==1?".":"s."));
				if(copiedNoteData.length > 0){ createSnapshot(CUT); }
			}
			else{
				//Event stuff later
			}
		}
		else if(FlxG.keys.anyJustPressed([V]) && FlxG.keys.anyPressed([CONTROL]) && gridCursorIndex >= 0){
			if(gridCursorIndex < 2){
				if(placedNoteHold){
					placedNoteHold = false;
					createSnapshot(PLACE_NOTES(1));
				}
				if(copiedNoteData.length > 0){
					selectedNotes = [];
					for(noteData in copiedNoteData){
						if(!copyingBoth){
							var newNote = addNote(noteData.time + getSongPositionFromY(gridCursor.y), noteData.direction, gridCursorIndex == 1, noteData.tag);
							newNote.sustainLength = noteData.length;
							selectedNotes.push(newNote);
						}
						else{
							var newNote = addNote(noteData.time + getSongPositionFromY(gridCursor.y), noteData.direction, noteData.player, noteData.tag);
							newNote.sustainLength = noteData.length;
							selectedNotes.push(newNote);
						}
					}
				}
				createPopup("Pasted " + copiedNoteData.length + " note" + (copiedNoteData.length==1?".":"s."));
				createSnapshot(PASTE);
				
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
			createSnapshot(CHANGE_HOLD_DURATION);
		}
		else if(FlxG.keys.anyJustPressed([Q])){
			for(note in selectedNotes){
				var sustainLength:Int = note.sustainLength;
				sustainLength = FlxMath.maxInt(sustainLength-1, 0);
				note.sustainLength = sustainLength;
			}
			createSnapshot(CHANGE_HOLD_DURATION);
		}
	}

	//Note stuff.

	function addNote(strumTime:Float, direction:Int, player:Bool, tag:String = ""):ChartingNote{
		removeNotesInProximity(strumTime, direction, player);

		var newNote = notes.recycle(ChartingNote);
		newNote.updateProperties(grids[player?1:0].grid.x + (GRID_SIZE * direction), getYFromSongPosition(strumTime), direction, strumTime, player, tag);
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
		notes.forEachAlive(function(note:ChartingNote){
			if((player == null || note.player == player) && (direction == null || note.direction == direction)){
				if(Utils.inRange(note.time, strumTime, region)){ r.push(note); }
			}
		});
		return r;
	}

	function removeNotesInProximity(strumTime:Float, direction:Int, player:Bool, region:Float = 5):Int{
		var removeList:Array<ChartingNote> = getNotesInRegion(strumTime, direction, player, region);
		for(note in removeList){
			if(selectedNotes.contains(note)){ selectedNotes.remove(note); }
			note.kill();
		}
		return removeList.length;
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
			copiedNoteData.push(note.generateNoteDefinition());
		}
		var startTime = copiedNoteData[0].time;
		for(data in copiedNoteData){
			data.time -= startTime;
		}
		copyingBoth = hasPlayer && hasOpponent;
	}

	//Event stuff.

	function addEvent(strumTime:Float, lane:Int, tag:String = ""):ChartingEvent{
		//removeNotesInProximity(strumTime, direction, player);

		var newEvent = events.recycle(ChartingEvent);
		newEvent.updateProperties(grids[2].grid.x + (GRID_SIZE * lane), getYFromSongPosition(strumTime), lane, strumTime, tag);
		events.members.sort(sortEvents);
		
		return newEvent;
	}

	function sortEvents(a:ChartingEvent, b:ChartingEvent):Int{
		var r:Int = 0;
		r = FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		if(r == 0){
			r = FlxSort.byValues(FlxSort.ASCENDING, a.lane, b.lane);
		}
		return r;
	}

	function getEventsInRegion(strumTime:Float, lane:Null<Int>, region:Float = 5):Array<ChartingEvent>{
		var r:Array<ChartingEvent> = [];
		events.forEachAlive(function(event:ChartingEvent){
			if(lane == null || event.lane == lane){
				if(Utils.inRange(event.time, strumTime, region)){ r.push(event); }
			}
		});
		return r;
	}

	function removeEventsInProximity(strumTime:Float, lane:Int, region:Float = 5):Int{
		var removeList:Array<ChartingEvent> = getEventsInRegion(strumTime, lane, region);
		for(event in removeList){
			if(selectedEvents.contains(event)){ selectedEvents.remove(event); }
			event.kill();
		}
		return removeList.length;
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
		notes.forEachAlive(function(note:ChartingNote){
			chart.notes.push(note.generateNoteDefinition());
		});
	}
	
	function generateLists():Void{
		characterList = [];
		gfList = [];
		stageList = [];

		for(className in ScriptableCharacter.listScriptClasses()){
			var pushedName:String = className;
			if(className.contains("characters.")){
				pushedName = className.split("characters.")[1];
			}
			var getScriptInfo:CharacterInfoBase = ScriptableCharacter.scriptInit(className);
			if(getScriptInfo.includeInCharacterList){ characterList.push(pushedName); }
			if(getScriptInfo.includeInGfList){ gfList.push(pushedName); }
		}

		for(className in ScriptableStage.listScriptClasses()){
			var pushedName:String = className;
			if(className.contains("stages.")){
				pushedName = className.split("stages.")[1];
			}
			stageList.push(pushedName);
		}

		//makes them be in alphabetical order
		characterList.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});
		gfList.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});
		
		stageList.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});
	}

	function updateHealthIcons(opponentCharacter:String, playerCharacter:String, force:Bool = false):Void{
		if(opponentCharacter != chart.meta.opponent || force){
			var oppClassName:String = "characters."+opponentCharacter;
			#if BACKWARD_COMPATIBILITY
			if(!ScriptableCharacter.listScriptClasses().contains(oppClassName)){
				oppClassName = opponentCharacter;
			}
			#end

			var opp:CharacterInfoBase = ScriptableCharacter.scriptInit(oppClassName);

			opponentIcon.setIconCharacter(opp.info.iconName);
			opponentIcon.scrollFactor.set(0, 0);
			opponentIcon.centerOrigin();
			opponentIcon.scale.set(opponentIcon.scale.x/2, opponentIcon.scale.y/2);
			opponentIcon.setPosition(grids[0].grid.x + grids[0].grid.width/2 - opponentIcon.width/2, GRID_SIZE - opponentIcon.height/2);
		}

		if(playerCharacter != chart.meta.player || force){
			var playerCharClassName:String = "characters."+playerCharacter;
			#if BACKWARD_COMPATIBILITY
			if(!ScriptableCharacter.listScriptClasses().contains(playerCharClassName)){
				playerCharClassName = playerCharacter;
			}
			#end
			
			var player:CharacterInfoBase = ScriptableCharacter.scriptInit(playerCharClassName);

			playerIcon.setIconCharacter(player.info.iconName);
			playerIcon.scrollFactor.set(0, 0);
			playerIcon.centerOrigin();
			playerIcon.scale.set(playerIcon.scale.x/2, playerIcon.scale.y/2);
			playerIcon.setPosition(grids[1].grid.x + grids[1].grid.width/2 - playerIcon.width/2, GRID_SIZE - playerIcon.height/2);
		}
	}

	function setMusic(song:String):Bool{
		if(Utils.exists(Paths.inst(song))){
			if(previousSong != null){
				Assets.cache.removeSound(Paths.voices(previousSong, "Player"));
				Assets.cache.removeSound(Paths.voices(previousSong, "Opponent"));
				Assets.cache.removeSound(Paths.voices(previousSong));
				Assets.cache.removeSound(Paths.inst(previousSong));

				vocals.destroy();
				vocalsOther.destroy();
			}
		
			if(Utils.exists(Paths.voices(song, "Player"))){
				vocals = Utils.createPausedSound(Paths.voices(song, "Player"));
				vocalsOther = Utils.createPausedSound(Paths.voices(song, "Opponent"));
			}
			else if(Utils.exists(Paths.voices(song))){
				vocals = Utils.createPausedSound(Paths.voices(song));
				vocalsOther = new FlxSound();
			}
			else{
				vocals = new FlxSound();
				vocalsOther = new FlxSound();
			}
	
			FlxG.sound.playMusic(Paths.inst(song), 0, false);
			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 1;

			previousSong = song;
			createPopup("Loaded audio for \"" + song + "\".", 2);
			Utils.gc();

			return true;
		}

		createPopup("Audio for \"" + song + "\" could not be found.", 2);
		return false;
	}

	function setGridSnap(value:String):Void{
		switch(value){
			case "Free":
				gridSnapDivisor = null;

			case "1/32nd Note":
				gridSnapDivisor = 2;

			case "1/64th Note":
				gridSnapDivisor = 4;

			case "1/16th Triplet":
				gridSnapDivisor = 3/4;

			case "1/32nd Triplet":
				gridSnapDivisor = 6/4;
			
			case "1/64th Triplet":
				gridSnapDivisor = 12/4;

			default:
				gridSnapDivisor = 1;
		}

		createPopup("Grid Snap set to " + value + (value=="Free"?".":"s."), 2);
	}

	function createPopup(text:String, time:Float = 1.5):Void{
		var popup = new Popup(0, 720, text, time);
		popup.scrollFactor.set(0, 0);
		popup.screenCenter(X);
		popup.x -= (1280/2) - gridCenterPosition;
		popup.setWantedToPosition();
		popupGroup.add(popup);
	}

	function setCurrentState(type:UndoAction):Void{
		var noteData:Array<NoteDefinition> = [];
		notes.forEachAlive(function(note:ChartingNote){
			noteData.push(note.generateNoteDefinition());
		});

		var eventData:Array<EventDefinition> = [];
		events.forEachAlive(function(event:EventDefinition){
			eventData.push(event.generateEventDefinition());
		});

		currentState = {notes: noteData, events: eventData, bpmChanges: [], action: type};
	}

	function createSnapshot(type:UndoAction):Void{
		undoHistory.push(currentState);
		setCurrentState(type);
		redoHistory = [];
	}

	function undo():Void{
		if(undoHistory.length <= 0){
			createPopup("Nothing to undo.", 1);
			return;
		}

		var snapshot:ChartSnapshot = undoHistory.pop();
		rebuildChartFromSnapshot(snapshot);

		var actionText:String = getUndoActionText(currentState.action);
		createPopup("Undo"+(actionText.length>0?" ":"")+actionText+".", 1);

		redoHistory.push(currentState);
		currentState = snapshot;
		selectedNotes = [];
	}

	function redo():Void{
		if(redoHistory.length <= 0){
			createPopup("Nothing to redo.", 1);
			return;
		}

		var snapshot:ChartSnapshot = redoHistory.pop();
		rebuildChartFromSnapshot(snapshot);

		var actionText:String = getUndoActionText(snapshot.action);
		createPopup("Redo"+(actionText.length>0?" ":"")+actionText+".", 1);

		undoHistory.push(currentState);
		currentState = snapshot;
		selectedNotes = [];
	}

	function rebuildChartFromSnapshot(snapshot:ChartSnapshot){
		notes.killMembers();
		for(noteData in snapshot.notes){
			var newNote = addNote(noteData.time, noteData.direction, noteData.player, noteData.tag);
			newNote.sustainLength = noteData.length;
		}

		events.killMembers();
		for(eventData in snapshot.events){
			var newNote = addEvent(eventData.time, eventData.lane, eventData.tag);
		}
	}

	inline function getUndoActionText(action:UndoAction):String{
		switch(action){
			case PLACE_NOTES(count): return "placed note"+(count==1?"":"s");
			case REMOVE_NOTES(count): return "deleted note"+(count==1?"":"s");
			case CUT: return "cut";
			case PASTE: return "paste";
			case CHANGE_HOLD_DURATION: return "duration change";
			default: return "";
		}
	}
	
}