package;

import thx.Path;
import shaders.*;
import ui.*;
import config.*;
import debug.*;
import title.*;
import transition.data.*;
import stages.*;
import objects.*;
import cutscenes.*;
import cutscenes.data.*;
import events.*;
import note.*;

import flixel.FlxBasic;
import flixel.math.FlxAngle;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import haxe.Json;
import results.ResultsState;
import freeplay.FreeplayState;
import Highscore.SongStats;
import flixel.FlxState;
import openfl.utils.Assets;
import flixel.math.FlxRect;
import openfl.system.System;
import Section.SwagSection;
import Song.SwagSong;
import Song.SongEvents;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import extensions.flixel.FlxTextExt;
import scripts.ScriptableScript;
import scripts.Script;
import modding.PolymodHandler;
import openfl.filters.ShaderFilter;
import story.StoryMenuState;
import caching.*;

using StringTools;

class PlayState extends MusicBeatState
{

	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var EVENTS:SongEvents;
	public static var loadEvents:Bool = true;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var fromChartEditor:Bool = false;
	public static var fceForLilBuddies:Bool = false;
	public static var overrideInsturmental:String = "";
	
	public static var returnLocation:String = "main";

	public static var uiSkinNames = {
		comboPopup: "Default",
		countdown: "Default",
		note: "DefaultNoteSkin",
		playerNotes: "Default",
		opponentNotes: "Default"
	};

	var previousReportedSongTime:Float = -1;
	
	private var canHit:Bool = false;
	private var missTime:Float = 0;

	private var invuln:Bool = false;
	private var invulnTime:Float = 0;

	private var releaseTimes:Array<Float> = [-1, -1, -1, -1];
	private final releaseBufferTime = (2/60);

	public var forceMissNextNote:Bool = false;

	public var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var camZoomAdjustTween:FlxTween;
	private var uiZoomTween:FlxTween;
	public var defaultCameraTime:Float = 1.9;
	public var defaultCameraEase:flixel.tweens.EaseFunction = FlxEase.expoOut;

	public var camFollow:FlxPoint;
	public var camFollowFinal:FlxObject;

	public var camFollowOffset:FlxPoint;
	private var offsetTween:FlxTween;
	private var returnedToCenter:Bool = true;
	public var defaultCameraOffsetTime:Float = 1.4;
	public var defaultCameraOffsetEase:flixel.tweens.EaseFunction = FlxEase.expoOut;

	public var camFollowShake:FlxPoint;
	private var shakeTween:FlxTween;
	private var shakeReturnTween:FlxTween;
	
	public var camOffsetAmount:Float = 20;

	public var autoCam:Bool = true;
	public var autoZoom:Bool = true;
	public var autoUi:Bool = true;
	public var autoCamBop:Bool = true;

	public var gfBopFrequency:Int = 1;
	public var iconBopFrequency:Int = 1;
	public var camBopFrequency:Int = 4;
	public var camBopIntensity:Float = 1;

	public var tweenManager:FlxTweenManager = new FlxTweenManager();

	public var instSong:String = null;
	public var vocals:FlxSound;
	public var vocalsOther:FlxSound;
	public var vocalType:VocalType = combinedVocalTrack;
	public var canChangeVocalVolume:Bool = true;
	public var songPlaybackSpeed(default, set):Float = 1;

	public var scrollSpeedMultiplier(default, set):Float = 1;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	var gfCheck:String;

	public var backgroundLayer:FlxGroup = new FlxGroup();
	public var gfLayer:FlxGroup = new FlxGroup();
	public var middleLayer:FlxGroup = new FlxGroup();
	public var characterLayer:FlxGroup = new FlxGroup();
	public var foregroundLayer:FlxGroup = new FlxGroup();
	public var hudLayer:FlxGroup = new FlxGroup();
	public var overlayLayer:FlxGroup = new FlxGroup();

	//Wacky input stuff=========================

	//private var skipListener:Bool = false;

	private var upTime:Int = 0;
	private var downTime:Int = 0;
	private var leftTime:Int = 0;
	private var rightTime:Int = 0;

	private var upPress:Bool = false;
	private var downPress:Bool = false;
	private var leftPress:Bool = false;
	private var rightPress:Bool = false;
	
	private var upRelease:Bool = false;
	private var downRelease:Bool = false;
	private var leftRelease:Bool = false;
	private var rightRelease:Bool = false;

	private var upHold:Bool = false;
	private var downHold:Bool = false;
	private var leftHold:Bool = false;
	private var rightHold:Bool = false;

	//End of wacky input stuff===================

	private var autoplay:Bool = false;
	public var preventScoreSaving:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var playerNotesInRange:Array<Bool> = [false, false, false, false];
	public var opponentNotesInRange:Array<Bool> = [false, false, false, false];
	
	public var anyPlayerNoteInRange(get, never):Bool;
	public var anyOpponentNoteInRange(get, never):Bool;

	inline function get_anyPlayerNoteInRange():Bool{
		return playerNotesInRange[0] || playerNotesInRange[1] || playerNotesInRange[2] || playerNotesInRange[3];
	}
	inline function get_anyOpponentNoteInRange():Bool{
		return opponentNotesInRange[0] || opponentNotesInRange[1] || opponentNotesInRange[2] || opponentNotesInRange[3];
	}

	public var strumLineVerticalPosition:Float;
	private var curSection:Int = 0;

	private static var prevCamFollow:FlxObject;

	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var enemyStrums:FlxTypedGroup<FlxSprite>;

	public var playerCovers:FlxTypedGroup<NoteHoldCover>;
	public var enemyCovers:FlxTypedGroup<NoteHoldCover>;

	public var curSong:String = "";

	public var health:Float = 1;
	public var healthLerp:Float = 1;
	public var healthAdjustOverride:Null<Float> = null;

	public var combo:Int = 0;
	public var totalPlayed:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = true;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOverlay:FlxCamera;
	private var camGameZoomAdjust:Float = 0;

	public var defaultIconBopScale:Float = 1.2;
	public var defaultIconBopTime:Float = 0.33;
	public var defaultIconBopEase:flixel.tweens.EaseFunction = FlxEase.quintOut;

	public var hudShader:AlphaShader = new AlphaShader(1);

	private var eventList:Array<Dynamic> = [];

	public var comboUI:ComboPopup;
	public static final minCombo:Int = 10;
	public var comboUiGroup:FlxTypedGroup<ComboPopup>;

	public var stage:BaseStage;

	public var scoreTxt:FlxTextExt;

	public var ccText:SongCaptions;

	public var songStats:ScoreStats = {
		score: 0,
		highestCombo: 0,
		accuracy: 0.0,
		sickCount: 0,
		goodCount: 0,
		badCount: 0,
		shitCount: 0,
		susCount: 0,
		missCount: 0,
		comboBreakCount: 0,
	};

	private var previouslyTrackedSongStats:ScoreStats = {
		score: -1,
		highestCombo: 0,
		accuracy: 0.0,
		sickCount: 0,
		goodCount: 0,
		badCount: 0,
		shitCount: 0,
		susCount: 0,
		missCount: 0,
		comboBreakCount: 0,
	};

	public static var weekStats:ScoreStats = {
		score: 0,
		highestCombo: 0,
		accuracy: 0.0,
		sickCount: 0,
		goodCount: 0,
		badCount: 0,
		shitCount: 0,
		susCount: 0,
		missCount: 0,
		comboBreakCount: 0,
	};

	public var defaultCamZoom:Float = 1.05;

	public var inCutscene:Bool = false;
	public var inVideoCutscene:Bool = false;
	public var inEndingCutscene:Bool = false;

	var songEnded:Bool = false;

	var startCutscene:Dynamic = null;
	var startCutsceneStoryOnly:Bool = false;
	var startCutscenePlayOnce:Bool = false;
	var endCutscene:Dynamic = null;
	var endCutsceneStoryOnly:Bool = false;
	var endCutscenePlayOnce:Bool = false;

	public var managedSounds:Array<FlxSound> = [];

	public var scripts:Map<String, Script> = new Map<String, Script>();

	public static var replayStartCutscene:Bool = true;
	public static var replayEndCutscene:Bool = true;

	public var dadBeats:Array<Int> = [0, 2];
	public var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	var endingSong:Bool = false;

	public var forceCenteredNotes:Bool = false;

	public var meta:SongMetaTags;

	public var metadata:Dynamic = null;

	public var arbitraryData:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	override public function create(){

		instance = this;
		FlxG.mouse.visible = false;
		add(tweenManager);

		FlxG.signals.preStateSwitch.addOnce(preStateChange);

		customTransIn = new ScreenWipeIn(1.2);
		customTransOut = new ScreenWipeOut(0.6);

		countSteps = false;

		if(overrideInsturmental != ""){
			instSong = overrideInsturmental;
			overrideInsturmental = "";
		}

		if(loadEvents){
			if(Utils.exists("assets/data/songs/" + SONG.song.toLowerCase() + "/events.json")){
				trace("loaded events");
				trace(Paths.json(SONG.song.toLowerCase() + "/events"));
				EVENTS = Song.parseEventJSON(Utils.getText(Paths.json(SONG.song.toLowerCase() + "/events")));
			}
			else{
				trace("No events found");
				EVENTS = {
					events: []
				};
			}
		}

		metadata = Utils.defaultSongMetadata(SONG.song.replace("-", " "));

		if(Utils.exists("assets/data/songs/" + SONG.song.toLowerCase() + "/meta.json")){
			var jsonMeta = Json.parse(Utils.getText("assets/data/songs/" + SONG.song.toLowerCase() + "/meta.json"));
			if(jsonMeta.name != null)				{ metadata.name = jsonMeta.name; }
			if(jsonMeta.artist != null)				{ metadata.artist = jsonMeta.artist; }
			if(jsonMeta.album != null)				{ metadata.album = jsonMeta.album; }
			if(jsonMeta.difficulties != null)		{ metadata.difficulties = jsonMeta.difficulties; }
			if(jsonMeta.difficultySet != null)		{ metadata.difficultySet = jsonMeta.difficultySet; }
			if(jsonMeta.dadBeats != null)			{ metadata.dadBeats = jsonMeta.dadBeats; }
			if(jsonMeta.bfBeats != null)			{ metadata.bfBeats = jsonMeta.bfBeats; }
			if(jsonMeta.compatableInsts != null)	{ metadata.compatableInsts = jsonMeta.compatableInsts; }
			if(jsonMeta.mixName != null)			{ metadata.mixName = jsonMeta.mixName; }
			if(jsonMeta.pauseMusic != null)			{ metadata.pauseMusic = jsonMeta.pauseMusic; }
		}
		
		for(i in EVENTS.events){
			eventList.push([i[1], i[3], i[2]]);
			preprocessEvent(i[3]);
		}

		eventList.sort(sortByEventStuff);

		inCutscene = false;

		songPreload();
		
		Config.setFramerate(999);

		camTween = tweenManager.tween(this, {}, 0);
		camZoomTween = tweenManager.tween(this, {}, 0);
		uiZoomTween = tweenManager.tween(this, {}, 0);
		offsetTween = tweenManager.tween(this, {}, 0);
		shakeTween = tweenManager.tween(this, {}, 0);
		shakeReturnTween = tweenManager.tween(this, {}, 0);
		camZoomAdjustTween = tweenManager.tween(this, {}, 0);
		
		canHit = !(Config.ghostTapType > 0);

		camGame = new FlxCamera();
		camGame.filters = [];

		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;
		camOverlay.filters = [];

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.filters = [new ShaderFilter(hudShader.shader)];

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOverlay, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = false;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);
		Conductor.recalculateHitZones(songPlaybackSpeed);
		stateConductorOffset = -Config.offset;

		gfCheck = "Gf";

		if (SONG.gf != null) {
			gfCheck = SONG.gf;
		}

		gf = new Character(400, 130, gfCheck, false, true);
		//gf.scrollFactor.set(0.95, 0.95);

		var dadChar = SONG.player2;

		dad = new Character(100, 100, dadChar);

		var bfChar = SONG.player1;

		boyfriend = new Character(770, 450, bfChar, true);

		for(missSound in boyfriend.missSounds){
			FlxG.sound.cache(Paths.sound(missSound));
		}

		var stageCheck:String = "EmptyStage";
		if (SONG.stage != null) { stageCheck = SONG.stage; }

