package;

import openfl.filters.ShaderFilter;
import shaders.*;
import ui.*;
import config.*;
import debug.*;
import title.*;
import transition.data.*;
import stages.*;
import stages.elements.*;
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

using StringTools;

class PlayState extends MusicBeatState
{

	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var curUiType:String = '';
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

	public var camFollow:FlxPoint;
	public var camFollowFinal:FlxObject;

	public var camFollowOffset:FlxPoint;
	private var offsetTween:FlxTween;
	private var returnedToCenter:Bool = true;

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

	public var tweenManager:FlxTweenManager = new FlxTweenManager();

	var instSong:String = null;
	public var vocals:FlxSound;
	public var vocalsOther:FlxSound;
	public var vocalType:VocalType = combinedVocalTrack;
	public var canChangeVocalVolume:Bool = true;

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

	public var anyPlayerNoteInRange:Bool = false;
	public var anyOpponentNoteInRange:Bool = false;

	private var strumLineVerticalPosition:Float;
	private var curSection:Int = 0;

	private static var prevCamFollow:FlxObject;

	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var enemyStrums:FlxTypedGroup<FlxSprite>;

	private var playerCovers:FlxTypedGroup<NoteHoldCover>;
	private var enemyCovers:FlxTypedGroup<NoteHoldCover>;

	private var curSong:String = "";

	public var health:Float = 1;
	public var healthLerp:Float = 1;
	public var healthAdjustOverride:Null<Float> = null;

	public var combo:Int = 0;
	public var totalPlayed:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOverlay:FlxCamera;
	private var camGameZoomAdjust:Float = 0;

	public var hudShader:AlphaShader = new AlphaShader(1);

	private var eventList:Array<Dynamic> = [];

	public var comboUI:ComboPopup;
	public static final minCombo:Int = 10;
	private var comboUiGroup:FlxTypedGroup<ComboPopup>;

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

	public static var replayStartCutscene:Bool = true;
	public static var replayEndCutscene:Bool = true;

	public var dadBeats:Array<Int> = [0, 2];
	public var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	var endingSong:Bool = false;

	var forceCenteredNotes:Bool = false;

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

		if(overrideInsturmental != ""){
			instSong = overrideInsturmental;
			overrideInsturmental = "";
		}

