package editors.chart;

import note.NoteType;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import events.Events;
import haxe.Json;
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

typedef ArgumentInput = {
	var elements:Array<FlxSprite>;
	var value:String;
	var defaultValue:String;
}

typedef HotbarSlot = {
	var type:HotbarSlotType;
	var tag:String;
}

typedef TagBuilderSection = {
	var section:String;
	var makeBlank:Bool;
}

//All the different actions that can be captured by the chart snapshot.
enum UndoAction {
	NONE; //Used for the intial state or when the action type isn't needed like building the inital chart.
	PLACE_NOTES(count:Int);
	REMOVE_NOTES(count:Int);
	CHANGE_HOLD_DURATION;
	CHANGE_NOTE_TAG;
	PLACE_EVENTS(count:Int);
	REMOVE_EVENTS(count:Int);
	CHANGE_EVENT_TAG;
	PLACE_BPM(count:Int);
	REMOVE_BPM(count:Int);
	CUT;
	PASTE;
}

enum abstract HotbarSlotType(String) from String to String {
	var empty;
	var note;
	var event;
}

class ChartingState extends MusicBeatState
{

	public static inline final GRID_POSITION:Float = 180;
	public static inline final GRID_SIZE:Float = 40;
	public static inline final GRID_SPACING:Float = 5;
	public static inline final GRID_COUNT:Int = 4;
	public static final 	   GRID_SQAURES:Array<Int> = [1, 4, 4, 4];

	public static inline final PLAYBACK_POSITION:Float = 160;

	public static inline final PLAYBACK_INFO_PADDING:Float = 5;

	public static inline final BACKGROUND_COLOR:FlxColor = 0xFF282434;
	public static inline final GRID_OVERLAY_COLOR:FlxColor = 0xFFB4A3CC;

	public static inline final TEXT_UPDATE_RATE:Float = 1/24;

	public static inline final PANEL_SPACING:Float = 5;
	public static inline final PANEL_EXTRA_SPACING:Float = 22;

	public static inline final ALERT_SPACING:Float = 12;

	public static inline final BPM_GRID:Int = 0;
	public static inline final OPPONENT_GRID:Int = 1;
	public static inline final PLAYER_GRID:Int = 2;
	public static inline final EVENT_GRID:Int = 3;

	public static var eventIconList:Array<String>;
	public static var eventIconOverrides:Map<String, String>;

	var fileReference:FileReference;

	var characterList:Array<String> = [];
	var gfList:Array<String> = [];
	var stageList:Array<String> = [];
	var eventPrefixes:Array<String> = [""];
	var noteTypePrefixes:Array<String> = [""];

	public var chart:ChartFormat;
	public var chartEvents:EventFormat;

	var startPosition:Float = 0;

	var notes:FlxTypedGroup<ChartingNote>;
	var events:FlxTypedGroup<ChartingEvent>;
	var bpmChanges:FlxTypedGroup<ChartingBPM>;
	
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

	var previousSustainLength:Int = -1;
	var placedNoteHold:Bool = false;

	var currentlySelectingEvents:Bool = false;
	var selectedNotes:Array<ChartingNote> = [];
	var selectedEvents:Array<ChartingEvent> = [];

	var selectionBoxOpen:Bool = false;
	var selectionBox:Box;
	var selectionStartY:Float = 0;
	var startingGrid:Int = -1;
	var selectingBoth:Bool = false;

	var currentlyCopyingEvents:Bool = false;

	var copiedNoteData:Array<NoteDefinition> = [];
	var copyingBoth:Bool = false;

	var copiedEventData:Array<EventDefinition> = [];

	var playerHitSoundToggle:Toggle;
	var opponentHitSoundToggle:Toggle;

	var gridSnapDropdown:Dropdown;
	var difficultyDropdown:Dropdown;

	var lilBuddiesEnabled:Bool = false;
	var lilGuy:Character;
	var lilBf:Character;

	var noteTypeInput:TextInput;
	var notePrefixDropdown:Dropdown;
	var noteParams:Array<ArgumentInput> = [];
	var noteParamStartLocation:Float = 0;
	var noteDescription:UIText;

	var eventTagInput:TextInput;
	var eventPrefixDropdown:Dropdown;
	var eventParams:Array<ArgumentInput> = [];
	var eventParamStartLocation:Float = 0;
	var eventDescription:UIText;

	var alertGroup:FlxTypedGroup<Alert>;
	var typeAlert:Alert;
	
	static inline final UNDO_LIMIT:Int = 128;
	var undoHistory:Array<ChartSnapshot> = [];
	var redoHistory:Array<ChartSnapshot> = [];
	var currentState:ChartSnapshot;

	var hotbarAssignOverlay:FlxSprite;
	var hotbarAssignPanel:Panel;
	var hotbarAssignText:UIText;
	var hotbarAssignAlertOpen:Bool = false;
	var hotbarAssignAlertForNote:Bool = false;

	static var hotbarSlots:Array<HotbarSlot> = [{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""},{type:empty,tag:""}];
	var hotbarSlotNotes:Array<ChartingNote> = [];
	var hotbarSlotEvents:Array<ChartingEvent> = [];

	var topOverlay:FlxSprite;
	var bpmChangePanel:Panel;
	var bpmChangeBoxOpen:Bool = false;
	var bpmChangeTime:Float = 0;
	var bpmInput:Stepper;

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

		bpmChanges = new FlxTypedGroup<ChartingBPM>();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		bg.screenCenter();
		bg.color = BACKGROUND_COLOR;
		bg.scrollFactor.set(0, 0);

		editorCursor = new Cursor();

		var gridTotal:Float = 0;
		for(s in GRID_SQAURES){ gridTotal += s; }

		var gridsUnderlay:FlxSprite = Utils.makeColoredSprite((gridTotal * GRID_SIZE) + (GRID_SPACING * (GRID_COUNT + 1)), 720, 0xFF8C8C8C);
		gridsUnderlay.x = GRID_POSITION - GRID_SPACING;
		gridsUnderlay.color = BACKGROUND_COLOR;
		gridsUnderlay.scrollFactor.set(0, 0);

		gridCenterPosition = gridsUnderlay.getMidpoint().x;

		var moveOverTotal:Float = 0;
		for(i in 0...GRID_COUNT){
			var gridParts:GridParts = {grid: null, gridOverlay: null, topFade: null, bottomFade: null};

			gridParts.grid = new FlxBackdrop(Paths.image("fpsPlus/editors/chart/grid" + (GRID_SQAURES[i] == 4 ? "" : "Small")), Y);
			gridParts.grid.x = GRID_POSITION + (moveOverTotal * GRID_SIZE) + (i * GRID_SPACING);
			gridParts.grid.antialiasing = false;
			gridParts.grid.scale.set(GRID_SIZE, GRID_SIZE);
			gridParts.grid.updateHitbox();
			gridParts.grid.scrollFactor.set(0, 1);
	
			gridParts.gridOverlay = new FlxBackdrop(Paths.image("fpsPlus/editors/chart/gridOverlay"), Y);
			gridParts.gridOverlay.x = gridParts.grid.x;
			gridParts.gridOverlay.y = ((i+OPPONENT_GRID)%2) * GRID_SIZE * 4;
			gridParts.gridOverlay.antialiasing = false;
			gridParts.gridOverlay.color = GRID_OVERLAY_COLOR;
			gridParts.gridOverlay.blend = MULTIPLY;
			gridParts.gridOverlay.scale.set(GRID_SQAURES[i] * GRID_SIZE, GRID_SIZE * 4);
			gridParts.gridOverlay.updateHitbox();
			gridParts.gridOverlay.scrollFactor.set(0, 1);

			gridParts.topFade = new FlxSprite(gridParts.grid.x, 0).loadGraphic(Paths.image("fpsPlus/editors/chart/gridFade"));
			gridParts.topFade.scale.set(GRID_SQAURES[i] * GRID_SIZE, 1);
			gridParts.topFade.updateHitbox();
			gridParts.topFade.scrollFactor.set(0, 0);

			gridParts.bottomFade = new FlxSprite(gridParts.grid.x, 720).loadGraphic(Paths.image("fpsPlus/editors/chart/gridFade"));
			gridParts.bottomFade.flipY = true;
			gridParts.bottomFade.y -= gridParts.bottomFade.height;
			gridParts.bottomFade.scale.set(GRID_SQAURES[i] * GRID_SIZE, 1);
			gridParts.bottomFade.updateHitbox();
			gridParts.bottomFade.scrollFactor.set(0, 0);

			grids.push(gridParts);
			moveOverTotal += GRID_SQAURES[i];
		}

