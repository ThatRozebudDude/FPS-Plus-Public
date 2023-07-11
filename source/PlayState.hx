package;

import flixel.math.FlxAngle;
import flixel.group.FlxGroup;
#if sys
import sys.FileSystem;
#end

import config.*;
import title.*;
import transition.data.*;

import lime.utils.Assets;
import flixel.math.FlxRect;
import openfl.system.System;
import openfl.ui.KeyLocation;
import flixel.input.keyboard.FlxKey;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
//import polymod.fs.SysFileSystem;
import Section.SwagSection;
import Song.SwagSong;
import Song.SongEvents;
//import WiggleEffect.WiggleEffectType;
//import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
//import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
//import flixel.FlxState;
import flixel.FlxSubState;
//import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
//import flixel.addons.effects.FlxTrailArea;
//import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
//import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
//import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
//import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
//import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
//import haxe.Json;
//import lime.utils.Assets;
//import openfl.display.BlendMode;
//import openfl.display.StageQuality;
//import openfl.filters.ShaderFilter;

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
	
	public static var returnLocation:String = "main";
	public static var returnSong:Int = 0;
	
	private var canHit:Bool = false;
	//private var noMissCount:Int = 0;
	private var missTime:Float = 0;

	private var invuln:Bool = false;
	//private var invulnCount:Int = 0;
	private var invulnTime:Float = 0;

	public static final stageSongs = ["tutorial", "bopeebo", "fresh", "dadbattle"]; //List isn't really used since stage is default, but whatever.
	public static final spookySongs = ["spookeez", "south", "monster"];
	public static final phillySongs = ["pico", "philly", "blammed"];
	public static final limoSongs = ["satin-panties", "high", "milf"];
	public static final mallSongs = ["cocoa", "eggnog"];
	public static final evilMallSongs = ["winter-horrorland"];
	public static final schoolSongs = ["senpai", "roses"];
	public static final schoolScared = ["roses"];
	public static final evilSchoolSongs = ["thorns"];
	public static final pixelSongs = ["senpai", "roses", "thorns"];
	public static final tankSongs = ["ugh", "guns", "stress"];

	private var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var uiZoomTween:FlxTween;
	private var camFollow:FlxObject;
	private var autoCam:Bool = true;
	private var autoZoom:Bool = true;
	private var autoUi:Bool = true;

	private var bopSpeed:Int = 1;

	private var sectionHasOppNotes:Bool = false;
	private var sectionHasBFNotes:Bool = false;
	private var sectionHaveNotes:Array<Array<Bool>> = [];

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Character;

	//Wacky input stuff=========================

	private var skipListener:Bool = false;

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

	private var camZooming:Bool = true;
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

	private var eventList:Array<Dynamic> = [];

	private var comboUI:ComboPopup;
	public static final minCombo:Int = 10;

	var dialogue:Array<String> = [':bf:strange code', ':dad:>:]'];

	/*var bfPos:Array<Array<Float>> = [
									[975.5, 862],
									[975.5, 862],
									[975.5, 862],
									[1235.5, 642],
									[1175.5, 866],
									[1295.5, 866],
									[1189, 1108],
									[1189, 1108]
									];

	var dadPos:Array<Array<Float>> = [
									 [314.5, 867],
									 [346, 849],
									 [326.5, 875],
									 [339.5, 914],
									 [42, 882],
									 [342, 861],
									 [625, 1446],
									 [334, 968]
									 ];*/

	var halloweenBG:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	//var wiggleShit:WiggleEffect = new WiggleEffect();

	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;

	var chartBlackBG:FlxSprite;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	private var meta:SongMetaTags;
	
	override public function create(){

		instance = this;
		FlxG.mouse.visible = false;
		PlayerSettings.gameControls();

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

		FlxG.sound.cache(Paths.inst(SONG.song));
		FlxG.sound.cache(Paths.voices(SONG.song));
		
		if(Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		else
			openfl.Lib.current.stage.frameRate = 144;

		camTween = FlxTween.tween(this, {}, 0);
		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);

		for(i in 0 ... SONG.notes.length){

			var array = [false, false];

			array[0] = sectionContainsBfNotes(i);
			array[1] = sectionContainsOppNotes(i);

			sectionHaveNotes.push(array);

		}
		
		canHit = !(Config.ghostTapType > 0);
		//noMissCount = 0;
		//invulnCount = 0;
	
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOverlay);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		if(CoolUtil.exists(Paths.text(SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue"))){
			try{
				dialogue = CoolUtil.coolTextFile(Paths.text(SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue"));
			}
			catch(e){}
		}

		var gfCheck:String = 'gf';

		if (SONG.gf == null) {
			switch(storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
				case 7:
					if(SONG.song.toLowerCase() == "stress"){
						gfCheck = 'pico-speaker';
					}
					else{
						gfCheck = 'gf-tankmen';
					}
			}

			SONG.gf = gfCheck;

		}

		gfCheck = SONG.gf;

		gf = new Character(400, 130, gfCheck);
		gf.scrollFactor.set(0.95, 0.95);

		var dadChar = SONG.player2;

		dad = new Character(100, 100, dadChar);

		var bfChar = SONG.player1;

		boyfriend = new Character(770, 450, bfChar, true);

		var stageCheck:String = 'stage';
		if (SONG.stage == null) {

			if(spookySongs.contains(SONG.song.toLowerCase())) { stageCheck = 'spooky'; }
			else if(phillySongs.contains(SONG.song.toLowerCase())) { stageCheck = 'philly'; }
			else if(limoSongs.contains(SONG.song.toLowerCase())) { stageCheck = 'limo'; }
			else if(mallSongs.contains(SONG.song.toLowerCase())) { stageCheck = 'mall'; }
			else if(evilMallSongs.contains(SONG.song.toLowerCase())) { stageCheck = 'mallEvil'; }
			else if(schoolSongs.contains(SONG.song.toLowerCase())) { stageCheck = 'school'; }
			else if(evilSchoolSongs.contains(SONG.song.toLowerCase())) { stageCheck = 'schoolEvil'; }
			else if(tankSongs.contains(SONG.song.toLowerCase())) { stageCheck = 'tank'; }

			SONG.stage = stageCheck;

		}
		else {stageCheck = SONG.stage;}

		if (stageCheck == 'spooky')
		{
			curStage = "spooky";

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = Paths.getSparrowAtlas("week2/halloween_bg");
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);

		}
		else if (stageCheck == 'philly')
		{
			curStage = 'philly';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('week3/philly/sky'));
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('week3/philly/city'));
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('week3/philly/win' + i));
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('week3/philly/behindTrain'));
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('week3/philly/train'));
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
			FlxG.sound.list.add(trainSound);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('week3/philly/street'));
			add(street);
		}
		else if (stageCheck == 'limo')
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image("week4/limo/limoSunset"));
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = Paths.getSparrowAtlas("week4/limo/bgLimo");
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			//overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.images("limo/limoOverlay"));
			//overlayShit.alpha = 0.5;
			//add(overlayShit);

			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

			// overlayShit.shader = shaderBullshit;

			limo = new FlxSprite(-120, 550);
			limo.frames = Paths.getSparrowAtlas("week4/limo/limoDrive");
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image("week4/limo/fastCarLol"));
			// add(limo);
		}
		else if (stageCheck == 'mall')
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('week5/christmas/bgWalls'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = Paths.getSparrowAtlas("week5/christmas/upperBop");
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image("week5/christmas/bgEscalator"));
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image("week5/christmas/christmasTree"));
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = Paths.getSparrowAtlas("week5/christmas/bottomBop");
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image("week5/christmas/fgSnow"));
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = Paths.getSparrowAtlas("week5/christmas/santa");
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (stageCheck == 'mallEvil')
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image("week5/christmas/evilBG"));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('week5/christmas/evilTree'));
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("week5/christmas/evilSnow"));
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (stageCheck == 'school')
		{
			curStage = 'school';

			// defaultCamZoom = 0.9;

			var bgSky = new FlxSprite().loadGraphic(Paths.image('week6/weeb/weebSky'));
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('week6/weeb/weebSchool'));
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('week6/weeb/weebStreet'));
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('week6/weeb/weebTreesBack'));
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = Paths.getPackerAtlas("week6/weeb/weebTrees");
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = Paths.getSparrowAtlas("week6/weeb/petals");
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);

			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);

			if (schoolScared.contains(SONG.song.toLowerCase()))
			{
				bgGirls.getScared();
			}

			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		else if (stageCheck == 'schoolEvil')
		{
			curStage = 'schoolEvil';

			var posX = 400;
			var posY = 200;

			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = Paths.getSparrowAtlas("week6/weeb/animatedEvilSchool");
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);
		}
		else if (stageCheck == 'tank')
		{
			curStage = 'tank';
			defaultCamZoom = 0.90;

			var bg:BGSprite = new BGSprite('week7/stage/tankSky', -400, -400, 0, 0);
			add(bg);

			var tankSky:BGSprite = new BGSprite('week7/stage/tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
			tankSky.active = true;
			tankSky.velocity.x = FlxG.random.float(5, 15);
			add(tankSky);

			var tankMountains:BGSprite = new BGSprite('week7/stage/tankMountains', -300, -20, 0.2, 0.2);
			tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
			tankMountains.updateHitbox();
			add(tankMountains);

			var tankBuildings:BGSprite = new BGSprite('week7/stage/tankBuildings', -200, 0, 0.30, 0.30);
			tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
			tankBuildings.updateHitbox();
			add(tankBuildings);

			var tankRuins:BGSprite = new BGSprite('week7/stage/tankRuins', -200, 0, 0.35, 0.35);
			tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
			tankRuins.updateHitbox();
			add(tankRuins);

			var smokeLeft:BGSprite = new BGSprite('week7/stage/smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
			add(smokeLeft);

			var smokeRight:BGSprite = new BGSprite('week7/stage/smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
			add(smokeRight);

			// tankGround.

			tankWatchtower = new BGSprite('week7/stage/tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
			add(tankWatchtower);

			tankGround = new BGSprite('week7/stage/tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
			add(tankGround);
			// tankGround.active = false;

			tankmanRun = new FlxTypedGroup<TankmenBG>();
			add(tankmanRun);

			var tankGround:BGSprite = new BGSprite('week7/stage/tankGround', -420, -150);
			tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
			tankGround.updateHitbox();
			add(tankGround);

			moveTank();

			// smokeLeft.screenCenter();

			var fgTank0:BGSprite = new BGSprite('week7/stage/tank0', -500, 650, 1.7, 1.5, ['fg']);
			foregroundSprites.add(fgTank0);

			var fgTank1:BGSprite = new BGSprite('week7/stage/tank1', -300, 750, 2, 0.2, ['fg']);
			foregroundSprites.add(fgTank1);

			// just called 'foreground' just cuz small inconsistency no bbiggei
			var fgTank2:BGSprite = new BGSprite('week7/stage/tank2', 450, 940, 1.5, 1.5, ['foreground']);
			foregroundSprites.add(fgTank2);

			var fgTank4:BGSprite = new BGSprite('week7/stage/tank4', 1300, 900, 1.5, 1.5, ['fg']);
			foregroundSprites.add(fgTank4);

			var fgTank5:BGSprite = new BGSprite('week7/stage/tank5', 1620, 700, 1.5, 1.5, ['fg']);
			foregroundSprites.add(fgTank5);

			var fgTank3:BGSprite = new BGSprite('week7/stage/tank3', 1300, 1200, 3.5, 2.5, ['fg']);
			foregroundSprites.add(fgTank3);
		}
		else if (stageCheck == 'chart')
		{
			curStage = 'chart';

			if(fromChartEditor){
				defaultCamZoom = 1;
				var chartBg = new FlxSprite().loadGraphic(ChartingState.screenshotBitmap.bitmapData);
				chartBg.antialiasing = true;
				add(chartBg);

				chartBlackBG = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF000000);
				chartBlackBG.alpha = 0;
				add(chartBlackBG);
			}
			else{
				defaultCamZoom = 2.8;
			}

			var blackBGThing = new FlxSprite(32, 432).makeGraphic(280, 256, 0xFF000000);
			add(blackBGThing);

			var lilStage = new FlxSprite(32, 432).loadGraphic(Paths.image("chartEditor/lilStage"));
			add(lilStage);
		}
		else
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image("week1/stageback"));
			// bg.setGraphicSize(Std.int(bg.width * 2.5));
			// bg.updateHitbox();
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image("week1/stagefront"));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image("week1/stagecurtains"));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		switch(SONG.song.toLowerCase()){
			case "tutorial":
				autoZoom = false;
				dadBeats = [0, 1, 2, 3];
			case "bopeebo":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "fresh":
				camZooming = false;
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

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
				}

			case "spooky":
				dad.y += 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case "monster":
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
				dad.x -= 280;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 165;
				dad.x -= 40;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new DeltaTrail(dad, null, 10, 3 / 60, 0.4);
				//var evilTrail = new DeltaTrail(dad, null, 10, 24 / 60, 0.4, 0.005); //This is basically the default look of Spirit in base game.
				add(evilTrail);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case "tank":
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;

				if (gf.curCharacter != 'pico-speaker'){
					gf.x -= 170;
					gf.y -= 75;
				}
				else{
					gf.x -= 50;
					gf.y -= 200;
				}

			case "chart":
				gf.visible = false;
				boyfriend.setPosition(32, 432);
				dad.setPosition(32, 432);

				autoCam = false;

				if(fromChartEditor){
					camPos.set(1280/2, 720/2);
				}
				else{
					camPos.set(155, 600);
				}
				
		}

		add(gf);

		if(gf.curCharacter == "pico-speaker" && SONG.song.toLowerCase() == "stress"){
			TankmenBG.loadMappedAnims("picospeaker", "stress");

			var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
			tempTankman.strumTime = 10;
			tempTankman.resetShit(20, 600, true);
			tankmanRun.add(tempTankman);

			for (i in 0...TankmenBG.animationNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var tankman:TankmenBG = tankmanRun.recycle(TankmenBG);
					// new TankmenBG(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankman.strumTime = TankmenBG.animationNotes[i][0];
					tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(tankman);
				}
			}
		}
		
		if (curStage == 'limo'){
			add(limo);
		}
		
		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		if(!pixelSongs.contains(SONG.song.toLowerCase())){
			comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y - 75,	[Paths.image("ui/ratings"), 403, 163, true], 
																			[Paths.image("ui/numbers"), 100, 120, true], 
																			[Paths.image("ui/comboBreak"), 348, 211, true]);
			NoteSplash.splashPath = "ui/noteSplashes";
		}
		else{
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

			if(pixelSongs.contains(SONG.song.toLowerCase())){
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

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON);
		
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

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
		
		scoreTxt = new FlxText(healthBarBG.x - 105, (FlxG.height * 0.9) + 36, 800, "", 22);
		scoreTxt.setFormat(Paths.font("vcr"), 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(boyfriend.iconName, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		

		iconP2 = new HealthIcon(dad.iconName, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		
		add(healthBar);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

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
						FlxG.camera.zoom = 1.5;

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
						FlxG.camera.zoom = defaultCamZoom * 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});
					
				case "guns":
					videoCutscene(Paths.video("week7/gunsCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						FlxG.camera.zoom = defaultCamZoom * 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});

				case "stress":
					videoCutscene(Paths.video("week7/stressCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						FlxG.camera.zoom = defaultCamZoom * 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
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
				/*case "ugh":
					videoCutscene(Paths.video("week7/ughCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						FlxG.camera.zoom = defaultCamZoom * 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});
					
				case "guns":
					videoCutscene(Paths.video("week7/gunsCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						FlxG.camera.zoom = defaultCamZoom * 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});

				case "stress":
					videoCutscene(Paths.video("week7/stressCutsceneFade"), function(){
						camMove(camFollow.x, camFollow.y + 100, 0, null);
						FlxG.camera.zoom = defaultCamZoom * 1.2;
						if(PlayState.SONG.notes[0].mustHitSection){ camFocusBF(); }
						else{ camFocusOpponent(); }
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, ((Conductor.crochet / 1000) * 5) - 0.1, {ease: FlxEase.quadOut});
					});*/

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
	
		var blackShit:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackShit.screenCenter(XY);
		blackShit.scrollFactor.set();
		add(blackShit);

		var video = new VideoHandler();
		video.scrollFactor.set();
		video.antialiasing = true;

		FlxG.camera.zoom = 1;

		video.playMP4(path, function(){
			
			FlxTween.tween(blackShit, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(t){
				remove(blackShit);
			}});

			remove(video);

			FlxG.camera.zoom = defaultCamZoom;

			if(endFunc != null){ endFunc(); }

			startCountdown();

		}, false, true);

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

		customTransIn = new BasicTransition();

		autoZoom = false;
		defaultCamZoom = 2.8;
		var hudElementsFadeInTime = 0.2;
		
		camChangeZoom(defaultCamZoom, Conductor.crochet / 1000 * 16, FlxEase.quadInOut, function(t){
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
		FlxTween.tween(chartBlackBG, {alpha: 1}, Conductor.crochet / 1000 * 16);

		beatHit();
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
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
			introAssets.set('default', ['ui/ready', "ui/set", "ui/go"]);
			introAssets.set('school', [
				'week6/weeb/pixelUI/ready-pixel',
				'week6/weeb/pixelUI/set-pixel',
				'week6/weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'week6/weeb/pixelUI/ready-pixel',
				'week6/weeb/pixelUI/set-pixel',
				'week6/weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}


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
					ready.antialiasing = !curStage.startsWith('school');

					if (curStage.startsWith('school'))
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
					set.antialiasing = !curStage.startsWith('school');

					if (curStage.startsWith('school'))
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
					go.antialiasing = !curStage.startsWith('school');

					if (curStage.startsWith('school'))
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

		if(sectionStart){
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
		}

		/*
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if(!paused)
			resyncVocals();
		});
		*/

	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(curSong));
		}
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		//for (section in noteData)
		for (section in noteData)
		{
			if(sectionStart && daBeats < sectionStartPoint){
				daBeats++;
				continue;
			}

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteType:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

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

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByEventStuff(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(player:Int, ?instant:Bool = false):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
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

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{

		PlayerSettings.gameControls();

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		setBoyfriendInvuln(1/60);

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length){
			vocals.time = Conductor.songPosition;
		}
		vocals.play();

		trace("resyncing vocals");
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


	override public function update(elapsed:Float)
	{
		
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

		/*if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}*/
		
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

		switch (curStage){

			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;

			case 'tank':
				moveTank();
		}

		super.update(elapsed);

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

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			PlayerSettings.menuControls();

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			PlayerSettings.menuControls();
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
		//trace(healthLerp);

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
			
		/* if (FlxG.keys.justPressed.NINE)
			switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT){

			PlayerSettings.menuControls();
			sectionStart = false;

			if(FlxG.keys.pressed.SHIFT){
				switchState(new AnimationDebug(SONG.player1));
			}
			else if(FlxG.keys.pressed.CONTROL){
				switchState(new AnimationDebug(gf.curCharacter));
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
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusBF();
			}
		}

		FlxG.watch.addQuick("totalBeats: ", totalBeats);

		if (curSong == 'Fresh')
		{
			switch (totalBeats)
			{
				case 16:
					camZooming = true;
					bopSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 48:
					bopSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 80:
					bopSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 112:
					bopSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 163:
			}
		}

		// RESET = Quick Game Over Screen
		if (controls.RESET && !startingSong)
		{
			health = 0;
			//trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			//trace("User is cheating!");
		}

		if (health <= 0)
		{
			//boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			PlayerSettings.menuControls();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollow.getScreenPosition().x, camFollow.getScreenPosition().y, boyfriend.deathCharacter));
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

			//MOVE NOTE TRANSPARENCY CODE BECAUSE REASONS 
			if(daNote.tooLate){
				if (daNote.alpha > 0.3){
					noteMiss(daNote.noteData, 0.055, false, true);
					vocals.volume = 0;
					daNote.alpha = 0.3;
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

				daNote.wasGoodHit = true;

				var altAnim:String = "";

				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = '-alt';
				}

				//trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);

				if(dad.canAutoAnim && (Character.LOOP_ANIM_ON_HOLD ? true : !daNote.isSustainNote)){
					switch (Math.abs(daNote.noteData))
					{
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
					}
				}

				enemyStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(daNote.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
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

				if (SONG.needsVoices)
					vocals.volume = 1;

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
		if (SONG.validScore && !usedAutoplay){
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), 1);

				PlayerSettings.menuControls();

				switchState(new StoryMenuState());
				sectionStart = false;

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore){
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

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

				//trace('LOADING NEXT SONG');
				//trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollow;
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
			PlayerSettings.menuControls();
			sectionStart = false;

			switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(note:Note):Void{

		var strumtime = note.strumTime;

		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);

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
			
	
		//trace('hit ' + daRating);

		songScore += score;

		comboUI.ratingPopup(daRating);

		if(combo >= minCombo)
			comboUI.comboPopup(combo);

	}

	private function createNoteSplash(note:Int){
		var bigSplashy = new NoteSplash(playerStrums.members[note].x, playerStrums.members[note].y, note);
		bigSplashy.cameras = [camHUD];
		add(bigSplashy);
	}

	private function keyCheck():Void{

		upTime = controls.UP ? upTime + 1 : 0;
		downTime = controls.DOWN ? downTime + 1 : 0;
		leftTime = controls.LEFT ? leftTime + 1 : 0;
		rightTime = controls.RIGHT ? rightTime + 1 : 0;

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
					noteMiss(daNote.noteData, 0.0425, false, true, false, false);
				}

				//This is for the first released note.
				if(daNote.prevNote.wasGoodHit && !daNote.wasGoodHit){

					var doTheMiss:Bool = false;

					switch(daNote.noteData){
						case 0:
							doTheMiss = leftRelease;
						case 1:
							doTheMiss = downRelease;
						case 2:
							doTheMiss = upRelease;
						case 3:
							doTheMiss = rightRelease;
					}

					if(doTheMiss){
						noteMiss(daNote.noteData, 0.055, true, true, false, true);
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

					if(!curStage.startsWith('school')){
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
			if (daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * (!daNote.isSustainNote ? 0.125 : (daNote.prevNote.wasGoodHit ? 1 : 0)))
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
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
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

			updateAccuracy();
		}

		if(Main.flippymode) { System.exit(0); }

	}

	inline function noteMissWrongPress(direction:Int = 1, ?healthLoss:Float = 0.0475):Void{
		noteMiss(direction, healthLoss, true, false, false, false, 4, 25);
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

	/*function setBoyfriendStunned(time:Float = 5 / 60){

		boyfriend.stunned = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});

	}*/

	function goodNoteHit(note:Note):Void
	{

		//Guitar Hero Styled Hold Notes
		//This is to make sure that if hold notes are hit out of order they are destroyed. Should not be possible though.
		if(note.isSustainNote && !note.prevNote.wasGoodHit){
			noteMiss(note.noteData, 0.055, true, true, false);
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
				health += 0.015 * Config.healthMultiplier;
			}
			else{
				health += 0.0075 * Config.healthMultiplier;
			}

			health += 0.015 * Config.healthMultiplier;
				
			if(boyfriend.canAutoAnim && (Character.LOOP_ANIM_ON_HOLD ? true : !note.isSustainNote)){
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
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

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.sound('carPass' + FlxG.random.int(0, 1)), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	function moveTank():Void
	{
		if (!inCutscene)
		{
			var daAngleOffset:Float = 1;
			tankAngle += FlxG.elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;

			tankGround.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
			tankGround.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
		}
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.sound('thunder_' + FlxG.random.int(1, 2)));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > 20 || (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition)) > 20)){
			resyncVocals();
		}

		/*if (dad.curCharacter == 'spooky' && totalSteps % 4 == 2)
		{
			// dad.dance();
		}*/

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

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

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			//else
			//	Conductor.changeBPM(SONG.bpm);

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
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat <= 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			uiBop(0.015, 0.03);
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 168)
		{
			dadBeats = [0, 1, 2, 3];
			bfBeats = [0, 1, 2, 3];
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 200)
		{
			dadBeats = [0, 2];
			bfBeats = [1, 3];
		}

		if(curBeat % (4 * bopSpeed) == 0 && camZooming){
			uiBop();
		}

		if (curBeat % bopSpeed == 0){
			iconP1.iconScale = iconP1.defualtIconScale * 1.25;
			iconP2.iconScale = iconP2.defualtIconScale * 1.25;

			iconP1.tweenToDefaultScale(0.2, FlxEase.quintOut);
			iconP2.tweenToDefaultScale(0.2, FlxEase.quintOut);

			gf.dance();

		}

		if(bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim && !boyfriend.animation.curAnim.name.startsWith('sing')){
			boyfriend.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo'){
			boyfriend.playAnim('hey', true);
		}

		foregroundSprites.forEach(function(spr:BGSprite){
			spr.dance();
		});

		switch (curStage)
		{
			case "school":
				bgGirls.dance();

			case "mall":
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case "limo":
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
				
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (totalBeats % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (totalBeats % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case "spooky":
				if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset){
					lightningStrikeShit();
				}
				
		}

		
	}

	private function executeEvent(tag:String):Void{

		if(tag.startsWith("playAnim;")){
			var tagSplit = tag.split(";");
			trace(tagSplit);

			switch(tagSplit[1]){
				case "dad":
					dad.playAnim(tagSplit[2]);

				case "gf":
					gf.playAnim(tagSplit[2]);

				default:
					boyfriend.playAnim(tagSplit[2]);
			}
		}
		else{
			switch(tag){
				case "dadAnimLockToggle":
					dad.canAutoAnim = !dad.canAutoAnim;

				case "bfAnimLockToggle":
					boyfriend.canAutoAnim = !boyfriend.canAutoAnim;

				case "gfAnimLockToggle":
					gf.canAutoAnim = !gf.canAutoAnim;

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

	function camFocusOpponent(){

		var followX = dad.getMidpoint().x + 150;
		var followY = dad.getMidpoint().y - 100;
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (dad.curCharacter)
		{
			case "spooky":
				followY = dad.getMidpoint().y - 30;
			case "pico":
				followX += 280;
			case "mom" | "mom-car":
				followY = dad.getMidpoint().y;
			case 'senpai':
				followY = dad.getMidpoint().y - 430;
				followX = dad.getMidpoint().x - 100;
			case 'senpai-angry':
				followY = dad.getMidpoint().y - 430;
				followX = dad.getMidpoint().x - 100;
			case 'spirit':
				followY = dad.getMidpoint().y;
		}

		/*if (dad.curCharacter == 'mom')
			vocals.volume = 1;*/

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "dad");
	}

	function camFocusBF(){

		var followX = boyfriend.getMidpoint().x - 100;
		var followY = boyfriend.getMidpoint().y - 100;

		switch (curStage)
		{
			case 'spooky':
				followY = boyfriend.getMidpoint().y - 125;
			case 'limo':
				followX = boyfriend.getMidpoint().x - 300;
			case 'mall':
				followY = boyfriend.getMidpoint().y - 200;
			case 'school':
				followX = boyfriend.getMidpoint().x - 200;
				followY = boyfriend.getMidpoint().y - 225;
			case 'schoolEvil':
				followX = boyfriend.getMidpoint().x - 200;
				followY = boyfriend.getMidpoint().y - 225;
		}

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "bf");
	}

	function camMove(_x:Float, _y:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_focus:String = "", ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		if(_time > 0){
			camTween.cancel();
			camTween = FlxTween.tween(camFollow, {x: _x, y: _y}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camTween.cancel();
			camFollow.setPosition(_x, _y);
		}
		
		camFocus = _focus;

	}

	function camChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		if(_time > 0){
			camZoomTween.cancel();
			camZoomTween = FlxTween.tween(FlxG.camera, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			camZoomTween.cancel();
			FlxG.camera.zoom = _zoom;
		}

	}

	function uiChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}


		if(_time > 0){
			uiZoomTween.cancel();
			uiZoomTween = FlxTween.tween(camHUD, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
		}
		else{
			uiZoomTween.cancel();
			camHUD.zoom = _zoom;
		}

	}

	function uiBop(?_camZoom:Float = 0.01, ?_uiZoom:Float = 0.02){

		if(autoZoom){
			camZoomTween.cancel();
			FlxG.camera.zoom = defaultCamZoom + _camZoom;
			camChangeZoom(defaultCamZoom, 0.6, FlxEase.quintOut);
		}

		if(autoUi){
			uiZoomTween.cancel();
			camHUD.zoom = 1 + _uiZoom;
			uiChangeZoom(1, 0.6, FlxEase.quintOut);
		}

	}

	override public function onFocus(){
		super.onFocus();
		new FlxTimer().start(0.3, function(t){
			if(Config.noFpsCap && !paused){
				openfl.Lib.current.stage.frameRate = 999;
			}
			else{
				openfl.Lib.current.stage.frameRate = 144;
			}
		});
	}

	function inRange(a:Float, b:Float, tolerance:Float){
		return (a <= b + tolerance && a >= b - tolerance);
	}

}
