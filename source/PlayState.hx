package;

#if sys
import sys.FileSystem;
#end

import config.*;
import debug.*;
import title.*;
import transition.data.*;
import stages.*;
import stages.elements.*;

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
	
	public static var returnLocation:String = "main";
	
	private var canHit:Bool = false;
	private var missTime:Float = 0;

	private var invuln:Bool = false;
	private var invulnTime:Float = 0;

	private var releaseTimes:Array<Float> = [-1, -1, -1, -1];
	private final releaseBufferTime = (2/60);

	private var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var camZoomAdjustTween:FlxTween;
	private var uiZoomTween:FlxTween;

	private var camFollow:FlxObject;
	private var camFollowOffset:FlxObject;
	private var camFollowFinal:FlxObject;
	private var offsetTween:FlxTween;
	
	private var camOffsetAmount:Float = 25;

	private var autoCam:Bool = true;
	private var autoZoom:Bool = true;
	private var autoUi:Bool = true;
	private var autoCamBop:Bool = true;

	private var gfBopFrequency:Int = 1;
	private var iconBopFrequency:Int = 1;
	private var camBopFrequency:Int = 4;

	private var sectionHasOppNotes:Bool = false;
	private var sectionHasBFNotes:Bool = false;
	private var sectionHaveNotes:Array<Array<Bool>> = [];

	private var vocals:FlxSound;
	private var vocalsOther:FlxSound;
	private var vocalType:VocalType = combinedVocalTrack;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	var gfCheck:String;

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
	private var usedAutoplay:Bool = false;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;

	private var curSong:String = "";

	private var health:Float = 1;
	private var healthLerp:Float = 1;

	private var combo:Int = 0;
	private var misses:Int = 0;
	private var comboBreaks:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camOverlay:FlxCamera;
	private var camGameZoomAdjust:Float = 0;

	private var eventList:Array<Dynamic> = [];

	private var comboUI:ComboPopup;
	public static final minCombo:Int = 10;

	var dialogue:Array<String> = [':bf:strange code', ':dad:>:]'];

	var stage:Dynamic;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxTextExt;

	var ccText:SongCaptions;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var video:VideoHandler;
	var inCutscene:Bool = false;
	var inVideoCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	private var meta:SongMetaTags;

	private static final NOTE_HIT_HEAL:Float = 0.02;
	private static final HOLD_HIT_HEAL:Float = 0.01;

	private static final NOTE_MISS_DAMAGE:Float = 0.065;
	private static final HOLD_RELEASE_STEP_DAMAGE:Float = 0.04;
	private static final WRONG_TAP_DAMAGE:Float = 0.05;
	
	override public function create(){

		instance = this;
		FlxG.mouse.visible = false;

		customTransIn = new ScreenWipeIn(1.2);
		customTransOut = new ScreenWipeOut(0.6);

		if(loadEvents){
			if(CoolUtil.exists("assets/data/" + SONG.song.toLowerCase() + "/events.json")){
				trace("loaded events");
				trace(Paths.json(SONG.song.toLowerCase() + "/events"));
				EVENTS = Song.parseEventJSON(CoolUtil.getText(Paths.json(SONG.song.toLowerCase() + "/events")));
			}
			else{
				trace("No events found");
				EVENTS = {
					events: []
				};
			}
		}

		for(i in EVENTS.events){
			eventList.push([i[1], i[3]]);
		}

		eventList.sort(sortByEventStuff);

		inCutscene = false;

		songPreload();
		
		Config.setFramerate(999);

		camTween = FlxTween.tween(this, {}, 0);
		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);
		offsetTween = FlxTween.tween(this, {}, 0);
		camZoomAdjustTween = FlxTween.tween(this, {}, 0);

		for(i in 0 ... SONG.notes.length){

			var array = [false, false];

			array[0] = sectionContainsBfNotes(i);
			array[1] = sectionContainsOppNotes(i);

			sectionHaveNotes.push(array);

		}
		
		canHit = !(Config.ghostTapType > 0);

		camGame = new FlxCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

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

		if(CoolUtil.exists(Paths.text(SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue"))){
			try{
				dialogue = CoolUtil.coolTextFile(Paths.text(SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue"));
			}
			catch(e){}
		}

		gfCheck = "Gf";

		if (SONG.gf != null) {
			gfCheck = SONG.gf;
		}

		gf = new Character(400, 130, gfCheck);
		gf.scrollFactor.set(0.95, 0.95);

		var dadChar = SONG.player2;

		dad = new Character(100, 100, dadChar);

		var bfChar = SONG.player1;

		boyfriend = new Character(770, 450, bfChar, true);

		var stageCheck:String = 'Stage';
		if (SONG.stage != null) {
			stageCheck = SONG.stage;
		}

		var stageClass = Type.resolveClass("stages." + stageCheck);
		if(stageClass == null){
			stageClass = BaseStage;
		}

		stage = Type.createInstance(stageClass, []);

		curStage = stage.name;
		curUiType = stage.uiType;

		
		if(stage.useStartPoints){
			dad.setPosition(stage.dadStart.x - ((dad.frameWidth * dad.scale.x)/2), stage.dadStart.y - (dad.frameHeight * dad.scale.y));
			boyfriend.setPosition(stage.bfStart.x - ((boyfriend.frameWidth * boyfriend.scale.x)/2), stage.bfStart.y - (boyfriend.frameHeight * boyfriend.scale.y));
			gf.setPosition(stage.gfStart.x - ((gf.frameWidth * gf.scale.x)/2), stage.gfStart.y - (gf.frameHeight * gf.scale.y));
		}
		
		dad.x += dad.reposition.x;
		dad.y += dad.reposition.y;
		boyfriend.x += boyfriend.reposition.x;
		boyfriend.y += boyfriend.reposition.y;
		gf.x += gf.reposition.x;
		gf.y += gf.reposition.y;

		for(i in 0...stage.backgroundElements.length){
			add(stage.backgroundElements[i]);
		}

		switch(SONG.song.toLowerCase()){
			case "tutorial":
				autoZoom = false;
				dadBeats = [0, 1, 2, 3];
			case "bopeebo":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "fresh":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "spookeez":
				dadBeats = [0, 1, 2, 3];
			case "south":
				dadBeats = [0, 1, 2, 3];
			case "monster":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "cocoa":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "thorns":
				dadBeats = [0, 1, 2, 3];
		}

		var camPos:FlxPoint = new FlxPoint(CoolUtil.getTrueGraphicMidpoint(dad).x, CoolUtil.getTrueGraphicMidpoint(dad).y);

		switch (dad.curCharacter)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				camPos.x += 600;
				if (isStoryMode){
					camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
				}

			case "spooky":
				//dad.y += 200;
				camPos.set(CoolUtil.getTrueGraphicMidpoint(dad).x + 300, CoolUtil.getTrueGraphicMidpoint(dad).y - 100);
			case "monster":
				//dad.y += 100;
				camPos.set(CoolUtil.getTrueGraphicMidpoint(dad).x + 300, CoolUtil.getTrueGraphicMidpoint(dad).y - 100);
			case 'monster-christmas':
				//dad.y += 130;
				camPos.set(CoolUtil.getTrueGraphicMidpoint(dad).x + 300, CoolUtil.getTrueGraphicMidpoint(dad).y - 100);
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				//dad.y += 300;
				//dad.x -= 280;
				//dad.x += 270;
				//dad.y -= 250;
				//dad.x += 160;
			case 'parents-christmas':
				//dad.x -= 500;
			case 'senpai':
				//dad.x += 150;
				//dad.y += 360;
				camPos.set(CoolUtil.getTrueGraphicMidpoint(dad).x + 300, CoolUtil.getTrueGraphicMidpoint(dad).y);
			case 'senpai-angry':
				//dad.x += 150;
				//dad.y += 360;
				camPos.set(CoolUtil.getTrueGraphicMidpoint(dad).x + 300, CoolUtil.getTrueGraphicMidpoint(dad).y);
			case 'spirit':
				//dad.x -= 150;
				//dad.y += 100;
				//dad.x += 36 * 6;
				//dad.y += 46 * 6;
				camPos.set(CoolUtil.getTrueGraphicMidpoint(dad).x + 300, CoolUtil.getTrueGraphicMidpoint(dad).y);
			case 'tankman':
				//dad.y += 165;
				//dad.x -= 40;
				camPos.x += 400;
		}

		autoCam = stage.cameraMovementEnabled;

		if(stage.cameraStartPosition != null){
			camPos.set(stage.cameraStartPosition.x, stage.cameraStartPosition.y);
		}
		
		if(stage.extraCameraMovementAmount != null){
			camOffsetAmount = stage.extraCameraMovementAmount;
		}

		add(gf);

		for(i in 0...stage.middleElements.length){
			add(stage.middleElements[i]);
		}
		
		add(dad);
		add(boyfriend);

		/*Start pos debug shit. I'll leave it in for now incase everything breaks.
		var dadPos = new FlxSprite(CoolUtil.getTrueGraphicMidpoint(dad).x, dad.y + (dad.frameHeight * dad.scale.y)).makeGraphic(24, 24, 0xFFFF00FF);
		var bfPos = new FlxSprite(CoolUtil.getTrueGraphicMidpoint(boyfriend).x, boyfriend.y + (boyfriend.frameHeight * boyfriend.scale.y)).makeGraphic(24, 24, 0xFF00FFFF);
		var gfPos = new FlxSprite(CoolUtil.getTrueGraphicMidpoint(gf).x, gf.y + (gf.frameHeight * gf.scale.y)).makeGraphic(24, 24, 0xFFFF0000);

		add(dadPos);
		add(bfPos);
		add(gfPos);

		trace("dad: " + dadPos.x + ", " + dadPos.y);
		trace("bf: " + bfPos.x + ", " + bfPos.y);
		trace("gf: " + gfPos.x + ", " + gfPos.y);*/

		for(i in 0...stage.foregroundElements.length){
			add(stage.foregroundElements[i]);
		}

		switch(curUiType){

			default:
				comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y - 75,	[Paths.image("ui/ratings"), 403, 163, true], 
				[Paths.image("ui/numbers"), 100, 120, true], 
				[Paths.image("ui/comboBreak"), 348, 211, true]);
				NoteSplash.splashPath = "ui/noteSplashes";

			case "pixel":
				comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y - 75, 	[Paths.image("week6/weeb/pixelUI/ratings-pixel"), 51, 20, false], 
																				[Paths.image("week6/weeb/pixelUI/numbers-pixel"), 11, 12, false], 
																				[Paths.image("week6/weeb/pixelUI/comboBreak-pixel"), 53, 32, false], 
																				[daPixelZoom * 0.7, daPixelZoom * 0.8, daPixelZoom * 0.7]);
				comboUI.numberPosition[0] -= 120;
				NoteSplash.splashPath = "week6/weeb/pixelUI/noteSplashes-pixel";

		}

		//Prevents the game from lagging at first note splash.
		var preloadSplash = new NoteSplash(-2000, -2000, 0);

		if(Config.comboType == 1){

			comboUI.cameras = [camHUD];
			comboUI.setPosition(0, 0);
			comboUI.scrollFactor.set(0, 0);
			comboUI.setScales([comboUI.ratingScale * 0.8, comboUI.numberScale, comboUI.breakScale * 0.8]);
			comboUI.accelScale = 0.2;
			comboUI.velocityScale = 0.2;

			if(!Config.downscroll){
				comboUI.ratingPosition = [700, 510];
				comboUI.numberPosition = [320, 480];
				comboUI.breakPosition = [690, 465];
			}
			else{
				comboUI.ratingPosition = [700, 80];
				comboUI.numberPosition = [320, 100];
				comboUI.breakPosition = [690, 85];
			}

			switch(curUiType){
				case "pixel":
					comboUI.numberPosition[0] -= 120;
					comboUI.setPosition(160, 60);
			}

		}

		if(Config.comboType < 2){
			add(comboUI);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		if(Config.downscroll){
			strumLine = new FlxSprite(0, 570).makeGraphic(FlxG.width, 10);
		}
		else {
			strumLine = new FlxSprite(0, 30).makeGraphic(FlxG.width, 10);
		}
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowOffset = new FlxObject(0, 0, 1, 1);
		camFollowFinal = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);
		camFollowFinal.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowOffset);
		add(camFollowFinal);

		FlxG.camera.follow(camFollowFinal, LOCKON);

		defaultCamZoom = stage.startingZoom;
		
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		camGame.zoom = defaultCamZoom;

		FlxG.camera.focusOn(camFollowFinal.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if(CoolUtil.exists(Paths.text(SONG.song.toLowerCase() + "/meta"))){
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
		iconP1.y = healthBar.y - (iconP1.height / 2);
		

		iconP2 = new HealthIcon(dad.iconName, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		ccText = new SongCaptions(Config.downscroll);
		ccText.scrollFactor.set();
		
		add(healthBar);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);
		if(Config.showCaptions){ add(ccText); } 

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		ccText.cameras = [camHUD];

		healthBar.visible = false;
		healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						camGame.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);

				case "ugh":
					videoCutscene(Paths.video("week7/ughCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						defaultCamZoom *= 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(this, {defaultCamZoom: defaultCamZoom / 1.2}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});
					
				case "guns":
					videoCutscene(Paths.video("week7/gunsCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						defaultCamZoom *= 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(this, {defaultCamZoom: defaultCamZoom / 1.2}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});

				case "stress":
					videoCutscene(Paths.video("week7/stressCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						defaultCamZoom *= 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(this, {defaultCamZoom: defaultCamZoom / 1.2}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});
					
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case "lil-buddies":
					if(fromChartEditor){
						lilBuddiesStart();
					}
					else{
						startCountdown();
					}

				default:
					startCountdown();
			}
		}

		var bgDim = new FlxSprite(1280 / -2, 720 / -2).makeGraphic(1280*2, 720*2, FlxColor.BLACK);
		bgDim.cameras = [camOverlay];
		bgDim.alpha = Config.bgDim/10;
		add(bgDim);

		fromChartEditor = false;

		super.create();
	}

	function updateAccuracy()
	{

		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
		if (accuracy >= 100){
			accuracy = 100;
		}
		
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('week6/weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 5.5));
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		//senpaiEvil.x -= 120;
		senpaiEvil.y -= 115;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function videoCutscene(path:String, ?endFunc:Void->Void, ?startFunc:Void->Void){
		
		inCutscene = true;
		inVideoCutscene = true;
	
		var blackShit:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackShit.screenCenter(XY);
		blackShit.scrollFactor.set();
		add(blackShit);

		video = new VideoHandler();
		video.scrollFactor.set();
		video.antialiasing = true;

		camGame.zoom = 1;

		video.playMP4(path, function(){
			
			FlxTween.tween(blackShit, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				remove(blackShit);
			}});

			inVideoCutscene = false;

			remove(video);

			if(endFunc != null){ endFunc(); }

			startCountdown();

		}, false);

		add(video);
		
		if(startFunc != null){ startFunc(); }
	}

	function lilBuddiesStart():Void
	{
		inCutscene = false;

		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		healthBar.alpha = 0;
		healthBarBG.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		scoreTxt.alpha = 0;

		generateStaticArrows(0, true);
		generateStaticArrows(1, true);

		for(x in strumLineNotes.members){
			x.alpha = 0;
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		//Conductor.songPosition -= Conductor.crochet * 5;

		customTransIn = new InstantTransition();

		autoZoom = false;
		var hudElementsFadeInTime = 0.2;
		
		camChangeZoom(2.8, Conductor.crochet / 1000 * 16, FlxEase.quadInOut, function(t){
			autoZoom = true;
			FlxTween.tween(healthBar, {alpha: 1}, hudElementsFadeInTime);
			FlxTween.tween(healthBarBG, {alpha: 1}, hudElementsFadeInTime);
			FlxTween.tween(iconP1, {alpha: 1}, hudElementsFadeInTime);
			FlxTween.tween(iconP2, {alpha: 1}, hudElementsFadeInTime);
			FlxTween.tween(scoreTxt, {alpha: 1}, hudElementsFadeInTime);
			for(x in strumLineNotes.members){
				FlxTween.tween(x, {alpha: 1}, hudElementsFadeInTime);
			}
		});
		camMove(155, 600, Conductor.crochet / 1000 * 16, FlxEase.quadOut, "center");

		beatHit();
	}

	var startTimer:FlxTimer;

	function startCountdown():Void {

		inCutscene = false;

		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ui/ready', "ui/set", "ui/go", ""]);
			introAssets.set('pixel', [
				"week6/weeb/pixelUI/ready-pixel",
				"week6/weeb/pixelUI/set-pixel",
				"week6/weeb/pixelUI/date-pixel",
				"-pixel"
			]);

		var introAlts:Array<String> = introAssets.get(curUiType);
		var altSuffix = introAlts[3];

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
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					if(meta != null){
						meta.start();
					}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.antialiasing = !(curUiType == "pixel");

					if (curUiType == "pixel")
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom * 0.8));
					else
						ready.setGraphicSize(Std.int(ready.width * 0.5));

					ready.updateHitbox();

					ready.screenCenter();
					ready.y -= 120;
					ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					set.antialiasing = !(curUiType == "pixel");

					if (curUiType == "pixel")
						set.setGraphicSize(Std.int(set.width * daPixelZoom * 0.8));
					else
						set.setGraphicSize(Std.int(set.width * 0.5));

					set.updateHitbox();

					set.screenCenter();
					set.y -= 120;
					set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					go.antialiasing = !(curUiType == "pixel");

					if (curUiType == "pixel")
						go.setGraphicSize(Std.int(go.width * daPixelZoom * 0.8));
					else
						go.setGraphicSize(Std.int(go.width * 0.8));

					go.updateHitbox();

					go.screenCenter();
					go.y -= 120;
					go.cameras = [camHUD];
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
					beatHit();
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		if(vocalType == splitVocalTrack){ vocalsOther.play(); }

		if(sectionStart){
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
			if(vocalType == splitVocalTrack){ vocalsOther.time = sectionStartTime; }
			curSection = sectionStartPoint;
		}

		/*
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if(!paused)
			resyncVocals();
		});
		*/

	}

	private function generateSong(dataPath:String):Void {

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		switch(vocalType){
			case splitVocalTrack:
				vocals = new FlxSound().loadEmbedded(Paths.voices(curSong, "Player"));
				vocalsOther = new FlxSound().loadEmbedded(Paths.voices(curSong, "Opponent"));
				FlxG.sound.list.add(vocalsOther);
			case combinedVocalTrack:
				vocals = new FlxSound().loadEmbedded(Paths.voices(curSong));
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
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.round(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteType, false, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats++;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByEventStuff(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(player:Int, ?instant:Bool = false):Void {

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y);

			switch (curUiType)
			{
				case "pixel":
					babyArrow.loadGraphic(Paths.image('week6/weeb/pixelUI/arrows-pixels'), true, 19, 19);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [26, 10], 12, false);
							babyArrow.animation.add('confirm', [30, 14, 18], 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [27, 11], 12, false);
							babyArrow.animation.add('confirm', [31, 15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [25, 9], 12, false);
							babyArrow.animation.add('confirm', [29, 13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [24, 8], 12, false);
							babyArrow.animation.add('confirm', [28, 12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('ui/NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if(!instant){
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.x += 50;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String){
					if(autoplay){
						if(name == "confirm"){
							babyArrow.animation.play('static', true);
							babyArrow.centerOffsets();
						}
					}
				}

				if(!Config.centeredNotes){
					babyArrow.x += ((FlxG.width / 2));
				}
				else{
					babyArrow.x += ((FlxG.width / 4));
				}

			}
			else
			{
				enemyStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String){
					if(name == "confirm"){
						babyArrow.animation.play('static', true);
						babyArrow.centerOffsets();
					}
				}

				if(Config.centeredNotes){
					babyArrow.x -= 1280;
				}
			}

			babyArrow.animation.play('static');

			strumLineNotes.add(babyArrow);
		}
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
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}


	override public function update(elapsed:Float) {

		if(inCutscene && inVideoCutscene){
			if(Binds.justPressed("menuAccept")){
				FlxTween.tween(video, {alpha: 0, volume: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
					video.skip();
				}});
			}
		}
		
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

		if (!inCutscene){
		 	if(!autoplay){
		 		keyShit();
			}
		 	else{
				keyShitAuto();
		 	}
		}
		
		
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.TAB && !isStoryMode){
			autoplay = !autoplay;
			usedAutoplay = true;
		}

		super.update(elapsed);

		stage.update(elapsed);

		updateAccuracyText();

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

		if (FlxG.keys.justPressed.SEVEN){

			if(!FlxG.keys.pressed.SHIFT){
				ChartingState.startSection = curSection;
			}

			switchState(new ChartingState());
			sectionStart = false;
		}

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2){
			health = 2;
		}

		if(healthLerp != health){
			healthLerp = CoolUtil.fpsAdjsutedLerp(healthLerp, health, 0.7);
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

		if (FlxG.keys.justPressed.EIGHT){

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
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusBF();
			}
		}

		camFollowFinal.setPosition(camFollow.x + camFollowOffset.x, camFollow.y + camFollowOffset.y);

		if(!inCutscene){
			camGame.zoom = defaultCamZoom + camGameZoomAdjust;
		}

		//FlxG.watch.addQuick("totalBeats: ", totalBeats);

		// RESET = Quick Game Over Screen
		if (Binds.justPressed("killbind") && !startingSong) {
			health = 0;
		}

		if (health <= 0) {

			persistentDraw = false;
			paused = true;

			vocals.stop();
			if(vocalType == splitVocalTrack){ vocalsOther.stop(); }
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowFinal.getScreenPosition().x, camFollowFinal.getScreenPosition().y, boyfriend.deathCharacter));
			sectionStart = false;

		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3000)
			{
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
			endSong();
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
				daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * scrollSpeed));	
				if(daNote.isSustainNote){
					daNote.y -= daNote.height;
					daNote.y += 125;

					if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
						&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
					{
						// Clip to strumline
						var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
						swagRect.height = (targetY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
						swagRect.y = daNote.frameHeight - swagRect.height;
	
						daNote.clipRect = swagRect;
					}
				}
			}
			else {
				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * scrollSpeed));
				if(daNote.isSustainNote){
					if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
						&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
					{
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
				if (!daNote.didTooLateAction){
					noteMiss(daNote.noteData, NOTE_MISS_DAMAGE, true, true);
					vocals.volume = 0;
					daNote.didTooLateAction = true;
				}
			}

			if (Config.downscroll ? (daNote.y > strumLine.y + daNote.height + 50) : (daNote.y < strumLine.y - daNote.height - 50))
			{
				if (daNote.tooLate || daNote.wasGoodHit){
								
					daNote.active = false;
					daNote.visible = false;
					daNote.destroy();
				}
			}
		});
	}

	function opponentNoteCheck(){
		notes.forEachAlive(function(daNote:Note)
		{
			if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
			{
				daNote.wasGoodHit = true;

				if(dad.canAutoAnim && (Character.LOOP_ANIM_ON_HOLD ? (daNote.isSustainNote ? (Character.HOLD_LOOP_WAIT ? (!dad.animation.name.contains("sing") || (dad.animation.curAnim.curFrame >= 3 || dad.animation.curAnim.finished)) : true) : true) : !daNote.isSustainNote)){
					switch (Math.abs(daNote.noteData))
					{
						case 2:
							dad.playAnim('singUP', true);
							if(Config.extraCamMovement && !daNote.isSustainNote){ changeCamOffset(0, -1 * camOffsetAmount); }
						case 3:
							dad.playAnim('singRIGHT', true);
							if(Config.extraCamMovement && !daNote.isSustainNote){ changeCamOffset(camOffsetAmount, 0); }
						case 1:
							dad.playAnim('singDOWN', true);
							if(Config.extraCamMovement && !daNote.isSustainNote){ changeCamOffset(0, camOffsetAmount); }
						case 0:
							dad.playAnim('singLEFT', true);
							if(Config.extraCamMovement && !daNote.isSustainNote){ changeCamOffset(-1 * camOffsetAmount, 0); }
					}
				}

				enemyStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(daNote.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
						if (spr.animation.curAnim.name == 'confirm' && !(curUiType == "pixel"))
						{
							spr.centerOffsets();
							spr.offset.x -= 14;
							spr.offset.y -= 14;
						}
						else
							spr.centerOffsets();
					}
				});

				dad.holdTimer = 0;

				switch(vocalType){
					case splitVocalTrack:
						vocalsOther.volume = 1;
					case combinedVocalTrack:
						vocals.volume = 1;
					default:
				}
					

				if(!daNote.isSustainNote){
					daNote.destroy();
				}
			}
		});
	}

	public function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if(vocalType == splitVocalTrack) { vocalsOther.volume = 0; }
		if (!usedAutoplay){
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), TitleScreen.titleMusicVolume);

				switchState(new StoryMenuState());
				sectionStart = false;

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * camGame.zoom,
						-FlxG.height * camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollowFinal;
				}

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				switchState(new PlayState());

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else
		{
			sectionStart = false;

			switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(note:Note):Void{

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * Conductor.shitZone){
			daRating = 'shit';
			if(Config.accuracy == "complex") {
				totalNotesHit += 1 - Conductor.shitZone;
			}
			else {
				totalNotesHit += 1;
			}
			score = 50;

			if(Config.noteSplashType == 2){
				createNoteSplash(note.noteData);
			}
		}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.badZone){
			daRating = 'bad';
			score = 100;
			if(Config.accuracy == "complex") {
				totalNotesHit += 1 - Conductor.badZone;
			}
			else {
				totalNotesHit += 1;
			}

			if(Config.noteSplashType == 2){
				createNoteSplash(note.noteData);
			}
		}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.goodZone){
			daRating = 'good';
			if(Config.accuracy == "complex") {
				totalNotesHit += 1 - Conductor.goodZone;
			}
			else {
				totalNotesHit += 1;
			}
				score = 200;

			if(Config.noteSplashType == 2){
				createNoteSplash(note.noteData);
			}
		}
		if (daRating == 'sick'){
			totalNotesHit += 1;

			if(Config.noteSplashType > 0){
				createNoteSplash(note.noteData);
			}
		}

		songScore += score;

		comboUI.ratingPopup(daRating);

		if(combo >= minCombo)
			comboUI.comboPopup(combo);

	}

	private function createNoteSplash(note:Int){
		var bigSplashy = new NoteSplash(CoolUtil.getTrueGraphicMidpoint(playerStrums.members[note]).x, CoolUtil.getTrueGraphicMidpoint(playerStrums.members[note]).y, note);
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

	private function keyShit():Void
	{

		var controlArray:Array<Bool> = [leftPress, downPress, upPress, rightPress];

		if ((upPress || rightPress || downPress || leftPress) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
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

			if (possibleNotes.length > 0){
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
		
		notes.forEachAlive(function(daNote:Note)
		{
			if ((upHold || rightHold || downHold || leftHold) && generatedMusic){
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
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
					updateAccuracy();
					noteMiss(daNote.noteData, HOLD_RELEASE_STEP_DAMAGE, false, true, false, false);
				}

				//This is for the first released note.
				if(daNote.prevNote.wasGoodHit && !daNote.wasGoodHit){

					if(releaseTimes[daNote.noteData] >= releaseBufferTime){
						noteMiss(daNote.noteData, NOTE_MISS_DAMAGE, true, true, false, true);
						vocals.volume = 0;
						daNote.tooLate = true;
						daNote.destroy();
						boyfriend.holdTimer = 0;
						updateAccuracy();

						var recursiveNote = daNote;
						while(recursiveNote.prevNote != null && recursiveNote.prevNote.exists && recursiveNote.prevNote.isSustainNote){
							recursiveNote.prevNote.visible = false;
							recursiveNote = recursiveNote.prevNote;
						}
					}
					
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.stepsUntilRelease * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')){
				if(Character.USE_IDLE_END){ 
					boyfriend.idleEnd(); 
				}
				else{ 
					boyfriend.dance(); 
					boyfriend.danceLockout = true;
				}
			}	
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (upPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!upHold)
						spr.animation.play('static');
				case 3:
					if (rightPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!rightHold)
						spr.animation.play('static');
				case 1:
					if (downPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!downHold)
						spr.animation.play('static');
				case 0:
					if (leftPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!leftHold)
						spr.animation.play('static');
			}

			switch(spr.animation.curAnim.name){

				case "confirm":

					//spr.alpha = 1;
					spr.centerOffsets();

					if(!(curUiType == "pixel")){
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}

				/*case "static":
					spr.alpha = 0.5; //Might mess around with strum transparency in the future or something.
					spr.centerOffsets();*/

				default:
					//spr.alpha = 1;
					spr.centerOffsets();

			}

		});
	}

	private function keyShitAuto():Void
	{

		var hitNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (!daNote.wasGoodHit && daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * (!daNote.isSustainNote ? 0.125 : (daNote.prevNote.wasGoodHit ? 1 : 0)))
			{
				hitNotes.push(daNote);
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.stepsUntilRelease * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')){
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
			
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(x.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm' && !(curUiType == "pixel"))
					{
						spr.centerOffsets();
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}
					else
						spr.centerOffsets();
				}
			});

		}

		
	}

	function noteMiss(direction:Int = 1, ?healthLoss:Float = 0.04, ?playAudio:Bool = true, ?skipInvCheck:Bool = false, ?countMiss:Bool = true, ?dropCombo:Bool = true, ?invulnTime:Int = 5, ?scoreAdjust:Int = 100):Void
	{
		if (!startingSong && (!invuln || skipInvCheck) )
		{
			health -= healthLoss * Config.healthDrainMultiplier;

			if(dropCombo){
				if (combo > minCombo){
					gf.playAnim('sad');
					comboUI.breakPopup();
				}
				combo = 0;
				comboBreaks++;
			}

			if(countMiss){
				misses++;
				updateAccuracy();
			}

			songScore -= scoreAdjust;
			
			if(playAudio){
				FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));
			}

			setBoyfriendInvuln(invulnTime / 60);

			if(boyfriend.canAutoAnim){
				switch (direction)
				{
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
				}
			}
			
		}

		if(Main.flippymode) { System.exit(0); }

	}

	inline function noteMissWrongPress(direction:Int = 1):Void{
		noteMiss(direction, WRONG_TAP_DAMAGE, true, false, false, false, 4, 25);
	}

	function badNoteCheck(direction:Int = -1)
	{
		if(Config.ghostTapType > 0 && !canHit){}
		else{
			if (leftPress && (direction == -1 || direction == 0))
				noteMissWrongPress(0);
			if (upPress && (direction == -1 || direction == 2))
				noteMissWrongPress(2);
			if (rightPress && (direction == -1 || direction == 3))
				noteMissWrongPress(3);
			if (downPress && (direction == -1 || direction == 1))
				noteMissWrongPress(1);
		}
	}

	function setBoyfriendInvuln(time:Float = 5 / 60){
		if(time > invulnTime){
			invulnTime = time;
			invuln = true;
		}
	}

	function setCanMiss(time:Float = 10 / 60){
		if(time > missTime){
			missTime = time;
			canHit = true;
		}
		
	}

	function goodNoteHit(note:Note):Void
	{

		//Guitar Hero Styled Hold Notes
		//This is to make sure that if hold notes are hit out of order they are destroyed. Should not be possible though.
		if(note.isSustainNote && !note.prevNote.wasGoodHit){
			noteMiss(note.noteData, NOTE_MISS_DAMAGE, true, true, false);
			vocals.volume = 0;
			note.prevNote.tooLate = true;
			note.prevNote.destroy();
			boyfriend.holdTimer = 0;
			updateAccuracy();
		}

		else if (!note.wasGoodHit)
		{
			if (!note.isSustainNote){
				popUpScore(note);
				combo += 1;
			}
			else{
				totalNotesHit += 1;
			}

			if (!note.isSustainNote){
				health += NOTE_HIT_HEAL * Config.healthMultiplier;
			}
			else{
				health += HOLD_HIT_HEAL * Config.healthMultiplier;
			}
				
			if(boyfriend.canAutoAnim && (Character.LOOP_ANIM_ON_HOLD ? (note.isSustainNote ? (Character.HOLD_LOOP_WAIT ? (!boyfriend.animation.name.contains("sing") || (boyfriend.animation.curAnim.curFrame >= 3 || boyfriend.animation.curAnim.finished)) : true) : true) : !note.isSustainNote)){
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
						if(Config.extraCamMovement && !note.isSustainNote){ changeCamOffset(0, -1 * camOffsetAmount); }
					case 3:
						boyfriend.playAnim('singRIGHT', true);
						if(Config.extraCamMovement && !note.isSustainNote){ changeCamOffset(camOffsetAmount, 0); }
					case 1:
						boyfriend.playAnim('singDOWN', true);
						if(Config.extraCamMovement && !note.isSustainNote){ changeCamOffset(0, camOffsetAmount); }
					case 0:
						boyfriend.playAnim('singLEFT', true);
						if(Config.extraCamMovement && !note.isSustainNote){ changeCamOffset(-1 * camOffsetAmount, 0); }
				}
			}

			if(!note.isSustainNote){
				setBoyfriendInvuln(2.5 / 60);
			}
			

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if(!note.isSustainNote){
				note.destroy();
			}
			
			updateAccuracy();
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

		stage.step(curStep);

		super.stepHit();
	}

	override function beatHit()
	{
		//wiggleShit.update(Conductor.crochet);
		super.beatHit();

		if(curBeat % 4 == 0){

			var sec = Math.floor(curBeat / 4);
			if(sec >= sectionHaveNotes.length) { sec = -1; }

			sectionHasBFNotes = sec >= 0 ? sectionHaveNotes[sec][0] : false;
			sectionHasOppNotes = sec >= 0 ? sectionHaveNotes[sec][1] : false;
			
		}

		//sortNotes();

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM){
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}

			// Dad doesnt interupt his own notes
			if (!sectionHasOppNotes){
				if(dadBeats.contains(curBeat % 4) && dad.canAutoAnim && dad.holdTimer == 0){
					dad.dance();
				}
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

		if(bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim && !boyfriend.animation.curAnim.name.startsWith('sing')){
			boyfriend.dance();
		}

		stage.beat(curBeat);
		
	}

	private function executeEvent(tag:String):Void{

		if(tag.startsWith("playAnim;")){
			var tagSplit = tag.split(";");

			if(tagSplit.length < 4){ tagSplit.push("false"); }
			if(tagSplit.length < 5){ tagSplit.push("false"); }
			if(tagSplit.length < 6){ tagSplit.push("0"); }

			switch(tagSplit[1]){
				case "dad":
					dad.playAnim(tagSplit[2], parseBool(tagSplit[3]), parseBool(tagSplit[4]), Std.parseInt(tagSplit[5]));

				case "gf":
					gf.playAnim(tagSplit[2], parseBool(tagSplit[3]), parseBool(tagSplit[4]), Std.parseInt(tagSplit[5]));

				default:
					boyfriend.playAnim(tagSplit[2], parseBool(tagSplit[3]), parseBool(tagSplit[4]), Std.parseInt(tagSplit[5]));
			}
		}

		if(tag.startsWith("setAnimSet;")){
			var tagSplit = tag.split(";");

			switch(tagSplit[1]){
				case "dad":
					dad.animSet = tagSplit[2];

				case "gf":
					gf.animSet = tagSplit[2];

				default:
					boyfriend.animSet = tagSplit[2];
			}
		}

		else if(tag.startsWith("cc;")){ ccText.display(tag.split("cc;")[1]); }

		else if(tag.startsWith("camMove;")){
			var properties = tag.split(";");
			camMove(Std.parseFloat(properties[1]), Std.parseFloat(properties[2]), eventConvertTime(properties[3]), easeNameToEase(properties[4]), null);
		}
		else if(tag.startsWith("camZoom;")){
			var properties = tag.split(";");
			camChangeZoom(Std.parseFloat(properties[1]), eventConvertTime(properties[2]), easeNameToEase(properties[3]), null);
		}

		else if(tag.startsWith("gfBopFreq;")){ gfBopFrequency = Std.parseInt(tag.split("gfBopFreq;")[1]); }
		else if(tag.startsWith("iconBopFreq;")){ iconBopFrequency = Std.parseInt(tag.split("iconBopFreq;")[1]); }
		else if(tag.startsWith("camBopFreq;")){ camBopFrequency = Std.parseInt(tag.split("camBopFreq;")[1]); }

		else if(tag.startsWith("bfBop")){
			switch(tag.split("bfBop")[1]){
				case "EveryBeat":
					bfBeats = [0, 1, 2, 3];
				case "OddBeats": //Swapped due to event icon starting at 1 instead of 0
					bfBeats = [0, 2];
				case "EvenBeats": //Swapped due to event icon starting at 1 instead of 0
					bfBeats = [1, 3];
				case "Never":
					bfBeats = [];
			}
		}
		else if(tag.startsWith("dadBop")){
			switch(tag.split("dadBop")[1]){
				case "EveryBeat":
					dadBeats = [0, 1, 2, 3];
				case "OddBeats": //Swapped due to event icon starting at 1 instead of 0
					dadBeats = [0, 2];
				case "EvenBeats": //Swapped due to event icon starting at 1 instead of 0
					dadBeats = [1, 3];
				case "Never":
					dadBeats = [];
			}
		}

		else if(tag.startsWith("flash;")){ 
			var properties = tag.split(";");
			if(properties.length < 2){ properties.push("1b"); }
			if(properties.length < 3){ properties.push("0xFFFFFF"); }
			camGame.stopFX();
			camGame.fade(Std.parseInt(properties[2]), eventConvertTime(properties[1]), true);
		}
		else if(tag.startsWith("flashHud;")){ 
			var properties = tag.split(";");
			if(properties.length < 2){ properties.push("1b"); }
			if(properties.length < 3){ properties.push("0xFFFFFF"); }
			camHUD.stopFX();
			camHUD.fade(Std.parseInt(properties[2]), eventConvertTime(properties[1]), true);
		}
		else if(tag.startsWith("fadeOut;")){ 
			var properties = tag.split(";");
			if(properties.length < 2){ properties.push("1b"); }
			if(properties.length < 3){ properties.push("0x000000"); }
			camGame.stopFX();
			camGame.fade(Std.parseInt(properties[2]), eventConvertTime(properties[1]));
		}
		else if(tag.startsWith("fadeOutHud;")){ 
			var properties = tag.split(";");
			if(properties.length < 2){ properties.push("1b"); }
			if(properties.length < 3){ properties.push("0x000000"); }
			camHUD.stopFX();
			camHUD.fade(Std.parseInt(properties[2]), eventConvertTime(properties[1]));
		}

		else{
			switch(tag){
				case "dadAnimLockToggle":
					dad.canAutoAnim = !dad.canAutoAnim;

				case "bfAnimLockToggle":
					boyfriend.canAutoAnim = !boyfriend.canAutoAnim;

				case "gfAnimLockToggle":
					gf.canAutoAnim = !gf.canAutoAnim;

				case "ccHide":
					ccText.hide();

				case "toggleCamBop":
					autoCamBop = !autoCamBop;

				case "toggleCamMovement":
					autoCam = !autoCam;

				case "camBop":
					uiBop(0.0175, 0.03, 0.8);
					
				case "camBopBig":
					uiBop(0.035, 0.06, 0.8);

				case "camFocusBf":
					camFocusBF();

				case "camFocusDad":
					camFocusOpponent();

				case "camFocusGf":
					camFocusGF();

				default:
					trace(tag);
			}
		}
		return;
	}

	var curLight:Int = 0;

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

	public function camFocusOpponent(){

		if(Config.extraCamMovement){ changeCamOffset(0, 0); }

		var followX = dad.getMidpoint().x + 150;
		var followY = dad.getMidpoint().y - 100;
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (dad.curCharacter){
			case "spooky":
				followY = dad.getMidpoint().y - 45;
			case "pico":
				followX += 162;
			case "mom" | "mom-car":
				followY = dad.getMidpoint().y;
			case 'senpai':
				followY = dad.getMidpoint().y - 20;
				followX = dad.getMidpoint().x + 212;
			case 'senpai-angry':
				followY = dad.getMidpoint().y - 20;
				followX = dad.getMidpoint().x + 212;
			case 'spirit':
				followX = dad.getMidpoint().x + 254;
				followY = dad.getMidpoint().y + 44;
		}

		if (SONG.song.toLowerCase() == 'tutorial'){
			camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.expoOut, "dad");
	}

	public function camFocusBF(){

		if(Config.extraCamMovement){ changeCamOffset(0, 0); }

		var followX = boyfriend.getMidpoint().x - 100;
		var followY = boyfriend.getMidpoint().y - 100;

		switch (stage.name){
			case 'spooky':
				followY = boyfriend.getMidpoint().y - 140;
			case 'limo':
				followX = boyfriend.getMidpoint().x - 300;
			case 'mall':
				followY = boyfriend.getMidpoint().y - 200;
			case 'school':
				followX = boyfriend.getMidpoint().x - 68;
				followY = boyfriend.getMidpoint().y - 92;
			case 'schoolEvil':
				followX = boyfriend.getMidpoint().x - 68;
				followY = boyfriend.getMidpoint().y - 117;
		}

		if (SONG.song.toLowerCase() == 'tutorial'){
			camChangeZoom(1, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.expoOut, "bf");
	}

	public function camFocusGF(){

		if(Config.extraCamMovement){ changeCamOffset(0, 0); }

		var followX = gf.getMidpoint().x;
		var followY = gf.getMidpoint().y;

		camMove(followX, followY, 1.9, FlxEase.expoOut, "gf");
	}

	public function camMove(_x:Float, _y:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_focus:String = "", ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camTween.cancel();
		if(_time > 0){
			camTween = FlxTween.tween(camFollow, {x: _x, y: _y}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camFollow.setPosition(_x, _y);
		}
		
		camFocus = _focus;

	}

	public function camChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camZoomTween.cancel();
		if(_time > 0){
			camZoomTween = FlxTween.tween(this, {defaultCamZoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			defaultCamZoom = _zoom;
		}

	}

	public function camChangeZoomAdjust(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camZoomAdjustTween.cancel();
		if(_time > 0){
			camZoomAdjustTween = FlxTween.tween(this, {camGameZoomAdjust: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camGameZoomAdjust = _zoom;
		}

	}

	public function uiChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		uiZoomTween.cancel();
		if(_time > 0){
			uiZoomTween = FlxTween.tween(camHUD, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
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

	function changeCamOffset(_x:Float, _y:Float, ?_time:Float = 1.4, ?_ease:Null<flixel.tweens.EaseFunction>){

		if(_ease == null){
			_ease = FlxEase.expoOut;
		}

		offsetTween.cancel();
		if(_time > 0){
			offsetTween = FlxTween.tween(camFollowOffset, {x: _x, y: _y}, _time, {ease: _ease});
		}
		else{
			camFollowOffset.setPosition(_x, _y);
		}

	}

	function updateAccuracyText(){
		switch(Config.accuracy){
			case "none":
				scoreTxt.text = "Score:" + songScore;
			default:
				if(Config.showComboBreaks){
					scoreTxt.text = "Score:" + songScore + " | Combo Breaks:" + comboBreaks + " | Accuracy:" + truncateFloat(accuracy, 2) + "%";
				}
				else{
					scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "%";
				}
		}
	}

	function inRange(a:Float, b:Float, tolerance:Float){
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

	//For converting event properties to easing functions. Please let me know if there is a better way.
	public static inline function easeNameToEase(ease:String):Null<flixel.tweens.EaseFunction>{
		var r;
		switch(ease){
			default:
				r = FlxEase.linear;

			case "quadIn":
				r = FlxEase.quadIn;
			case "quadOut":
				r = FlxEase.quadOut;
			case "quadInOut":
				r = FlxEase.quadInOut;

			case "cubeIn":
				r = FlxEase.cubeIn;
			case "cubeOut":
				r = FlxEase.cubeOut;
			case "cubeInOut":
				r = FlxEase.cubeInOut;

			case "quartIn":
				r = FlxEase.quartIn;
			case "quartOut":
				r = FlxEase.quartOut;
			case "quartInOut":
				r = FlxEase.quartInOut;

			case "quintIn":
				r = FlxEase.quintIn;
			case "quintOut":
				r = FlxEase.quintOut;
			case "quintInOut":
				r = FlxEase.quintInOut;

			case "smoothStepIn":
				r = FlxEase.smoothStepIn;
			case "smoothStepOut":
				r = FlxEase.smoothStepOut;
			case "smoothStepInOut":
				r = FlxEase.smoothStepInOut;

			case "smootherStepIn":
				r = FlxEase.smootherStepIn;
			case "smootherStepOut":
				r = FlxEase.smootherStepOut;
			case "smootherStepInOut":
				r = FlxEase.smootherStepInOut;

			case "sineIn":
				r = FlxEase.sineIn;
			case "sineOut":
				r = FlxEase.sineOut;
			case "sineInOut":
				r = FlxEase.sineInOut;

			case "bounceIn":
				r = FlxEase.bounceIn;
			case "bounceOut":
				r = FlxEase.bounceOut;
			case "bounceInOut":
				r = FlxEase.bounceInOut;

			case "circIn":
				r = FlxEase.circIn;
			case "circOut":
				r = FlxEase.circOut;
			case "circInOut":
				r = FlxEase.circInOut;

			case "expoIn":
				r = FlxEase.expoIn;
			case "expoOut":
				r = FlxEase.expoOut;
			case "expoInOut":
				r = FlxEase.expoInOut;

			case "backIn":
				r = FlxEase.backIn;
			case "backOut":
				r = FlxEase.backOut;
			case "backInOut":
				r = FlxEase.backInOut;

			case "elasticIn":
				r = FlxEase.elasticIn;
			case "elasticOut":
				r = FlxEase.elasticOut;
			case "elasticInOut":
				r = FlxEase.elasticInOut;
		}
		return r;
	}

	//Coverts event properties to time. If value ends in "b" the number is treated as a beat duration, if the value ends in "s" the number is treated as a step duration, otherwise it's just time in seconds.
	public static inline function eventConvertTime(v:String):Float{
		var r;
		if(v.endsWith("b")){
			v = v.split("b")[0];
			r = (Conductor.crochet * Std.parseFloat(v) / 1000);
		}
		else if(v.endsWith("s")){
			v = v.split("s")[0];
			r = (Conductor.stepCrochet * Std.parseFloat(v) / 1000);
		}
		else{
			r = Std.parseFloat(v);
		}
		return r;
	}

	public static inline function parseBool(v:String):Bool{
		return (v.toLowerCase() == "true");
	}

	function songPreload():Void {
		FlxG.sound.cache(Paths.inst(SONG.song));
		
		if(CoolUtil.exists(Paths.voices(SONG.song, "Player"))){
			FlxG.sound.cache(Paths.voices(SONG.song, "Player"));
			FlxG.sound.cache(Paths.voices(SONG.song, "Opponent"));
			vocalType = splitVocalTrack;
		}
		else if(CoolUtil.exists(Paths.voices(SONG.song))){
			FlxG.sound.cache(Paths.voices(SONG.song));
		}
		else{
			vocalType = noVocalTrack;
		}
	}

	/*
	public function changeState(_state:FlxState, clearImagesFromCache:Bool = true) {

		if(CoolUtil.exists(Paths.voices(SONG.song, "Player"))){
			Assets.cache.removeSound(Paths.voices(SONG.song, "Player"));
			Assets.cache.removeSound(Paths.voices(SONG.song, "Opponent"));
		}
		else if(CoolUtil.exists(Paths.voices(SONG.song))){
			Assets.cache.removeSound(Paths.voices(SONG.song));
		}

		if(!CacheConfig.music){
			Assets.cache.removeSound(Paths.inst(SONG.song));
		}

		
		//Turns out this doesn't do anything :[
		//I WILL FIGURRE IT OUT THO MAYBE
		if(clearImagesFromCache){
			FlxG.bitmap.clearCache();
		}

		switchState(_state);
	}*/

	override function switchState(_state:FlxState) {
		if(CoolUtil.exists(Paths.voices(SONG.song, "Player"))){
			Assets.cache.removeSound(Paths.voices(SONG.song, "Player"));
			Assets.cache.removeSound(Paths.voices(SONG.song, "Opponent"));
		}
		else if(CoolUtil.exists(Paths.voices(SONG.song))){
			Assets.cache.removeSound(Paths.voices(SONG.song));
		}

		if(!CacheConfig.music){
			Assets.cache.removeSound(Paths.inst(SONG.song));
		}

		super.switchState(_state);
	}

}

enum VocalType {
	noVocalTrack;
	combinedVocalTrack;
	splitVocalTrack;
}