		if(ScriptableStage.listScriptClasses().contains(stageCheck)){
			stage = ScriptableStage.init(stageCheck);
		}
		else{
			stage = new BaseStage();
		}

		curStage = stage.name;

		uiSkinNames = {
			comboPopup: "Default",
			countdown: "Default",
			note: "DefaultNoteSkin",
			playerNotes: "Default",
			opponentNotes: "Default"
		};

		if(Utils.exists(Paths.json(stage.uiType, "data/uiSkins"))){
			var skinJson = Json.parse(Utils.getText(Paths.json(stage.uiType, "data/uiSkins")));

			if(skinJson.note != null && ScriptableNoteSkin.listScriptClasses().contains(skinJson.note)){ uiSkinNames.note = skinJson.note; }
			if(skinJson.comboPopup != null && Utils.exists(Paths.json(skinJson.comboPopup, "data/uiSkins/comboPopup"))){ uiSkinNames.comboPopup = skinJson.comboPopup; }
			if(skinJson.countdown != null && Utils.exists(Paths.json(skinJson.countdown, "data/uiSkins/countdown"))){ uiSkinNames.countdown = skinJson.countdown; }
			if(skinJson.playerNotes != null && Utils.exists(Paths.json(skinJson.playerNotes, "data/uiSkins/hudNote"))){ uiSkinNames.playerNotes = skinJson.playerNotes; }
			if(skinJson.opponentNotes != null && Utils.exists(Paths.json(skinJson.opponentNotes, "data/uiSkins/hudNote"))){ uiSkinNames.opponentNotes = skinJson.opponentNotes; }
		}

		//Set the start point of the characters.
		if((stage.useStartPoints && !stage.overrideBfStartPoints) || (!stage.useStartPoints && stage.overrideBfStartPoints)){
			boyfriend.setPosition(stage.bfStart.x - ((boyfriend.getFrameWidth() * boyfriend.getScale().x)/2), stage.bfStart.y - (boyfriend.getFrameHeight() * boyfriend.getScale().y));
			//trace("doing boyfriend start point");
		}
		if((stage.useStartPoints && !stage.overrideDadStartPoints) || (!stage.useStartPoints && stage.overrideDadStartPoints)){
			dad.setPosition(stage.dadStart.x - ((dad.getFrameWidth() * dad.getScale().x)/2), stage.dadStart.y - (dad.getFrameHeight() * dad.getScale().y));
			//trace("doing dad start point");
		}
		if((stage.useStartPoints && !stage.overrideGfStartPoints) || (!stage.useStartPoints && stage.overrideGfStartPoints)){
			gf.setPosition(stage.gfStart.x - ((gf.getFrameWidth() * gf.getScale().x)/2), stage.gfStart.y - (gf.getFrameHeight() * gf.getScale().y));
			//trace("doing gf start point");
		}
		
		boyfriend.reposition();
		dad.reposition();
		gf.reposition();

		if(metadata != null){
			if(metadata.bfBeats != null){
				bfBeats = metadata.bfBeats;
			}
			if(metadata.dadBeats != null){
				dadBeats = metadata.dadBeats;
			}
		}


		/*
			Moving the onAdd to PlayState since the old way I did it relied on update being called at least once which meant
			it wasn't really an "on add" it was more of a "first update" and it was causing a few issues (namely the camera
			position at the begining of Tutorial wasn't correct becuase the move happened after the camera position was set)
		*/

		characterLayer.memberAdded.add(function(obj:FlxBasic) {
			var char = cast(obj, Character);
			if(!char.debugMode && char.characterInfo.info.functions.add != null){
				char.characterInfo.info.functions.add(char);
			}
		});

		gfLayer.memberAdded.add(function(obj:FlxBasic) {
			var char = cast(obj, Character);
			if(!char.debugMode && char.characterInfo.info.functions.add != null){
				char.characterInfo.info.functions.add(char);
			}
		});
		
		if(stage.extraCameraMovementAmount != null){
			camOffsetAmount = stage.extraCameraMovementAmount;
		}

		for(i in 0...stage.backgroundElements.length){
			backgroundLayer.add(stage.backgroundElements[i]);
		}

		gfLayer.add(gf);

		for(i in 0...stage.middleElements.length){
			middleLayer.add(stage.middleElements[i]);
		}
		
		characterLayer.add(dad);
		characterLayer.add(boyfriend);

		for(i in 0...stage.foregroundElements.length){
			foregroundLayer.add(stage.foregroundElements[i]);
		}
		
		for(i in 0...stage.hudElements.length){
			hudLayer.add(stage.hudElements[i]);
		}
		
		for(i in 0...stage.overlayElements.length){
			overlayLayer.add(stage.overlayElements[i]);
		}

		add(backgroundLayer);
		add(gfLayer);
		add(middleLayer);
		add(characterLayer);
		add(foregroundLayer);

		add(overlayLayer);
		overlayLayer.cameras = [camOverlay];

		characterLayer.memberAdded.removeAll();
		gfLayer.memberAdded.removeAll();

		var camPos:FlxPoint = new FlxPoint(FlxMath.lerp(getOpponentFocusPosition().x, getBfFocusPostion().x, 0.5), FlxMath.lerp(getOpponentFocusPosition().y, getBfFocusPostion().y, 0.5));

		autoCam = stage.cameraMovementEnabled;

		if(stage.cameraStartPosition != null){
			camPos.set(stage.cameraStartPosition.x, stage.cameraStartPosition.y);
		}

		/*//Start pos debug shit. I'll leave it in for now incase everything breaks.
		var dadPos = new FlxSprite(dad.getGraphicMidpoint().x, dad.y + (dad.getFrameHeight() * dad.scale.y)).makeGraphic(24, 24, 0xFFFF00FF);
		var bfPos = new FlxSprite(boyfriend.getGraphicMidpoint().x, boyfriend.y + (boyfriend.getFrameHeight() * boyfriend.scale.y)).makeGraphic(24, 24, 0xFF00FFFF);
		var gfPos = new FlxSprite(gf.getGraphicMidpoint().x, gf.y + (gf.getFrameHeight() * gf.scale.y)).makeGraphic(24, 24, 0xFFFF0000);

		add(dadPos);
		add(bfPos);
		add(gfPos);

		trace("dad: " + dadPos.x + ", " + dadPos.y);
		trace("bf: " + bfPos.x + ", " + bfPos.y);
		trace("gf: " + gfPos.x + ", " + gfPos.y);*/

		for(type => data in stage.extraData){
			switch(type){
				case "forceCenteredNotes":
					forceCenteredNotes = data;
				default:
					//Do nothing by default.
			}
		}

		comboUiGroup = new FlxTypedGroup<ComboPopup>();

		generateComboPopup();

		add(comboUiGroup);

		Conductor.songPosition = -5000;

		if(Config.downscroll){
			strumLineVerticalPosition = 570;
		}
		else {
			strumLineVerticalPosition = 40;
		}

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		add(playerStrums);
		add(enemyStrums);

		playerCovers = new FlxTypedGroup<NoteHoldCover>();
		enemyCovers = new FlxTypedGroup<NoteHoldCover>();

		generateSong(SONG.song);

		add(playerCovers);
		add(enemyCovers);

		camFollow = new FlxPoint();
		camFollowOffset = new FlxPoint();
		camFollowShake = new FlxPoint();
		camFollowFinal = new FlxObject(0, 0, 1, 1);

		camFollow.set(camPos.x, camPos.y);
		camFollowFinal.setPosition(camPos.x, camPos.y);

		add(camFollowFinal);

		camGame.follow(camFollowFinal, LOCKON);

		defaultCamZoom = stage.startingZoom;
		
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		camGame.zoom = defaultCamZoom;

		camGame.focusOn(camFollowFinal.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if(Utils.exists(Paths.json(SONG.song.toLowerCase() + "/meta"))){
			meta = new SongMetaTags(0, 144, SONG.song.toLowerCase());
			meta.cameras = [camHUD];
			add(meta);
		}

		healthBarBG = new FlxSprite(0, Config.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.875).loadGraphic(Paths.image("ui/healthBar"));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'healthLerp', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.characterColor, boyfriend.characterColor);
		healthBar.antialiasing = true;
		// healthBar
		
		scoreTxt = new FlxTextExt(healthBarBG.x - 105, (FlxG.height * 0.9) + 36, 800, "", 22);
		scoreTxt.setFormat(Paths.font("vcr"), 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(boyfriend.iconName, true);
		iconP1.y = healthBar.y - (iconP1.height / 2) + iconP1.yOffset;

		iconP2 = new HealthIcon(dad.iconName, false);
		iconP2.y = healthBar.y - (iconP2.height / 2) + iconP2.yOffset;

		ccText = new SongCaptions(Config.downscroll);
		ccText.scrollFactor.set();
		
		add(healthBar);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);
		if(Config.showCaptions){ add(ccText); } 

		playerStrums.cameras = [camHUD];
		enemyStrums.cameras = [camHUD];
		playerCovers.cameras = [camHUD];
		enemyCovers.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		ccText.cameras = [camHUD];

		healthBar.visible = false;
		healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		// cameras = [FlxG.cameras.list[1]];
		//startingSong = true;

		add(hudLayer);
		hudLayer.cameras = [camHUD];

		//Get and run cutscene stuff
		if(Utils.exists("assets/data/songs/" + SONG.song.toLowerCase() + "/cutscene.json") && !fromChartEditor){
			trace("song has cutscene info");
			var cutsceneJson = Json.parse(Utils.getText("assets/data/songs/" + SONG.song.toLowerCase() + "/cutscene.json"));
			//trace(cutsceneJson);
			if(Type.typeof(cutsceneJson.startCutscene) == TObject){
				if(cutsceneJson.startCutscene.storyOnly != null) {startCutsceneStoryOnly = cutsceneJson.startCutscene.storyOnly;}
				if((!startCutsceneStoryOnly || (startCutsceneStoryOnly && isStoryMode)) ){
					//var startCutsceneClass = Type.resolveClass("cutscenes.data." + cutsceneJson.startCutscene.name);
					var startCutsceneArgs = [];
					if(cutsceneJson.startCutscene.args != null) {startCutsceneArgs = cutsceneJson.startCutscene.args;}
					if(cutsceneJson.startCutscene.playOnce != null) {startCutscenePlayOnce = cutsceneJson.startCutscene.playOnce;}
					//startCutscene = Type.createInstance(startCutsceneClass, startCutsceneArgs);
					if((startCutscenePlayOnce ? replayStartCutscene : true)){
						startCutscene = ScriptableCutscene.init(cutsceneJson.startCutscene.name, startCutsceneArgs);
					}
				}
			}
			//trace(startCutscene);
			//trace(startCutsceneStoryOnly);

			if(Type.typeof(cutsceneJson.endCutscene) == TObject){
				if(cutsceneJson.endCutscene.storyOnly != null) {endCutsceneStoryOnly = cutsceneJson.endCutscene.storyOnly;}
				if((!endCutsceneStoryOnly || (endCutsceneStoryOnly && isStoryMode)) ){
					//var endCutsceneClass = Type.resolveClass("cutscenes.data." + cutsceneJson.endCutscene.name);
					var endCutsceneArgs = [];
					if(cutsceneJson.endCutscene.args != null) {endCutsceneArgs = cutsceneJson.endCutscene.args;}
					if(cutsceneJson.endCutscene.playOnce != null) {endCutscenePlayOnce = cutsceneJson.endCutscene.playOnce;}
					//endCutscene = Type.createInstance(endCutsceneClass, endCutsceneArgs);
					endCutscene = ScriptableCutscene.init(cutsceneJson.endCutscene.name, endCutsceneArgs);
				}
			}
			//trace(endCutscene);
			//trace(endCutsceneStoryOnly);
		}
		var globalScripts:Array<String> = [];
		if(Utils.exists(Paths.text("globalScripts", "data/scripts"))){
			var globalScriptsText:String = Utils.getText(Paths.text("globalScripts", "data/scripts"));
			globalScripts = globalScriptsText.split("\n");
			for(script in globalScripts){
				script = script.trim();
			}
		}

		//trace(globalScripts);

		var scriptList:Array<String> = [];
		if(Utils.exists(Paths.json("scripts", "data/songs/" + SONG.song.toLowerCase()))){
			trace("song has scripts");
			var scriptJson = Json.parse(Utils.getText(Paths.json("scripts", "data/songs/" + SONG.song.toLowerCase())));
			scriptList = scriptJson.scripts;

			//Remove duplicates from song script list.
			scriptList = Utils.removeDuplicates(scriptList);
		}