		if(loadEvents){
			if(Utils.exists("assets/data/" + SONG.song.toLowerCase() + "/events.json")){
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

		if(Utils.exists(Paths.json(SONG.song.toLowerCase() + "/meta"))){
			metadata = Json.parse(Utils.getText(Paths.json(SONG.song.toLowerCase() + "/meta")));
		}

		for(i in EVENTS.events){
			eventList.push([i[1], i[3]]);
		}

		eventList.sort(sortByEventStuff);

		inCutscene = false;

		songPreload();

		for(i in 1...4){
			FlxG.sound.cache(Paths.sound("missnote" + i));
		}
		
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

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.filters = [new ShaderFilter(hudShader.shader)];

		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

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

		var stageCheck:String = 'Stage';
		if (SONG.stage != null) {
			stageCheck = SONG.stage;
		}

		var stageClass = Type.resolveClass("stages.data." + stageCheck);
		if(stageClass == null){
			stageClass = BaseStage;
		}

		stage = Type.createInstance(stageClass, []);

		curStage = stage.name;
		curUiType = stage.uiType;

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
		
		add(hudLayer);
		hudLayer.cameras = [camHUD];

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
			strumLineVerticalPosition = 30;
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

		FlxG.camera.follow(camFollowFinal, LOCKON);

		defaultCamZoom = stage.startingZoom;
		
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		camGame.zoom = defaultCamZoom;

		FlxG.camera.focusOn(camFollowFinal.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if(Utils.exists(Paths.text(SONG.song.toLowerCase() + "/meta"))){
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
		startingSong = true;

		//Get and run cutscene stuff
		if(Utils.exists("assets/data/" + SONG.song.toLowerCase() + "/cutscene.json")){
			trace("song has cutscene info");
			var cutsceneJson = Json.parse(Utils.getText("assets/data/" + SONG.song.toLowerCase() + "/cutscene.json"));
			//trace(cutsceneJson);
			if(Type.typeof(cutsceneJson.startCutscene) == TObject){
				if(cutsceneJson.startCutscene.storyOnly != null) {startCutsceneStoryOnly = cutsceneJson.startCutscene.storyOnly;}
				if((!startCutsceneStoryOnly || (startCutsceneStoryOnly && isStoryMode)) ){
					var startCutsceneClass = Type.resolveClass("cutscenes.data." + cutsceneJson.startCutscene.name);
					var startCutsceneArgs = [];
					if(cutsceneJson.startCutscene.args != null) {startCutsceneArgs = cutsceneJson.startCutscene.args;}
					if(cutsceneJson.startCutscene.playOnce != null) {startCutscenePlayOnce = cutsceneJson.startCutscene.playOnce;}
					startCutscene = Type.createInstance(startCutsceneClass, startCutsceneArgs);
				}
			}
			//trace(startCutscene);
			//trace(startCutsceneStoryOnly);

			if(Type.typeof(cutsceneJson.endCutscene) == TObject){
				if(cutsceneJson.endCutscene.storyOnly != null) {endCutsceneStoryOnly = cutsceneJson.endCutscene.storyOnly;}
				if((!endCutsceneStoryOnly || (endCutsceneStoryOnly && isStoryMode)) ){
					var endCutsceneClass = Type.resolveClass("cutscenes.data." + cutsceneJson.endCutscene.name);
					var endCutsceneArgs = [];
					if(cutsceneJson.endCutscene.args != null) {endCutsceneArgs = cutsceneJson.endCutscene.args;}
					if(cutsceneJson.endCutscene.playOnce != null) {endCutscenePlayOnce = cutsceneJson.endCutscene.playOnce;}
					endCutscene = Type.createInstance(endCutsceneClass, endCutsceneArgs);
				}
			}
			//trace(endCutscene);
			//trace(endCutsceneStoryOnly);
		}

		var bgDim = new FlxSprite(1280 / -2, 720 / -2).makeGraphic(1, 1, FlxColor.BLACK);
		bgDim.scale.set(1280*2, 720*2);
		bgDim.updateHitbox();
		bgDim.cameras = [camOverlay];
		bgDim.alpha = Config.bgDim/10;
		add(bgDim);

		cutsceneCheck();

		if(fromChartEditor && !fceForLilBuddies){
			preventScoreSaving = true;
		}
		fromChartEditor = false;
		fceForLilBuddies = false;

		stage.postCreate();

		super.create();
	}

	function cutsceneCheck():Void{
		//trace("in cutsceneCheck");
		if(startCutscene != null && (startCutscenePlayOnce ? replayStartCutscene : true)){
			add(startCutscene);
			inCutscene = true;
			startCutscene.start();
		}
		else{
			if(!stage.instantStart){
				startCountdown();
			}
			else{
				instantStart();
			}
		}
		replayStartCutscene = true;
	}

	function updateAccuracy(){
		var total:Float = (songStats.sickCount) + (songStats.goodCount) + (songStats.badCount) + (songStats.shitCount) + (songStats.missCount);
		songStats.accuracy = total == 0 ? 0 : (((songStats.sickCount + songStats.goodCount) / total) * 100);
		songStats.accuracy = Utils.clamp(songStats.accuracy, 0, 100);
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

		var countdownSkinName:String = PlayState.curUiType;
		var countdownSkinClass = Type.resolveClass("ui.countdownSkins." + countdownSkinName);
		if(countdownSkinClass == null){
			countdownSkinClass = ui.countdownSkins.Default;
		}
		var countdownSkin:CountdownSkinBase = Type.createInstance(countdownSkinClass, []);

		stage.countdownBeat(-1);

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{

			if(swagCounter != 4) { gf.dance(); }

			if(dadBeats.contains((swagCounter % 4)))
				if(swagCounter != 4) { dad.dance(); }

			if(bfBeats.contains((swagCounter % 4)))
				if(swagCounter != 4) { boyfriend.dance(); }

			switch (swagCounter)

			{
				case 0:
					if(meta != null){ meta.start(); }

					if(countdownSkin.info.first.audioPath != null){
						FlxG.sound.play(Paths.sound(countdownSkin.info.first.audioPath), 0.6);
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
						FlxG.sound.play(Paths.sound(countdownSkin.info.second.audioPath), 0.6);
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
						FlxG.sound.play(Paths.sound(countdownSkin.info.third.audioPath), 0.6);
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
						FlxG.sound.play(Paths.sound(countdownSkin.info.fourth.audioPath), 0.6);
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
					beatHit();
			}

			if(swagCounter < 4){
				stage.countdownBeat(swagCounter);
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

		beatHit();
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

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByEventStuff(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	//player 1 is player, player 0 is opponent
	public function generateStaticArrows(player:Int, ?instant:Bool = false, ?skin:String):Void{
		if(skin == null){ skin = PlayState.curUiType; }

		var hudNoteSkinName:String = skin;
		var hudNoteSkinClass = Type.resolveClass("ui.hudNoteSkins." + hudNoteSkinName);
		if(hudNoteSkinClass == null){
			hudNoteSkinClass = ui.hudNoteSkins.Default;
		}
		var hudNoteSkin:HudNoteSkinBase = Type.createInstance(hudNoteSkinClass, []);

		var hudNoteSkinInfo = hudNoteSkin.info.notes;

		if(player == 0){
			if(hudNoteSkin.info.opponentNotes != null){
				hudNoteSkinInfo = hudNoteSkin.info.opponentNotes;
			}
		}

		for (i in 0...4){
			
			var babyArrow:FlxSprite = new FlxSprite(50, strumLineVerticalPosition);

			switch(hudNoteSkinInfo.noteFrameLoadType){
				case sparrow:
					babyArrow.frames = Paths.getSparrowAtlas(hudNoteSkinInfo.notePath);
				case packer:
					babyArrow.frames = Paths.getPackerAtlas(hudNoteSkinInfo.notePath);
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
			babyArrow.antialiasing = hudNoteSkinInfo.anitaliasing;

			var noteCover:NoteHoldCover = new NoteHoldCover(babyArrow, i, hudNoteSkinInfo.coverPath);

			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			babyArrow.x += 50;

			if (player == 1) {
				playerStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String){
					if(autoplay){
						if(name == "confirm"){
							babyArrow.animation.play('static', true);
						}
					}
				}

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
				babyArrow.animation.finishCallback = function(name:String){
					if(name == "confirm"){
						babyArrow.animation.play('static', true);
					}
				}

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

			babyArrow.animation.callback = function(name:String, frame:Int, index:Int) {
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
			}

			babyArrow.animation.play('static');
		}

		if(player == 1){
			//Prevents the game from lagging at first note splash.
			NoteSplash.splashSkinClassName = hudNoteSkinInfo.splashClass;
			var preloadSplash = new NoteSplash(-2000, -2000, 0);
		}
	}

	public function generateComboPopup(?skin:String):Void{
		if(skin == null){ skin = PlayState.curUiType; }

		var comboPopupSkinName:String = skin;
		var comboPopupSkinClass = Type.resolveClass("ui.comboPopupSkins." + comboPopupSkinName);
		if(comboPopupSkinClass == null){
			comboPopupSkinClass = ui.comboPopupSkins.Default;
		}
		var comboPopupSkin:ComboPopupSkinBase = Type.createInstance(comboPopupSkinClass, []);

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
				comboUI.comboBreakInfo.position.set(844, 580);
			}
			else{
				comboUI.ratingInfo.position.set(844, 150);
				comboUI.numberInfo.position.set(340, 125);
				comboUI.comboBreakInfo.position.set(844, 150);
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

	override function openSubState(SubState:FlxSubState) {

		if (paused){

			if (FlxG.sound.music != null){
				FlxG.sound.music.pause();
				vocals.pause();
				if(vocalType == splitVocalTrack){ vocalsOther.pause(); }
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;

			stage.pause();
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		
		if (paused){

			if (FlxG.sound.music != null && !startingSong){
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished){
				startTimer.active = true;
			}
				
			paused = false;

			stage.unpause();
		}

		setBoyfriendInvuln(1/60);

		super.closeSubState();
	}

	function resyncVocals():Void {
		vocals.pause();
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
		//trace("resyncing vocals");
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
		updateScoreText();

		super.update(elapsed);

		stage.update(elapsed);

		if(!startingSong){
			for(i in eventList){
				if(i[0] > Conductor.songPosition){
					break;
				}
				else{
					executeEvent(i[1]);
					eventList.remove(i);
				}
			}
		}

		if (Binds.justPressed("pause") && startedCountdown && canPause){
			paused = true;
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN && !isStoryMode){

			if(!FlxG.keys.pressed.SHIFT){
				ChartingState.startSection = curSection;
			}

			switchState(new ChartingState());
			sectionStart = false;
		}

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconP1.xOffset);
		iconP1.y = healthBar.y - (iconP1.height / 2) + iconP1.yOffset;
		
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconP2.xOffset);
		iconP2.y = healthBar.y - (iconP2.height / 2) + iconP2.yOffset;

		if (health > 2){
			health = 2;
		}

		if(healthLerp != health){
			healthLerp = Utils.fpsAdjsutedLerp(healthLerp, health, 0.7);
		}
		if(inRange(healthLerp, 2, 0.001)){
			healthLerp = 2;
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

		if (FlxG.keys.justPressed.EIGHT && !isStoryMode){

			sectionStart = false;

			if(FlxG.keys.pressed.SHIFT){
				switchState(new AnimationDebug(SONG.player1));
			}
			else if(FlxG.keys.pressed.CONTROL){
				switchState(new AnimationDebug(gfCheck));
			}
			else{
				switchState(new AnimationDebug(SONG.player2));
			}
		}
			

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		/*else if(inEndingCutscene){

		}*/
		else{
			if(previousReportedSongTime != FlxG.sound.music.time){
				Conductor.songPosition = FlxG.sound.music.time;
				previousReportedSongTime = FlxG.sound.music.time;
			}
			else{
				Conductor.songPosition += FlxG.elapsed * 1000;
			}
		}

		if(!dad.isSinging && !boyfriend.isSinging && !returnedToCenter){
			returnedToCenter = true;
			changeCamOffset(0, 0);
		}
		if(dad.isSinging || boyfriend.isSinging){
			returnedToCenter = false;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong) {

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam){
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam){
				camFocusBF();
			}
		}

		camFollowFinal.setPosition(camFollow.x + camFollowOffset.x + camFollowShake.x + stage.globalCameraOffset.x, camFollow.y + camFollowOffset.y + camFollowShake.y + stage.globalCameraOffset.y);

		if(!inVideoCutscene){
			camGame.zoom = defaultCamZoom + camGameZoomAdjust;
		}

		//FlxG.watch.addQuick("totalBeats: ", totalBeats);

		// RESET = Quick Game Over Screen
		if (Binds.justPressed("killbind") && !startingSong) {
			health = 0;
		}

		if (health <= 0){ openGameOver(); }

		if (unspawnNotes[0] != null){
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3000){
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);

				sortNotes();
			}
		}

		if (generatedMusic){
			updateNote();
			opponentNoteCheck();
		}

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
					noteMiss(daNote.noteData, daNote.missCallback, Scoring.MISS_DAMAGE_AMMOUNT, true, true);
					if(canChangeVocalVolume){ vocals.volume = 0; }
					daNote.didTooLateAction = true;
				}
			}

			if (Config.downscroll ? (daNote.y > targetY + daNote.height + 50) : (daNote.y < targetY - daNote.height - 50)){
				if (daNote.tooLate || daNote.wasGoodHit){
								
					daNote.active = false;
					daNote.visible = false;
					daNote.destroy();
				}
			}
		});
	}

	function opponentNoteCheck(){
		anyOpponentNoteInRange = false;
		notes.forEachAlive(function(daNote:Note){

			if(daNote.inRange && !daNote.mustPress) {anyOpponentNoteInRange = true;}

			if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit){

				daNote.wasGoodHit = true;

				daNote.hitCallback(daNote, dad);
				healthAdjustOverride = null;

				enemyStrums.forEach(function(spr:FlxSprite){
					if (Math.abs(daNote.noteData) == spr.ID){
						spr.animation.play('confirm', true);
					}
				});

				dad.holdTimer = 0;

				switch(vocalType){
					case splitVocalTrack:
						if(canChangeVocalVolume){ vocalsOther.volume = 1; }
					case combinedVocalTrack:
						if(canChangeVocalVolume){ vocals.volume = 1;}
					default:
				}
					

				if(!daNote.isSustainNote){
					daNote.destroy();
				}
				else{
					if(daNote.prevNote == null || !daNote.prevNote.isSustainNote){
						enemyCovers.forEach(function(cover:NoteHoldCover) {
							if (Math.abs(daNote.noteData) == cover.noteDirection) {
								cover.start();
							}
						});
					}
					else if(daNote.isSustainEnd){
						enemyCovers.forEach(function(cover:NoteHoldCover) {
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
				//FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), TitleScreen.titleMusicVolume);

				StoryMenuState.fromPlayState = true;
				//returnToMenu();
				sectionStart = false;

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				weekStats.accuracy / StoryMenuState.weekData[storyWeek].length;

				//Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				var songSaveStuff:SaveInfo = null;
				if(!preventScoreSaving){
					songSaveStuff = {
						song: null,
						week: storyWeek,
						diff: storyDifficulty
					}
				}
				switchState(new ResultsState(weekStats, StoryMenuState.weekNamesShort[storyWeek], boyfriend.characterInfo.info.resultsCharacter, songSaveStuff));

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
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

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		//CODE FOR ENDING A FREEPLAY SONG
		else{

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
			switchState(new ResultsState(songStats, songName, boyfriend.characterInfo.info.resultsCharacter, songSaveStuff));
		}
	}

	public function returnToMenu():Void{
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
				health += Scoring.SICK_HEAL_AMMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.sickCount++;
				if(Config.noteSplashType >= 1 && Config.noteSplashType < 4){
					createNoteSplash(note.noteData);
				}
			case "good":
				health += Scoring.GOOD_HEAL_AMMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.goodCount++;
			case "bad":
				health += Scoring.BAD_HEAL_AMMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.badCount++;
				comboBreak();
			case "shit":
				health += Scoring.SHIT_HEAL_AMMOUNT * Config.healthMultiplier * noHealMultiply;
				songStats.shitCount++;
				comboBreak();
		}

		comboUI.ratingPopup(rating);

		if(combo >= minCombo)
			comboUI.comboPopup(combo);

	}

	private function createNoteSplash(note:Int){
		var bigSplashy = new NoteSplash(Utils.getGraphicMidpoint(playerStrums.members[note]).x, Utils.getGraphicMidpoint(playerStrums.members[note]).y, note);
		bigSplashy.cameras = [camHUD];
		add(bigSplashy);
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

		anyPlayerNoteInRange = false;
		notes.forEachAlive(function(daNote:Note){
			if(!anyPlayerNoteInRange && daNote.inRange && daNote.mustPress){anyPlayerNoteInRange = true;}
		});

		if ((upPress || rightPress || downPress || leftPress) && generatedMusic){
			
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate) {
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);

					if(Config.ghostTapType == 1){
						setCanMiss();
					}
				}
			});

			var directionsAccounted = [false,false,false,false];

			if (possibleNotes.length > 0 && !forceMissNextNote){
				for(note in possibleNotes){
					if (controlArray[note.noteData] && !directionsAccounted[note.noteData]){
						goodNoteHit(note);
						directionsAccounted[note.noteData] = true;
					}
				}
				for(i in 0...4){
					if(!ignoreList.contains(i) && controlArray[i]){
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

					boyfriend.holdTimer = 0;

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
					noteMiss(daNote.noteData, daNote.missCallback, Scoring.HOLD_DROP_DMAMGE_PER_NOTE * (daNote.isFake ? 0 : 1), false, false, true, Scoring.HOLD_DROP_PENALTY);
					//updateAccuracyOld();
				}

				//This is for the first released note.
				if(daNote.prevNote.wasGoodHit && !daNote.wasGoodHit){

					if(releaseTimes[daNote.noteData] >= releaseBufferTime){
						noteMiss(daNote.noteData, daNote.missCallback, Scoring.HOLD_DROP_INITAL_DAMAGE, true, false, true, Scoring.HOLD_DROP_INITIAL_PENALTY);
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

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.stepsUntilRelease * 0.001 && !upHold && !downHold && !rightHold && !leftHold && boyfriend.canAutoAnim && (Character.PREVENT_SHORT_IDLE ? !anyPlayerNoteInRange : true)){
			if (boyfriend.isSinging){
				if(Character.USE_IDLE_END){ 
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

		/*	switch(spr.animation.curAnim.name){

				case "confirm":

					//spr.alpha = 1;
					spr.centerOffsets();

					if(!(curUiType.toLowerCase() == "pixel")){
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}

					//i'm bored lol
				//	if(spr.animation.curAnim.curFrame == 0){
				//		tweenManager.cancelTweensOf(spr.scale);
				//		spr.centerOrigin();
				//		spr.scale.set(1.4, 1.4);
				//		tweenManager.tween(spr.scale, {x: 0.7, y: 0.7}, 1, {ease: FlxEase.elasticOut});
				//	}

				//case "static":
				//	spr.alpha = 0.5; //Might mess around with strum transparency in the future or something.
				//	spr.centerOffsets();

				default:
					//spr.alpha = 1;
					spr.centerOffsets();

			}*/

		});
	}

	private function keyShitAuto():Void{

		var hitNotes:Array<Note> = [];

		anyPlayerNoteInRange = false;

		notes.forEachAlive(function(daNote:Note){
			if(daNote.inRange && daNote.mustPress){anyPlayerNoteInRange = true;}

			if (!forceMissNextNote && !daNote.wasGoodHit && daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * (!daNote.isSustainNote ? 0.125 : (daNote.prevNote.wasGoodHit ? 1 : 0))){
				hitNotes.push(daNote);
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.stepsUntilRelease * 0.001 && !upHold && !downHold && !rightHold && !leftHold && boyfriend.canAutoAnim && (Character.PREVENT_SHORT_IDLE ? !anyPlayerNoteInRange : true)){
			if (boyfriend.isSinging){
				if(Character.USE_IDLE_END){ 
					boyfriend.idleEnd(); 
				}
				else{ 
					boyfriend.dance(); 
					boyfriend.danceLockout = true;
				}
			}
		}

		for(x in hitNotes){

			boyfriend.holdTimer = 0;

			goodNoteHit(x);
			
			playerStrums.forEach(function(spr:FlxSprite){
				if (Math.abs(x.noteData) == spr.ID){
					spr.animation.play('confirm', true);
					/*if (spr.animation.curAnim.name == 'confirm' && !(curUiType.toLowerCase() == "pixel")){
						spr.centerOffsets();
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}
					else{
						spr.centerOffsets();
					}*/
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
			
			if(playAudio){
				FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), 0.2);
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

		}

	}

	inline function noteMissWrongPress(direction:Int = 1):Void{
		var forceMissNextNoteState = forceMissNextNote;
		noteMiss(direction, defaultNoteMiss, Scoring.WRONG_TAP_DAMAGE_AMMOUNT, true, false, false, Scoring.WRONG_PRESS_PENALTY);
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
					playerCovers.forEach(function(cover:NoteHoldCover) {
						if (Math.abs(note.noteData) == cover.noteDirection) {
							cover.start();
						}
					});
				}
				return;
			}
			
			note.hitCallback(note, boyfriend);

			if (!note.isSustainNote){
				popUpScore(note, healthAdjustOverride == null);
				combo++;
				if(combo > songStats.highestCombo) { songStats.highestCombo = combo; }
			}
			else{
				if(healthAdjustOverride != null){
					health += Scoring.HOLD_HEAL_AMMOUNT * Config.healthMultiplier;
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

			if(!note.isSustainNote){
				note.destroy();
			}
			else{
				if(note.prevNote == null || !note.prevNote.isSustainNote){
					playerCovers.forEach(function(cover:NoteHoldCover) {
						if (Math.abs(note.noteData) == cover.noteDirection) {
							cover.start();
						}
					});
				}
				else if(note.isSustainEnd){
					playerCovers.forEach(function(cover:NoteHoldCover) {
						if (Math.abs(note.noteData) == cover.noteDirection) {
							cover.end(true);
						}
					});
				}
			}
		}
	}

	override function stepHit()
	{

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > 20 || (vocalType != noVocalTrack && Math.abs(vocals.time - (Conductor.songPosition)) > 20)){
			resyncVocals();
		}

		if(vocalType == splitVocalTrack){
			if (Math.abs(vocalsOther.time - (Conductor.songPosition)) > 20){
				resyncVocals();
			}
		}

		if(curStep > 0 && curStep % 16 == 0){
			curSection++;
		}

		boyfriend.step(curStep);
		dad.step(curStep);
		gf.step(curStep);
		stage.step(curStep);

		super.stepHit();
	}

	override function beatHit()
	{
		//wiggleShit.update(Conductor.crochet);
		super.beatHit();

		//sortNotes();

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM){
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}

			// Dad doesnt interupt his own notes
			if(dadBeats.contains(curBeat % 4) && dad.canAutoAnim && dad.holdTimer == 0 && !dad.isSinging && (Character.PREVENT_SHORT_IDLE ? !anyOpponentNoteInRange : true)){
				dad.dance();
			}
			
		}
		else{
			if(dadBeats.contains(curBeat % 4))
				dad.dance();
		}

		if(curBeat % camBopFrequency == 0 && autoCamBop){
			uiBop(0.0175, 0.03, 0.8);
		}

		if (curBeat % iconBopFrequency == 0){
			iconP1.iconScale = iconP1.defualtIconScale * 1.25;
			iconP2.iconScale = iconP2.defualtIconScale * 1.25;

			iconP1.tweenToDefaultScale(0.2, FlxEase.quintOut);
			iconP2.tweenToDefaultScale(0.2, FlxEase.quintOut);
		}
		
		if (curBeat % gfBopFrequency == 0){
			gf.dance();
		}

		if(bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim && !boyfriend.isSinging && (Character.PREVENT_SHORT_IDLE ? !anyPlayerNoteInRange : true)){
			boyfriend.dance();
		}

		boyfriend.beat(curBeat);
		dad.beat(curBeat);
		gf.beat(curBeat);
		stage.beat(curBeat);
		
	}

	public function executeEvent(tag:String):Void{

		var prefix = tag.split(";")[0];

		if(Events.events.exists(prefix)){
			Events.events.get(prefix)(tag);
		}
		else if(stage.events.exists(tag)){
			stage.events.get(prefix)(tag);
		}
		else{
			trace("No event found for: " + tag);
		}

		return;
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
		return (Character.LOOP_ANIM_ON_HOLD ? (note.isSustainNote ? (Character.HOLD_LOOP_WAIT ? (!character.isSinging || (character.timeInCurrentAnimation >= (3/24) || character.curAnimFinished())) : true) : true) : !note.isSustainNote)
			&& (Character.PREVENT_SHORT_SING ? !inRange(character.lastSingTime, Conductor.songPosition, Character.SHORT_SING_TOLERENCE) : true);
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

	public function camFocusOpponent(?offsetX:Float = 0, ?offsetY:Float = 0, ?_time:Float = 1.9, ?_ease:Null<flixel.tweens.EaseFunction>){
		if(_ease == null){_ease = FlxEase.expoOut;}
		
		var pos = getOpponentFocusPosition();
		camMove(pos.x + offsetX, pos.y + offsetY, _time, _ease, "dad");
		changeCamOffset(0, 0);
	}

	public inline function getOpponentFocusPosition():FlxPoint{
		return new FlxPoint(dad.getMidpoint().x + dad.focusOffset.x + stage.dadCameraOffset.x, dad.getMidpoint().y + dad.focusOffset.y + stage.dadCameraOffset.y);
	}

	public function camFocusBF(?offsetX:Float = 0, ?offsetY:Float = 0, ?_time:Float = 1.9, ?_ease:Null<flixel.tweens.EaseFunction>){
		if(_ease == null){_ease = FlxEase.expoOut;}

		var pos = getBfFocusPostion();
		camMove(pos.x + offsetX, pos.y + offsetY, _time, _ease, "bf");
		changeCamOffset(0, 0);
	}

	public inline function getBfFocusPostion():FlxPoint{
		return new FlxPoint(boyfriend.getMidpoint().x + boyfriend.focusOffset.x + stage.bfCameraOffset.x, boyfriend.getMidpoint().y + boyfriend.focusOffset.y + stage.bfCameraOffset.y);
	}

	public function camFocusGF(?offsetX:Float = 0, ?offsetY:Float = 0, ?_time:Float = 1.9, ?_ease:Null<flixel.tweens.EaseFunction>){
		if(_ease == null){_ease = FlxEase.expoOut;}

		var pos = getGfFocusPosition();
		camMove(pos.x + offsetX, pos.y + offsetY, _time, _ease, "gf");
		changeCamOffset(0, 0);
	}

	public inline function getGfFocusPosition():FlxPoint{
		return new FlxPoint(gf.getMidpoint().x + gf.focusOffset.x + stage.gfCameraOffset.x, gf.getMidpoint().y + gf.focusOffset.y + stage.gfCameraOffset.y);
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

	public function changeCamOffset(_x:Float, _y:Float, ?_time:Float = 1.4, ?_ease:Null<flixel.tweens.EaseFunction>){

		//Don't allow for extra camera offsets if it's disabled in the config.
		if(!Config.extraCamMovement){ return; }

		if(_ease == null){
			_ease = FlxEase.expoOut;
		}

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

	function updateScoreText(){

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

	static function inRange(a:Float, b:Float, tolerance:Float):Bool{
		return (a <= b + tolerance && a >= b - tolerance);
	}

	function sortNotes(){
		if (generatedMusic){
			notes.sort(noteSortThing, FlxSort.DESCENDING);
		}
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

	override function switchState(_state:FlxState):Void{
		if(Utils.exists(Paths.voices(SONG.song, "Player"))){
			Assets.cache.removeSound(Paths.voices(SONG.song, "Player"));
			Assets.cache.removeSound(Paths.voices(SONG.song, "Opponent"));
		}
		else if(Utils.exists(Paths.voices(SONG.song))){
			Assets.cache.removeSound(Paths.voices(SONG.song));
		}

		if(!CacheConfig.music){
			if(instSong != null){
				Assets.cache.removeSound(Paths.inst(instSong));
			}
			else{
				Assets.cache.removeSound(Paths.inst(SONG.song));
			}
		}

		super.switchState(_state);
	}

	function preStateChange():Void{
		stage.exit();
	}

}

enum VocalType {
	noVocalTrack;
	combinedVocalTrack;
	splitVocalTrack;
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