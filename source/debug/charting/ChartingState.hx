package debug.charting;

import note.NoteType;
import characters.CharacterInfoBase;
import modding.PolymodHandler;
import characters.ScriptableCharacter;
import events.Events;
import ui.HealthIcon;
import flixel.util.FlxSort;
import extensions.flixel.addons.ui.FlxUIDropDownMenuScrollable;
import note.Note;
import transition.data.InstantTransition;
import flixel.addons.ui.FlxUIText;
import config.Config;
import flixel.group.FlxSpriteGroup;
import transition.data.InstantTransition;
import openfl.display.Bitmap;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import Song.SongEvents;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;

import haxe.ui.backend.flixel.UIState;
import haxe.ui.events.UIEvent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.focus.FocusManager;
import debug.charting.ui.*;
import debug.charting.components.*;
import haxe.ui.containers.menus.*;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.containers.dialogs.Dialogs;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("art/ui/chart/tabBar.xml"))
class ChartingState extends UIState
{

	public static var screenshotBitmap:Bitmap = null;
	public static var startSection:Int = 0;

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	public static var stageList:Array<String> = [];

	static var eventIconList:Array<String> = [];
	static var eventIconOverrides:Map<String, String> = new Map<String, String>();

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public var curSection:Int = 0;

	var timeOld:Float = 0;

	public var ee2Check:Bool;

	public static var lastSection:Int = 0;

	final GRID_SIZE:Int = 40;

	var bpmTxt:FlxText;
	var stageDropDown:FlxUIDropDownMenuScrollable;
	final diffList:Map<String, String> = [
		"Easy" => "-easy",
		"Normal" => "",
		"Hard" => "-hard"
	];
	var diffDropFinal:String = "";
	var diffDrop:FlxUIDropDownMenu;

	public var strumLine:FlxSprite;
	var bullshitUI:FlxGroup;

	final strumColors:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
	final eventColors:Array<FlxColor> = [0xFFFFFFFF, 0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFF00FF, 0xFFFFFF00, 0xFF00FFFF, 0xFFFF9100, 0xFFA200FF, 0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F, 0xFF00FFBF, 0xFFFF0095, 0xFFC8FF00, 0xFF0077FF];

	public var highlight:FlxSprite;

	//var TRIPLE_GRID_SIZE:Float = 40 * 4/3;

	var dummyArrow:FlxSprite;
	var holding:Bool;

	public var curRenderedNotes:FlxTypedGroup<Note>;
	public var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	public var curRenderedEvents:FlxTypedGroup<EventSprite>;

	var gridBG:FlxSprite;
	var gridBG2:FlxSprite;
	//var gridBGTriple:FlxSprite;
	var gridBGOverlay:FlxSprite;

	public var _song:SwagSong;
	public var _events:SongEvents;

	var noteType:FlxUIInputText;

	var textBoxArray:Array<FlxUIInputText> = [];

	var eventTagList:Array<String> = [""];
	var allEventPrefixes:Array<String> = [];

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	public var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	public var vocals:FlxSound;
	public var vocalsOther:FlxSound;

	public var leftIcon:HealthIcon;
	public var rightIcon:HealthIcon;

	public var leftIconBack:FlxSprite;
	public var rightIconBack:FlxSprite;
	
	public var justChanged:Bool;

	var lilBuddies:LilBuddies;

	var eventCache:Map<String, BitmapData> = new Map();

	var dataWindow:DataWindow;
	var sectionWindow:SectionWindow;
	var noteWindow:NoteWindow;
	var eventWindow:EventWindow;

	public var bfClickSoundCheck:MenuCheckBox;
	public var oppClickSoundCheck:MenuCheckBox;

	// Todo: make Dynamic to ChartWindowBasic and ChartComponentBasic

	public var windows:Map<String, Dynamic> = [];

	public var components:Map<String, Dynamic> = [];