		selectionBox = new Box(GRID_POSITION, 0, GRID_SIZE * 4, GRID_SIZE);
		selectionBox.fillColor = UIColors.SELECTED_COLOR;
		selectionBox.borderColor = 0xFF1953C0;
		selectionBox.alpha = 0.3;
		selectionBox.blend = BlendMode.MULTIPLY;
		selectionBox.visible = false;

		var gridsBarSeperator:FlxBackdrop = new FlxBackdrop(Utils.makeColoredSprite(1, 1, 0xFF8C8C8C).graphic, Y, 0, (GRID_SIZE * 4) - 1);
		gridsBarSeperator.x = GRID_POSITION - GRID_SPACING;
		gridsBarSeperator.y -= 2;
		gridsBarSeperator.color = BACKGROUND_COLOR;
		gridsBarSeperator.scale.set((gridTotal * GRID_SIZE) + (GRID_SPACING * (GRID_COUNT + 1)), 4);
		gridsBarSeperator.updateHitbox();

		var gridsTopCover:FlxSprite = Utils.makeColoredSprite((gridTotal * GRID_SIZE) + (GRID_SPACING * (GRID_COUNT + 1)), (GRID_COUNT * GRID_SIZE * 8), 0xFF8C8C8C);
		gridsTopCover.x = GRID_POSITION - GRID_SPACING;
		gridsTopCover.y = -gridsTopCover.height;
		gridsTopCover.color = BACKGROUND_COLOR;

		playerIcon = new HealthIcon("bf", true);
		playerIcon.scrollFactor.set(0, 0);
		playerIcon.centerOrigin();
		playerIcon.scale.set(playerIcon.scale.x/2, playerIcon.scale.y/2);
		playerIcon.setPosition(grids[PLAYER_GRID].grid.x + grids[PLAYER_GRID].grid.width/2 - playerIcon.width/2, GRID_SIZE - playerIcon.height/2);

		opponentIcon = new HealthIcon("dad", false);
		opponentIcon.scrollFactor.set(0, 0);
		opponentIcon.centerOrigin();
		opponentIcon.scale.set(opponentIcon.scale.x/2, opponentIcon.scale.y/2);
		opponentIcon.setPosition(grids[OPPONENT_GRID].grid.x + grids[OPPONENT_GRID].grid.width/2 - opponentIcon.width/2, GRID_SIZE - opponentIcon.height/2);

		eventIcon = new FlxSprite().loadGraphic(Paths.image("fpsPlus/editors/chart/events/generic"));
		eventIcon.scale.set(0.5, 0.5);
		eventIcon.updateHitbox();
		eventIcon.scrollFactor.set(0, 0);
		eventIcon.setPosition(grids[EVENT_GRID].grid.x + grids[EVENT_GRID].grid.width/2 - eventIcon.width/2, GRID_SIZE - eventIcon.height/2);

