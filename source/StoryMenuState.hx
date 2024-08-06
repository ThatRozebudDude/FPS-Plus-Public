package;

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
import lime.net.curl.CURLCode;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	public static var fromPlayState:Bool = false;

	public static var weekData:Map<Int, Array<String>> = [
		0 => ['Tutorial'],
		1 => ['Bopeebo', 'Fresh', 'Dadbattle'],
		2 => ['Spookeez', 'South', 'Monster'],
		3 => ['Pico', 'Philly', "Blammed"],
		4 => ['Satin-Panties', "High", "Milf"],
		5 => ['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		6 => ['Senpai', 'Roses', 'Thorns'],
		7 => ['Ugh', 'Guns', 'Stress'],
		101 => ['Darnell', 'Lit-Up', '2hot', 'Blazin']
	];
	
	static var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true, true, true, true, true, true, true, true];

	public static var weekCharacters = [
		['dad', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-xmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf'],
		['tankman', 'bf', 'gf'],
		['darnell', 'pico-player', 'nene']
	];

	public static var weekNames:Map<Int, String> = [
		0 => "Tutorial",
		1 => "Daddy Dearest",
		2 => "Spooky Month",
		3 => "Pico",
		4 => "Mommy Must Murder",
		5 => "Red Snow",
		6 => "Hating Simulator ft. Moawling",
		7 => "Tankman",
		101 => "Due Debts"
	];

	public static var weekNamesShort:Map<Int, String> = [
		0 => "Tutorial",
		1 => "Daddy Dearest",
		2 => "Spooky Month",
		3 => "Pico",
		4 => "Mommy Must Murder",
		5 => "Red Snow",
		6 => "Hating Simulator",
		7 => "Tankman",
		101 => "Due Debts"
	];

	public static var weekNumber:Array<Int> = [
		0,
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		101
	];

	var txtWeekTitle:FlxText;

	public static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var ui_tex:FlxAtlasFrames;

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

	override function create()
	{

		Config.setFramerate(144);
	
		if (FlxG.sound.music == null || !FlxG.sound.music.playing){
			FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), TitleScreen.titleMusicVolume);
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
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		for (i in 0...weekNumber.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekNumber[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		for (char in 0...3){
			var weekCharacterThing:MenuCharacter = new MenuCharacter(0, 0, weekCharacters[curWeek][char]);
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

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(Utils.fpsAdjsutedLerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[weekNumber[curWeek]].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (Binds.justPressed("menuUp"))
				{
					changeWeek(-1);
				}

				if (Binds.justPressed("menuDown"))
				{
					changeWeek(1);
				}

				if (Binds.pressed("menuRight"))
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (Binds.pressed("menuLeft"))
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (Binds.justPressed("menuRight"))
					changeDifficulty(1);
				if (Binds.justPressed("menuLeft"))
					changeDifficulty(-1);
			}

			if (Binds.justPressed("menuAccept"))
			{
				selectWeek();
			}
		}

		if (Binds.justPressed("menuBack") && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('confirm');
				grpWeekCharacters.members[1].centerOffsets();
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[weekNumber[curWeek]].copy();
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
			PlayState.storyWeek = weekNumber[curWeek];
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

	function changeDifficulty(change:Int = 0, ?playAnim:Bool = true):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
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

		FlxTween.cancelTweensOf(sprDifficulty);

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(weekNumber[curWeek], curDifficulty).score;
		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		if(!playAnim){
			FlxTween.completeTweensOf(sprDifficulty);
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekNumber.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekNumber.length - 1;

		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		changeDifficulty(0, false);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText(){

		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);
		repositionCharacter(0);
		repositionCharacter(1);
		repositionCharacter(2);

		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = weekData[weekNumber[curWeek]];

		for (song in stringThing){
			var meta = Json.parse(Utils.getText("assets/data/" + song.toLowerCase() + "/meta.json"));
			txtTracklist.text += "\n" + meta.name;
		}

		txtTracklist.text += "\n";

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
		intendedScore = Highscore.getWeekScore(weekNumber[curWeek], curDifficulty).score;
	}
}