	override function create()
	{

		Config.setFramerate(120);

		PlayState.fromChartEditor = true;
		SaveManager.global();
		ee2Check = Config.ee2;

		loadLists();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xfff95ba4;
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		//Hardcoded Components
		components.set("lilBuddies", new LilBuddies(32, 432, this));

		lastSection = 0;

		var gridBG2Length:Int = 4;

		//gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * 16, true, 0xFFE7E7E7, 0xFFC5C5C5);
		gridBG = new FlxSprite().makeGraphic(GRID_SIZE * 12, GRID_SIZE * 16);


		//gridBGTriple = FlxGridOverlay.create(GRID_SIZE, Std.int(GRID_SIZE * 4/3), GRID_SIZE * 12, GRID_SIZE * 16, true, 0xFFE7E7E7, 0xFFC5C5C5);
		//gridBGTriple.visible = false;

		//gridBG2 = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * 16 * gridBG2Length, true, 0xFF515151, 0xFF3D3D3D);
		gridBG2 = new FlxSprite().makeGraphic(GRID_SIZE * 12, GRID_SIZE * 16 * gridBG2Length);

		//gridBGOverlay = FlxGridOverlay.create(GRID_SIZE * 4, GRID_SIZE * 4, GRID_SIZE * 12, GRID_SIZE * 16 * gridBG2Length, true, 0xFFFFFFFF, 0xFFB5A5CE);
		//gridBGOverlay.blend = "multiply";

		var gridParts:FlxSpriteGroup = new FlxSpriteGroup();

		var gridWhiteBitmap = FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 4, true, 0xFFE7E7E7, 0xFFC5C5C5);
		var gridPurpleBitmap = FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 4, true, 0xFFA495BB, 0xFF8C7F9F);
		var gridDarkWhiteBitmap = FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 4, true, 0xFF515151, 0xFF3D3D3D);
		var gridDarkPurpleBitmap = FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 4, true, 0xFF393441, 0xFF2B2731);

		for(iy in 0...4 * gridBG2Length){
			for(ix in 0...3){
				var isDark = iy >= 4;
				var isPurple = (iy % 2 == 0 && ix == 1) || (iy % 2 == 1 && ix != 1);
				var gridSegment = new FlxSprite(GRID_SIZE * ix * 4, GRID_SIZE * iy * 4).loadGraphic((isPurple ? (isDark ? gridDarkPurpleBitmap : gridPurpleBitmap) : (isDark ? gridDarkWhiteBitmap : gridWhiteBitmap)));
				gridSegment.active = false;
				gridParts.add(gridSegment);
			}
		}

		//add(gridBG2);
		//add(gridBG);
		//add(gridBGTriple);
		//add(gridBGOverlay);

		add(gridParts);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');

		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setPosition((gridBG.width / 6) - (leftIcon.width / 4), -75);
		rightIcon.setPosition((gridBG.width / 6) * 3 - (rightIcon.width / 4), -75);

		leftIconBack = new FlxSprite(leftIcon.x - 2.5, leftIcon.y - 2.5).makeGraphic(75, 75, 0xFF00AAFF);
		rightIconBack = new FlxSprite(rightIcon.x - 2.5, rightIcon.y - 2.5).makeGraphic(75, 75, 0xFF00AAFF);

		var eventIcon = new FlxSprite().loadGraphic(Paths.image("chartEditor/event/genericEvent"));
		eventIcon.setPosition(((gridBG.width / 6) * 5) - (eventIcon.width / 2), -75 + (eventIcon.width / 2));
		//eventIcon.color = 0xFFFF0000;
		
		add(leftIconBack);
		add(rightIconBack);
		add(leftIcon);
		add(rightIcon);

		add(eventIcon);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 3).makeGraphic(2, Std.int(gridBG2.height), FlxColor.BLACK);
		add(gridBlackLine);

		var gridBlackLine2:FlxSprite = new FlxSprite(gridBG.x + (gridBG.width / 3) * 2).makeGraphic(2, Std.int(gridBG2.height), FlxColor.BLACK);
		add(gridBlackLine2);

		for(i in 1...gridBG2Length){

			var gridSectionLine:FlxSprite = new FlxSprite(gridBG.x, gridBG.y + (gridBG.height * i)).makeGraphic(Std.int(gridBG2.width), 2, FlxColor.BLACK);
			add(gridSectionLine);

		}

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedEvents = new FlxTypedGroup<EventSprite>();

		if (PlayState.SONG != null){
			_song = PlayState.SONG;
			_song = sanatizeSong(_song);
		}
		else {
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				player1: 'Bf',
				player2: 'Dad',
				stage: 'Stage',
				gf: 'Gf',
				speed: 1
			};
		}

		if (PlayState.EVENTS != null)
			_events = PlayState.EVENTS;
		else
		{
			_events = {
				events: []
			};
		}

		for(i in _events.events){
			pushEvent(i[3]);
		}
		
		for(x in _song.notes){
			if(!x.changeBPM)
				x.bpm = 0;
		}

		FlxG.mouse.visible = true;
		//FlxG.save.bind(_song.song.replace(" ", "-"), "Rozebud/FPSPlus/Chart-Editor-Autosaves");
		SaveManager.chartAutosave(_song.song.replace(" ", "-"));

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1140, 50, 0, "", 12);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4, 0xFF0000FF);
		add(strumLine);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Event", label: 'Event'},
			{name: "Tools", label: 'Tools'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 830;
		UI_box.y = 20;
		//add(UI_box);

		setFileUI();
		setToolsUI();
		setMiscUI();

		dataWindow = new DataWindow(this);

		sectionWindow = new SectionWindow(this);
		addSectionUI();
		noteWindow = new NoteWindow(this);
		addNoteUI();
		addEventUI();
		eventWindow = new EventWindow(this);

		// Uhh should add softcode support of this too?
		windows = [
			"Song Properties" => dataWindow,
			"Section Properties" => sectionWindow,
			"Note Properties" => noteWindow,
			"Event Properties" => eventWindow
		];

		for (window in windows.keys())
		{
			var windowBox = new MenuCheckBox();
			windowBox.text = window;
			windowBox.onClick = function(e){
				if (windowBox.selected)
					windows.get(window).open();
				else
					windows.get(window).close();
			}

			windowBox.selected = false;

			windowMenu.addComponent(windowBox);
			//windows.get(window).open();
		}



		updateHeads(true);

		FlxG.camera.follow(strumLine);

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);

		for(i in 0..._song.notes.length){
			removeDuplicates(i);
		}

		super.create();

		if(startSection > 0){
			changeSection(startSection);
		}

		startSection = 0;
	}

	function setFileUI():Void
	{
		saveChartButton.onClick = function(e){ saveLevel(); };

		saveEventButton.onClick = function(e){ saveEvents(); };

		reloadMusicButton.onClick = function(e)
		{
			loadSong(_song.song);
		};

		reloadChartButton.onClick = function(e)
		{
			loadJson(_song.song.toLowerCase());
		};

		loadAutoSaveButton.onClick = function(e){ loadAutosave(); };

		clearChartButton.onClick = function(e)
		{
			PlayState.SONG = {
				song: _song.song,
				notes: [],
				bpm: 120.0,
				player1: 'Bf',
				player2: 'Dad',
				stage: 'Stage',
				gf: 'Gf',
				speed: 1
			};

			PlayState.EVENTS = {
				events: []
			};

			FlxG.resetState();
		};
	}

	function setToolsUI():Void
	{
		muteInstCheck.selected = false;
		muteInstCheck.onClick = function(e){
			if(muteInstCheck.selected){
				FlxG.sound.music.volume = 0;
			}
			else{
				FlxG.sound.music.volume = 0.6;
			}
		};

		muteVocalCheck.selected = false;
		muteVocalCheck.onClick = function(e){
			if(muteVocalCheck.selected){
				vocals.volume = 0;
			}
			else{
				vocals.volume = 1;
			}
		};

		muteVocalOtherCheck.selected = false;
		muteVocalOtherCheck.onClick = function(e){
			if(muteVocalOtherCheck.selected){
				vocalsOther.volume = 0;
			}
			else{
				vocalsOther.volume = 1;
			}
		};
	
		bfClickSoundCheck.selected = false;
		oppClickSoundCheck.selected = false;

		lilBuddiesCheck.selected = true;
		lilBuddiesCheck.onClick = function(e){
			components.get("lilBuddies").visible = lilBuddiesCheck.selected;
		};

		halfSpeedCheck.selected = false;
		halfSpeedCheck.onClick = function(e){
			if(halfSpeedCheck.selected){
				FlxG.sound.music.pitch = 0.5;
				vocals.pitch = 0.5;
				vocalsOther.pitch = 0.5;
			}
			else{
				FlxG.sound.music.pitch = 1;
				vocals.pitch = 1;
				vocalsOther.pitch = 1;
			}
		}
	}

	function setMiscUI():Void
	{
		controlButton.onClick = function(e){
			createModal("Control Info",
			"LEFT CLICK - Place Notes\nRIGHT CLICK - Delete Notes\nMIDDLE CLICK - Reselect a note.\n\nSHIFT - Unlock cursor from grid\nALT - Triplets\nCONTROL - 1/32 Notes\nSHIFT + CONTROL - 1/64 Notes\n\nTAB - Place notes on both sides\nHJKL - Place notes during\n                       playback\n\nR - Top of section\nCTRL + R - Song start\n\nENTER - Test chart.\nCTRL + ENTER - Test chart from\n                         current section.",
			"info");
		}
	}

	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, 0, 0, 999, 0);
		stepperSectionBPM.value = _song.notes[0].bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);

		UI_box.addGroup(tab_group_section);
	}

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		noteType = new FlxUIInputText(10, 30, 160, "", 8);
		textBoxArray.push(noteType);
	
		tab_group_note.add(noteType);

		UI_box.addGroup(tab_group_note);
	}

	function addEventUI():Void
	{
		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 40, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 40, "Copy", function()
		{
			copyEventSection(Std.int(stepperCopy.value));
		});

		var clearButton:FlxButton = new FlxButton(210, 40, "Clear Section", function()
		{
			clearEventSection(curSection);
		});

		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Event';

		var eventInfo = new FlxText(10, 400, 400, "EVENT INFORMATION\n\nArguments are separated by a semicolon ( ; )\n\nArgument Types:\n   Int: A non decimal number\n   Float: A decimal number\n   Bool: true or false\n   String: text\n   Hex: A hexadecimal number prefixed with \"0x\"\n   Time: A float that can be suffixed with a \"b\" or an \"s\"\n          \"b\" makes it a length in beats\n          \"s\" makes it a length in steps\n          Otherwise it's in seconds\n   Ease: An FlxEase type", 11);

		tab_group_event.add(eventInfo);
		tab_group_event.add(stepperCopy);
		tab_group_event.add(copyButton);
		tab_group_event.add(clearButton);

		UI_box.addGroup(tab_group_event);
		
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		if(Utils.exists(Paths.voices(daSong, "Player"))){
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong, "Player"));
			vocalsOther = new FlxSound().loadEmbedded(Paths.voices(daSong, "Opponent"));
			
		}
		else if(Utils.exists(Paths.voices(daSong))){
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
			vocalsOther = new FlxSound();
		}
		else{
			vocals = new FlxSound();
			vocalsOther = new FlxSound();
		}

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(vocalsOther);

		FlxG.sound.music.pause();

		FlxG.sound.music.time = 0;

		vocals.play();
		vocals.pause();
		vocals.time = FlxG.sound.music.time;

		vocalsOther.play();
		vocalsOther.pause();
		vocalsOther.time = FlxG.sound.music.time;

		FlxG.sound.music.volume = 0.6;

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			vocalsOther.pause();
			vocalsOther.time = 0;

			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
				autosaveSong();
			}
			else if (wname == 'section_bpm')
			{
				Conductor.mapBPMChanges(_song);
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
				autosaveSong();
			}
			else if (wname == 'check_changeBPM')
			{
				Conductor.mapBPMChanges(_song);
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
				autosaveSong();
			}
		}
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = dataWindow.songNameField.text;

		strumLine.y = getYfromStrum(Conductor.songPosition - sectionStartTime());

		if (Math.ceil(strumLine.y) >= gridBG.height)
		{
			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		} else if(strumLine.y < -10) {
			changeSection(curSection - 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if(eventWindow.eventField.focus){
			updateEventDescription();
		}

		if (FocusManager.instance.focus == null)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					vocalsOther.pause();
				}
				else
				{
					vocals.play();
					vocalsOther.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.CONTROL)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.keys.justPressed.U){
				_song.notes[curSection].mustHitSection = !_song.notes[curSection].mustHitSection;
				sectionWindow.mustHitCheck.selected = _song.notes[curSection].mustHitSection;
				updateHeads();
				swapSections();
			}

			if (FlxG.mouse.wheel != 0){
				// && strumLine.y > gridBG.y)
				var wheelSpin = FlxG.mouse.wheel;

				FlxG.sound.music.pause();
				vocals.pause();
				vocalsOther.pause();

				if(wheelSpin > 0 && strumLine.y < gridBG.y)
					wheelSpin = 0;

				if(wheelSpin < 0 && strumLine.y > gridBG2.y + gridBG2.height)
					wheelSpin = 0;
					

				FlxG.sound.music.time -= (wheelSpin * Conductor.stepCrochet * 0.4);

				/*while(strumLine.y < gridBG.y){
					FlxG.sound.music.time += 1;
					Conductor.songPosition = FlxG.sound.music.time;
					strumLine.y = getYfromStrum(Conductor.songPosition - sectionStartTime());
				}
				while(strumLine.y > gridBG2.y + gridBG2.height){
					FlxG.sound.music.time -= 1;
					Conductor.songPosition = FlxG.sound.music.time;
					strumLine.y = getYfromStrum(Conductor.songPosition - sectionStartTime());
				}*/

				vocals.time = FlxG.sound.music.time;
				vocalsOther.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT){
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN){
					FlxG.sound.music.pause();
					vocals.pause();
					vocalsOther.pause();

					var daTime:Float = 1000 * FlxG.elapsed;

					if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && strumLine.y > gridBG.y){
						FlxG.sound.music.time -= daTime;
					}
					else if (strumLine.y < gridBG2.y + gridBG2.height)
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
					vocalsOther.time = FlxG.sound.music.time;
				}
			}
			else{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN){
					FlxG.sound.music.pause();
					vocals.pause();
					vocalsOther.pause();

					var daTime:Float = 2500 * FlxG.elapsed;

					if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && strumLine.y > gridBG.y){
						FlxG.sound.music.time -= daTime;
					}
					else if (strumLine.y < gridBG2.y + gridBG2.height)
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
					vocalsOther.time = FlxG.sound.music.time;
				}
			}

			if (FlxG.mouse.justPressed){
		
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + ((gridBG.width / 3) * 2)
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps)){
						FlxG.log.add('added note');
						addNote(getStrumTime(dummyArrow.y) + sectionStartTime(), Math.floor(FlxG.mouse.x / GRID_SIZE));
						holding = true;
					}
					
				else if (FlxG.mouse.x > gridBG.x + ((gridBG.width / 3) * 2)
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps)){
						FlxG.log.add('added event');
						addEventNote(getStrumTime(dummyArrow.y) + sectionStartTime(), Math.floor(FlxG.mouse.x / GRID_SIZE) - 8);
					}
		
			}
		
			if (FlxG.mouse.justPressedRight)
			{
		
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
		
					trace("Overlapping Notes");
		
					curRenderedNotes.forEach(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							deleteNote(note);
						}
					});
				}
				else if (FlxG.mouse.overlaps(curRenderedEvents))
				{
		
					trace("Overlapping Events");
		
					curRenderedEvents.forEach(function(event:EventSprite)
					{
						if (FlxG.mouse.overlaps(event))
						{
							deleteEvent(event);
						}
					});
				}
			}
		
			if (FlxG.mouse.justPressedMiddle)
			{
		
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
		
					trace("Overlapping Notes");
		
					var selected:Bool = false;
		
					curRenderedNotes.forEach(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note) && !selected)
						{
							selectNote(note);
							selected = true;
		
						}
					});
				}
				else if (FlxG.mouse.overlaps(curRenderedEvents))
				{
		
					trace("Overlapping Events");
		
					curRenderedEvents.forEach(function(event:EventSprite)
					{
						if (FlxG.mouse.overlaps(event))
						{
							eventWindow.eventField.text = event.tag;
						}
					});
				}
			}
		
			if(holding && FlxG.mouse.pressed){
		
				setNoteSustain((getStrumTime(dummyArrow.y) + sectionStartTime()) - curSelectedNote[0]);
		
			}
			else{
		
				holding = false;
		
			}
		
			if(curSection * 16 != curStep && curStep % 16 == 0 && FlxG.sound.music.playing){
		
				if(curSection * 16 > curStep){
					changeSection(curSection - 1, false);
				}
				else if(curSection * 16 < curStep){
					changeSection(curSection + 1, false);
				}
			}
		
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Z){

			}
		
			if (FlxG.mouse.x > gridBG.x
				&& FlxG.mouse.x < gridBG.x + gridBG.width
				&& FlxG.mouse.y > gridBG.y
				&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
			{
				dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
	
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT){
					dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / 4)) * (GRID_SIZE / 4);
				}
				else if (FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.ALT){
					dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE * 4/6)) * (GRID_SIZE * 4/6);
				}
				else if (FlxG.keys.pressed.ALT){
					dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE * 4/3)) * (GRID_SIZE * 4/3);
				}
				else if (FlxG.keys.pressed.CONTROL){
					dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / 2)) * (GRID_SIZE / 2);
				}
				else if (FlxG.keys.pressed.SHIFT){
					dummyArrow.y = FlxG.mouse.y;
				}
				else{
					dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
				}
			}
		
			if (FlxG.keys.justPressed.ENTER)
			{
				PlayState.SONG = _song;
				PlayState.EVENTS = _events;
				FlxG.sound.music.stop();
				vocals.stop();
				vocalsOther.stop();
				autosaveSong();
		
				//FlxG.save.bind("data", "Rozebud/FPSPlus");
				SaveManager.global();
		
				PlayState.sectionStart = false;
				if(FlxG.keys.pressed.CONTROL && curSection > 0){
					PlayState.sectionStart = true;
					changeSection(curSection, true);
					PlayState.sectionStartPoint = curSection;
					PlayState.sectionStartTime = FlxG.sound.music.time - (sectionHasBfNotes(curSection) ? Conductor.crochet : 0);
				}
					
				PlayState.loadEvents = false;
		
				switchState(new PlayState());
			}
		
			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
					changeNoteSustain(-Conductor.stepCrochet);
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);
		}

		_song.bpm = tempBpm;

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition, 0))
			+ "\t/ " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length, 0))
			+ "\n" + Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ "\t/ " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: " + curSection
			+ "\ncurBeat: " + curBeat
			+ "\ncurStep: " + curStep;