		var metronomeIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image("fpsPlus/editors/chart/metronomeIcon"));
		metronomeIcon.scale.set(0.5, 0.5);
		metronomeIcon.updateHitbox();
		metronomeIcon.scrollFactor.set(0, 0);
		metronomeIcon.setPosition(grids[BPM_GRID].grid.x + grids[BPM_GRID].grid.width/2 - metronomeIcon.width/2, GRID_SIZE - metronomeIcon.height/2);

		gridCursor = Utils.makeColoredSprite(GRID_SIZE, GRID_SIZE, 0xFFFFFFFF);
		gridCursor.visible = false;

		var playbackBar:FlxSliceSprite = new FlxSliceSprite(Paths.image("fpsPlus/editors/chart/playbackBar"), new FlxRect(20, 20, 1, 20), 40 + (gridTotal * GRID_SIZE) + (GRID_SPACING * (GRID_COUNT - 1)), 20);
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
		hotbar.onSelect.add(function(slot:Int):Void{
			if(!hotbarAssignAlertOpen){
				switch(hotbarSlots[slot].type){
					case note:
						noteTypeInput.value = hotbarSlots[slot].tag;
						createArguments(hotbarSlots[slot].tag, true);
					case event:
						eventTagInput.value = hotbarSlots[slot].tag;
						createArguments(hotbarSlots[slot].tag, false);
					default:
				}
			}
			else{
				if(hotbarAssignAlertForNote){
					hotbarSlots[slot].tag = noteTypeInput.value;
					hotbarSlots[slot].type = note;
				}
				else{
					hotbarSlots[slot].tag = eventTagInput.value;
					hotbarSlots[slot].type = event;
				}
				updateHotbarGraphics();
				closeHotbarAlert();
			}
		});
		hotbar.onRightClick.add(function(slot:Int):Void{
			hotbarSlots[slot].tag = "";
			hotbarSlots[slot].type = empty;
			updateHotbarGraphics();
		});
		hotbar.onOverlap.add(function(slot:Int):Void{
			if(hotbarSlots[slot].type != empty && !bpmChangeBoxOpen){
				typeAlert.text = hotbarSlots[slot].tag;
				typeAlert.alpha = 1;
			}
		});
		hotbar.onOverlapStop.add(function():Void{
			typeAlert.alpha = 0;
		});

		hotbarAssignOverlay = Utils.makeColoredSprite(1280, 720, 0xFFFFFFFF);
		hotbarAssignOverlay.color = 0xFF000000;
		hotbarAssignOverlay.alpha = 0.7;
		hotbarAssignOverlay.scrollFactor.set(0, 0);
		hotbarAssignOverlay.visible = false;

		//276
		hotbarAssignPanel = new Panel(1280/2 - 298/2, 720/2 - 186/2, 298, 186, ["Assign to Hotbar"], 40);
		hotbarAssignPanel.scrollFactor.set(0, 0);
		hotbarAssignPanel.visible = false;

		hotbarAssignText = new UIText(10, 6, "Select a hotbar slot to assign this event to. Click on the slot or use the number keys to select a slot. Press Escape to cancel.", 0.5, 276);
		hotbarAssignText.alignment = JUSTIFY;

		hotbarAssignPanel.addToTab("Assign to Hotbar", hotbarAssignText);
		
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

		alertGroup = new FlxTypedGroup<Alert>();

		typeAlert = new Alert(0, 0, "Text Yes!");
		typeAlert.scrollFactor.set(0, 0);
		typeAlert.alpha = 1;
		typeAlert.hasLifetime = false;
		typeAlert.doLerp = false;

		topOverlay = Utils.makeColoredSprite(1280, 720, 0xFFFFFFFF);
		topOverlay.color = 0xFF000000;
		topOverlay.alpha = 0.7;
		topOverlay.scrollFactor.set(0, 0);
		topOverlay.visible = false;

		bpmChangePanel = new Panel(1280/2 - 240/2, 720/2 - 150/2, 320, 150, ["Add BPM Change"], 40);
		bpmChangePanel.scrollFactor.set(0, 0);
		bpmChangePanel.visible = false;

		bpmInput = new Stepper(21, 20, 192, 100, 1, 1, null, true, "New BPM");
		var newBPMButton:Button = new Button(62, 64, 192, "Create");
		newBPMButton.onPress.add(function(){
			closeBPMPanel(true);
		});

		bpmChangePanel.addToTab("Add BPM Change", bpmInput);
		bpmChangePanel.addToTab("Add BPM Change", newBPMButton);

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
		add(bpmChanges);
		add(selectionBox);
		
		for(gridParts in grids){
			add(gridParts.topFade);
			add(gridParts.bottomFade);
		}
		
		add(gridsTopCover);

		add(playerIcon);
		add(opponentIcon);
		add(eventIcon);
		add(metronomeIcon);

		add(alertGroup);

		add(playbackBar);

		add(panelDropShadow);
		add(toolbarDropShadow);

		add(panel);

		add(timeBox);
		add(timeBoxLeftText);
		add(timeBoxRightText);
		add(beatBox);
		add(beatBoxLeftText);
		add(beatBoxRightText);
		add(stepBox);
		add(stepBoxLeftText);
		add(stepBoxRightText);

		add(hotbarAssignOverlay);
		add(hotbarAssignPanel);

		add(hotbar);

		for(i in 0...hotbarSlots.length){
			var newNote:ChartingNote = new ChartingNote();
			newNote.updateProperties(10, ((i+1)*60)+11, 0, 0, false, "bleh");
			newNote.scrollFactor.set(0, 0);
			hotbarSlotNotes.push(newNote);

			var newEvent:ChartingEvent = new ChartingEvent();
			newEvent.updateProperties(10, ((i+1)*60)+11, 0, 0, "");
			newEvent.scrollFactor.set(0, 0);
			hotbarSlotEvents.push(newEvent);

			add(newNote);
			add(newEvent);
		}

		updateHotbarGraphics();

		camFollow = new FlxObject(1280/2, 720/2, 0, 0);
		camFollow.y -= PLAYBACK_POSITION;
		camFollow.velocity.y = 0;
		FlxG.camera.follow(camFollow);

		add(camFollow);
		updateHealthIcons(chart.meta.opponent, chart.meta.player, true);
		setCurrentState(NONE);

		add(topOverlay);
		add(bpmChangePanel);
		
		super.create();

		add(typeAlert);
		add(editorCursor);
	}

	function setupSongTab():Void{
		var songNameInput:TextInput = new TextInput(PANEL_SPACING, PANEL_SPACING, 240, chart.meta.song, "Song");
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

		var opponentDropdown:Dropdown = new Dropdown(PANEL_SPACING, songNameInput.y + songNameInput.elementHeight + PANEL_EXTRA_SPACING, 240, characterList, chart.meta.opponent, "Opponent");
		opponentDropdown.onSelect.add(function(v:String){
			updateHealthIcons(v, chart.meta.player);
			chart.meta.opponent = v;
		});
		var playerDropown:Dropdown = new Dropdown(PANEL_SPACING, opponentDropdown.y + opponentDropdown.elementHeight + PANEL_SPACING, 240, characterList, chart.meta.player, "Player");
		playerDropown.onSelect.add(function(v:String){
			updateHealthIcons(chart.meta.opponent, v);
			chart.meta.player = v;
		});
		var speakerDropdown:Dropdown = new Dropdown(PANEL_SPACING, playerDropown.y + playerDropown.elementHeight + PANEL_SPACING, 240, gfList, chart.meta.speaker, "Partner");
		speakerDropdown.onSelect.add(function(v:String){ chart.meta.speaker = v; });
		var stageDropdown:Dropdown = new Dropdown(PANEL_SPACING, speakerDropdown.y + speakerDropdown.elementHeight + PANEL_EXTRA_SPACING, 240, stageList, chart.meta.stage, "Stage");
		stageDropdown.onSelect.add(function(v:String){ chart.meta.stage = v; });

		final startingDiff:String = (PlayState.storyDifficulty == 2 ? "Hard" : (PlayState.storyDifficulty == 0 ? "Easy" : "Normal"));
		difficultyDropdown = new Dropdown(PANEL_SPACING, stageDropdown.y + stageDropdown.elementHeight + PANEL_EXTRA_SPACING, 192, ["Easy", "Normal", "Hard"], startingDiff, "Difficulty");

		var saveChartButton:Button = new Button(PANEL_SPACING, difficultyDropdown.y + difficultyDropdown.elementHeight + PANEL_SPACING, 192, "Save Chart");
		saveChartButton.onPress.add(function(){ saveChartToFile(); });
		var saveEventsButton:Button = new Button(PANEL_SPACING, saveChartButton.y + saveChartButton.elementHeight + PANEL_SPACING, 192, "Save Events");
		saveEventsButton.onPress.add(function(){ saveEventsToFile(); });

		var reloadChartButton:Button = new Button(PANEL_SPACING, saveEventsButton.y + saveEventsButton.elementHeight + PANEL_SPACING, 192, "Reload Chart");
		reloadChartButton.onPress.add(function(){ trace("I don't do anything yet! God, I'm such a fucking useless button! Ugh!"); });

		panel.addToTab("Song", songNameInput);
		panel.addToTab("Song", opponentDropdown);
		panel.addToTab("Song", playerDropown);
		panel.addToTab("Song", speakerDropdown);
		panel.addToTab("Song", stageDropdown);
		panel.addToTab("Song", difficultyDropdown);
		panel.addToTab("Song", saveChartButton);
		panel.addToTab("Song", saveEventsButton);
		panel.addToTab("Song", reloadChartButton);
	}

	function setupNotesTab():Void{
		//Temp for now, just so it exists.
		noteTypeInput = new TextInput(PANEL_SPACING, PANEL_SPACING, 336, "", "Tag");
		noteTypeInput.onValueChanged.add(function(v:String){
			createArguments(v, true);
		});

		notePrefixDropdown = new Dropdown(PANEL_SPACING, noteTypeInput.y + noteTypeInput.elementHeight + PANEL_SPACING, 240, noteTypePrefixes, "", "Note Tags");
		notePrefixDropdown.onSelect.add(function(v:String){
			noteTypeInput.value = v;
			createArguments(v, true);
		});

		var assignNoteTypeToHotbar:Button = new Button(PANEL_SPACING, notePrefixDropdown.y + notePrefixDropdown.elementHeight + PANEL_SPACING, 240, "Assign to Hotbar");
		assignNoteTypeToHotbar.onPress.add(function(){
			openHotbarAlert(true);
		});

		noteParamStartLocation = assignNoteTypeToHotbar.y + assignNoteTypeToHotbar.elementHeight + PANEL_EXTRA_SPACING;

		noteDescription = new UIText(PANEL_SPACING, 0, "", 0.5, panel.width - Box.BORDER_SIZE*2 - PANEL_SPACING*2);
		noteDescription.alignment = JUSTIFY;
		noteDescription.color = 0xFFBABABA;

		panel.addToTab("Notes", noteDescription);
		panel.addToTab("Notes", noteTypeInput);
		panel.addToTab("Notes", notePrefixDropdown);
		panel.addToTab("Notes", assignNoteTypeToHotbar);
	}
	
	function setupEventsTab():Void{
		eventTagInput = new TextInput(PANEL_SPACING, PANEL_SPACING, 336, "", "Tag");
		eventTagInput.onValueChanged.add(function(v:String){
			createArguments(v, false);
		});

		eventPrefixDropdown = new Dropdown(PANEL_SPACING, eventTagInput.y + eventTagInput.elementHeight + PANEL_SPACING, 240, eventPrefixes, "", "Event Tags");
		eventPrefixDropdown.onSelect.add(function(v:String){
			eventTagInput.value = v;
			createArguments(v, false);
		});

		var assignEventToHotbar:Button = new Button(PANEL_SPACING, eventPrefixDropdown.y + eventPrefixDropdown.elementHeight + PANEL_SPACING, 240, "Assign to Hotbar");
		assignEventToHotbar.onPress.add(function(){
			openHotbarAlert(false);
		});

		eventParamStartLocation = assignEventToHotbar.y + assignEventToHotbar.elementHeight + PANEL_EXTRA_SPACING;

		eventDescription = new UIText(PANEL_SPACING, 0, "", 0.5, panel.width - Box.BORDER_SIZE*2 - PANEL_SPACING*2);
		eventDescription.alignment = JUSTIFY;
		eventDescription.color = 0xFFBABABA;
		
		panel.addToTab("Events", eventDescription);
		panel.addToTab("Events", eventTagInput);
		panel.addToTab("Events", eventPrefixDropdown);
		panel.addToTab("Events", assignEventToHotbar);
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
		if(gridCursorIndex > -1){
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
		}

		gridCursor.visible = false;
		if(canDoThings()){
			gridCursor.visible = true;

			if(gridCursorIndex == OPPONENT_GRID || gridCursorIndex == PLAYER_GRID){ //Placing notes.
				var overlapHoldCheck:ChartingNote = null;
				notes.forEachAlive(function(note:ChartingNote){
					if(note.isMouseOverHold()){
						overlapHoldCheck = note;
						gridCursor.visible = false;
					}
				});

				if(FlxG.mouse.justPressed && !FlxG.keys.anyPressed([SHIFT])){
					if(overlapHoldCheck == null){ //Place new note.
						var newNote = addNote(getSongPositionFromY(gridCursor.y), gridCursorLane, gridCursorIndex == PLAYER_GRID, noteTypeInput.value);
						selectedNotes = [newNote];
						previousSustainLength = -1;
						placedNoteHold = true;
						currentlySelectingEvents = false;
					}
					else{ //Regrab note hold.
						selectedNotes = [overlapHoldCheck];
						previousSustainLength = overlapHoldCheck.sustainLength;
						placedNoteHold = true;
						currentlySelectingEvents = false;
					}
				}
				else if(FlxG.mouse.justPressedRight && !FlxG.keys.anyPressed([SHIFT])){
					var deleteCount:Int = removeNotesInProximity(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, gridCursorIndex == PLAYER_GRID, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
					selectedNotes = [];
					if(deleteCount > 0){ createSnapshot(REMOVE_NOTES(deleteCount)); }
					currentlySelectingEvents = false;
				}
				else if(FlxG.mouse.justPressedMiddle){
					if(!FlxG.keys.anyPressed([SHIFT])){ selectedNotes = []; }
					var note:ChartingNote = getNoteUnderCursor();
					if(note != null && !selectedNotes.contains(note)){
						selectedNotes.push(note);
						noteTypeInput.value = note.tag;
						createArguments(note.tag, true);
					}
					else if(note != null && selectedNotes.contains(note)){ selectedNotes.remove(note); }
					else if(note == null){
						noteTypeInput.value = "";
						createArguments("", true);
					}
					currentlySelectingEvents = false;
				}
			}
			else if(gridCursorIndex == EVENT_GRID){ //Placing events.
				if(FlxG.mouse.justPressed && !FlxG.keys.anyPressed([SHIFT])){
					var newEvent = addEvent(getSongPositionFromY(gridCursor.y), gridCursorLane, eventTagInput.value);
					selectedEvents = [newEvent];
					createSnapshot(PLACE_EVENTS(1));
					currentlySelectingEvents = true;
				}
				else if(FlxG.mouse.justPressedRight && !FlxG.keys.anyPressed([SHIFT])){
					var deleteCount:Int = removeEventsInProximity(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, null, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
					selectedEvents = [];
					if(deleteCount > 0){ createSnapshot(REMOVE_EVENTS(deleteCount)); }
					currentlySelectingEvents = true;
				}
				else if(FlxG.mouse.justPressedMiddle){
					if(!FlxG.keys.anyPressed([SHIFT])){ selectedEvents = []; }
					var event:ChartingEvent = getEventUnderCursor();
					if(event != null && !selectedEvents.contains(event)){
						selectedEvents.push(event);
						eventTagInput.value = event.tag;
						createArguments(event.tag, false);
					}
					else if(event != null && selectedEvents.contains(event)){ selectedEvents.remove(event); }
					else if(event == null){
						eventTagInput.value = "";
						createArguments("", false);
					}
					currentlySelectingEvents = true;
				}
			}
			else if(gridCursorIndex == BPM_GRID){
				if(FlxG.mouse.justPressed){
					openBPMPanel(getSongPositionFromY(gridCursor.y));
				}
				else if(FlxG.mouse.justPressedRight){
					var deleteCount:Int = removeBPMChangesInProximity(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
					if(deleteCount > 0){
						if(bpmChanges.getFirstAlive() == null || bpmChanges.getFirstAlive().time != 0){
							openBPMPanel(0);
							createAlert("Starting BPM removed, creating a new one.", 3);
						}
						else{
							retimeNotesAndEvents();
							createSnapshot(REMOVE_BPM(deleteCount));
							createAlert("Deleted BPM change.");
						}
					}
				}
			}

			if(!selectionBoxOpen && FlxG.mouse.justPressed && FlxG.keys.anyPressed([SHIFT]) && gridCursorIndex >= OPPONENT_GRID){
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
				selectedEvents = [];
				var selectionStartTime:Float = getSongPositionFromY(selectionBox.y - GRID_SIZE);
				var selectionEndTime:Float = getSongPositionFromY(selectionBox.y + selectionBox.height);
				
				if(startingGrid == OPPONENT_GRID || startingGrid == PLAYER_GRID){
					notes.forEachAlive(function(note:ChartingNote){
						if(note.time >= selectionStartTime && note.time < selectionEndTime){
							if(selectingBoth || ((!note.player && startingGrid == OPPONENT_GRID) || (note.player && startingGrid == PLAYER_GRID))){
								selectedNotes.push(note);
							}
						}
					});
					currentlySelectingEvents = false;
				}
				else if(startingGrid == EVENT_GRID){
					events.forEachAlive(function(event:ChartingEvent){
						if(event.time >= selectionStartTime && event.time < selectionEndTime){
							selectedEvents.push(event);
						}
					});
					currentlySelectingEvents = true;
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
			if(FlxG.mouse.wheel != 0 && allowGridScroll){
				pauseMusic();
				final wheelSpin = FlxG.mouse.wheel;
				FlxG.sound.music.time = Math.round(FlxG.sound.music.time / (Conductor.getStepCrotchetMs()/2)) * (Conductor.getStepCrotchetMs()/2); //Snap to nearest half step.
				FlxG.sound.music.time -= (wheelSpin * Conductor.getStepCrotchetMs() * 0.5);
				musicBoundsCheck();
			}

			if(gridCursorIndex == OPPONENT_GRID || gridCursorIndex == PLAYER_GRID){
				var note:ChartingNote = getNoteUnderCursor();
				if(note != null && note.tag.length > 0){
					typeAlert.alpha = 1;
					typeAlert.text = note.tag;
				}
				else{ typeAlert.alpha = 0; }
			}
			else if(gridCursorIndex == EVENT_GRID){
				var event:ChartingEvent = getEventUnderCursor();
				if(event != null){
					typeAlert.alpha = 1;
					typeAlert.text = event.tag;
				}
				else{ typeAlert.alpha = 0; }
			}
			else if(gridCursorIndex == BPM_GRID){
				var bpmChange:ChartingBPM = getBPMChangeUnderCursor();
				if(bpmChange != null){
					typeAlert.alpha = 1;
					typeAlert.text = bpmChange.bpm + " BPM";
				}
				else{ typeAlert.alpha = 0; }
			}
			else{ typeAlert.alpha = 0; }
				
			checkShortcuts();
		}
		else if(hotbarAssignAlertOpen){
			panel.blockAllInteraction();
			
			if(FlxG.keys.anyJustPressed([ESCAPE])){
				closeHotbarAlert();
			}
			
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
		}
		else if(bpmChangeBoxOpen){
			panel.blockAllInteraction();
			typeAlert.alpha = 0;

			if(bpmChangePanel.tabs[0].manager.focused == null && bpmChangePanel.tabs[0].manager.allowInteraction){
				if(FlxG.keys.anyJustPressed([ESCAPE])){
					closeBPMPanel(false);
				}
				else if(FlxG.keys.anyJustPressed([ENTER])){
					closeBPMPanel(true);
				}
			}
		}

		if(placedNoteHold && !FlxG.mouse.released && selectedNotes.length > 0){
			var sustainLength:Int = FlxMath.maxInt(Math.round((gridCursor.y - selectedNotes[0].y) / GRID_SIZE), 0);
			if(selectedNotes[0].sustainLength != sustainLength){ selectedNotes[0].sustainLength = sustainLength; }
			gridCursor.visible = false;
		}
		else if(placedNoteHold){
			placedNoteHold = false;
			if(previousSustainLength < 0){
				createSnapshot(PLACE_NOTES(1));
			}
			else if(previousSustainLength != selectedNotes[0].sustainLength){
				createSnapshot(CHANGE_HOLD_DURATION);
			}
		}

		if(selectionBoxOpen){
			var boxHeight:Float = FlxG.mouse.y - selectionStartY;
			selectionBox.y = boxHeight >= 0 ? selectionStartY : FlxG.mouse.y;
			selectionBox.height = Math.max(1, Math.abs(boxHeight));

			if(startingGrid == OPPONENT_GRID || startingGrid == PLAYER_GRID){
				if((startingGrid == OPPONENT_GRID && lastGridCursorIndex > startingGrid) || (startingGrid == PLAYER_GRID && lastGridCursorIndex < startingGrid)){
					selectingBoth = true;
					selectionBox.x = grids[OPPONENT_GRID].grid.x;
					selectionBox.width = GRID_SIZE * 8 + GRID_SPACING;
				}
				else{
					selectingBoth = false;
					selectionBox.x = grids[startingGrid].grid.x;
					selectionBox.width = GRID_SIZE * GRID_SQAURES[startingGrid];
				}
			}
			else if(startingGrid == EVENT_GRID){
				selectionBox.width = GRID_SIZE * GRID_SQAURES[startingGrid];
			}
		}

		if(!currentlySelectingEvents && selectedEvents.length > 0)		{ selectedEvents = []; }
		else if(currentlySelectingEvents && selectedNotes.length > 0)	{ selectedNotes = []; }

		notes.forEachAlive(function(note:ChartingNote){
			if(selectedNotes.contains(note)){ note.select(); }
			else{ note.deselect(); }
		});

		events.forEachAlive(function(event:ChartingEvent){
			if(selectedEvents.contains(event)){ event.select(); }
			else{ event.deselect(); }
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

		var alertDead:Array<Alert> = [];
		alertGroup.forEachDead(function(alert:Alert):Void{
			alertDead.push(alert);
		});
		for(alert in alertDead){
			alertGroup.remove(alert, true);
			alert.destroy();
		}

		for(i in 0...alertGroup.members.length){
			alertGroup.members[i].wantedY = 720 - (alertGroup.members[i].elementHeight + ALERT_SPACING) * (alertGroup.members.length - i);
		}

		super.update(elapsed);

		//Show tag of note/event you are hovering over.
		typeAlert.x = editorCursor.x + 10;
		typeAlert.y = editorCursor.y - 10;

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
		//Allows you to use the command key on Mac for shortcuts.
		var controlPressed:Bool = #if mac FlxG.keys.anyPressed([WINDOWS]); #else FlxG.keys.anyPressed([CONTROL]); #end

		//To top of section/song.
		if(FlxG.keys.anyJustPressed([R])){
			if(FlxG.sound.music.playing){ pauseMusic(); }
			if(controlPressed){
				FlxG.sound.music.time = 0;
			}
			else{
				FlxG.sound.music.time = getSongPositionFromY(Math.floor(getYFromSongPosition(FlxG.sound.music.time) / (GRID_SIZE * 16)) * (GRID_SIZE * 16));
			}
		}

		//Next/previous section.
		if(FlxG.keys.anyJustPressed([D]) && !FlxG.keys.anyPressed([ALT])){
			if(FlxG.sound.music.playing){ pauseMusic(); }
			FlxG.sound.music.time = getSongPositionFromY((Math.floor(getYFromSongPosition(FlxG.sound.music.time + 1) / (GRID_SIZE * 16)) * (GRID_SIZE * 16)) + (GRID_SIZE * 16));
			musicBoundsCheck();
		}
		if(FlxG.keys.anyJustPressed([A]) && !FlxG.keys.anyPressed([ALT])){
			if(FlxG.sound.music.playing){ pauseMusic(); }
			FlxG.sound.music.time = getSongPositionFromY((Math.floor(getYFromSongPosition(FlxG.sound.music.time + 1) / (GRID_SIZE * 16)) * (GRID_SIZE * 16)) - (GRID_SIZE * 16));
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
			if(!currentlySelectingEvents){
				var deleteCount:Int = 0;
				while(selectedNotes.length > 0){
					deleteCount += removeNotesInProximity(selectedNotes[0].time, selectedNotes[0].direction, selectedNotes[0].player, 1);
				}
				selectedNotes = [];
				if(deleteCount > 0){
					createAlert("Deleted " + deleteCount + " note" + (deleteCount==1?".":"s."));
					createSnapshot(REMOVE_NOTES(deleteCount));
				}
			}
			else if(currentlySelectingEvents){
				var deleteCount:Int = 0;
				while(selectedEvents.length > 0){
					deleteCount += removeEventsInProximity(selectedEvents[0].time, selectedEvents[0].lane, null, 1);
				}
				selectedEvents = [];
				if(deleteCount > 0){
					createAlert("Deleted " + deleteCount + " event" + (deleteCount==1?".":"s."));
					createSnapshot(REMOVE_EVENTS(deleteCount));
				}
			}
		}

		//Cycle panel tabs.
		if(FlxG.keys.anyJustPressed([TAB]))		{ panel.changeTab((panel.selectedTab + 1) % panel.tabs.length); }

		//Grid snap.
		if(FlxG.keys.anyJustPressed([LEFT]) || (FlxG.keys.anyJustPressed([A]) && FlxG.keys.anyPressed([ALT]))){
			gridSnapDropdown.currentIndex -= 1;
			if(gridSnapDropdown.currentIndex < 0){ gridSnapDropdown.currentIndex = gridSnapDropdown.values.length-1; }
			setGridSnap(gridSnapDropdown.values[gridSnapDropdown.currentIndex]);
		}
		if(FlxG.keys.anyJustPressed([RIGHT]) || (FlxG.keys.anyJustPressed([D]) && FlxG.keys.anyPressed([ALT]))){
			gridSnapDropdown.currentIndex += 1;
			if(gridSnapDropdown.currentIndex >= gridSnapDropdown.values.length){ gridSnapDropdown.currentIndex = 0; }
			setGridSnap(gridSnapDropdown.values[gridSnapDropdown.currentIndex]);
		}

		//Undo Redo
		if(FlxG.keys.anyJustPressed([Z]) && controlPressed)			{ undo(); }
		else if(FlxG.keys.anyJustPressed([Y]) && controlPressed)	{ redo(); }

		//Copy Cut Paste
		if(FlxG.keys.anyJustPressed([C]) && controlPressed){
			if(selectedNotes.length >= 1 && !currentlySelectingEvents){
				copyNotes();
				createAlert("Copied " + copiedNoteData.length + " note" + (copiedNoteData.length==1?".":"s."));
			}
			else if(selectedEvents.length >= 1 && currentlySelectingEvents){
				copyEvents();
				createAlert("Copied " + copiedEventData.length + " event" + (copiedEventData.length==1?".":"s."));
			}
		}
		else if(FlxG.keys.anyJustPressed([X]) && controlPressed){
			if(selectedNotes.length >= 1 && !currentlySelectingEvents){
				copyNotes();
				while(selectedNotes.length > 0){
					removeNotesInProximity(selectedNotes[0].time, selectedNotes[0].direction, selectedNotes[0].player, 1);
				}
				selectedNotes = [];
				createAlert("Cut " + copiedNoteData.length + " note" + (copiedNoteData.length==1?".":"s."));
				if(copiedNoteData.length > 0){ createSnapshot(CUT); }
			}
			else if(selectedEvents.length >= 1 && currentlySelectingEvents){
				copyEvents();
				while(selectedEvents.length > 0){
					removeEventsInProximity(selectedEvents[0].time, selectedEvents[0].lane, null, 1);
				}
				selectedEvents = [];
				createAlert("Cut " + copiedEventData.length + " event" + (copiedEventData.length==1?".":"s."));
				if(copiedEventData.length > 0){ createSnapshot(CUT); }
			}
		}
		else if(FlxG.keys.anyJustPressed([V]) && controlPressed && gridCursorIndex >= OPPONENT_GRID){
			if((gridCursorIndex == OPPONENT_GRID || gridCursorIndex == PLAYER_GRID) && !currentlyCopyingEvents){
				if(placedNoteHold){
					placedNoteHold = false;
					createSnapshot(PLACE_NOTES(1));
				}
				if(copiedNoteData.length > 0){
					selectedNotes = [];
					for(noteData in copiedNoteData){
						if(!copyingBoth){
							var newNote = addNote(noteData.time + getSongPositionFromY(gridCursor.y), noteData.direction, gridCursorIndex == PLAYER_GRID, noteData.tag);
							newNote.sustainLength = noteData.length;
							selectedNotes.push(newNote);
						}
						else{
							var newNote = addNote(noteData.time + getSongPositionFromY(gridCursor.y), noteData.direction, noteData.player, noteData.tag);
							newNote.sustainLength = noteData.length;
							selectedNotes.push(newNote);
						}
					}
					currentlySelectingEvents = false;
				}
				createAlert("Pasted " + copiedNoteData.length + " note" + (copiedNoteData.length==1?".":"s."));
				createSnapshot(PASTE);
			}
			else if(gridCursorIndex == EVENT_GRID && currentlyCopyingEvents){
				if(placedNoteHold){
					placedNoteHold = false;
					createSnapshot(PLACE_NOTES(1));
				}
				if(copiedEventData.length > 0){
					selectedEvents = [];
					for(eventData in copiedEventData){
						var newEvent = addEvent(eventData.time + getSongPositionFromY(gridCursor.y), eventData.lane, eventData.tag);
						selectedEvents.push(newEvent);
					}
					currentlySelectingEvents = true;
				}
				createAlert("Pasted " + copiedEventData.length + " event" + (copiedEventData.length==1?".":"s."));
				createSnapshot(PASTE);
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

		//Playtest song on PlayState.
		if(FlxG.keys.anyJustPressed([ENTER])){
			pauseMusic();

			notes.members.sort(sortNotes);
			events.members.sort(sortEvents);
			generateChart();
			
			if(controlPressed){
				PlayState.sectionStart = true;
				PlayState.sectionStartTime = FlxG.sound.music.time;
			}

			PlayState.setSong(chart, PlayState.events);
			PlayState.fromChartEditor = true;
			ImageCache.refreshLocal();
			switchState(new PlayState());
		}
	}

	//Note stuff.

	function addNote(strumTime:Float, direction:Int, player:Bool, tag:String = ""):ChartingNote{
		if(strumTime < 0){ strumTime = 0; }
		removeNotesInProximity(strumTime, direction, player);

		var newNote = notes.recycle(ChartingNote, null, true, true);
		newNote.updateProperties(grids[player?PLAYER_GRID:OPPONENT_GRID].grid.x + (GRID_SIZE * direction), getYFromSongPosition(strumTime), direction, strumTime, player, tag);
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
		if(gridCursorIndex != OPPONENT_GRID && gridCursorIndex != PLAYER_GRID){ return null; }
		var eligibleNotes:Array<ChartingNote> = getNotesInRegion(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, gridCursorIndex == PLAYER_GRID, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
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
		currentlyCopyingEvents = false;
	}

	//Event stuff.

	function addEvent(strumTime:Float, lane:Int, tag:String = ""):ChartingEvent{
		if(strumTime < 0){ strumTime = 0; }
		removeEventsInProximity(strumTime, lane, tag);

		var newEvent = events.recycle(ChartingEvent, null, true, true);
		newEvent.updateProperties(grids[EVENT_GRID].grid.x + (GRID_SIZE * lane), getYFromSongPosition(strumTime), lane, strumTime, tag);
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

	function getEventsInRegion(strumTime:Float, lane:Null<Int>, ?tag:String, region:Float = 5):Array<ChartingEvent>{
		var r:Array<ChartingEvent> = [];
		events.forEachAlive(function(event:ChartingEvent){
			if((lane == null || event.lane == lane) && (tag == null || event.tag == tag)){
				if(Utils.inRange(event.time, strumTime, region)){ r.push(event); }
			}
		});
		return r;
	}

	function removeEventsInProximity(strumTime:Float, lane:Int, ?tag:String, region:Float = 1):Int{
		var removeList:Array<ChartingEvent> = getEventsInRegion(strumTime, lane, tag, region);
		for(event in removeList){
			if(selectedEvents.contains(event)){ selectedEvents.remove(event); }
			event.kill();
		}
		return removeList.length;
	}

	function getEventUnderCursor():ChartingEvent{
		if(gridCursorIndex != EVENT_GRID){ return null; }
		var eligibleEvents:Array<ChartingEvent> = getEventsInRegion(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), gridCursorLane, null, ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
		if(eligibleEvents.length == 0){ return null; }
		eligibleEvents.sort(function(a:ChartingEvent, b:ChartingEvent):Int{
			return Math.abs(a.time - getSongPositionFromY(FlxG.mouse.y)) < Math.abs(b.time - getSongPositionFromY(FlxG.mouse.y)) ? -1 : 1;
		});
		return eligibleEvents[0];
	}

	function copyEvents():Void{
		copiedEventData = [];
		for(event in selectedEvents){
			copiedEventData.push(event.generateEventDefinition());
		}
		var startTime = copiedEventData[0].time;
		for(data in copiedEventData){
			data.time -= startTime;
		}
		currentlyCopyingEvents = true;
	}

	//BPM Stuff.

	function addBPMChange(strumTime:Float, bpm:Float):ChartingBPM{
		if(strumTime < 0){ strumTime = 0; }
		removeBPMChangesInProximity(strumTime);

		var deletedZero:Bool = true;
		bpmChanges.forEachAlive(function(bpmChange:ChartingBPM){
			deletedZero = deletedZero && bpmChange.time != 0;
		});
		if(deletedZero){ strumTime = 0; }

		var newBPMChange = bpmChanges.recycle(ChartingBPM, null, true, true);
		newBPMChange.updateProperties(grids[BPM_GRID].grid.x, getYFromSongPosition(strumTime), bpm, strumTime);
		bpmChanges.members.sort(sortBPMChanges);
		
		return newBPMChange;
	}

	function sortBPMChanges(a:ChartingBPM, b:ChartingBPM):Int{
		var r:Int = 0;
		r = FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		return r;
	}

	function getBPMChangesInRegion(strumTime:Float, region:Float = 5):Array<ChartingBPM>{
		var r:Array<ChartingBPM> = [];
		bpmChanges.forEachAlive(function(bpmChange:ChartingBPM){
			if(Utils.inRange(bpmChange.time, strumTime, region)){ r.push(bpmChange); }
		});
		return r;
	}

	function removeBPMChangesInProximity(strumTime:Float, region:Float = 1):Int{
		var removeList:Array<ChartingBPM> = getBPMChangesInRegion(strumTime, region);
		for(bpmChange in removeList){ bpmChange.kill(); }
		return removeList.length;
	}

	function getBPMChangeUnderCursor():ChartingBPM{
		if(gridCursorIndex != BPM_GRID){ return null; }
		var eligibleBPMChanges:Array<ChartingBPM> = getBPMChangesInRegion(getSongPositionFromY(FlxG.mouse.y - (GRID_SIZE/2)), ((getSongPositionFromY(FlxG.mouse.y + GRID_SIZE) - getSongPositionFromY(FlxG.mouse.y))/2)*0.999999);
		if(eligibleBPMChanges.length == 0){ return null; }
		eligibleBPMChanges.sort(function(a:ChartingBPM, b:ChartingBPM):Int{
			return Math.abs(a.time - getSongPositionFromY(FlxG.mouse.y)) < Math.abs(b.time - getSongPositionFromY(FlxG.mouse.y)) ? -1 : 1;
		});
		return eligibleBPMChanges[0];
	}

	//

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

		chartEvents.events = [];
		events.forEachAlive(function(event:ChartingEvent){
			chartEvents.events.push(event.generateEventDefinition());
		});
		
		chart.meta.bpm = [];
		bpmChanges.forEachAlive(function(bpmChange:ChartingBPM){
			chart.meta.bpm.push(bpmChange.generateBPMDefinition());
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

		for(noteType in NoteType.types){
			if(!noteType.editor.hidden){
				noteTypePrefixes.push(noteType.prefix);
			}
		}
		
		for(event in Events.events){
			if(!event.editor.hidden){
				eventPrefixes.push(event.prefix);
			}
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

		noteTypePrefixes.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});

		eventPrefixes.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});

		eventIconList = [];
		eventIconOverrides = new Map<String, String>();

		var eventsDirectory = Utils.readDirectory("assets/images/fpsPlus/editors/chart/events/");
		for(file in eventsDirectory){
			if(file.split(".")[1] == "png"){
				eventIconList.push(file.split(".")[0]);
			}
			else if(file.split(".")[1] == "json"){
				var json = Json.parse(Utils.getText("assets/images/fpsPlus/editors/chart/events/" + file));
				for(key in cast(json.overrides, Array<Dynamic>)){
					eventIconOverrides.set(key, file.split(".")[0]);
				}
			}
		}
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
			opponentIcon.setPosition(grids[OPPONENT_GRID].grid.x + grids[OPPONENT_GRID].grid.width/2 - opponentIcon.width/2, GRID_SIZE - opponentIcon.height/2);
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
			playerIcon.setPosition(grids[PLAYER_GRID].grid.x + grids[PLAYER_GRID].grid.width/2 - playerIcon.width/2, GRID_SIZE - playerIcon.height/2);
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
			createAlert("Loaded audio for \"" + song + "\".", 2);
			Utils.gc();

			return true;
		}

		createAlert("Audio for \"" + song + "\" could not be found.", 2);
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

		createAlert("Grid Snap set to " + value + (value=="Free"?".":"s."), 2);
	}

	function createAlert(text:String, time:Float = 1.5):Void{
		var alert = new Alert(0, 720, text, time);
		alert.scrollFactor.set(0, 0);
		alert.screenCenter(X);
		alert.x -= (1280/2) - gridCenterPosition;
		alert.setWantedToPosition();
		alertGroup.add(alert);
	}

	function setCurrentState(type:UndoAction):Void{
		var noteData:Array<NoteDefinition> = [];
		notes.forEachAlive(function(note:ChartingNote){
			noteData.push(note.generateNoteDefinition());
		});

		var eventData:Array<EventDefinition> = [];
		events.forEachAlive(function(event:ChartingEvent){
			eventData.push(event.generateEventDefinition());
		});
		
		var bpmData:Array<BPMDefinition> = [];
		bpmChanges.forEachAlive(function(bpmChange:ChartingBPM){
			bpmData.push(bpmChange.generateBPMDefinition());
		});

		currentState = {notes: noteData, events: eventData, bpmChanges: bpmData, action: type};
	}

	function createSnapshot(type:UndoAction):Void{
		pushToUndoHistory(currentState);
		setCurrentState(type);
		redoHistory = [];
	}

	function undo():Void{
		if(undoHistory.length <= 0){
			createAlert("Nothing to undo.", 1);
			return;
		}

		var snapshot:ChartSnapshot = undoHistory.pop();
		rebuildChartFromSnapshot(snapshot);

		var actionText:String = getUndoActionText(currentState.action);
		createAlert("Undo"+(actionText.length>0?" ":"")+actionText+".", 1);

		pushToRedoHistory(currentState);
		currentState = snapshot;
		selectedNotes = [];
	}

	function redo():Void{
		if(redoHistory.length <= 0){
			createAlert("Nothing to redo.", 1);
			return;
		}

		var snapshot:ChartSnapshot = redoHistory.pop();
		rebuildChartFromSnapshot(snapshot);

		var actionText:String = getUndoActionText(snapshot.action);
		createAlert("Redo"+(actionText.length>0?" ":"")+actionText+".", 1);

		pushToUndoHistory(currentState);
		currentState = snapshot;
		selectedNotes = [];
	}

	function pushToUndoHistory(snapshot:ChartSnapshot):Void{
		if(UNDO_LIMIT > 0 && undoHistory.length >= UNDO_LIMIT){
			undoHistory.shift();
		}
		undoHistory.push(currentState);
	}

	function pushToRedoHistory(snapshot:ChartSnapshot):Void{
		if(UNDO_LIMIT > 0 && redoHistory.length >= UNDO_LIMIT){
			redoHistory.shift();
		}
		redoHistory.push(currentState);
	}

	function rebuildChartFromSnapshot(snapshot:ChartSnapshot){
		var startingY:Float = getYFromSongPosition(FlxG.sound.music.time);
		
		notes.killMembers();
		events.killMembers();
		bpmChanges.killMembers();

		for(bpmData in snapshot.bpmChanges){
			addBPMChange(bpmData.time, bpmData.bpm);
		}

		updateConductorBPMChanges();

		for(noteData in snapshot.notes){
			var newNote = addNote(noteData.time, noteData.direction, noteData.player, noteData.tag);
			newNote.sustainLength = noteData.length;
		}

		for(eventData in snapshot.events){
			addEvent(eventData.time, eventData.lane, eventData.tag);
		}

		FlxG.sound.music.time = getSongPositionFromY(startingY);
		Conductor.songPosition = FlxG.sound.music.time;
	}

	inline function getUndoActionText(action:UndoAction):String{
		switch(action){
			case PLACE_NOTES(count): return "placed note"+(count==1?"":"s");
			case REMOVE_NOTES(count): return "deleted note"+(count==1?"":"s");
			case CHANGE_HOLD_DURATION: return "note duration change";
			case CHANGE_NOTE_TAG: return "note tag change";
			case PLACE_EVENTS(count): return "placed event"+(count==1?"":"s");
			case REMOVE_EVENTS(count): return "deleted event"+(count==1?"":"s");
			case CHANGE_EVENT_TAG: return "event tag change";
			case PLACE_BPM(count): return "placed BPM change"+(count==1?"":"s");
			case REMOVE_BPM(count): return "deleted BPM change"+(count==1?"":"s");
			case CUT: return "cut";
			case PASTE: return "paste";
			default: return "";
		}
	}

	private function saveChartToFile(){
		generateChart();
		var data:String = Json.stringify(chart, null, "\t");
		if(data != null && data.length > 0){
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, onSaveComplete);
			fileReference.addEventListener(Event.CANCEL, onSaveCancel);
			//fileReference.addEventListener(IOErrorEvent.IO_ERROR, onSaveError); //I don't think this does anything for local files.
			fileReference.save(data.trim(), "chart-" + difficultyDropdown.value.toLowerCase() + ".json");
		}
	}

	private function saveEventsToFile(){
		generateChart();
		var data:String = Json.stringify(chartEvents, null, "\t");
		if(data != null && data.length > 0){
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, onSaveComplete);
			fileReference.addEventListener(Event.CANCEL, onSaveCancel);
			//fileReference.addEventListener(IOErrorEvent.IO_ERROR, onSaveError); //I don't think this does anything for local files.
			fileReference.save(data.trim(), "events.json");
		}
	}

	private function onSaveComplete(_):Void{
		fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
		//fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference = null;
		createAlert("File saved.");
	}

	private function onSaveCancel(_):Void{
		fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
		//fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference = null;
	}

	/*private function onSaveError(_):Void{
		fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
		fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference = null;
		createAlert("Error saving file.");
	}*/

	function createArguments(tag:String, forNoteType:Bool):Void{
		if(!forNoteType){
			eventDescription.text = "";
			for(eventParam in eventParams){
				for(element in eventParam.elements){
					panel.removeFromTab("Events", element);
					element.destroy();
				}
			}
			eventParams = [];
		}
		else{
			noteDescription.text = "";
			for(noteParam in noteParams){
				for(element in noteParam.elements){
					panel.removeFromTab("Notes", element);
					element.destroy();
				}
			}
			noteParams = [];
		}

		var prefix:String = "";
		if(tag.length > 0){
			prefix = tag.split(";")[0];
		}
		else{ return; }
		
		if(!forNoteType){
			var eventDefinition = Events.events.get(prefix);
			if(eventDefinition == null){ return; }
			if(eventDefinition.editor == null){ return; }
			if(eventDefinition.editor.description != null){
				eventDescription.text = eventDefinition.editor.description;
				eventDescription.y = panel.y + panel.elementHeight - 1 - Box.BORDER_SIZE - eventDescription.height;
			}
			if(eventDefinition.editor.arguments == null){ return; }
			var defaultArgs = Events.getArgs(tag);
	
			for(i in 0...eventDefinition.editor.arguments.length){
				makeArgument(eventDefinition.editor.arguments[i], eventParamStartLocation+((24+PANEL_SPACING)*i), forNoteType, defaultArgs[i]);
			}

			eventPrefixDropdown.setSelectedTo(prefix);

			buildEventTag();
		}
		else{
			var noteDefinition = NoteType.types.get(prefix);
			if(noteDefinition == null){ return; }
			if(noteDefinition.editor == null){ return; }
			if(noteDefinition.editor.description != null){
				noteDescription.text = noteDefinition.editor.description;
				noteDescription.y = panel.y + panel.elementHeight - 1 - Box.BORDER_SIZE - noteDescription.height;
			}
			if(noteDefinition.editor.arguments == null){ return; }
			var defaultArgs = NoteType.getArgs(tag);
			
			for(i in 0...noteDefinition.editor.arguments.length){
				makeArgument(noteDefinition.editor.arguments[i], eventParamStartLocation+((24+PANEL_SPACING)*i), forNoteType, defaultArgs[i]);
			}

			notePrefixDropdown.setSelectedTo(prefix);
			
			buildNoteTag();
		}
	}

	function makeArgument(argData:EventArgument, y:Float, forNoteType:Bool, argValue:String):Void{
		var arg:ArgumentInput = {elements: [], value: argValue, defaultValue: argData.value};

		function buildTag(){
			if(!forNoteType) { buildEventTag(); } else { buildNoteTag(); }
		}

		switch(argData.type){
			case bool:
				var input:Toggle = new Toggle(PANEL_SPACING, y, Events.parseBool(arg.value), argData.name);
				arg.elements.push(input);

				input.onToggle.add(function(v:Bool){
					arg.value = ""+v;
					buildTag();
				});

			case int:
				var input:Stepper = new Stepper(PANEL_SPACING, y, 192, Std.parseInt(arg.value), 1, null, null, true, argData.name);
				input.isInt = true;
				arg.elements.push(input);

				input.onValueChanged.add(function(v:Float){
					arg.value = ""+Std.int(v);
					buildTag();
				});

			case float:
				var input:Stepper = new Stepper(PANEL_SPACING, y, 192, Std.parseFloat(arg.value), 1, null, null, true, argData.name);
				arg.elements.push(input);

				input.onValueChanged.add(function(v:Float){
					arg.value = ""+v;
					buildTag();
				});

			case string:
				var input:TextInput = new TextInput(PANEL_SPACING, y, 192, arg.value, argData.name);
				arg.elements.push(input);

				input.onValueChanged.add(function(v:String){
					arg.value = v;
					buildTag();
				});

			case ease:
				final valueWithCaptital:String = arg.value.charAt(0).toUpperCase() + arg.value.substr(1, 99);
				final initalEaseValue:String = arg.value.endsWith("In") ? valueWithCaptital.split("In")[0] : arg.value.endsWith("InOut") ? valueWithCaptital.split("InOut")[0] : arg.value.endsWith("Out") ? valueWithCaptital.split("Out")[0] : "Linear";
				var easeDropdown:Dropdown = new Dropdown(PANEL_SPACING, y, 99, ["Linear", "Quad", "Cube", "Quart", "Quint", "SmoothStep", "SmooterStep", "Sine", "Bounce", "Circ", "Expo", "Back", "Elastic"], initalEaseValue);
				arg.elements.push(easeDropdown);

				final initalDrectionValue:String = arg.value.endsWith("In") ? "In" : arg.value.endsWith("InOut") ? "InOut" : "Out";
				var directionDropdown:Dropdown = new Dropdown(easeDropdown.x + easeDropdown.elementWidth + PANEL_SPACING, y, 88, ["In", "Out", "InOut"], initalDrectionValue, argData.name);
				arg.elements.push(directionDropdown);

				easeDropdown.onSelect.add(function(v:String){
					if(easeDropdown.value == "Linear"){ arg.value = "linear"; }
					else{ arg.value = easeDropdown.value.charAt(0).toLowerCase() + easeDropdown.value.substr(1, 99) + directionDropdown.value; }
					buildTag();
				});

				directionDropdown.onSelect.add(function(v:String){
					if(easeDropdown.value == "Linear"){ arg.value = "linear"; }
					else{ arg.value = easeDropdown.value.charAt(0).toLowerCase() + easeDropdown.value.substr(1, 99) + directionDropdown.value; }
					buildTag();
				});

			case time:
				var initalNumberValue:Float = arg.value.endsWith("b") ? Std.parseFloat(arg.value.split("b")[0]) : arg.value.endsWith("s") ? Std.parseFloat(arg.value.split("s")[0]) : Std.parseFloat(arg.value);
				initalNumberValue = Math.isNaN(initalNumberValue) ? 0 : initalNumberValue;
				var numberInput:Stepper = new Stepper(PANEL_SPACING, y, 110, initalNumberValue, 0.1, 0, null, true);
				arg.elements.push(numberInput);

				final initalUnitValue:String = arg.value.endsWith("b") ? "Beat" : arg.value.endsWith("s") ? "Step" : "Sec";
				var unitInput:Dropdown = new Dropdown(numberInput.x + numberInput.elementWidth + PANEL_SPACING, y, 77, ["Sec", "Beat", "Step"], initalUnitValue, argData.name);
				arg.elements.push(unitInput);

				numberInput.onValueChanged.add(function(v:Float){
					arg.value = numberInput.value + (unitInput.value == "Beat" ? "b" : unitInput.value == "Step" ? "s" : "");
					buildTag();
				});

				unitInput.onSelect.add(function(v:String){
					arg.value = numberInput.value + (unitInput.value == "Beat" ? "b" : unitInput.value == "Step" ? "s" : "");
					buildTag();
				});

			case character:
				final initalValue:String = arg.value == "dad" ? "Opponent" : arg.value == "gf" ? "Speaker" : "Player";
				var input:Dropdown = new Dropdown(PANEL_SPACING, y, 192, ["Player", "Opponent", "Speaker"], initalValue, argData.name);
				arg.elements.push(input);

				input.onSelect.add(function(v:String){
					switch(v){
						case "Opponent":
							arg.value = "dad";
						case "Speaker":
							arg.value = "gf";
						default:
							arg.value = "bf";
					}
					buildTag();
				});
			
			case color:
				final initalValue:String = arg.value.startsWith("0x") ? arg.value.split("0x")[1] : arg.value;
				var input:TextInput = new TextInput(PANEL_SPACING, y, 163, initalValue);
				input.allowedCharacters = "0123456789ABCDEF";
				arg.elements.push(input);

				var colorPreview:Box = new Box(input.x + input.elementWidth + PANEL_SPACING, y, 24, 24);
				colorPreview.fillColor = FlxColor.fromString(arg.value);
				arg.elements.push(colorPreview);
				
				var label:UIText = new UIText(input.x + input.elementWidth + colorPreview.width + PANEL_SPACING*2, y+(input.elementHeight/2), argData.name);
				label.y -= label.height/2;
				label.color = UIColors.FILL_TEXT_COLOR;
				arg.elements.push(label);

				input.onValueChanged.add(function(v:String){
					arg.value = "0x"+v;
					colorPreview.fillColor = FlxColor.fromString(arg.value);
					buildTag();
				});

			case vocalTrack:
				final initalValue:String = arg.value == "bf" ? "Player" : arg.value == "dad" ? "Opponent" : "Both";
				var input:Dropdown = new Dropdown(PANEL_SPACING, y, 192, ["Player", "Opponent", "Both"], initalValue, argData.name);
				arg.elements.push(input);

				input.onSelect.add(function(v:String){
					switch(v){
						case "Player":
							arg.value = "bf";
						case "Opponent":
							arg.value = "dad";
						default:
							arg.value = "all";
					}
					buildTag();
				});
			
			case normalizedFloat:
				var input:Stepper = new Stepper(PANEL_SPACING, y, 192, Std.parseFloat(arg.value), 0.1, 0, 1, true, argData.name);
				arg.elements.push(input);

				input.onValueChanged.add(function(v:Float){
					v = Utils.truncateFloat(v, 3);
					arg.value = ""+v;
					input.value = v;
					input.updateNumberLabel();
					buildTag();
				});

			default:
				trace("Type \"" + argData.type + "\" is not implemented!");
		}
		
		if(!forNoteType){
			for(element in arg.elements){ panel.addToTab("Events", element); }
			eventParams.push(arg);
		}
		else{
			for(element in arg.elements){ panel.addToTab("Notes", element); }
			noteParams.push(arg);
		}
	}

	function buildEventTag():Void{
		var tag:String = eventPrefixDropdown.value;
		var sections:Array<TagBuilderSection> = [];
		for(i in 0...eventParams.length){
			sections.push({section: ";" + eventParams[i].value, makeBlank: eventParams[i].value == eventParams[i].defaultValue});
			if(eventParams[i].value != eventParams[i].defaultValue){
				for(arg in sections){ arg.makeBlank = false; }
			}
		}
		for(section in sections){
			if(!section.makeBlank){ tag += section.section; }
		}
		eventTagInput.value = tag;
	}
	
	function buildNoteTag():Void{
		var tag:String = notePrefixDropdown.value;
		var sections:Array<TagBuilderSection> = [];
		for(i in 0...noteParams.length){
			sections.push({section: ";" + noteParams[i].value, makeBlank: noteParams[i].value == noteParams[i].defaultValue});
			if(noteParams[i].value != noteParams[i].defaultValue){
				for(arg in sections){ arg.makeBlank = false; }
			}
		}
		for(section in sections){
			if(!section.makeBlank){ tag += section.section; }
		}
		noteTypeInput.value = tag;
	}

	inline function canDoThings():Bool{
		return !panel.isAnythingFocused() && !hotbarAssignAlertOpen && !bpmChangeBoxOpen;
	}
	
	inline function openHotbarAlert(forNote:Bool):Void{
		hotbarAssignText.text = "Select a hotbar slot to assign this " + (forNote?"note":"event") + " to. Click on the slot or use the number keys to select a slot. Press Escape to cancel.";
		hotbarAssignAlertForNote = forNote;
		hotbarAssignAlertOpen = true;
		hotbarAssignOverlay.visible = true;
		hotbarAssignPanel.visible = true;
	}

	inline function closeHotbarAlert():Void{
		hotbarAssignAlertOpen = false;
		hotbarAssignOverlay.visible = false;
		hotbarAssignPanel.visible = false;
	}

	function updateHotbarGraphics():Void{
		for(i in 0...hotbarSlots.length){
			switch(hotbarSlots[i].type){
				case empty:
					hotbarSlotNotes[i].visible = false;
					hotbarSlotEvents[i].visible = false;

				case note:
					hotbarSlotNotes[i].visible = true;
					hotbarSlotEvents[i].visible = false;

					hotbarSlotNotes[i].updateProperties(hotbarSlotNotes[i].x, hotbarSlotNotes[i].y, i%4, 0, false, hotbarSlots[i].tag);

				case event:
					hotbarSlotNotes[i].visible = false;
					hotbarSlotEvents[i].visible = true;

					hotbarSlotEvents[i].updateProperties(hotbarSlotEvents[i].x, hotbarSlotEvents[i].y, 0, 0, hotbarSlots[i].tag);
			}
		}
	}

	inline function openBPMPanel(time:Float):Void{
		bpmChangeBoxOpen = true;
		topOverlay.visible = true;
		bpmChangePanel.visible = true;
		bpmChangeTime = time;
		bpmInput.value = Conductor.getBPMDefine(time).bpm;
		bpmInput.updateNumberLabel();
	}

	function closeBPMPanel(addChange:Bool = false):Void{
		bpmChangeBoxOpen = false;
		topOverlay.visible = false;
		bpmChangePanel.visible = false;

		if(addChange){
			addBPMChange(bpmChangeTime, bpmInput.value);
			retimeNotesAndEvents();
			createSnapshot(PLACE_BPM(1));
			createAlert("Added BPM change.");
		}
	}

	function retimeNotesAndEvents():Void{
		var startingY:Float = getYFromSongPosition(FlxG.sound.music.time);
		Conductor.setBPMChanges([bpmChanges.getFirstAlive().generateBPMDefinition()]);
		bpmChanges.forEachAlive(function(bpmChange:ChartingBPM){
			bpmChange.time = getSongPositionFromY(bpmChange.y);
			updateConductorBPMChanges(bpmChange.time);
		});
		notes.forEachAlive(function(note:ChartingNote){
			note.time = getSongPositionFromY(note.y);
		});
		events.forEachAlive(function(event:ChartingEvent){
			event.time = getSongPositionFromY(event.y);
		});
		FlxG.sound.music.time = getSongPositionFromY(startingY);
		Conductor.songPosition = FlxG.sound.music.time;
	}

	function updateConductorBPMChanges(?cutoff:Null<Float> = null):Void{
		var bpmArray:Array<BPMDefinition> = [];
		bpmChanges.forEachAlive(function(bpmChange:ChartingBPM){
			if(cutoff == null || bpmChange.time <= cutoff){
				bpmArray.push(bpmChange.generateBPMDefinition());
			}
		});
		Conductor.setBPMChanges(bpmArray);
	}
}