		//Remove duplicates from global script list.
		globalScripts = Utils.removeDuplicates(globalScripts, [scriptList]);
		
		//Combine song and global script list.
		scriptList = scriptList.concat(globalScripts);

		while(scriptList.contains("")){
			scriptList.remove("");
		}

		//trace(scriptList);

		for(script in scriptList){
			if(ScriptableScript.listScriptClasses().contains(script)){
				var scriptToAdd:Script = ScriptableScript.init(script);
				scripts.set(script, scriptToAdd);
			}
		}

		var bgDim = new FlxSprite(1280 / -2, 720 / -2).makeGraphic(1, 1, FlxColor.BLACK);
		bgDim.scale.set(1280*2, 720*2);
		bgDim.updateHitbox();
		bgDim.cameras = [camOverlay];
		bgDim.alpha = Config.bgDim/10;
		add(bgDim);

		if(fromChartEditor && !fceForLilBuddies){
			preventScoreSaving = true;
		}
		
		stage.postCreate();
		for(script in scripts){ script.create(); }
		
		cutsceneCheck();

		super.create();
	}

	function cutsceneCheck():Void{
		//trace("in cutsceneCheck");
		if(startCutscene != null && (startCutscenePlayOnce ? replayStartCutscene : true)){
			if(!stage.instantStart){ countdownPreload(); }
			add(startCutscene);
			inCutscene = true;
			startCutscene.start();
		}
		else{
			if(!stage.instantStart){
				countdownPreload();
				startCountdown();
			}
			else{
				instantStart();
			}
		}
		replayStartCutscene = true;
	}

	function updateAccuracy(){
		songStats.accuracy = Scoring.calculateAccuracy(songStats.sickCount, songStats.goodCount, songStats.badCount, songStats.shitCount, songStats.missCount);
	}

	//Preload countdown audio and graphics for the countdown because sometimes it lags the game when starting countdown from a cutscene I guess.
	public function countdownPreload():Void{
		var countdownSkinName:String = uiSkinNames.countdown;
		var countdownSkin:CountdownSkinBase = new CountdownSkinBase(countdownSkinName);

		//Audio Cache
		if(countdownSkin.info.first.audioPath != null){
			FlxG.sound.cache(Paths.sound(countdownSkin.info.first.audioPath));
		}
		if(countdownSkin.info.second.audioPath != null){
			FlxG.sound.cache(Paths.sound(countdownSkin.info.second.audioPath));
		}
		if(countdownSkin.info.third.audioPath != null){
			FlxG.sound.cache(Paths.sound(countdownSkin.info.third.audioPath));
		}
		if(countdownSkin.info.fourth.audioPath != null){
			FlxG.sound.cache(Paths.sound(countdownSkin.info.fourth.audioPath));
		}

		//Preload graphics in local cache.
		//Fun side effect of how Paths.image is done is that just calling it on it's own will load a graphic into the cache even if it doesn't get used.
		if(countdownSkin.info.first.graphicPath != null){
			Paths.image(countdownSkin.info.first.graphicPath);
		}
		if(countdownSkin.info.second.graphicPath != null){
			Paths.image(countdownSkin.info.second.graphicPath);
		}
		if(countdownSkin.info.third.graphicPath != null){
			Paths.image(countdownSkin.info.third.graphicPath);
		}
		if(countdownSkin.info.fourth.graphicPath != null){
			Paths.image(countdownSkin.info.fourth.graphicPath);
		}
	}

	var startTimer:FlxTimer;

	public function startCountdown():Void {
		inCutscene = false;

		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var countdownSkinName:String = uiSkinNames.countdown;
		var countdownSkin:CountdownSkinBase = new CountdownSkinBase(countdownSkinName);

		stage.countdownBeat(-1);
		for(script in scripts){ script.countdownBeat(-1); }

		if(boyfriend.characterInfo.info.functions.countdownBeat != null){
			boyfriend.characterInfo.info.functions.countdownBeat(boyfriend, -1);
		}
		if(dad.characterInfo.info.functions.countdownBeat != null){
			dad.characterInfo.info.functions.countdownBeat(dad, -1);
		}
		if(gf.characterInfo.info.functions.countdownBeat != null){
			gf.characterInfo.info.functions.countdownBeat(gf, -1);
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{

			if(swagCounter != 4) { gf.dance(); }

			if(dadBeats.contains((swagCounter % 4)))
				if(swagCounter != 4) { dad.dance(); }

			if(bfBeats.contains((swagCounter % 4)))
				if(swagCounter != 4) { boyfriend.dance(); }

			switch (swagCounter){
				case 0:
					if(countdownSkin.info.first.audioPath != null){
						playSound(Paths.sound(countdownSkin.info.first.audioPath), 0.6);
					}
					if(countdownSkin.info.first.graphicPath != null){
						var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(countdownSkin.info.first.graphicPath));
						countdownSprite.scrollFactor.set();
						countdownSprite.antialiasing = countdownSkin.info.first.antialiasing;
			
						countdownSprite.setGraphicSize(countdownSprite.width * countdownSkin.info.first.scale);
						countdownSprite.updateHitbox();
			
						countdownSprite.screenCenter();
						countdownSprite.x += countdownSkin.info.first.offset.x;
						countdownSprite.y += countdownSkin.info.first.offset.y;
						countdownSprite.cameras = [camHUD];
						add(countdownSprite);
			
						tweenManager.tween(countdownSprite, {y: countdownSprite.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
								countdownSprite.destroy();
							}
						});
					}
				case 1:
					if(countdownSkin.info.second.audioPath != null){
						playSound(Paths.sound(countdownSkin.info.second.audioPath), 0.6);
					}
					if(countdownSkin.info.second.graphicPath != null){
						var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(countdownSkin.info.second.graphicPath));
						countdownSprite.scrollFactor.set();
						countdownSprite.antialiasing = countdownSkin.info.second.antialiasing;
			
						countdownSprite.setGraphicSize(countdownSprite.width * countdownSkin.info.second.scale);
						countdownSprite.updateHitbox();
			
						countdownSprite.screenCenter();
						countdownSprite.x += countdownSkin.info.second.offset.x;
						countdownSprite.y += countdownSkin.info.second.offset.y;
						countdownSprite.cameras = [camHUD];
						add(countdownSprite);
			
						tweenManager.tween(countdownSprite, {y: countdownSprite.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
								countdownSprite.destroy();
							}
						});
					}
				case 2:
					if(countdownSkin.info.third.audioPath != null){
						playSound(Paths.sound(countdownSkin.info.third.audioPath), 0.6);
					}
					if(countdownSkin.info.third.graphicPath != null){
						var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(countdownSkin.info.third.graphicPath));
						countdownSprite.scrollFactor.set();
						countdownSprite.antialiasing = countdownSkin.info.third.antialiasing;
			
						countdownSprite.setGraphicSize(countdownSprite.width * countdownSkin.info.third.scale);
						countdownSprite.updateHitbox();
			
						countdownSprite.screenCenter();
						countdownSprite.x += countdownSkin.info.third.offset.x;
						countdownSprite.y += countdownSkin.info.third.offset.y;
						countdownSprite.cameras = [camHUD];
						add(countdownSprite);
			
						tweenManager.tween(countdownSprite, {y: countdownSprite.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
								countdownSprite.destroy();
							}
						});
					}
				case 3:
					if(countdownSkin.info.fourth.audioPath != null){
						playSound(Paths.sound(countdownSkin.info.fourth.audioPath), 0.6);
					}
					if(countdownSkin.info.fourth.graphicPath != null){
						var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(countdownSkin.info.fourth.graphicPath));
						countdownSprite.scrollFactor.set();
						countdownSprite.antialiasing = countdownSkin.info.fourth.antialiasing;
			
						countdownSprite.setGraphicSize(countdownSprite.width * countdownSkin.info.fourth.scale);
						countdownSprite.updateHitbox();
			
						countdownSprite.screenCenter();
						countdownSprite.x += countdownSkin.info.fourth.offset.x;
						countdownSprite.y += countdownSkin.info.fourth.offset.y;
						countdownSprite.cameras = [camHUD];
						add(countdownSprite);
			
						tweenManager.tween(countdownSprite, {y: countdownSprite.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
								countdownSprite.destroy();
							}
						});
					}
				case 4:
					//stepHit();
					
			}

			if(swagCounter < 4){
				stage.countdownBeat(swagCounter);
				for(script in scripts){ script.countdownBeat(swagCounter); }

				if(boyfriend.characterInfo.info.functions.countdownBeat != null){
					boyfriend.characterInfo.info.functions.countdownBeat(boyfriend, swagCounter);
				}
				if(dad.characterInfo.info.functions.countdownBeat != null){
					dad.characterInfo.info.functions.countdownBeat(dad, swagCounter);
				}
				if(gf.characterInfo.info.functions.countdownBeat != null){
					gf.characterInfo.info.functions.countdownBeat(gf, swagCounter);
				}
				
			}

			swagCounter++;
			// generateSong('fresh');
		}, 5);
	}

	public function instantStart():Void {
		inCutscene = false;

		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0, true);
		generateStaticArrows(1, true);

		startedCountdown = true;
		Conductor.songPosition = 0;
	}

	function startSong():Void{
		startingSong = false;

		//if (!paused)
		if(instSong != null){
			FlxG.sound.playMusic(Paths.inst(instSong), 1, false);
		}
		else{
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSongCutsceneCheck;
		vocals.play();
		if(vocalType == splitVocalTrack){ vocalsOther.play(); }

		Conductor.songPosition = 0;

		if(sectionStart){
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
			if(vocalType == splitVocalTrack){ vocalsOther.time = sectionStartTime; }
			curSection = sectionStartPoint;
		}

		if(boyfriend.characterInfo.info.functions.songStart != null){
			boyfriend.characterInfo.info.functions.songStart(boyfriend);
		}
		if(dad.characterInfo.info.functions.songStart != null){
			dad.characterInfo.info.functions.songStart(dad);
		}
		if(gf.characterInfo.info.functions.songStart != null){
			gf.characterInfo.info.functions.songStart(gf);
		}
		stage.songStart();
		for(script in scripts){ script.songStart(); }

		countSteps = true;
	}

	private function generateSong(dataPath:String):Void {

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		switch(vocalType){
			case splitVocalTrack:
				vocals = new FlxSound().loadEmbedded(Paths.voices(curSong, "Player"));
				vocals.onComplete = function(){ vocals.volume = 0; }
				vocalsOther = new FlxSound().loadEmbedded(Paths.voices(curSong, "Opponent"));
				vocalsOther.onComplete = function(){ vocalsOther.volume = 0; }
				FlxG.sound.list.add(vocalsOther);
			case combinedVocalTrack:
				vocals = new FlxSound().loadEmbedded(Paths.voices(curSong));
				vocals.onComplete = function(){ vocals.volume = 0; }
			case noVocalTrack:
				vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var preloadSplashList:Array<String> = [];
		var preloadCoverList:Array<String> = [];

		for (section in noteData)
		{
			if(sectionStart && daBeats < sectionStartPoint){
				daBeats++;
				continue;
			}

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteType:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3){
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0){
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				}
				else{
					oldNote = null;
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, daNoteType, false, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				swagNote.mustPress = gottaHitNote;

				if(swagNote.noteSplashOverride != null && !preloadSplashList.contains(swagNote.noteSplashOverride)){
					preloadSplashList.push(swagNote.noteSplashOverride);
				}
				
				if(swagNote.holdCoverOverride != null && !preloadCoverList.contains(swagNote.holdCoverOverride)){
					preloadCoverList.push(swagNote.holdCoverOverride);
				}

				setNoteHitCallback(swagNote);
				
				unspawnNotes.push(swagNote);

				if(Math.round(susLength) > 0){
					for (susNote in 0...(Math.round(susLength) + 1)){
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						var makeFake = false;
						var timeAdd = 0.0;
						if(susNote == 0){ 
							makeFake = true; 
							timeAdd = 0.1; 
						}
	
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + timeAdd, daNoteData, daNoteType, false, oldNote, true);
						sustainNote.isFake = makeFake;
						sustainNote.scrollFactor.set();
						sustainNote.mustPress = gottaHitNote;

						setNoteHitCallback(sustainNote);

						unspawnNotes.push(sustainNote);
					}
				}

			}
			daBeats++;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		if(preloadSplashList.length > 0){
			for(splash in preloadSplashList){
				var preloadSplash = new NoteSplash(-2000, -2000, 0, false, splash);
			}
		}
		
		if(preloadCoverList.length > 0){
			var preloadCover = new NoteHoldCover(null, 0, preloadSplashList[0]);
			for(cover in preloadCoverList){
				if(cover != preloadCover.coverSkin){
					preloadCover.coverSkin = cover;
					preloadCover.loadSkin();
				}
			}
			preloadCover.destroy();
		}
		

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByEventStuff(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int{
		var r:Int = FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
		return (r != 0) ? r : FlxSort.byValues(FlxSort.ASCENDING, Obj1[2], Obj2[2]);
	}

	//player 1 is player, player 0 is opponent
	public function generateStaticArrows(player:Int, ?instant:Bool = false, ?skin:String):Void{
		if(skin == null){ 
			if(player == 0){ skin = uiSkinNames.opponentNotes; }
			else{ skin = uiSkinNames.playerNotes; }
		}

		var hudNoteSkinName:String = skin;
		var hudNoteSkin:HudNoteSkinBase = new HudNoteSkinBase(hudNoteSkinName);

		var hudNoteSkinInfo = hudNoteSkin.info;

		for (i in 0...4){
			
			var babyArrow:FlxSprite = new FlxSprite(50, strumLineVerticalPosition);

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

			babyArrow.x += Note.swagWidth * i;

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

			babyArrow.setGraphicSize(Std.int(babyArrow.width * hudNoteSkinInfo.scale));
			babyArrow.updateHitbox();
			babyArrow.antialiasing = hudNoteSkinInfo.antialiasing;

			var noteCover:NoteHoldCover = new NoteHoldCover(babyArrow, i, hudNoteSkinInfo.coverPath);
			noteCover.ID = i;
			NoteHoldCover.defaultSkin = hudNoteSkinInfo.coverPath;

			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			babyArrow.x += 50;

			if (player == 1) {
				playerStrums.add(babyArrow);
				babyArrow.animation.onFinish.add(function(name:String){
					if(autoplay){
						if(name == "confirm"){
							babyArrow.animation.play('static', true);
						}
					}
				});

				if(!Config.centeredNotes && !forceCenteredNotes){
					babyArrow.x += ((FlxG.width / 2));
				}
				else{
					babyArrow.x += ((FlxG.width / 4));
				}

				playerCovers.add(noteCover);

			}
			else {
				enemyStrums.add(babyArrow);
				babyArrow.animation.onFinish.add(function(name:String){
					if(name == "confirm"){
						babyArrow.animation.play('static', true);
					}
				});

				if(Config.centeredNotes || forceCenteredNotes){
					babyArrow.x -= 1280;
				}

				enemyCovers.add(noteCover);
			}

			if(!instant){
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				tweenManager.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

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

			babyArrow.animation.play('static');
		}

		if(player == 1){
			//Prevents the game from lagging at first note splash.
			NoteSplash.skinName = hudNoteSkinInfo.splashClass;
			var preloadSplash = new NoteSplash(-2000, -2000, 0, true);
		}
	}

	public function generateComboPopup(?skin:String):Void{
		if(skin == null){ skin = uiSkinNames.comboPopup; }

		var comboPopupSkin:ComboPopupSkinBase = new ComboPopupSkinBase(skin);

		comboUI = new ComboPopup(boyfriend.x + boyfriend.worldPopupOffset.x, boyfriend.y + boyfriend.worldPopupOffset.y,
			comboPopupSkin.info.ratingsInfo,
			comboPopupSkin.info.numbersInfo,
			comboPopupSkin.info.breakInfo
		);

		if(Config.comboType == 1){

			comboUI.cameras = [camHUD];
			comboUI.setPosition(0, 0);
			comboUI.scrollFactor.set(0, 0);
			comboUI.accelScale = 0.3;
			comboUI.velocityScale = 0.3;
			comboUI.limitSprites = true;

			if(!Config.downscroll){
				comboUI.ratingInfo.position.set(844, 580);
				comboUI.numberInfo.position.set(340, 505);
				comboUI.comboBreakInfo.position.set(400, 535);
			}
			else{
				comboUI.ratingInfo.position.set(844, 150);
				comboUI.numberInfo.position.set(340, 125);
				comboUI.comboBreakInfo.position.set(400, 165);
			}

			comboUI.ratingInfo.scale *= comboPopupSkin.info.ratingsHudScaleMultiply;
			comboUI.numberInfo.scale *= comboPopupSkin.info.numbersHudScaleMultiply;
			comboUI.comboBreakInfo.scale *= comboPopupSkin.info.breakHudScaleMultiply;
		}

		if(Config.comboType < 2){
			comboUiGroup.add(comboUI);
		}
	}

	public function regenerateUiSkin(skin:String):Void{
		comboUiGroup.forEachAlive(function(comboPopup){
			comboUiGroup.remove(comboPopup);
			comboPopup.destroy();
		});
		
		playerStrums.forEachAlive(function(strum){
			playerStrums.remove(strum);
			strum.destroy();
		});

		playerCovers.forEachAlive(function(cover){
			playerCovers.remove(cover);
			cover.destroy();
		});

		enemyStrums.forEachAlive(function(strum){
			enemyStrums.remove(strum);
			strum.destroy();
		});

		enemyCovers.forEachAlive(function(cover){
			enemyCovers.remove(cover);
			cover.destroy();
		});

		generateStaticArrows(0, true, skin);
		generateStaticArrows(1, true, skin);
		generateComboPopup(skin);
	}

	override function openSubState(SubState:FlxSubState){

		if(paused){
			pauseSongPlayback();
			if (startTimer != null && !startTimer.finished){
				startTimer.active = false;
			}

			for(sound in managedSounds){
				if(sound != null && sound.playing){
					sound.pause();
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState(){
		
		if(paused){
			if(!startingSong){
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished){
				startTimer.active = true;
			}

			for(sound in managedSounds){
				if(sound != null && !sound.playing){
					sound.resume();
				}
			}
				
			paused = false;
		}

		setBoyfriendInvuln(1/60);

		super.closeSubState();
	}

	function resyncVocals():Void {
		vocals.pause();
		//FlxG.sound.music.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length){
			vocals.time = Conductor.songPosition;
			vocals.play();
		}

		if(vocalType == splitVocalTrack){
			vocalsOther.pause();
			if (Conductor.songPosition <= vocalsOther.length){
				vocalsOther.time = Conductor.songPosition;
				vocalsOther.play();
			}
		}

		resyncWindow = RESYNC_WINDOW_FINAL;
		//trace("resyncing vocals");
	}

	public function pauseSongPlayback():Void {
		if(FlxG.sound.music != null){
			FlxG.sound.music.pause();
			vocals.pause();
			if(vocalType == splitVocalTrack){ vocalsOther.pause(); }
		}
	}

	public function resumeSongPlayback():Void {
		if(FlxG.sound.music != null){
			FlxG.sound.music.play();
			vocals.play();
			if(vocalType == splitVocalTrack){ vocalsOther.play(); }
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number:Float, precision:Int):Float{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num)/Math.pow(10, precision);
		return num;
	}


	override public function update(elapsed:Float) {
		if(invulnTime > 0){
			invulnTime -= elapsed;
			//trace(invulnTime);
			if(invulnTime <= 0){
				invuln = false;
			}
		}

		if(missTime > 0){
			missTime -= elapsed;
			//trace(missTime);
			if(missTime <= 0){
				canHit = false;
			}
		}

		if(resyncWindow < RESYNC_WINDOW_FINAL && FlxG.sound.music.playing && !startingSong){
			resyncWindow += (RESYNC_WINDOW_FINAL - RESYNC_WINDOW_INITIAL) * elapsed;
			if(resyncWindow > RESYNC_WINDOW_FINAL){ resyncWindow = RESYNC_WINDOW_FINAL; }
		}

		keyCheck();

		for(i in 0...releaseTimes.length){
			if(releaseTimes[i] != -1){
				releaseTimes[i] += elapsed;
				//trace(i + ": " + releaseTimes[i]);
			}
		}

		if (!inCutscene && !endingSong){
		 	if(!autoplay){
		 		keyShit();
			}
		 	else{
				keyShitAuto();
		 	}
		}
		
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.TAB && !isStoryMode){
			autoplay = !autoplay;
			preventScoreSaving = true;
		}

		updateAccuracy();

		if(songStats.score != previouslyTrackedSongStats.score || 
		   songStats.accuracy != previouslyTrackedSongStats.accuracy || 
		   songStats.missCount != previouslyTrackedSongStats.missCount || 
		   songStats.comboBreakCount != previouslyTrackedSongStats.comboBreakCount){
			updateScoreText();
			previouslyTrackedSongStats = Reflect.copy(songStats);
		}

		stage.update(elapsed);
		for(script in scripts){ script.update(elapsed); }

		if (Binds.justPressed("pause") && startedCountdown && canPause){
			paused = true;
			openSubState(new PauseSubState());
		}

		if (Binds.justPressed("chartEditor") && !isStoryMode){

			if(!FlxG.keys.pressed.SHIFT){
				ChartingState.startSection = curSection;
			}

			FlxG.sound.music.pause();

			switchState(new ChartingState(), false);
			sectionStart = false;

			if(instSong != null){
				overrideInsturmental = instSong;
			}

			canPause = false;

			FlxG.sound.music.pause();
			vocals.pause();
			if(vocalType == splitVocalTrack){ vocalsOther.pause(); }
		}

		if (Binds.justPressed("polymodReload") && !isStoryMode){
			FlxG.sound.music.pause();
			vocals.pause();
			if(vocalType == splitVocalTrack){ vocalsOther.pause(); }
			if(instSong != null){ overrideInsturmental = instSong; }
			PolymodHandler.reload();
		}

		/*if(FlxG.keys.anyJustPressed([P])){
			trace(getBfFocusPostion());
		}

		if(FlxG.keys.anyJustPressed([O])){
			trace(getOpponentFocusPosition());
		}

		if(FlxG.keys.anyJustPressed([I])){
			trace(getGfFocusPosition());
		}*/

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconP1.xOffset);
		iconP1.y = healthBar.y - (iconP1.height / 2) + iconP1.yOffset;
		
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconP2.xOffset);
		iconP2.y = healthBar.y - (iconP2.height / 2) + iconP2.yOffset;

		if (health > 2){
			health = 2;
		}

		if(healthLerp != health){
			//Designed to be roughly equivalent to Utils.fpsAdjustedLerp(healthLerp, health, 0.07, 600),
			//which is roughly equivalent to Utils.fpsAdjustedLerpOld(healthLerp, health, 0.7) at the performance I got when I implemented with smoother health bar.
			healthLerp = Utils.fpsAdjustedLerp(healthLerp, health, 0.516, 60, true, 0.0001);
		}

		//Health Icons
		if (healthBar.percent < 20){
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 2;
		}
		else if (healthBar.percent > 80){
			iconP1.animation.curAnim.curFrame = 2;
			iconP2.animation.curAnim.curFrame = 1;
		}
		else{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
		}

		if (Binds.justPressed("offsetEditor") && !isStoryMode){

			sectionStart = false;

			if(FlxG.keys.pressed.SHIFT){
				switchState(new AnimationDebug(SONG.player1), false);
			}
			else if(FlxG.keys.pressed.CONTROL){
				switchState(new AnimationDebug(gfCheck), false);
			}
			else{
				switchState(new AnimationDebug(SONG.player2), false);
			}
		}

		if(songPlaybackSpeed != FlxG.sound.music.pitch){
			FlxG.sound.music.pitch = songPlaybackSpeed;
			vocals.pitch = songPlaybackSpeed;
			if(vocalType == splitVocalTrack){ vocalsOther.pitch = songPlaybackSpeed; }
		}

		if(startingSong){
			if (startedCountdown){
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0){
					startSong();
				}
			}
		}
		else{
			if(previousReportedSongTime != FlxG.sound.music.time){
				Conductor.songPosition = FlxG.sound.music.time;
				//Failsafe to make sure that the onComplete actually runs because sometimes it would just not run sometimes when I was doing stuff with the song playback speed.
				if(Utils.inRange(previousReportedSongTime, FlxG.sound.music.length, 1000) && !Utils.inRange(Conductor.songPosition, FlxG.sound.music.length, 1000) && !songEnded){ FlxG.sound.music.onComplete(); }
				previousReportedSongTime = FlxG.sound.music.time;
			}
			else{
				Conductor.songPosition += FlxG.elapsed * 1000 * songPlaybackSpeed;
			}
		}

		if(!startingSong){
			//countSteps = !FlxG.keys.anyPressed(["TAB"]); //Debug to test for lag.
			for(i in 0...Conductor.bpmChangeMap.length){
				if(Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime && Conductor.bpm != Conductor.bpmChangeMap[i].bpm){
					Conductor.changeBPM(Conductor.bpmChangeMap[i].bpm);
				}
			}
		}

		if(!startingSong){
			for(i in eventList){
				var eventTime = i[0] + Config.offset;
				if(eventTime < 0) { eventTime = 0; }
				if(eventTime > Conductor.songPosition){
					break;
				}
				else{
					executeEvent(i[1]);
					eventList.remove(i);
				}
			}
		}

		if(!dad.isSinging && !boyfriend.isSinging && !returnedToCenter){
			returnedToCenter = true;
			changeCamOffset(0, 0);
		}
		if(dad.isSinging || boyfriend.isSinging){
			returnedToCenter = false;
		}

		if (generatedMusic && PlayState.SONG.notes[Math.floor(curStep / 16)] != null && !endingSong && startedCountdown) {

			if (camFocus != "dad" && !PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection && autoCam){
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Math.floor(curStep / 16)].mustHitSection && autoCam){
				camFocusBF();
			}
		}

		camFollowFinal.setPosition(camFollow.x + camFollowOffset.x + camFollowShake.x + stage.globalCameraOffset.x, camFollow.y + camFollowOffset.y + camFollowShake.y + stage.globalCameraOffset.y);

		if(!inVideoCutscene){
			camGame.zoom = defaultCamZoom + camGameZoomAdjust;
		}

		//FlxG.watch.addQuick("totalBeats: ", totalBeats);

		// RESET = Quick Game Over Screen
		if(Binds.justPressed("killbind") && !startingSong) {
			health = 0;
		}

		if(health <= 0){ openGameOver(); }

		if(unspawnNotes[0] != null){
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3000){
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);

				sortNotes();
			}
		}

		if(generatedMusic){
			updateNote();
			opponentNoteCheck();
		}

		playerCovers.forEach(function(cover:NoteHoldCover) {
			if(!playerNotesInRange[cover.noteDirection] && cover.visible && cover.animation.curAnim.name != "end"){
				cover.end(false);
			}
		});

		enemyCovers.forEach(function(cover:NoteHoldCover) {
			if(!opponentNotesInRange[cover.noteDirection] && cover.visible && cover.animation.curAnim.name != "end"){
				cover.end(false);
			}
		});

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSongCutsceneCheck();
		#end
		
		leftPress = false;
		leftRelease = false;
		downPress = false;
		downRelease = false;
		upPress = false;
		upRelease = false;
		rightPress = false;
		rightRelease = false;

		for(i in 0...releaseTimes.length){
			if(releaseTimes[i] >= releaseBufferTime){
				releaseTimes[i] = -1;
			}
		}

		super.update(elapsed);
	}

	public function openGameOver(?character:String):Void{
		if(character == null){
			character = boyfriend.deathCharacter;
		}

		//persistentDraw = true;
		paused = true;

		vocals.stop();
		if(vocalType == splitVocalTrack){ vocalsOther.stop(); }
		FlxG.sound.music.stop();

		camGame.filters = [];

		openSubState(new GameOverSubstate(boyfriend.getSprite().getScreenPosition().x, boyfriend.getSprite().getScreenPosition().y, camFollowFinal.getScreenPosition().x, camFollowFinal.getScreenPosition().y, defaultCamZoom, character));
		sectionStart = false;
	}

	function updateNote(){
		notes.forEachAlive(function(daNote:Note)
		{
			var targetY:Float;
			var targetX:Float;

			var scrollSpeed:Float;

			if(daNote.mustPress){
				targetY = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
				targetX = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
			}
			else{
				targetY = enemyStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
				targetX = enemyStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
			}

			if(Config.scrollSpeedOverride > 0){
				scrollSpeed = Config.scrollSpeedOverride;
			}
			else{
				scrollSpeed = FlxMath.roundDecimal(PlayState.SONG.speed, 2);
			}

			scrollSpeed *= scrollSpeedMultiplier;

			if(Config.downscroll){
				daNote.y = (targetY + (Conductor.songPosition - daNote.strumTime) * (0.45 * scrollSpeed)) - daNote.yOffset;	
				if(daNote.isSustainNote){
					daNote.y -= daNote.height;
					daNote.y += 125;

					if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
						&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (targetY + Note.swagWidth / 2)){
						// Clip to strumline
						var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
						swagRect.height = (targetY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
						swagRect.y = daNote.frameHeight - swagRect.height;
	
						daNote.clipRect = swagRect;
					}
				}
			}
			else {
				daNote.y = (targetY - (Conductor.songPosition - daNote.strumTime) * (0.45 * scrollSpeed)) + daNote.yOffset;
				if(daNote.isSustainNote){
					if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
						&& daNote.y + daNote.offset.y * daNote.scale.y <= (targetY + Note.swagWidth / 2)){
						// Clip to strumline
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (targetY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}
			}

			daNote.x = targetX + daNote.xOffset;

			if(daNote.tooLate){
				if (!daNote.didTooLateAction && !daNote.isFake){
					noteMiss(daNote.noteData, daNote.missCallback, Scoring.MISS_DAMAGE_AMOUNT, true, true);
					if(canChangeVocalVolume){ vocals.volume = 0; }
					daNote.didTooLateAction = true;
				}
			}

			if(Config.downscroll ? (daNote.y > targetY + daNote.height + 50) : (daNote.y < targetY - daNote.height - 50)){
				if (daNote.tooLate || daNote.wasGoodHit){
								
					daNote.active = false;
					daNote.visible = false;
					daNote.destroy();
				}
			}
		});
	}

	function opponentNoteCheck(){
		opponentNotesInRange = [false, false, false, false];
		notes.forEachAlive(function(daNote:Note){

			if(!opponentNotesInRange[daNote.noteData] && daNote.inRange && !daNote.mustPress) {opponentNotesInRange[daNote.noteData] = true;}

			if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit){

				daNote.wasGoodHit = true;

				daNote.hitCallback(daNote, dad);
				healthAdjustOverride = null;

				enemyStrums.forEach(function(spr:FlxSprite){
					if (Math.abs(daNote.noteData) == spr.ID){
						spr.animation.play('confirm', true);
					}
				});

				//dad.holdTimer = 0;

				switch(vocalType){
					case splitVocalTrack:
						if(canChangeVocalVolume){ vocalsOther.volume = 1; }
					case combinedVocalTrack:
						if(canChangeVocalVolume){ vocals.volume = 1;}
					default:
				}

				if(dad.characterInfo.info.functions.noteHit != null){
					dad.characterInfo.info.functions.noteHit(dad, daNote);
				}
				stage.noteHit(dad, daNote);
				for(script in scripts){ script.noteHit(dad, daNote); }
					

				if(!daNote.isSustainNote){
					daNote.destroy();
				}
				else{
					if(daNote.prevNote == null || !daNote.prevNote.isSustainNote){
						/*enemyCovers.forEach(function(cover:NoteHoldCover) {
							if (Math.abs(daNote.noteData) == cover.noteDirection) {
								cover.start();
							}
						});*/
						startHoldCover(daNote);
					}
					else if(daNote.isSustainEnd){
						enemyCovers.forEachAlive(function(cover:NoteHoldCover) {
							if (Math.abs(daNote.noteData) == cover.noteDirection) {
								cover.end(false);
							}
						});
					}
				}

			}
		});
	}

	function endSongCutsceneCheck():Void{
		//trace("in cutsceneCheck");
		stopMusic();

		if(boyfriend.characterInfo.info.functions.songEnd != null){
			boyfriend.characterInfo.info.functions.songEnd(boyfriend);
		}
		if(dad.characterInfo.info.functions.songEnd != null){
			dad.characterInfo.info.functions.songEnd(dad);
		}
		if(gf.characterInfo.info.functions.songEnd != null){
			gf.characterInfo.info.functions.songEnd(gf);
		}
		stage.songEnd();
		for(script in scripts){ script.songEnd(); }

		if(endCutscene != null){
			add(endCutscene);
			inCutscene = true;
			inEndingCutscene = true;
			endCutscene.start();
		}
		else{
			endSong();
		}
	}

	function stopMusic():Void{
		songEnded = true;
		canPause = false;
		endingSong = true;
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();
		vocals.volume = 0;
		vocals.pause();
		if(vocalType == splitVocalTrack) { 
			vocalsOther.volume = 0; 
			vocalsOther.pause();
		}
		countSteps = false;
	}

	public function endSong():Void{
		
		inEndingCutscene = false;

		if(!songEnded){ stopMusic(); }

		if (isStoryMode){

			storyPlaylist.remove(storyPlaylist[0]);

			if (!preventScoreSaving){
				Highscore.saveScore(SONG.song, songStats.score, songStats.accuracy, storyDifficulty, Highscore.calculateRank(songStats));
				weekStats.score += songStats.score;
				if(songStats.highestCombo > weekStats.highestCombo) {weekStats.highestCombo = songStats.highestCombo;}
				weekStats.accuracy += songStats.accuracy;
				weekStats.sickCount += songStats.sickCount;
				weekStats.goodCount += songStats.goodCount;
				weekStats.badCount += songStats.badCount;
				weekStats.shitCount += songStats.shitCount;
				weekStats.susCount += songStats.susCount;
				weekStats.missCount += songStats.missCount;
				weekStats.comboBreakCount += songStats.comboBreakCount;
			}

			//CODE FOR ENDING A WEEK
			if (storyPlaylist.length <= 0)
			{

				StoryMenuState.fromPlayState = true;
				//returnToMenu();
				sectionStart = false;

				// if ()
				//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				weekStats.accuracy / StoryMenuState.weekList[storyWeek].songs.length;

				//Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				var songSaveStuff:SaveInfo = null;
				if(!preventScoreSaving){
					songSaveStuff = {
						song: null,
						week: StoryMenuState.weekList[storyWeek].id,
						diff: storyDifficulty
					}
				}
				var weekName:String = StoryMenuState.weekList[storyWeek].name;

				ImageCache.forceClearOnTransition = true;
				switchState(new ResultsState(weekStats, weekName, boyfriend.characterInfo.info.resultsCharacter, songSaveStuff, StoryMenuState.weekList[storyWeek].stickerSet));

				//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				//FlxG.save.flush();
			}
			//CODE FOR CONTINUING A WEEK
			else{

				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				switchState(new PlayState());

				//transIn = FlxTransitionableState.defaultTransIn;
				//transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		//CODE FOR ENDING A FREEPLAY SONG
		else{
			if(!fromChartEditor){
				sectionStart = false;
				//returnToMenu();
	
				var songName = SONG.song.replace("-", " ");
				if(metadata != null){
					songName = metadata.name;
				}
	
				var songSaveStuff:SaveInfo = null;
				if(!preventScoreSaving){
					songSaveStuff = {
						song: SONG.song,
						week: null,
						diff: storyDifficulty
					}
				}
				ImageCache.forceClearOnTransition = true;
				switchState(new ResultsState(songStats, songName, boyfriend.characterInfo.info.resultsCharacter, songSaveStuff));
			}
			else{ //Return to the chart editor after finishing a song from the chart editor.
				ChartingState.startSection = 0;
				switchState(new ChartingState(), false);
				sectionStart = false;
			}
		}
	}

	public function returnToMenu():Void{
		ImageCache.forceClearOnTransition = true;
		switch(returnLocation){
			case "story":
				switchState(new StoryMenuState());
			case "freeplay":
				switchState(new FreeplayState(fromSongExit));
			default:
				switchState(new MainMenuState());
		}
	}

	private function popUpScore(note:Note, adjustHealth:Bool = true):Void{

		var noteDiff:Float = note.strumTime - Conductor.songPosition;
		var noHealMultiply:Float = adjustHealth ? 1 : 0;

		songStats.score += Scoring.scoreNote(noteDiff);
		var rating:String = Scoring.rateNote(noteDiff);

		switch(rating){
			case "sick":
				health += Scoring.SICK_HEAL_AMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.sickCount++;
				if(Config.noteSplashType >= 1 && Config.noteSplashType < 4){
					createNoteSplash(note);
				}
			case "good":
				health += Scoring.GOOD_HEAL_AMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.goodCount++;
			case "bad":
				health += Scoring.BAD_HEAL_AMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.badCount++;
				comboBreak();
			case "shit":
				health += Scoring.SHIT_HEAL_AMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.shitCount++;
				comboBreak();
		}

		comboUI.ratingPopup(rating);

		if(combo >= minCombo)
			comboUI.comboPopup(combo);

	}

	private function createNoteSplash(note:Note){
		var bigSplashy = new NoteSplash(Utils.getGraphicMidpoint(playerStrums.members[note.noteData]).x, Utils.getGraphicMidpoint(playerStrums.members[note.noteData]).y, note.noteData, false, note.noteSplashOverride);
		bigSplashy.cameras = [camHUD];
		add(bigSplashy);
	}

	private function startHoldCover(note:Note){

		if(note.mustPress){
			playerCovers.forEachAlive(function(cover:NoteHoldCover){
				if(cover.ID == note.noteData){
					if((note.holdCoverOverride == null && cover.coverSkin != NoteHoldCover.defaultSkin) || (note.holdCoverOverride != null && cover.coverSkin != note.holdCoverOverride)){
						cover.coverSkin = note.holdCoverOverride == null ? NoteHoldCover.defaultSkin : note.holdCoverOverride;
						cover.loadSkin();
					}
					cover.start();
				}
			});
		}
		else{
			enemyCovers.forEachAlive(function(cover:NoteHoldCover){
				if(cover.ID == note.noteData){
					if((note.holdCoverOverride == null && cover.coverSkin != NoteHoldCover.defaultSkin) || (note.holdCoverOverride != null && cover.coverSkin != note.holdCoverOverride)){
						cover.coverSkin = note.holdCoverOverride == null ? NoteHoldCover.defaultSkin : note.holdCoverOverride;
						cover.loadSkin();
					}
					cover.start();
				}
			});
		}

	}

	private function keyCheck():Void{

		upTime = Binds.pressed("gameplayUp") ? upTime + 1 : 0;
		downTime = Binds.pressed("gameplayDown") ? downTime + 1 : 0;
		leftTime = Binds.pressed("gameplayLeft") ? leftTime + 1 : 0;
		rightTime = Binds.pressed("gameplayRight") ? rightTime + 1 : 0;

		upPress = upTime == 1;
		downPress = downTime == 1;
		leftPress = leftTime == 1;
		rightPress = rightTime == 1;

		upRelease = upHold && upTime == 0;
		downRelease = downHold && downTime == 0;
		leftRelease = leftHold && leftTime == 0;
		rightRelease = rightHold && rightTime == 0;

		upHold = upTime > 0;
		downHold = downTime > 0;
		leftHold = leftTime > 0;
		rightHold = rightTime > 0;

		if(leftRelease){ releaseTimes[0] = 0; }
		else if(leftPress){ releaseTimes[0] = -1; }

		if(downRelease){ releaseTimes[1] = 0; }
		else if(downPress){ releaseTimes[1] = -1; }

		if(upRelease){ releaseTimes[2] = 0; }
		else if(upPress){ releaseTimes[2] = -1; }

		if(rightRelease){ releaseTimes[3] = 0; }
		else if(rightPress){ releaseTimes[3] = -1; }

		/*THE FUNNY 4AM CODE! [bro what was i doin????]
		trace((leftHold?(leftPress?"^":"|"):(leftRelease?"^":" "))+(downHold?(downPress?"^":"|"):(downRelease?"^":" "))+(upHold?(upPress?"^":"|"):(upRelease?"^":" "))+(rightHold?(rightPress?"^":"|"):(rightRelease?"^":" ")));
		I should probably remove this from the code because it literally serves no purpose, but I'm gonna keep it in because I think it's funny.
		It just sorta prints 4 lines in the console that look like the arrows being pressed. Looks something like this:
		====
		^  | 
		| ^|
		| |^
		^ |
		====*/

	}

	private function keyShit():Void{

		var controlArray:Array<Bool> = [leftPress, downPress, upPress, rightPress];

		playerNotesInRange = [false, false, false, false];
		notes.forEachAlive(function(daNote:Note){
			if(!playerNotesInRange[daNote.noteData] && daNote.inRange && daNote.mustPress){playerNotesInRange[daNote.noteData] = true;}
		});

		if((upPress || rightPress || downPress || leftPress) && generatedMusic){
			var possibleNotes:Array<Note> = [];
			var directionsAccounted:Array<Bool> = [false,false,false,false];
			var ignoreList:Array<Bool> = [false, false, false, false];

			notes.forEachAlive(function(daNote:Note){
				if(daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					possibleNotes.push(daNote);
					ignoreList[daNote.noteData] = true;

					if(Config.ghostTapType == 1){
						setCanMiss();
					}
				}
			});

			possibleNotes.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime));

			if(possibleNotes.length > 0 && !forceMissNextNote){
				for(i in 0...possibleNotes.length){
					if(controlArray[possibleNotes[i].noteData] && !directionsAccounted[possibleNotes[i].noteData]){
						goodNoteHit(possibleNotes[i]);
						directionsAccounted[possibleNotes[i].noteData] = true;
					}
				}
				for(i in 0...4){
					if(!ignoreList[i] && controlArray[i]){
						badNoteCheck(i);
					}
				}
			}
			else{
				badNoteCheck();
			}
		}
		
		notes.forEachAlive(function(daNote:Note) {
			if ((upHold || rightHold || downHold || leftHold) && generatedMusic){
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote && !daNote.wasGoodHit)
				{

					//boyfriend.holdTimer = 0;

					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (upHold)
								goodNoteHit(daNote);
						case 3:
							if (rightHold)
								goodNoteHit(daNote);
						case 1:
							if (downHold)
								goodNoteHit(daNote);
						case 0:
							if (leftHold)
								goodNoteHit(daNote);
					}
				}
			}

			//Guitar Hero Type Held Notes
			if(daNote.isSustainNote && daNote.mustPress){

				//This is for all subsequent released notes.
				if(daNote.prevNote.tooLate && !daNote.prevNote.wasGoodHit){
					daNote.tooLate = true;
					daNote.destroy();
					noteMiss(daNote.noteData, daNote.missCallback, Scoring.HOLD_DROP_DMAMGE_PER_NOTE * (daNote.isFake ? 0 : 1), false, false, true, Std.int(Scoring.HOLD_DROP_PENALTY_PER_SECOND * (Conductor.stepCrochet/1000)));
					//updateAccuracyOld();
				}

				//This is for the first released note.
				if(daNote.prevNote.wasGoodHit && !daNote.wasGoodHit){

					if(releaseTimes[daNote.noteData] >= releaseBufferTime){
						noteMiss(daNote.noteData, daNote.missCallback, Scoring.HOLD_DROP_INITAL_DAMAGE, true, false, true, Std.int(Scoring.HOLD_DROP_INITIAL_PENALTY_PER_SECOND * (Conductor.stepCrochet/1000)));
						if(canChangeVocalVolume){ vocals.volume = 0; }
						daNote.tooLate = true;
						daNote.destroy();
						boyfriend.holdTimer = 0;
						//updateAccuracyOld();

						playerCovers.forEach(function(cover:NoteHoldCover) {
							if (Math.abs(daNote.noteData) == cover.noteDirection) {
								cover.end(false);
							}
						});

						var recursiveNote = daNote;
						while(recursiveNote.prevNote != null && recursiveNote.prevNote.exists && recursiveNote.prevNote.isSustainNote){
							recursiveNote.prevNote.visible = false;
							recursiveNote = recursiveNote.prevNote;
						}
					}
					
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.stepsUntilRelease * 0.001 && !upHold && !downHold && !rightHold && !leftHold && boyfriend.canAutoAnim && ((boyfriend.characterInfo.info.characterPropertyOverrides.preventShortIdle != null ? boyfriend.characterInfo.info.characterPropertyOverrides.preventShortIdle : Character.PREVENT_SHORT_IDLE) ? !anyPlayerNoteInRange : true)){
			if (boyfriend.isSinging){
				if((boyfriend.characterInfo.info.characterPropertyOverrides.useIdleEnd != null ? boyfriend.characterInfo.info.characterPropertyOverrides.useIdleEnd : Character.USE_IDLE_END)){ 
					boyfriend.idleEnd(); 
				}
				else{ 
					boyfriend.dance(); 
					boyfriend.danceLockout = true;
				}
			}	
		}

		playerStrums.forEach(function(spr:FlxSprite){
			switch (spr.ID){
				case 2:
					if (upPress && spr.animation.curAnim.name != 'confirm'){
						spr.animation.play('pressed');
					}
					if (!upHold){
						spr.animation.play('static');
					}
				case 3:
					if (rightPress && spr.animation.curAnim.name != 'confirm'){
						spr.animation.play('pressed');
					}
					if (!rightHold){
						spr.animation.play('static');
					}
				case 1:
					if (downPress && spr.animation.curAnim.name != 'confirm'){
						spr.animation.play('pressed');
					}
					if (!downHold){
						spr.animation.play('static');
					}
				case 0:
					if (leftPress && spr.animation.curAnim.name != 'confirm'){
						spr.animation.play('pressed');
					}
					if (!leftHold){
						spr.animation.play('static');
					}
			}

		});
	}

	private function keyShitAuto():Void{

		var hitNotes:Array<Note> = [];

		playerNotesInRange = [false, false, false, false];

		notes.forEachAlive(function(daNote:Note){
			if(!playerNotesInRange[daNote.noteData] && daNote.inRange && daNote.mustPress){ playerNotesInRange[daNote.noteData] = true; }

			if (!forceMissNextNote && !daNote.wasGoodHit && daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * (!daNote.isSustainNote ? 0.125 : (daNote.prevNote.wasGoodHit ? 1 : 0))){
				hitNotes.push(daNote);
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.stepsUntilRelease * 0.001 && !upHold && !downHold && !rightHold && !leftHold && boyfriend.canAutoAnim && ((boyfriend.characterInfo.info.characterPropertyOverrides.preventShortIdle != null ? boyfriend.characterInfo.info.characterPropertyOverrides.preventShortIdle : Character.PREVENT_SHORT_IDLE) ? !anyPlayerNoteInRange : true)){
			if (boyfriend.isSinging){
				if((boyfriend.characterInfo.info.characterPropertyOverrides.useIdleEnd != null ? boyfriend.characterInfo.info.characterPropertyOverrides.useIdleEnd : Character.USE_IDLE_END)){ 
					boyfriend.idleEnd(); 
				}
				else{ 
					boyfriend.dance(); 
					boyfriend.danceLockout = true;
				}
			}
		}

		for(x in hitNotes){

			//boyfriend.holdTimer = 0;

			goodNoteHit(x);
			
			playerStrums.forEach(function(spr:FlxSprite){
				if (Math.abs(x.noteData) == spr.ID){
					spr.animation.play('confirm', true);
				}
			});

		}

	}

	function noteMiss(direction:Int = 1, callback:(Int, Character)->Void, ?healthLoss:Float, ?playAudio:Bool = true, ?countMiss:Bool = true, ?dropCombo:Bool = true, ?scoreAdjust:Null<Int>):Void{

		if(scoreAdjust == null){
			scoreAdjust = Scoring.MISS_PENALTY;
		}

		if (!startingSong){

			if(dropCombo){
				comboBreak();
			}
			
			if(countMiss){
				songStats.missCount++;
				if(Main.flippymode) { System.exit(0); }
			}
			
			songStats.score -= scoreAdjust;
			
			if(playAudio && boyfriend.missSounds.length > 0){
				playSound(Paths.sound(boyfriend.missSounds[FlxG.random.int(0, boyfriend.missSounds.length-1)]), boyfriend.missSoundVolume);
			}
			
			forceMissNextNote = false;
			
			callback(direction, boyfriend);
			
			if(healthAdjustOverride == null){
				health -= healthLoss * Config.healthDrainMultiplier;
			}
			else{
				health += healthAdjustOverride;
				healthAdjustOverride = null;
			}

			if(boyfriend.characterInfo.info.functions.noteMiss != null){
				boyfriend.characterInfo.info.functions.noteMiss(boyfriend, direction, countMiss);
			}
			stage.noteMiss(direction, countMiss);
			for(script in scripts){ script.noteMiss(direction, countMiss); }

		}

	}

	inline function noteMissWrongPress(direction:Int = 1):Void{
		var forceMissNextNoteState = forceMissNextNote;
		noteMiss(direction, defaultNoteMiss, Scoring.WRONG_TAP_DAMAGE_AMOUNT, true, false, false, Scoring.WRONG_PRESS_PENALTY);
		setBoyfriendInvuln(4/60);
		forceMissNextNote = forceMissNextNoteState;
	}

	function badNoteCheck(direction:Int = -1){
		if((Config.ghostTapType == 0 || canHit) && !invuln){
			if (leftPress && (direction == -1 || direction == 0))
				noteMissWrongPress(0);
			else if (upPress && (direction == -1 || direction == 2))
				noteMissWrongPress(2);
			else if (rightPress && (direction == -1 || direction == 3))
				noteMissWrongPress(3);
			else if (downPress && (direction == -1 || direction == 1))
				noteMissWrongPress(1);
		}
	}

	function setBoyfriendInvuln(time:Float = 5/60){
		if(time > invulnTime){
			invulnTime = time;
			invuln = true;
		}
	}

	function setCanMiss(time:Float = 10/60){
		if(time > missTime){
			missTime = time;
			canHit = true;
		}
		
	}

	function goodNoteHit(note:Note):Void{
		if (!note.wasGoodHit){

			if(note.isFake){
				note.wasGoodHit = true;
				if(note.prevNote == null || !note.prevNote.isSustainNote){
					/*playerCovers.forEach(function(cover:NoteHoldCover) {
						if (Math.abs(note.noteData) == cover.noteDirection) {
							cover.start();
						}
					});*/
					startHoldCover(note);
				}
				return;
			}
			
			note.hitCallback(note, boyfriend);

			if (!note.isSustainNote){
				combo++;
				popUpScore(note, healthAdjustOverride == null);
				if(gf.hasAnimation("combo" + combo)){ gf.danceLockout = gf.playAnim("combo" + combo); }
				if(combo > songStats.highestCombo) { songStats.highestCombo = combo; }
			}
			else{
				if(healthAdjustOverride == null){
					health += (Scoring.HOLD_HEAL_AMOUNT_PER_SECOND * (Conductor.stepCrochet/1000)) * Config.healthMultiplier;
				}
				songStats.score += Std.int(Scoring.HOLD_SCORE_PER_SECOND * (Conductor.stepCrochet/1000));
				songStats.susCount++;
			}

			if(healthAdjustOverride != null){
				health += healthAdjustOverride;
				healthAdjustOverride = null;
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID) {
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			if(canChangeVocalVolume){ vocals.volume = 1; }

			if(boyfriend.characterInfo.info.functions.noteHit != null){
				boyfriend.characterInfo.info.functions.noteHit(boyfriend, note);
			}
			stage.noteHit(boyfriend, note);
			for(script in scripts){ script.noteHit(boyfriend, note); }

			if(!note.isSustainNote){
				note.destroy();
			}
			else{
				if(note.prevNote == null || !note.prevNote.isSustainNote){
					startHoldCover(note);
				}
				else if(note.isSustainEnd){
					playerCovers.forEachAlive(function(cover:NoteHoldCover) {
						if (Math.abs(note.noteData) == cover.noteDirection) {
							cover.end(true);
						}
					});
				}
			}

		}
	}

	static final RESYNC_WINDOW_INITIAL:Float = 12.5;
	static final RESYNC_WINDOW_FINAL:Float = 25;
	var resyncWindow:Float = RESYNC_WINDOW_INITIAL;

	override function stepHit(){

		super.stepHit();

		if((Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > (resyncWindow * songPlaybackSpeed) || (vocalType != noVocalTrack && Math.abs(vocals.time - (Conductor.songPosition)) > (resyncWindow * songPlaybackSpeed))) && FlxG.sound.music.playing){
			resyncVocals();
		}

		if(vocalType == splitVocalTrack){
			if((Math.abs(vocalsOther.time - (Conductor.songPosition)) > (resyncWindow * songPlaybackSpeed)) && FlxG.sound.music.playing){
				resyncVocals();
			}
		}

		if(curStep > 0 && curStep % 16 == 0){
			curSection++;
		}

		//curStep is kinda weird, maybe I'll fix it at some point
		//UPDATE: I FIXED IT!!!!!!!!
		boyfriend.step(curStep);
		dad.step(curStep);
		gf.step(curStep);
		stage.step(curStep);
		notes.forEachAlive(function(note){ note.step(curStep); });
		for(script in scripts){ script.step(curStep); }

		//trace("STEP: " + curStep);
	}

	override function beatHit(){

		super.beatHit();

		if (SONG.notes[Math.floor(curStep / 16)] != null){

			// Dad doesnt interupt his own notes
			if(dadBeats.contains(curBeat % 4) && dad.canAutoAnim && dad.holdTimer == 0 && !dad.isSinging && ((dad.characterInfo.info.characterPropertyOverrides.preventShortIdle != null ? dad.characterInfo.info.characterPropertyOverrides.preventShortIdle : Character.PREVENT_SHORT_IDLE) ? !anyOpponentNoteInRange : true)){
				dad.dance();
			}
			
		}
		else{
			if(dadBeats.contains(curBeat % 4))
				dad.dance();
		}

		if(curBeat % camBopFrequency == 0 && autoCamBop){
			uiBop(0.0175 * camBopIntensity, 0.03 * camBopIntensity, 0.8);
		}

		if (curBeat % iconBopFrequency == 0){
			iconP1.bop(defaultIconBopScale, defaultIconBopTime, defaultIconBopEase, tweenManager);
			iconP2.bop(defaultIconBopScale, defaultIconBopTime, defaultIconBopEase, tweenManager);
		}
		
		if (curBeat % gfBopFrequency == 0){
			gf.dance();
		}

		if(bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim && !boyfriend.isSinging && ((boyfriend.characterInfo.info.characterPropertyOverrides.preventShortIdle != null ? boyfriend.characterInfo.info.characterPropertyOverrides.preventShortIdle : Character.PREVENT_SHORT_IDLE) ? !anyPlayerNoteInRange : true)){
			boyfriend.dance();
		}

		boyfriend.beat(curBeat);
		dad.beat(curBeat);
		gf.beat(curBeat);
		stage.beat(curBeat);
		notes.forEachAlive(function(note){ note.beat(curBeat); });
		for(script in scripts){ script.beat(curBeat); }

		managedSounds = managedSounds.filter(function(sound:FlxSound):Bool{
			return sound != null;
		});

		//trace("BEAT: " + curBeat);
	}

	public function executeEvent(tag:String):Void{

		var prefix = tag.split(";")[0];

		if(Events.events.exists(prefix)){
			Events.events.get(prefix)(tag);
		}
		else if(stage.events.exists(prefix)){
			stage.events.get(prefix)(tag);
		}
		else{
			trace("No event found for: " + tag);
		}
	}

	public function preprocessEvent(tag:String):Void{
		var prefix = tag.split(";")[0];
		if(Events.preEvents.exists(prefix)){
			Events.preEvents.get(prefix)(tag);
		}
	}

	public function defaultNoteHit(note:Note, character:Character):Void{
		if(character.canAutoAnim && characterShouldPlayAnimation(note, character)){
			switch (note.noteData){
				case 0:
					character.singAnim('singLEFT', true);
				case 1:
					character.singAnim('singDOWN', true);
				case 2:
					character.singAnim('singUP', true);
				case 3:
					character.singAnim('singRIGHT', true);
			}
		}
		getExtraCamMovement(note);
	}

	public function defaultNoteMiss(direction:Int, character:Character):Void{
		if(character.canAutoAnim){
			switch (direction){
				case 0:
					character.singAnim('singLEFTmiss', true);
				case 1:
					character.singAnim('singDOWNmiss', true);
				case 2:
					character.singAnim('singUPmiss', true);
				case 3:
					character.singAnim('singRIGHTmiss', true);
			}
		}
	}

	function setNoteHitCallback(note:Note):Void{

		if(!note.isSustainNote){ //Normal notes
			if(NoteType.types.exists(note.type)){
				var callbacks = NoteType.types.get(note.type);
				if(callbacks[0] != null){ note.hitCallback = callbacks[0]; }
				else{ note.hitCallback = defaultNoteHit; }
				if(callbacks[1] != null){ note.missCallback = callbacks[1]; }
				else{ note.missCallback = defaultNoteMiss; }
			}
			else{
				note.hitCallback = defaultNoteHit;
				note.missCallback = defaultNoteMiss;
			}
		}
		else{ //sustain notes
			if(NoteType.sustainTypes.exists(note.type)){
				var callbacks = NoteType.sustainTypes.get(note.type);
				if(callbacks[0] != null){ note.hitCallback = callbacks[0]; }
				else{ note.hitCallback = defaultNoteHit; }
				if(callbacks[1] != null){ note.missCallback = callbacks[1]; }
				else{ note.missCallback = defaultNoteMiss; }
			}
			else{
				note.hitCallback = defaultNoteHit;
				note.missCallback = defaultNoteMiss;
			}
		}
		
	}

	//Moved to a separate function and out of note check so the hit callback function will be run every note hit and not just when the animation is supposed to play.
	public inline static function characterShouldPlayAnimation(note:Note, character:Character):Bool{
		return ((character.characterInfo.info.characterPropertyOverrides.loopAnimOnHold != null ? character.characterInfo.info.characterPropertyOverrides.loopAnimOnHold : Character.LOOP_ANIM_ON_HOLD) ? (note.isSustainNote ? ((character.characterInfo.info.characterPropertyOverrides.holdLoopWait != null ? character.characterInfo.info.characterPropertyOverrides.holdLoopWait : Character.HOLD_LOOP_WAIT) ? (!character.isSinging || (character.timeInCurrentAnimation >= (3/24) || character.curAnimFinished())) : true) : true) : !note.isSustainNote)
			&& ((character.characterInfo.info.characterPropertyOverrides.preventShortSing != null ? character.characterInfo.info.characterPropertyOverrides.preventShortSing : Character.PREVENT_SHORT_SING) ? !Utils.inRange(character.lastSingTime, Conductor.songPosition, (character.characterInfo.info.characterPropertyOverrides.shortSingTolerence != null ? character.characterInfo.info.characterPropertyOverrides.shortSingTolerence : Character.SHORT_SING_TOLERENCE)) : true);
	}

	var bfOnTop:Bool = true;
	public function setBfOnTop():Void{
		if(bfOnTop){ return; }
		bfOnTop = true;
		characterLayer.remove(boyfriend, true);
		characterLayer.remove(dad, true);
		characterLayer.add(dad);
		characterLayer.add(boyfriend);
	}
	public function setOppOnTop():Void{
		if(!bfOnTop){ return; }
		bfOnTop = false;
		characterLayer.remove(boyfriend, true);
		characterLayer.remove(dad, true);
		characterLayer.add(boyfriend);
		characterLayer.add(dad);
	}

	public function getExtraCamMovement(note:Note):Void{
		if(note.isSustainNote){return;}
		switch (note.noteData){
			case 0:
				changeCamOffset(-1 * camOffsetAmount, 0);
			case 1:
				changeCamOffset(0, camOffsetAmount);
			case 2:
				changeCamOffset(0, -1 * camOffsetAmount);
			case 3:
				changeCamOffset(camOffsetAmount, 0);
		}
	}

	function sectionContainsBfNotes(section:Int):Bool{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for(x in notes){
			if(mustHit) { if(x[1] < 4) { return true; } }
			else { if(x[1] > 3) { return true; } }
		}

		return false;
	}

	function sectionContainsOppNotes(section:Int):Bool{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for(x in notes){
			if(mustHit) { if(x[1] > 3) { return true; } }
			else { if(x[1] < 4) { return true; } }
		}

		return false;
	}

	public function camFocusOpponent(?offsetX:Float = 0, ?offsetY:Float = 0, ?_time:Null<Float>, ?_ease:Null<flixel.tweens.EaseFunction>){
		if(_time == null){_time = defaultCameraTime;}
		if(_ease == null){_ease = defaultCameraEase;}
		
		var pos = getOpponentFocusPosition();
		camMove(pos.x + offsetX, pos.y + offsetY, _time, _ease, "dad");
		changeCamOffset(0, 0);
	}

	public inline function getOpponentFocusPosition():FlxPoint{
		if(!stage.useStaticStageCameras){
			return new FlxPoint(dad.getMidpoint().x + dad.focusOffset.x + stage.dadCameraOffset.x, dad.getMidpoint().y + dad.focusOffset.y + stage.dadCameraOffset.y);
		}
		else{
			return new FlxPoint(stage.staticDadCamera.x + stage.dadCameraOffset.x, stage.staticDadCamera.y + stage.dadCameraOffset.y);
		}
	}

	public function camFocusBF(?offsetX:Float = 0, ?offsetY:Float = 0, ?_time:Null<Float>, ?_ease:Null<flixel.tweens.EaseFunction>){
		if(_time == null){_time = defaultCameraTime;}
		if(_ease == null){_ease = defaultCameraEase;}

		var pos = getBfFocusPostion();
		camMove(pos.x + offsetX, pos.y + offsetY, _time, _ease, "bf");
		changeCamOffset(0, 0);
	}

	public inline function getBfFocusPostion():FlxPoint{
		if(!stage.useStaticStageCameras){
			return new FlxPoint(boyfriend.getMidpoint().x + boyfriend.focusOffset.x + stage.bfCameraOffset.x, boyfriend.getMidpoint().y + boyfriend.focusOffset.y + stage.bfCameraOffset.y);
		}
		else{
			return new FlxPoint(stage.staticBfCamera.x + stage.bfCameraOffset.x, stage.staticBfCamera.y + stage.bfCameraOffset.y);
		}
	}

	public function camFocusGF(?offsetX:Float = 0, ?offsetY:Float = 0, ?_time:Null<Float>, ?_ease:Null<flixel.tweens.EaseFunction>){
		if(_time == null){_time = defaultCameraTime;}
		if(_ease == null){_ease = defaultCameraEase;}

		var pos = getGfFocusPosition();
		camMove(pos.x + offsetX, pos.y + offsetY, _time, _ease, "gf");
		changeCamOffset(0, 0);
	}

	public inline function getGfFocusPosition():FlxPoint{
		if(!stage.useStaticStageCameras){
			return new FlxPoint(gf.getMidpoint().x + gf.focusOffset.x + stage.gfCameraOffset.x, gf.getMidpoint().y + gf.focusOffset.y + stage.gfCameraOffset.y);
		}
		else{
			return new FlxPoint(stage.staticGfCamera.x + stage.gfCameraOffset.x, stage.staticGfCamera.y + stage.gfCameraOffset.y);
		}
	}

	public function camMove(_x:Float, _y:Float, _time:Float, ?_ease:Null<flixel.tweens.EaseFunction>, ?_focus:String = "", ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camTween.cancel();
		if(_time > 0){
			camTween = tweenManager.tween(camFollow, {x: _x, y: _y}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camFollow.set(_x, _y);
		}
		
		camFocus = _focus;

	}

	public function camChangeZoom(_zoom:Float, _time:Float, ?_ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camZoomTween.cancel();
		if(_time > 0){
			camZoomTween = tweenManager.tween(this, {defaultCamZoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			defaultCamZoom = _zoom;
		}

	}

	public function camChangeZoomAdjust(_zoom:Float, _time:Float, ?_ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camZoomAdjustTween.cancel();
		if(_time > 0){
			camZoomAdjustTween = tweenManager.tween(this, {camGameZoomAdjust: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camGameZoomAdjust = _zoom;
		}

	}

	public function uiChangeZoom(_zoom:Float, _time:Float, ?_ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		uiZoomTween.cancel();
		if(_time > 0){
			uiZoomTween = tweenManager.tween(camHUD, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camHUD.zoom = _zoom;
		}

	}

	public function uiBop(?_camZoom:Float = 0.01, ?_uiZoom:Float = 0.02, ?_time:Float = 0.6, ?_ease:Null<flixel.tweens.EaseFunction>){

		if(Config.camBopAmount == 2){ return; }
		else if(Config.camBopAmount == 1){
			_camZoom /= 2;
			_uiZoom /= 2;
		}

		if(_ease == null){
			_ease = FlxEase.quintOut;
		}

		if(autoZoom){
			camZoomAdjustTween.cancel();
			camGameZoomAdjust = _camZoom;
			camChangeZoomAdjust(0, _time, _ease);
		}

		if(autoUi){
			uiZoomTween.cancel();
			camHUD.zoom = 1 + _uiZoom;
			uiChangeZoom(1, _time, _ease);
		}

	}

	public function changeCamOffset(_x:Float, _y:Float, ?_time:Null<Float>, ?_ease:Null<flixel.tweens.EaseFunction>){

		//Don't allow for extra camera offsets if it's disabled in the config.
		if(!Config.extraCamMovement){ return; }

		if(_time == null){ _time = defaultCameraOffsetTime; }
		if(_ease == null){ _ease = defaultCameraOffsetEase; }

		offsetTween.cancel();
		if(_time > 0){
			offsetTween = tweenManager.tween(camFollowOffset, {x: _x, y: _y}, _time, {ease: _ease});
		}
		else{
			camFollowOffset.set(_x, _y);
		}

	}

	public function startCamShake(_intensity:Float, ?_period:Float = 1/24, ?_ease:Null<flixel.tweens.EaseFunction>, ?_notFirstCall:Bool = false){

		if(_ease == null){
			_ease = FlxEase.linear;
		}
		if(_period < 1/60){
			_period = 1/60;
		}

		shakeTween.cancel();
		if(!_notFirstCall){ shakeReturnTween.cancel(); }
		shakeTween = tweenManager.tween(camFollowShake, {x: FlxG.random.float(-1, 1) * _intensity * 1280, y: FlxG.random.float(-1, 1) * _intensity * 720}, _period, {ease: _ease, onComplete: function(t){
			startCamShake(_intensity, _period, _ease, true);
		}});

	}

	public function endCamShake(?_time:Float = 1/24, ?_ease:Null<flixel.tweens.EaseFunction>, ?_startDelay:Float = 0){

		if(_ease == null){
			_ease = FlxEase.linear;
		}
		if(_time < 1/60){
			_time = 1/60;
		}

		shakeReturnTween.cancel();
		shakeReturnTween = tweenManager.tween(camFollowShake, {x: 0, y: 0}, _time, {ease: _ease, startDelay: _startDelay, onStart: function(t) {
			shakeTween.cancel();
		}});
	}

	public function camShake(_intensity:Float, ?_period:Float = 1/24, ?_time:Float = 1, ?_returnTime:Null<Float>, ?_ease:Null<flixel.tweens.EaseFunction>):Void{
		if(_returnTime == null){ _returnTime = _period; }
		startCamShake(_intensity, _period, _ease);
		endCamShake(_returnTime, _ease, _time);
	}

	public dynamic function updateScoreText():Void{

		scoreTxt.text = "Score:" + songStats.score;

		if(Config.showMisses == 1){
			scoreTxt.text += " | Misses:" + songStats.missCount;
		}
		else if(Config.showMisses == 2){
			scoreTxt.text += " | Combo Breaks:" + songStats.comboBreakCount;
		}

		if(Config.showAccuracy){
			scoreTxt.text += " | Accuracy:" + truncateFloat(songStats.accuracy, 2) + "%";
		}

	}

	function comboBreak():Void{
		if (combo > minCombo){
			gf.danceLockout = gf.playAnim("sad");
			comboUI.breakPopup();
		}
		if(combo > 0){ songStats.comboBreakCount++; }
		combo = 0;
	}

	function sortNotes(){
		if(generatedMusic){
			notes.sort(noteSortThing, FlxSort.DESCENDING);
		}
	}

	public function playSound(_embeddedSound:flixel.system.FlxAssets.FlxSoundAsset, _volume:Float = 1.0, _looped:Bool = false, ?_group:Null<flixel.sound.FlxSoundGroup>, _autoDestroy:Bool = true, ?_onComplete:Null<() -> Void>):FlxSound{
		var sound = FlxG.sound.play(_embeddedSound, _volume, _looped, _group, _autoDestroy, _onComplete);
		managedSounds.push(sound);
		return sound;
	}

	public static inline function noteSortThing(Order:Int, Obj1:Note, Obj2:Note):Int{
		return FlxSort.byValues(Order, Obj1.strumTime, Obj2.strumTime);
	}

	function songPreload():Void {
		if(instSong != null){
			FlxG.sound.cache(Paths.inst(instSong));
		}
		else{
			FlxG.sound.cache(Paths.inst(SONG.song));
		}
		
		if(Utils.exists(Paths.voices(SONG.song, "Player"))){
			FlxG.sound.cache(Paths.voices(SONG.song, "Player"));
			FlxG.sound.cache(Paths.voices(SONG.song, "Opponent"));
			vocalType = splitVocalTrack;
		}
		else if(Utils.exists(Paths.voices(SONG.song))){
			FlxG.sound.cache(Paths.voices(SONG.song));
		}
		else{
			vocalType = noVocalTrack;
		}
	}

	override function switchState(_state:FlxState, ?_allowScriptedStates:Bool = true):Void{
		if(Utils.exists(Paths.voices(SONG.song, "Player"))){
			Assets.cache.removeSound(Paths.voices(SONG.song, "Player"));
			Assets.cache.removeSound(Paths.voices(SONG.song, "Opponent"));
		}
		else if(Utils.exists(Paths.voices(SONG.song))){
			Assets.cache.removeSound(Paths.voices(SONG.song));
		}

		if(instSong != null){
			Assets.cache.removeSound(Paths.inst(instSong));
		}
		else{
			Assets.cache.removeSound(Paths.inst(SONG.song));
		}

		var pauseSongName = "pause/breakfast";
		if(metadata != null){ pauseSongName = metadata.pauseMusic; }
		Assets.cache.removeSound(Paths.music(pauseSongName));

		super.switchState(_state);
	}

	function preStateChange():Void{
		stage.exit();
		for(script in scripts){ script.exit(); }
		Conductor.resetBPMChanges();
		fromChartEditor = false;
		fceForLilBuddies = false;
	}

	override function onFocus(){
		Utils.gc();
		super.onFocus();
	}

	/* 
	* This is done because changing the playback speed causes the song time to update slower essentially
	* causing the hit window to change with the playback speed. This mitigates that.
	*/
	private function set_songPlaybackSpeed(value:Float):Float{
		songPlaybackSpeed = value;
		Conductor.recalculateHitZones(value);
		return value;
	}
	
	private function set_scrollSpeedMultiplier(value:Float):Float{
		scrollSpeedMultiplier = value;
		for(note in unspawnNotes){
			if(note.isSustainNote && !note.isSustainEnd){
				note.updateHoldLength(value);
			}
		}
		notes.forEachAlive(function(note){
			if(note.isSustainNote && !note.isSustainEnd){
				note.updateHoldLength(value);
			}
		});
		return value;
	}

	public static function setupSong(_song:String, _difficuly:Int, ?_storyMode:Null<Bool> = null, ?_returnLocation:String = null, ?_overrideInstrumental:String = null):Void{
		var formattedSong:String = Highscore.formatSong(_song.toLowerCase(), _difficuly);
		PlayState.SONG = Song.loadFromJson(formattedSong, _song.toLowerCase());
		PlayState.storyDifficulty = _difficuly;
		PlayState.loadEvents = true;
		if(_storyMode != null)				{ PlayState.isStoryMode = _storyMode; }
		if(_returnLocation != null) 		{ PlayState.returnLocation = _returnLocation; }
		if(_overrideInstrumental != null)	{ PlayState.overrideInsturmental = _overrideInstrumental; }
	}

}

enum abstract VocalType(Int) {
	var noVocalTrack = 0;
	var combinedVocalTrack = 1;
	var splitVocalTrack = 2;
}

typedef ScoreStats = {
	score:Int,
	highestCombo:Int,
	accuracy:Float,
	sickCount:Int,
	goodCount:Int,
	badCount:Int,
	shitCount:Int,
	susCount:Int,
	missCount:Int,
	comboBreakCount:Int,
}