// || FlxG.keys.justPressed.X  || FlxG.keys.justPressed.C || FlxG.keys.justPressed.V
		if(FlxG.sound.music.playing){

			if(FlxG.keys.justPressed.H)
				addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(), 0 + (_song.notes[curSection].mustHitSection ? 4 : 0));

			if(FlxG.keys.justPressed.J)
				addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(), 1 + (_song.notes[curSection].mustHitSection ? 4 : 0));

			if(FlxG.keys.justPressed.K)
				addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(), 2 + (_song.notes[curSection].mustHitSection ? 4 : 0));

			if(FlxG.keys.justPressed.L)
				addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(), 3 + (_song.notes[curSection].mustHitSection ? 4 : 0));

		}

		justChanged = false;

		if(Startup.hasEe2 && FlxG.keys.justPressed.B && FlxG.keys.pressed.SHIFT){
			ee2Check = false;
			//FlxG.save.bind("data", "Rozebud/FPSPlus");
			SaveManager.global();
			FlxG.save.data.ee2 = false;
			SaveManager.flush();
			Config.reload();
			//FlxG.save.flush();
			//FlxG.save.bind(_song.song.replace(" ", "-"), "Rozebud/FPSPlus/Chart-Editor-Autosaves");
			SaveManager.chartAutosave(_song.song.replace(" ", "-"));
		}

		if(Startup.hasEe2 && lilBuddiesCheck.selected){
			if(!ee2Check && 
				!FlxG.sound.music.playing &&
				FlxG.mouse.screenX >= components.get("lilBuddies").lilBf.x &&
				FlxG.mouse.screenX <= components.get("lilBuddies").lilBf.x + components.get("lilBuddies").lilBf.width &&
				FlxG.mouse.screenY >= components.get("lilBuddies").lilBf.y &&
				FlxG.mouse.screenY <= components.get("lilBuddies").lilBf.y + components.get("lilBuddies").lilBf.height &&
				FlxG.mouse.justPressed){
	
					autosaveSong();

					//FlxG.save.bind("data", "Rozebud/FPSPlus");
					SaveManager.global();
					FlxG.save.data.ee2 = true;
					//FlxG.save.flush();
					SaveManager.flush();
					Config.reload();
	
					PlayState.fceForLilBuddies = true;
					screenshotBitmap = FlxScreenGrab.grab(null, false, true);
	
					customTransOut = new InstantTransition();
	
					var poop:String = Highscore.formatSong("lil-buddies", 2);
					PlayState.SONG = Song.loadFromJson(poop, "lil-buddies");
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					PlayState.loadEvents = true;
					PlayState.returnLocation = "freeplay";
					PlayState.storyWeek = 0;
					PlayState.overrideInsturmental = "";
					trace('CUR WEEK' + PlayState.storyWeek);
					switchState(new PlayState());
	
					//lilBf.animation.play("yeah");
			}
			else if(!FlxG.sound.music.playing &&
				FlxG.mouse.screenX >= components.get("lilBuddies").lilBf.x &&
				FlxG.mouse.screenX <= components.get("lilBuddies").lilBf.x + components.get("lilBuddies").lilBf.width &&
				FlxG.mouse.screenY >= components.get("lilBuddies").lilBf.y &&
				FlxG.mouse.screenY <= components.get("lilBuddies").lilBf.y + components.get("lilBuddies").lilBf.height &&
				FlxG.mouse.justPressed){
					components.get("lilBuddies").lilBf.animation.play("yeah");
			}
		}
		else if(lilBuddiesCheck.selected){
			if(!FlxG.sound.music.playing &&
				FlxG.mouse.screenX >= components.get("lilBuddies").lilBf.x &&
				FlxG.mouse.screenX <= components.get("lilBuddies").lilBf.x + components.get("lilBuddies").lilBf.width &&
				FlxG.mouse.screenY >= components.get("lilBuddies").lilBf.y &&
				FlxG.mouse.screenY <= components.get("lilBuddies").lilBf.y + components.get("lilBuddies").lilBf.height &&
				FlxG.mouse.justPressed){
					components.get("lilBuddies").lilBf.animation.play("yeah");
			}
		}

		if(Binds.justPressed("polymodReload")){
			PlayState.SONG = _song;
			PlayState.EVENTS = _events;
			PolymodHandler.reload();
		}

		super.update(elapsed);
	}

	public function updateEventDescription():Void{
		if(Events.eventsMeta.exists(eventWindow.eventField.text.split(";")[0])){
			var descText = Events.eventsMeta.get(eventWindow.eventField.text.split(";")[0]);
			if(eventWindow.eventDesc.text == descText){ return; }
			eventWindow.eventDesc.text = descText;
		}
		else{ eventWindow.eventDesc.text = ""; }
		//eventDesc.y = 410 - eventDesc.height;
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function setNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] = value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();
		vocalsOther.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		vocalsOther.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();

		for (component in components) component.resetSection(songBeginning);
	}

	public function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		justChanged = true;

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				vocalsOther.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				vocalsOther.time = FlxG.sound.music.time;
				updateCurStep();
			}

			//removeDuplicates(curSection);

			updateGrid();
			updateSectionUI();
		}

		for (component in components) component.changeSection(sec, updateMusic);
	}

	function copySection(?sectionNum:Int = 1){

		var daSec = FlxMath.maxInt(curSection, sectionNum);

		if(daSec - sectionNum < _song.notes.length && daSec - sectionNum >= 0){
			for (note in _song.notes[daSec - sectionNum].sectionNotes){
				var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);
				var type = note[3];
				if(type == null){ type = ""; }
	
				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], type];
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}
	
			removeDuplicates(curSection);
	
			updateGrid();
		}
		else{
			trace("Section does not exist.");
		}
		
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		sectionWindow.mustHitCheck.selected = sec.mustHitSection;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads(?changedCharacters:Bool = false):Void{

		if(changedCharacters){
			var leftChar:characters.CharacterInfoBase;
			var rightChar:characters.CharacterInfoBase;

			leftChar = ScriptableCharacter.init(dataWindow.oppDrop.text);
			rightChar = ScriptableCharacter.init(dataWindow.bfDrop.text);

			leftIcon.setIconCharacter(leftChar.info.iconName);
			leftIcon.iconScale = leftIcon.defualtIconScale * 0.5;
			rightIcon.setIconCharacter(rightChar.info.iconName);
			rightIcon.iconScale = rightIcon.defualtIconScale * 0.5;
		}

		if (_song.notes[curSection].mustHitSection){
			leftIconBack.alpha = 0;
			rightIconBack.alpha = 1;
		}
		else{
			leftIconBack.alpha = 1;
			rightIconBack.alpha = 0;
		}
	}

	function updateNoteUI():Void{
		
	}

	public function updateGrid():Void{

		curRenderedNotes.clear();
		curRenderedSustains.clear();
		curRenderedEvents.clear();
				
		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for(i in 0...4){

			//trace(_song.notes[curSection + i] != null);

			if(_song.notes[curSection + i] != null)
				addNotesToRender(curSection, i);

		}
	}

	private function addNotesToRender(curSec:Int, ?secOffset:Int = 0){

		var section:Array<Dynamic> = _song.notes[curSec + secOffset].sectionNotes;
		var noteAdjust:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];

		var eventSection:Array<Dynamic> = _events.events;

		if(_song.notes[curSec + secOffset].mustHitSection){
			noteAdjust = [4, 5, 6, 7, 0, 1, 2, 3];
		}

		for (i in section)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daNoteType = i[3];
	
				var note:Note = new Note(daStrumTime, daNoteInfo % 4, daNoteType, true);
				note.absoluteNumber = daNoteInfo;
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
				
				note.x = Math.floor(noteAdjust[daNoteInfo] * GRID_SIZE);

				note.y = (getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
				note.y += GRID_SIZE * 16 * secOffset;

				if(secOffset != 0)
					note.alpha = 0.4;

				if(curSelectedNote != null){
					if(daStrumTime 	== curSelectedNote[0] &&
					daNoteInfo 	== curSelectedNote[1] &&
					daSus 		== curSelectedNote[2]){
						note.glow();
					}
				}
	
				curRenderedNotes.add(note);
	
				if (daSus > 1)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 4,
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)), strumColors[daNoteInfo % 4]);
					if(secOffset != 0)
						sustainVis.alpha = 0.4;
					curRenderedSustains.add(sustainVis);
				}
			}
		
		for (i in eventSection){

			var slot = i[2];
			var strumTime = i[1];
			var section = i[0];
			var tag:String = i[3];

			if(section == curSec + secOffset){
				var eventSymbol = new EventSprite();
				var customIcon:Bool = false;

				#if sys
				var foundIcon:Bool = false;

				for(key => value in eventIconOverrides){
					if(tag.startsWith(key)){
						eventSymbol.loadGraphic(loadAndCacheEventGraphic(value));
						customIcon = true;
						foundIcon = true;
						break;
					}
				}

				if(!foundIcon){
					for(icon in eventIconList){
						if(tag == icon){
							eventSymbol.loadGraphic(loadAndCacheEventGraphic(icon));
							customIcon = true;
							foundIcon = true;
							break;
						}
						else if(tag.startsWith(icon)){
							eventSymbol.loadGraphic(loadAndCacheEventGraphic(icon));
							customIcon = true;
							foundIcon = true;
							break;
						}
					}
				}

				if(!foundIcon){
					eventSymbol.loadGraphic(Paths.image("chartEditor/event/genericEvent"));
				}
				#else
					eventSymbol.loadGraphic(Paths.image("chartEditor/event/genericEvent"));
				#end

				//eventSymbol.antialiasing = true;

				eventSymbol.setGraphicSize(40, 40);
				eventSymbol.updateHitbox();
				eventSymbol.x = Math.floor((slot + 8) * GRID_SIZE);

				eventSymbol.y = (getYfromStrum((strumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
				eventSymbol.y += GRID_SIZE * 16 * secOffset;

				if(!customIcon)
					eventSymbol.color = eventColors[eventTagList.indexOf(tag) % eventColors.length];

				if(secOffset != 0)
					eventSymbol.alpha = 0.4;

				eventSymbol.tag = tag;

				curRenderedEvents.add(eventSymbol);
			}
		}

	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: []
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{

		for(x in _song.notes[curSection].sectionNotes){

			if(approxEqual(x[0], note.strumTime, 3) && x[1] == note.absoluteNumber && approxEqual(x[2], note.sustainLength, 3)){

				curSelectedNote = x;
				noteType.text = x[3];
				break;

			}

		}

		//curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void{

		//trace('Trying: ' + note.strumTime);

		for (i in _song.notes[curSection].sectionNotes)
		{
			//trace("Testing: " + i[0]);
			if (approxEqual(i[0], note.strumTime, 3) && i[1] == note.absoluteNumber)
			{
				//trace('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}

		}

		_song.notes[curSection].sectionNotes.sort(sortByNoteStuff);

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSectionBF():Void
	{

		var newSectionNotes:Array<Dynamic> = [];

		if(_song.notes[curSection].mustHitSection){
			for(x in _song.notes[curSection].sectionNotes){
				if(x[1] > 3)
					newSectionNotes.push(x);
			}
		}
		else{
			for(x in _song.notes[curSection].sectionNotes){
				if(x[1] < 4)
					newSectionNotes.push(x);
			}
		}


		_song.notes[curSection].sectionNotes = newSectionNotes;
		_song.notes[curSection].sectionNotes.sort(sortByNoteStuff);

		updateGrid();
	}

	public function clearSectionOpp():Void
		{
	
			var newSectionNotes:Array<Dynamic> = [];
	
			if(_song.notes[curSection].mustHitSection){
				for(x in _song.notes[curSection].sectionNotes){
					if(x[1] < 4)
						newSectionNotes.push(x);
				}
			}
			else{
				for(x in _song.notes[curSection].sectionNotes){
					if(x[1] > 3)
						newSectionNotes.push(x);
				}
			}
	
	
			_song.notes[curSection].sectionNotes = newSectionNotes;
			_song.notes[curSection].sectionNotes.sort(sortByNoteStuff);
	
			updateGrid();
		}

	public function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(_noteStrum:Float, _noteData:Int, ?skipSectionCheck:Bool = false):Void
	{
		var noteAdjust:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];

		if(_song.notes[curSection].mustHitSection){
			noteAdjust = [4, 5, 6, 7, 0, 1, 2, 3];
		}

		var noteData = noteAdjust[_noteData];
		var noteStrum = _noteStrum;
		var noteSus = 0;
		var noteTypeString = noteType.text;

		if(!skipSectionCheck){
			while(noteStrum < sectionStartTime()){
				noteStrum++;
			}
		}
			

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteTypeString]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.TAB)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteTypeString]);
		}

		removeDuplicates(curSection, curSelectedNote);

		_song.notes[curSection].sectionNotes.sort(sortByNoteStuff);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	public function sortByNoteStuff(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	public function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	public function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		//Return if chart doesn't exist
		var findPath = Paths.json(song.toLowerCase() + '/' + song.toLowerCase() + diffDropFinal).trim();
		if(!Utils.exists(findPath)){
			createModal("Error!", "No Chart Found on " + findPath + "!", "error");
			return;
		}

		PlayState.SONG = Song.loadFromJson(song.toLowerCase() + diffDropFinal, song.toLowerCase());
		if(Utils.exists("assets/data/songs/" + song.toLowerCase() + "/events.json")){
			PlayState.EVENTS = Song.parseEventJSON(Utils.getText(Paths.json(song.toLowerCase() + "/events")));
		}
		if(PlayState.SONG.stage == null){
			PlayState.SONG.stage = _song.stage;
		}
		if(PlayState.SONG.gf == null){
			PlayState.SONG.gf = _song.gf;
		}
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		if (FlxG.save.data.autosave == null)
		{
			createModal("Warning", "No Autosave Found!", "warning");
			return;
		}
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		PlayState.EVENTS = Song.parseEventJSON(FlxG.save.data.autosaveEvents);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		SaveManager.chartAutosave(_song.song.replace(" ", "-"));
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.data.autosaveEvents = Json.stringify({
			"events": _events,
		});
		SaveManager.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + diffDropFinal + ".json");
		}
	}

	private function saveEvents()
	{
		_events.events.sort(sortByEventStuff);
		var json = {
			"events": _events
		};

		var data:String = Json.stringify(json, null, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	public function swapSections()
	{
		for (i in 0..._song.notes[curSection].sectionNotes.length)
		{
			_song.notes[curSection].sectionNotes[i][1] = (_song.notes[curSection].sectionNotes[i][1] + 4) % 8;
			updateGrid();
		}
		_song.notes[curSection].sectionNotes.sort(sortByNoteStuff);
	}

	function sectionHasBfNotes(section:Int):Bool{
		var notes = _song.notes[section].sectionNotes;
		var mustHit = _song.notes[section].mustHitSection;

		for(x in notes){
			if(mustHit) { if(x[1] < 4) { return true; } }
			else { if(x[1] > 3) { return true; } }
		}

		return false;

	}

	function removeDuplicates(section:Int, ?forceNote:Array<Dynamic> = null){

		var newNotes:Array<Dynamic> = [];

		if(forceNote != null){
			newNotes.push(forceNote);
		}

		for(x in _song.notes[section].sectionNotes){

			var add = true;

			for(y in newNotes){

				if(newNotes.length > 0){
					if(approxEqual(x[0], y[0], 6) && x[1] == y[1]){
						add = false;
					}
				}

			}

			if(add)
				newNotes.push(x);

		}

		_song.notes[section].sectionNotes = newNotes;
		_song.notes[section].sectionNotes.sort(sortByNoteStuff);

	}

	private function addEventNote(_noteStrum:Float, _noteData:Int):Void{
		var noteData = _noteData;
		var noteStrum = _noteStrum;
		var eventTag = eventWindow.eventField.text;
		var section = curSection;

		for (i in _events.events){
			if (approxEqual(i[1], noteStrum, 3) && (eventTag == i[3] || noteData == i[2])){
				return;
			}
		}

		if(pushEvent(eventWindow.eventField.text)){
			eventWindow.usedEventsDrop.dataSource = ArrayDataSource.fromArray(eventTagList);
		}

		_events.events.push([section, noteStrum, noteData, eventTag]);
		_events.events.sort(sortByEventStuff);
		
		//trace("Slot: " + noteData);
		//trace("Time: " + noteStrum);
		//trace("Tag:  " + eventTag);

		updateGrid();
		autosaveSong();
	}

	function deleteEvent(event:EventSprite):Void{

		var strumTime = getStrumTime(event.y) + sectionStartTime();

		var tag = event.tag;

		for (i in _events.events){
			if (approxEqual(i[1], strumTime, 3) && tag == i[3]){
				_events.events.remove(i);
			}

		}

		_events.events.sort(sortByEventStuff);

		var remove = (tag != "");
		if(remove){
			for (i in _events.events){
				if(i[3] == tag) { 
					remove = false;
					break;
				}
			}
		}
		if(remove){
			eventTagList.remove(tag);
			eventWindow.usedEventsDrop.dataSource = ArrayDataSource.fromArray(eventTagList);
		}
		

		updateGrid();
	}

	function sortByEventStuff(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[1], Obj2[1]);
	}

	function copyEventSection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (event in _events.events)
		{
			if(event[0] == daSec - sectionNum){
				var strum = event[1] + Conductor.stepCrochet * (16 * sectionNum);

				var copiedNote:Array<Dynamic> = [daSec, strum, event[2], event[3]];
				_events.events.push(copiedNote);
			}
		}

		_events.events.sort(sortByEventStuff);

		updateGrid();
	}

	function clearEventSection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (event in _events.events)
		{
			if(event[0] == daSec){
				_events.events.remove(event);
			}
		}

		_events.events.sort(sortByEventStuff);

		updateGrid();
	}

	function approxEqual(x:Dynamic, y:Dynamic, tolerance:Float){

		return x <= y + tolerance && x >= y - tolerance;

	}

	function loadAndCacheEventGraphic(tag:String):FlxGraphic{
		if(!eventCache.exists("assets/images/chartEditor/event/" + tag + ".png")){
			eventCache.set("assets/images/chartEditor/event/" + tag + ".png", BitmapData.fromFile("assets/images/chartEditor/event/" + tag + ".png"));
		}
		return FlxGraphic.fromBitmapData(eventCache.get("assets/images/chartEditor/event/" + tag + ".png"));
	}

	public static function loadLists():Void{
		var iconsRaw = Utils.readDirectory("assets/images/chartEditor/event/");
		for(icon in iconsRaw){
			if(icon.split(".")[1] == "png"){
				eventIconList.push(icon.split(".")[0]);
			}
			else if(icon.split(".")[1] == "json"){
				var json = Json.parse(Utils.getText("assets/images/chartEditor/event/" + icon));
				for(key in cast(json.overrides, Array<Dynamic>)){
					eventIconOverrides.set(key, icon.split(".")[0]);
				}
			}
		}

	}

	override function beatHit()
	{
		super.beatHit();
	}

	function sanatizeSong(song:SwagSong):SwagSong {

		var newNotes:Array<SwagSection> = [];

		for(x in song.notes){
			var sec = {
				lengthInSteps: x.lengthInSteps,
				bpm: x.bpm,
				changeBPM: x.changeBPM,
				mustHitSection: x.mustHitSection,
				sectionNotes: x.sectionNotes
			};
			newNotes.push(sec);
		}

		song = {
			song: song.song,
			notes: newNotes,
			bpm: song.bpm,
			player1: song.player1,
			player2: song.player2,
			stage: song.stage,
			gf: song.gf,
			speed: song.speed
		};

		return song;
		
	}

	function pushEvent(e:String):Bool{
		if(!eventTagList.contains(e) && !e.startsWith("cc;")){
			eventTagList.push(e);
			return true;
		}
		return false;
	}

	public function createModal(title:String, message:String, boxType:String = "yesno"):Void{
		Dialogs.messageBox(message, title, boxType, true);
	}
	
}

class EventSprite extends FlxSprite{

	public var tag:String;

}