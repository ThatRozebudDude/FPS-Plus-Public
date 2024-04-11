package debug;

import transition.data.InstantTransition;
import flixel.addons.ui.FlxUIText;
import flixel.util.FlxTimer;
import haxe.rtti.Meta;
import config.Config;
import flixel.input.FlxInput;
import flixel.group.FlxSpriteGroup;
import transition.data.InstantTransition;
import openfl.display.Bitmap;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import Song.SongEvents;
import openfl.media.SoundChannel;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class ChartingState extends MusicBeatState
{

	public static var screenshotBitmap:Bitmap = null;
	public static var startSection:Int = 0;

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	static var charactersList:Array<String> = [];
	static var gfList:Array<String> = [];
	static var stageList:Array<String> = [];

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var timeOld:Float = 0;

	var ee2Check:Bool;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var player1DropDown:FlxUIDropDownMenu;
	var player2DropDown:FlxUIDropDownMenu;
	var gfDropDown:FlxUIDropDownMenu;
	var stageDropDown:FlxUIDropDownMenu;
	var diffNameList:Array<String> = ["Easy", "Normal", "Hard"];
	var diffList:Array<String> = ["-easy", "", "-hard"];
	var diffDropFinal:String = "";
	var diffDrop:FlxUIDropDownMenu;
	var bfClick:FlxUICheckBox;
	var opClick:FlxUICheckBox;
	var gotoSectionStepper:FlxUINumericStepper;
	var lilBuddiesBox:FlxUICheckBox;
	//var halfSpeedCheck:FlxUICheckBox;

	var strumLine:FlxSprite;
	var bullshitUI:FlxGroup;

	final strumColors:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
	final eventColors:Array<FlxColor> = [0xFFFFFFFF, 0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFF00FF, 0xFFFFFF00, 0xFF00FFFF, 0xFFFF9100, 0xFFA200FF, 0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F, 0xFF00FFBF, 0xFFFF0095, 0xFFC8FF00, 0xFF0077FF];

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;
	//var TRIPLE_GRID_SIZE:Float = 40 * 4/3;

	var dummyArrow:FlxSprite;
	var holding:Bool;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedEvents:FlxTypedGroup<EventSprite>;

	var gridBG:FlxSprite;
	var gridBG2:FlxSprite;
	//var gridBGTriple:FlxSprite;
	var gridBGOverlay:FlxSprite;

	var _song:SwagSong;
	var _events:SongEvents;

	var typingShit:FlxUIInputText;
	var noteType:FlxUIInputText;

	var textBoxArray:Array<FlxUIInputText> = [];
	var anyTextHasFocus:Bool = false;

	var eventTagName:FlxUIInputText;
	var eventTagDrop:FlxUIDropDownMenu;
	var eventTagList:Array<String> = [""];

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;
	var vocalsOther:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var leftIconBack:FlxSprite;
	var rightIconBack:FlxSprite;
	
	var justChanged:Bool;

	var lilStage:FlxSprite;
	var lilBf:FlxSprite;
	var lilOpp:FlxSprite;

	var eventCache:Map<String, BitmapData> = new Map();

	override function create()
	{

		Config.setFramerate(120);

		SaveManager.global();
		ee2Check = FlxG.save.data.ee2;

		var controlInfo = new FlxText(10, 30, 0, "LEFT CLICK - Place Notes\nRIGHT CLICK - Delete Notes\nMIDDLE CLICK - Reselect a note.\n\nSHIFT - Unlock cursor from grid\nALT - Triplets\nCONTROL - 1/32 Notes\nSHIFT + CONTROL - 1/64 Notes\n\nTAB - Place notes on both sides\nHJKL - Place notes during\n                       playback\n\nR - Top of section\nCTRL + R - Song start\n\nENTER - Test chart.\nCTRL + ENTER - Test chart from\n                         current section.", 12);
		controlInfo.scrollFactor.set();
		add(controlInfo);

		lilStage = new FlxSprite(32, 432).loadGraphic(Paths.image("chartEditor/lilStage"));
		lilStage.scrollFactor.set();
		add(lilStage);

		lilBf = new FlxSprite(32, 432).loadGraphic(Paths.image("chartEditor/lilBf"), true, 300, 256);
		lilBf.animation.add("idle", [0, 1], 12, true);
		lilBf.animation.add("0", [3, 4, 5], 12, false);
		lilBf.animation.add("1", [6, 7, 8], 12, false);
		lilBf.animation.add("2", [9, 10, 11], 12, false);
		lilBf.animation.add("3", [12, 13, 14], 12, false);
		lilBf.animation.add("yeah", [17, 20, 23], 12, false);
		lilBf.animation.play("idle");
		lilBf.animation.finishCallback = function(name:String){
			lilBf.animation.play(name, true, false, lilBf.animation.getByName(name).numFrames - 2);
		}
		lilBf.scrollFactor.set();
		add(lilBf);

		lilOpp = new FlxSprite(32, 432).loadGraphic(Paths.image("chartEditor/lilOpp"), true, 300, 256);
		lilOpp.animation.add("idle", [0, 1], 12, true);
		lilOpp.animation.add("0", [3, 4, 5], 12, false);
		lilOpp.animation.add("1", [6, 7, 8], 12, false);
		lilOpp.animation.add("2", [9, 10, 11], 12, false);
		lilOpp.animation.add("3", [12, 13, 14], 12, false);
		lilOpp.animation.play("idle");
		lilOpp.animation.finishCallback = function(name:String){
			lilOpp.animation.play(name, true, false, lilOpp.animation.getByName(name).numFrames - 2);
		}
		lilOpp.scrollFactor.set();
		add(lilOpp);

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

		leftIcon.iconScale = 0.5;
		rightIcon.iconScale = 0.5;

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
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
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
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventUI();
		addToolsUI();
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

	function addSongUI():Void
	{
		typingShit = new FlxUIInputText(10, 10, 70, _song.song, 8);
		textBoxArray.push(typingShit);

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var saveEventsButton:FlxButton = new FlxButton(110, saveButton.y + 30, "Save Events", function()
		{
			saveEvents();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var fullreset:FlxButton = new FlxButton(10, 150, "Full Blank", function()
		{
			var song_name = _song.song;

			PlayState.SONG = {
				song: song_name,
				notes: [],
				bpm: 120.0,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
				speed: 1
			};

			FlxG.resetState();
		});

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 0.1, 1, 0.1, 25, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 50, 1, 1, 1, 999, 2);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		//var characters:Array<String> = CoolUtil.coolTextFile(Paths.text("characterList"));
		//var gfs:Array<String> = CoolUtil.coolTextFile(Paths.text("gfList"));
		//var stages:Array<String> = CoolUtil.coolTextFile(Paths.text("stageList"));

		player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(charactersList, true), function(character:String)
		{
			_song.player1 = charactersList[Std.parseInt(character)];
			updateHeads(true);
		});
		player1DropDown.selectedLabel = _song.player1;

		player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(charactersList, true), function(character:String)
		{
			_song.player2 = charactersList[Std.parseInt(character)];
			updateHeads(true);
		});
		player2DropDown.selectedLabel = _song.player2;

		diffDrop = new FlxUIDropDownMenu(10, 160, FlxUIDropDownMenu.makeStrIdLabelArray(diffNameList, true), function(diff:String)
		{
			trace(diff);
			diffDropFinal = diffList[Std.parseInt(diff)];
			PlayState.storyDifficulty = Std.parseInt(diff);
			
		});
		diffDrop.selectedLabel = diffNameList[PlayState.storyDifficulty];
		diffDropFinal = diffList[Std.parseInt(diffDrop.selectedId)];

		gfDropDown = new FlxUIDropDownMenu(10, 130, FlxUIDropDownMenu.makeStrIdLabelArray(gfList, true), function(gf:String)
			{
				_song.gf = gfList[Std.parseInt(gf)];
			});
		gfDropDown.selectedLabel = _song.gf;
		
		stageDropDown = new FlxUIDropDownMenu(140, 130, FlxUIDropDownMenu.makeStrIdLabelArray(stageList, true), function(selStage:String)
			{
				_song.stage = stageList[Std.parseInt(selStage)];
			});
		stageDropDown.selectedLabel = _song.stage;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";

		tab_group_song.add(typingShit);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEventsButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(diffDrop);
		tab_group_song.add(gfDropDown);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();
	}

	function addToolsUI():Void
		{
			gotoSectionStepper = new FlxUINumericStepper(10, 400, 1, 0, 0, 999, 0);
			gotoSectionStepper.name = 'gotoSection';
	
			var gotoSectionButton:FlxButton = new FlxButton(gotoSectionStepper.x, gotoSectionStepper.y + 20, "Go to Section", function()
			{
				changeSection(Std.int(gotoSectionStepper.value), true);
				gotoSectionStepper.value = 0;
			});

			//I DO NOT KNOW WHY THE TEXT IS FUCKING MISALIGNED WHY IS FLXUI LIKE THIS????????????
	
			var check_mute_inst = new FlxUICheckBox(10, 10, null, null, "Mute Instrumental", 100);
			check_mute_inst.checked = false;
			check_mute_inst.callback = function() {
				if(check_mute_inst.checked){
					FlxG.sound.music.volume = 0;
				}
				else{
					FlxG.sound.music.volume = 0.6;
				}
			};

			var check_mute_vox = new FlxUICheckBox(10, 40, null, null, "Mute Vocals", 100);
			check_mute_vox.checked = false;
			check_mute_vox.callback = function() {
				if(check_mute_vox.checked){
					vocals.volume = 0;
				}
				else{
					vocals.volume = 1;
				}
			};

			var check_mute_vox_other = new FlxUICheckBox(10, 70, null, null, "Mute Opponent Vocals (if available)", 200);
			check_mute_vox_other.checked = false;
			check_mute_vox_other.callback = function() {
				if(check_mute_vox_other.checked){
					vocalsOther.volume = 0;
				}
				else{
					vocalsOther.volume = 1;
				}
			};
	
			bfClick = new FlxUICheckBox(10, 100, null, null, "BF Note Click", 100);
			bfClick.checked = false;

			opClick = new FlxUICheckBox(10, 130, null, null, "Opp Note Click", 100);
			opClick.checked = false;

			lilBuddiesBox = new FlxUICheckBox(10, 160, null, null, "Lil' Buddies", 100);
			lilBuddiesBox.checked = true;
			lilBuddiesBox.callback = function()
			{
				lilBf.visible = lilBuddiesBox.checked;
				lilOpp.visible = lilBuddiesBox.checked;
				lilStage.visible = lilBuddiesBox.checked;
			};
	
			//halfSpeedCheck = new FlxUICheckBox(10, 170, null, null, "Half Speed", 100);
			//halfSpeedCheck.checked = false;
	
			var tab_group_tools = new FlxUI(null, UI_box);
			tab_group_tools.name = "Tools";
	
			tab_group_tools.add(gotoSectionStepper);
			tab_group_tools.add(gotoSectionButton);
			tab_group_tools.add(check_mute_inst);
			tab_group_tools.add(check_mute_vox);
			tab_group_tools.add(check_mute_vox_other);
			tab_group_tools.add(bfClick);
			tab_group_tools.add(opClick);
			tab_group_tools.add(lilBuddiesBox);
			
	
			UI_box.addGroup(tab_group_tools);
			UI_box.scrollFactor.set();
		}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, 0, 0, 999, 0);
		stepperSectionBPM.value = _song.notes[0].bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);
		
		var clearSectionOppButton:FlxButton = new FlxButton(110, 150, "Clear Opp", clearSectionOpp);

		var clearSectionBFButton:FlxButton = new FlxButton(210, 150, "Clear BF", clearSectionBF);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", swapSections);

		var blankButton:FlxButton = new FlxButton(10, 300, "Full Clear", function()
		{

			for(x in 0..._song.notes.length){
				_song.notes[x].sectionNotes = [];
			}
			
			updateGrid();
		});

		//Flips BF Notes
		var bSideButton:FlxButton = new FlxButton(10, 200, "Flip BF Notes", function()
		{
			var flipTable:Array<Int> = [3, 2, 1, 0, 7, 6, 5, 4];

			//[noteStrum, noteData, noteSus]
			for(x in _song.notes[curSection].sectionNotes){
				if(_song.notes[curSection].mustHitSection){
					if(x[1] < 4)
						x[1] = flipTable[x[1]];
				}
				else{
					if(x[1] > 3)
						x[1] = flipTable[x[1]];
				}
			}
			
			updateGrid();
		});
		
		//Flips Opponent Notes
		var bSideButton2:FlxButton = new FlxButton(10, 220, "Flip Opp Notes", function()
		{
			var flipTable:Array<Int> = [3, 2, 1, 0, 7, 6, 5, 4];

			//[noteStrum, noteData, noteSus]
			for(x in _song.notes[curSection].sectionNotes){
				if(_song.notes[curSection].mustHitSection){
					if(x[1] > 3)
						x[1] = flipTable[x[1]];
				}
				else{
					if(x[1] < 4)
						x[1] = flipTable[x[1]];
				}
			}
			
			updateGrid();
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[0].mustHitSection;

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		//tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(clearSectionOppButton);
		tab_group_section.add(clearSectionBFButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(blankButton);
		tab_group_section.add(bSideButton);
		tab_group_section.add(bSideButton2);

		UI_box.addGroup(tab_group_section);
	}

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		noteType = new FlxUIInputText(10, 30, 160, "", 8);
		textBoxArray.push(noteType);

		var noteTagText = new FlxUIText(10, noteType.y - 20, 0, "Note Tag");

		tab_group_note.add(noteTagText);
		tab_group_note.add(noteType);

		UI_box.addGroup(tab_group_note);
	}

	function addEventUI():Void
	{
		eventTagName = new FlxUIInputText(10, 70, 160, "", 8);
		textBoxArray.push(eventTagName);

		eventTagDrop = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(eventTagList, true), function(tag:String)
		{
			eventTagName.text = eventTagList[Std.parseInt(tag)];
		});

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

		tab_group_event.add(eventTagName);
		tab_group_event.add(eventTagDrop);
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
		if(CoolUtil.exists(Paths.voices(daSong, "Player"))){
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong, "Player"));
			vocalsOther = new FlxSound().loadEmbedded(Paths.voices(daSong, "Opponent"));
			
		}
		else if(CoolUtil.exists(Paths.voices(daSong))){
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

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
					swapSections();

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
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
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
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum(Conductor.songPosition - sectionStartTime());

		if (curStep >= 16 * (curSection + 1) && FlxG.sound.music.playing)
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		anyTextHasFocus = false;
		for(x in textBoxArray){
			if(x.hasFocus){
				anyTextHasFocus = true;
			}
		}

		if (!anyTextHasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					vocalsOther.pause();

					lilBf.animation.play("idle");
					lilOpp.animation.play("idle");
				}
				else
				{
					vocals.play();
					vocalsOther.play();
					FlxG.sound.music.play();

					lilBf.animation.play("idle");
					lilOpp.animation.play("idle");
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.CONTROL)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				// && strumLine.y > gridBG.y)
				var wheelSpin = FlxG.mouse.wheel;

				FlxG.sound.music.pause();
				vocals.pause();
				vocalsOther.pause();

				lilBf.animation.play("idle");
				lilOpp.animation.play("idle");

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

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					vocalsOther.pause();

					lilBf.animation.play("idle");
					lilOpp.animation.play("idle");

					var daTime:Float = 1000 * FlxG.elapsed;

					if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && strumLine.y > gridBG.y)
					{
						FlxG.sound.music.time -= daTime;
					}
					else if (strumLine.y < gridBG2.y + gridBG2.height)
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
					vocalsOther.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN)
				{
					if(FlxG.sound.music.playing){
						lilBf.animation.play("idle");
						lilOpp.animation.play("idle");
					}

					FlxG.sound.music.pause();
					vocals.pause();
					vocalsOther.pause();

					var daTime:Float = 2500 * FlxG.elapsed;

					if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && strumLine.y > gridBG.y)
					{
						FlxG.sound.music.time -= daTime;
					}
					else if (strumLine.y < gridBG2.y + gridBG2.height)
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
					vocalsOther.time = FlxG.sound.music.time;
				}
			}

			if (FlxG.mouse.justPressed)
				{
		
					if (FlxG.mouse.x > gridBG.x
						&& FlxG.mouse.x < gridBG.x + ((gridBG.width / 3) * 2)
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
					{
						FlxG.log.add('added note');
						addNote(getStrumTime(dummyArrow.y) + sectionStartTime(), Math.floor(FlxG.mouse.x / GRID_SIZE));
						holding = true;
		
					}
					
					else if (FlxG.mouse.x > gridBG.x + ((gridBG.width / 3) * 2)
						&& FlxG.mouse.x < gridBG.x + gridBG.width
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
					{
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
								eventTagName.text = event.tag;
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

		if(!justChanged){
			curRenderedNotes.forEach(function(x:Note) {

				if(x.absoluteNumber < 4 && _song.notes[curSection].mustHitSection){
					x.editorBFNote = true;
				}
				else if(x.absoluteNumber > 3 && !_song.notes[curSection].mustHitSection){
					x.editorBFNote = true;
				}
				
				if(x.y < strumLine.y && !x.playedEditorClick && FlxG.sound.music.playing){
					if(x.editorBFNote){
						if(bfClick.checked){ FlxG.sound.play(Paths.sound("tick"), 0.6); }
						lilBf.animation.play("" + (x.noteData % 4), true);
					}
					else if(!x.editorBFNote){
						if(opClick.checked){ FlxG.sound.play(Paths.sound("tick"), 0.6); }
						lilOpp.animation.play("" + (x.noteData % 4), true);
					}
				}

				if(x.y > strumLine.y && x.alpha != 0.4){
					x.playedEditorClick = false;
				}

				if(x.y < strumLine.y && x.alpha != 0.4){
					x.playedEditorClick = true;
				}

			});
		}

		justChanged = false;

		if(Startup.hasEe2 && FlxG.keys.justPressed.B && FlxG.keys.pressed.SHIFT){
			ee2Check = false;
			//FlxG.save.bind("data", "Rozebud/FPSPlus");
			SaveManager.global();
			FlxG.save.data.ee2 = false;
			//FlxG.save.flush();
			//FlxG.save.bind(_song.song.replace(" ", "-"), "Rozebud/FPSPlus/Chart-Editor-Autosaves");
			SaveManager.chartAutosave(_song.song.replace(" ", "-"));
		}

		if(Startup.hasEe2 && lilBuddiesBox.checked){
			if(!ee2Check && 
				!FlxG.sound.music.playing &&
				FlxG.mouse.screenX >= lilBf.x &&
				FlxG.mouse.screenX <= lilBf.x + lilBf.width &&
				FlxG.mouse.screenY >= lilBf.y &&
				FlxG.mouse.screenY <= lilBf.y + lilBf.height &&
				FlxG.mouse.justPressed){
	
					autosaveSong();

					//FlxG.save.bind("data", "Rozebud/FPSPlus");
					SaveManager.global();
					FlxG.save.data.ee2 = true;
					//FlxG.save.flush();
					SaveManager.flush();
	
					PlayState.fromChartEditor = true;
					screenshotBitmap = FlxScreenGrab.grab(null, false, true);
	
					customTransOut = new InstantTransition();
	
					var poop:String = Highscore.formatSong("lil-buddies", 2);
					PlayState.SONG = Song.loadFromJson(poop, "lil-buddies");
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					PlayState.loadEvents = true;
					PlayState.returnLocation = "freeplay";
					PlayState.storyWeek = 0;
					trace('CUR WEEK' + PlayState.storyWeek);
					switchState(new PlayState());
	
					//lilBf.animation.play("yeah");
			}
			else if(!FlxG.sound.music.playing &&
				FlxG.mouse.screenX >= lilBf.x &&
				FlxG.mouse.screenX <= lilBf.x + lilBf.width &&
				FlxG.mouse.screenY >= lilBf.y &&
				FlxG.mouse.screenY <= lilBf.y + lilBf.height &&
				FlxG.mouse.justPressed){
					lilBf.animation.play("yeah");
			}
		}
		else if(lilBuddiesBox.checked){
			if(!FlxG.sound.music.playing &&
				FlxG.mouse.screenX >= lilBf.x &&
				FlxG.mouse.screenX <= lilBf.x + lilBf.width &&
				FlxG.mouse.screenY >= lilBf.y &&
				FlxG.mouse.screenY <= lilBf.y + lilBf.height &&
				FlxG.mouse.justPressed){
					lilBf.animation.play("yeah");
			}
		}

		super.update(elapsed);

		/*if(halfSpeedCheck.checked){
			if(FlxG.sound.music.playing){
				FlxG.sound.music.time -= (FlxG.sound.music.time - timeOld) / 2;
				vocals.time = FlxG.sound.music.time;
			}
		timeOld = FlxG.sound.music.time;
		}*/

		

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

		lilBf.animation.play("idle");
		lilOpp.animation.play("idle");

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
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		justChanged = true;

		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				vocalsOther.pause();

				lilBf.animation.play("idle");
				lilOpp.animation.play("idle");

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

		lilBf.animation.play("idle");
		lilOpp.animation.play("idle");
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);
			var type = note[3];
			if(type == null){ type = ""; }

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], type];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		removeDuplicates(curSection);

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads(?changedCharacters:Bool = false):Void{

		if(changedCharacters){
			var leftChar:characters.CharacterInfoBase = Type.createInstance(Type.resolveClass("characters." + player2DropDown.selectedLabel), []);
			var rightChar:characters.CharacterInfoBase = Type.createInstance(Type.resolveClass("characters." + player1DropDown.selectedLabel), []);

			leftIcon.setIconCharacter(leftChar.info.iconName);
			rightIcon.setIconCharacter(rightChar.info.iconName);
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

	function updateGrid():Void{

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
				if(tag.startsWith("playAnim;dad;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("dadPlayAnim"));
					customIcon = true;
				}
				else if(tag.startsWith("playAnim;bf;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("bfPlayAnim"));
					customIcon = true;
				}
				else if(tag.startsWith("playAnim;gf;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("gfPlayAnim"));
					customIcon = true;
				}
				else if(tag.startsWith("setAnimSet;dad;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("dadSetAnimSet"));
					customIcon = true;
				}
				else if(tag.startsWith("setAnimSet;bf;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("bfSetAnimSet"));
					customIcon = true;
				}
				else if(tag.startsWith("setAnimSet;gf;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("gfSetAnimSet"));
					customIcon = true;
				}
				else if(tag.startsWith("cc;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("cc"));
					customIcon = true;
				}
				else if(tag.startsWith("camMove;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("camMove"));
					customIcon = true;
				}
				else if(tag.startsWith("camZoom;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("camZoom"));
					customIcon = true;
				}
				else if(tag.startsWith("gfBopFreq;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("gfBopFreq"));
					customIcon = true;
				}
				else if(tag.startsWith("iconBopFreq;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("iconBopFreq"));
					customIcon = true;
				}
				else if(tag.startsWith("camBopFreq;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("camBopFreq"));
					customIcon = true;
				}
				else if(tag.startsWith("flash;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("flash"));
					customIcon = true;
				}
				else if(tag.startsWith("flashHud;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("flashHud"));
					customIcon = true;
				}
				else if(tag.startsWith("fadeOut;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("fadeOut"));
					customIcon = true;
				}
				else if(tag.startsWith("fadeOutHud;")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic("fadeOutHud"));
					customIcon = true;
				}

				else if(sys.FileSystem.exists("assets/images/chartEditor/event/" + tag + ".png")){
					eventSymbol.loadGraphic(loadAndCacheEventGraphic(tag));
					customIcon = true;
				}
				else{
					eventSymbol.loadGraphic(Paths.image("chartEditor/event/genericEvent"));
				}
				#else
					eventSymbol.loadGraphic(Paths.image("chartEditor/event/genericEvent"));
				#end

				eventSymbol.antialiasing = true;

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

		updateGrid();
	}

	function clearSectionOpp():Void
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
	
			updateGrid();
		}

	function clearSong():Void
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

		trace(noteStrum);
		trace(curSection);
		trace("adding \"" + noteType.text + "\" note");
		trace(_song.notes[curSection].sectionNotes);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
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
		PlayState.SONG = Song.loadFromJson(song.toLowerCase() + diffDropFinal, song.toLowerCase());
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
		FlxG.save.flush();
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
	
	/* No more save generic no one uses that shit
	private function saveGenericLevel()
	{
		
		var genericSong =
		{
			song: _song.song,
			notes: _song.notes,
			bpm: _song.bpm,
			needsVoices: _song.needsVoices,
			speed: _song.speed,
			player1: _song.player1,
			player2: _song.player2,
			validScore: true
		};

		var json = {
			"song": genericSong
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
	}*/

	private function saveEvents()
	{
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

	function swapSections()
	{
		for (i in 0..._song.notes[curSection].sectionNotes.length)
		{
			var note = _song.notes[curSection].sectionNotes[i];
			note[1] = (note[1] + 4) % 8;
			_song.notes[curSection].sectionNotes[i] = note;
			updateGrid();
		}
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

	}

	private function addEventNote(_noteStrum:Float, _noteData:Int):Void{
		var noteData = _noteData;
		var noteStrum = _noteStrum;
		var eventTag = eventTagName.text;
		var section = curSection;

		for (i in _events.events){
			if (approxEqual(i[1], noteStrum, 3) && (eventTag == i[3] || noteData == i[2])){
				return;
			}
		}

		if(pushEvent(eventTagName.text)){
			eventTagDrop.setData(FlxUIDropDownMenu.makeStrIdLabelArray(eventTagList, true));
		}

		_events.events.push([section, noteStrum, noteData, eventTag]);
		
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
			eventTagDrop.setData(FlxUIDropDownMenu.makeStrIdLabelArray(eventTagList, true));
		}
		

		updateGrid();
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
		

		//static var charactersList:Array<String> = [];
		//static var gfList:Array<String> = [];
		//static var stageList:Array<String> = [];

		var characterClasses = CompileTime.getAllClasses("characters", false, characters.CharacterInfoBase);
		for(x in characterClasses){
			var meta = Meta.getType(x);
			if(meta.charList == null || meta.charList[0]){
				charactersList.push(Type.getClassName(x).split("characters.")[1]);
			}
			if(meta.gfList != null && meta.gfList[0]){
				gfList.push(Type.getClassName(x).split("characters.")[1]);
			}
		}

		var stageClasses = CompileTime.getAllClasses("stages", false, stages.BaseStage);
		for(x in stageClasses){
			stageList.push(Type.getClassName(x).split("stages.")[1]);
		}

		//makes them be in alphabetical order instead of reverse alphabetical order
		charactersList.reverse();
		gfList.reverse();
		stageList.reverse();

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
	
}

class EventSprite extends FlxSprite{

	public var tag:String;

}