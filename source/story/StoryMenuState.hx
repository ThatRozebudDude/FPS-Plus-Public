package story;

import modding.PolymodHandler;
import flixel.tweens.FlxEase;
import haxe.Json;
import transition.data.StickerIn;
import config.Config;
import title.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import caching.*;

using StringTools;

@:hscriptClass
class ScriptedStoryMenuState extends StoryMenuState implements polymod.hscript.HScriptedClass{}

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	public static var fromPlayState:Bool = false;

	//public static var weekData:Array<Array<String>> = [];
	
	static var curDifficulty:Int = 1;

	//public static var weekUnlocked:Array<Bool> = [];

	//public static var weekCharacters = [];

	//public static var weekNames:Array<String> = [];
	//public static var weekNamesShort:Array<String> = [];

	//public static var weekList:Array<String> = [];
	public static var weekList:Array<StoryWeek> = [];

	var txtWeekTitle:FlxText;

	public static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var ui_tex:FlxAtlasFrames;

	var yellowBG:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	public function new(?stickerIntro:Bool = false) {
		super();
		if(stickerIntro){
			customTransIn = new transition.data.StickerIn();
		}
	}

	override function create(){
		
		Config.setFramerate(144);
	
		if(FlxG.sound.music == null || !FlxG.sound.music.playing){
			MainMenuState.playMenuMusic();
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		ui_tex = Paths.getSparrowAtlas('menu/story/campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFFFFFFF); //not so yellow now, huh...

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		weekList = [];

		var weekData:Array<String> = Utils.readDirectory("assets/data/weeks/");

		for(week in weekData){
			if(week.endsWith(".json")){
				var weekToAdd:StoryWeek = {
					name: null,
					id: null,
					sortOrder: 1000,
					songs: null,
					characters: ["dad", "bf", "gf"],
					stickerSet: null,
					color: 0xFFF9CF51,
					difficulties: ["easy", "normal", "hard"],
				}
				var weekJson = Json.parse(Utils.getText(Paths.json(week.split(".json")[0], "data/weeks")));
				weekToAdd.name = weekJson.name;
				if (weekJson.id != null){ weekToAdd.id = weekJson.id; }
				else{ weekToAdd.id = week.split(".json")[0].toLowerCase(); }
				if(weekJson.sortOrder != null){ weekToAdd.sortOrder = weekJson.sortOrder; }
				weekToAdd.songs = weekJson.songs;
				if(weekJson.characters != null){ weekToAdd.characters = weekJson.characters; }
				if(weekJson.stickerSet != null){ weekToAdd.stickerSet = weekJson.stickerSet; }
				if(weekJson.color != null){ weekToAdd.color = FlxColor.fromString(weekJson.color); }
				if(weekJson.difficulties != null){ weekToAdd.difficulties = weekJson.difficulties; }
				
				weekList.push(weekToAdd);
			}
		}

		/*for(week in ScriptableWeek.listScriptClasses()){
			var weekToAdd = ScriptableWeek.init(week);
			weekToAdd.create();
			weekList.push(weekToAdd);
		}*/

		weekList.sort(function(a:StoryWeek, b:StoryWeek):Int{
			if(a.sortOrder < b.sortOrder){ return -1; }
			else if(a.sortOrder > b.sortOrder){ return 1; }
			else{ return 0; }
		});

		/*for (week in scriptList) {
			if (!weekList.contains(week.toLowerCase())) {
				var weekScript:Week = ScriptableWeek.init(week);
				weekScript.create();
				weekList.push(week.toLowerCase());
				weekNames.push(weekScript.name);
				weekNamesShort.push(weekScript.short);
				weekData.push(weekScript.songs);
				weekCharacters.push(weekScript.characters);
				weekUnlocked.push(weekScript.unlocked);
			}
		}*/

		for (i in 0...weekList.length){
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekList[i].id);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.x += weekThing.positionOffset.x;
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			/*if (!weekUnlocked[i]){
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}*/
		}

		yellowBG.color = weekList[0].color;

		for (char in 0...3){
			var weekCharacterThing:MenuCharacter = new MenuCharacter(0, 0, weekList[curWeek].characters[char]);
			grpWeekCharacters.add(weekCharacterThing);
			repositionCharacter(char);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek(0);

		updateText();

		if(fromPlayState){
			customTransIn = new StickerIn();
		}

		fromPlayState = false;

		super.create();
	}

	function repositionCharacter(charIndex:Int) {
		grpWeekCharacters.members[charIndex].screenCenter(XY);
		grpWeekCharacters.members[charIndex].y -= 104;
		switch(charIndex){
			case 0:
				grpWeekCharacters.members[charIndex].x -= 1280 * (3/10); 	
			case 2:
				grpWeekCharacters.members[charIndex].x += 1280 * (3/10);
		}
	}

	override function update(elapsed:Float){
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(Utils.fpsAdjustedLerp(lerpScore, intendedScore, 0.21, 144, true));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekList[curWeek].name.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = true; //weekUnlocked[curWeek]

		grpLocks.forEach(function(lock:FlxSprite){
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack){
			if (!selectedWeek){
				if(Binds.justPressed("menuUp")){
					changeWeek(-1);
					changeDifficulty(0, false);
				}
				else if(Binds.justPressed("menuDown")){
					changeWeek(1);
					changeDifficulty(0, false);
				}

				if (Binds.pressed("menuRight")){
					rightArrow.animation.play('press');
				}
				else{
					rightArrow.animation.play('idle');
				}

				if(Binds.pressed("menuLeft")){
					leftArrow.animation.play('press');
				}
				else{
					leftArrow.animation.play('idle');
				}

				if(Binds.justPressed("menuRight")){
					changeDifficulty(1);
				}

				if(Binds.justPressed("menuLeft")){
					changeDifficulty(-1);
				}
			}

			if (Binds.justPressed("menuAccept")){
				selectWeek();
			}
		}

		if (Binds.justPressed("menuBack") && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			switchState(new MainMenuState());
		}

		if (Binds.justPressed("polymodReload") && !movedBack){
			PolymodHandler.reload();
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (true) //weekUnlocked[curWeek]
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].playAnim('confirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekList[curWeek].songs.copy();
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.returnLocation = "story";

			PlayState.weekStats = {
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

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				PlayState.loadEvents = true;
				switchState(new PlayState());
			});
		}
	}

	function changeDifficulty(change:Int = 0, ?playAnim:Bool = true):Void{

		curDifficulty += change;
		final diffList = ["easy", "normal", "hard"];

		if(curDifficulty < 0){
			curDifficulty = 2;
		}
		if(curDifficulty > 2){
			curDifficulty = 0;
		}

		//the evil while(true) >:O
		while(true){
			if(weekList[curWeek].difficulties.contains(diffList[curDifficulty])){
				break;
			}
			curDifficulty += change >= 0 ? 1 : -1;
			if(curDifficulty < 0){
				curDifficulty = 2;
			}
			if(curDifficulty > 2){
				curDifficulty = 0;
			}
		}
		

		sprDifficulty.offset.x = 0;

		switch (curDifficulty){
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}
		
		intendedScore = Highscore.getWeekScore(weekList[curWeek].id, curDifficulty).score;
		if(playAnim){
			FlxTween.completeTweensOf(sprDifficulty);
			sprDifficulty.y = leftArrow.y - 15;
			sprDifficulty.alpha = 0;
			FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekList.length - 1;

		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		changeDifficulty(0, false);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == 0 && true) //weekUnlocked[curWeek]
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		FlxTween.cancelTweensOf(yellowBG);
		FlxTween.color(yellowBG, 0.8, yellowBG.color, weekList[curWeek].color, {ease: FlxEase.quintOut});

		updateText();
	}

	function updateText(){

		grpWeekCharacters.members[0].setCharacter(weekList[curWeek].characters[0]);
		grpWeekCharacters.members[1].setCharacter(weekList[curWeek].characters[1]);
		grpWeekCharacters.members[2].setCharacter(weekList[curWeek].characters[2]);
		repositionCharacter(0);
		repositionCharacter(1);
		repositionCharacter(2);

		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = weekList[curWeek].songs;

		for (song in stringThing){

			var meta = Utils.defaultSongMetadata(song.replace("-", " "));

			if(Utils.exists("assets/data/songs/" + song.toLowerCase() + "/meta.json")){
				var jsonMeta = Json.parse(Utils.getText("assets/data/songs/" + song.toLowerCase() + "/meta.json"));
				if(jsonMeta.name != null) { meta.name = jsonMeta.name; }
			}

			txtTracklist.text += "\n" + meta.name;
		}

		txtTracklist.text += "\n";

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
		intendedScore = Highscore.getWeekScore(weekList[curWeek].id, curDifficulty).score;
	}
}

typedef StoryWeek = {
	var name:String;				//Name that will appear in the story menu and results screen.
	var id:String;					//Internal name that will be used by the save file and week name image.
	var sortOrder:Float;			//Determines where in the story mode list the week appears.
	var songs:Array<String>;		//Name of the songs used in the week.
	var characters:Array<String>;	//Characters that show up in the story menu.
	var stickerSet:Array<String>;	//The set of stickers to use when returning to the story menu.
	var color:FlxColor;				//The color that the story menu is set to when selecting the week.
	var difficulties:Array<String>;	//The color that the story menu is set to when selecting the week.
}