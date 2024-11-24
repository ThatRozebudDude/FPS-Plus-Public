package credits;

import extensions.flixel.FlxUIStateExt;
import config.CacheConfig;
import title.TitleScreen;
import config.Config;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import modding.PolymodHandler;
import polymod.Polymod;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

using StringTools;

class CreditsState extends MusicBeatState
{
	public static var contributors:Array<ModContributor> = [];
	//I might rewrite it to use Map at some point.
	public static var modNamesArray:Array<String> = [];

	public static var startingSelection:Int = 0;
	public static var curSelected:Int = 0;

	private var grpCredits:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	
	private var hintTxt:FlxText;

	private var titleTxt:FlxText;
	private var descTxt:FlxText;

	private var iconArray:Array<CreditIcon> = [];

	override function create()
	{
		Config.setFramerate(144);
		
		curSelected = 0;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/menuDesat'));
		bg.color = 0xFF1C1C1C;
		add(bg);

		grpCredits = new FlxTypedGroup<Alphabet>();
		add(grpCredits);

		
		contributors = [];
		modNamesArray = [];

		//You Can Hardcode Credits Here!
		contributors.push({
			name: "Funkin Crew'",
			url: "https://github.com/FunkinCrew/Funkin",
			role: "Developers of original Friday Night Funkin'"
		});
		modNamesArray.push("Friday Night Funkin'");

		contributors.push({
			name: "Rozebud",
			url: "https://x.com/helpme_thebigt",
			role: "Basically everything that's been added."
		});
		modNamesArray.push("Friday Night Funkin' FPS Plus");

		contributors.push({
			name: "Elikapika",
			url: "https://x.com/elikapika",
			role: "Additional Sticker Art"
		});
		modNamesArray.push("Friday Night Funkin' FPS Plus");

		contributors.push({
			name: "River",
			url: "https://x.com/rivermusic_",
			role: "Additional Sticker Art"
		});
		modNamesArray.push("Friday Night Funkin' FPS Plus");


		for (meta in PolymodHandler.loadedModMetadata){
			for (c in meta.contributors){
				modNamesArray.push(meta.title);
				contributors.push(c);
			}
		}

		for (i in 0...contributors.length)
		{
			var credText:Alphabet = new Alphabet(0, (70 * i) + 30, contributors[i].name, true, false);
			credText.isMenuItem = true;
			credText.targetY = i;
			grpCredits.add(credText);

			var icon:CreditIcon = new CreditIcon(contributors[i].name);
			icon.sprTracker = credText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			//credText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// credText.screenCenter(X);
		}

		var descBox = new FlxSprite(0, 650).makeGraphic(1300, 100, 0xFF000000);
		descBox.screenCenter(FlxAxes.X);
		descBox.alpha = 0.8;
		add(descBox);

		titleTxt = new FlxText(40, 660, 1240, "???", 25);
		titleTxt.setFormat(Paths.font("vcr"), 25, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		titleTxt.scrollFactor.set();
		add(titleTxt);

		descTxt = new FlxText(40, 685, 1240, "???", 25);
		descTxt.setFormat(Paths.font("vcr"), 25, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		descTxt.scrollFactor.set();
		add(descTxt);
		

		changeSelection(startingSelection);

		if(!CacheConfig.music){
			FlxG.sound.playMusic(Paths.music("title"), TitleScreen.titleMusicVolume);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Binds.justPressed("menuUp")){
			changeSelection(-1);
		}
		if (Binds.justPressed("menuDown")){
			changeSelection(1);
		}
			

		if (Binds.justPressed("menuBack") && !FlxUIStateExt.inTransition){
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			switchState(new MainMenuState());
		}

		if (Binds.justPressed("menuAccept") && !FlxUIStateExt.inTransition)
		{
			if (contributors[curSelected].url != null){
				#if linux
				Sys.command('/usr/bin/xdg-open', [contributors[curSelected].url, "&"]);
				#else
				FlxG.openURL(contributors[curSelected].url);
				#end
			}
		}
	}

	function changeSelection(change:Int = 0){

		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected = FlxMath.wrap(curSelected + change, 0, contributors.length - 1);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		titleTxt.text = modNamesArray[curSelected];
		//Unhardcode this shit later
		switch(titleTxt.text){
			case "Friday Night Funkin'":
				titleTxt.color = 0xFF7BD6F6;
			case "Friday Night Funkin' FPS Plus":
				titleTxt.color = 0xFFFF3FAC;
			default:
				titleTxt.color = 0xFFA1A1A1;
		}
		if (contributors[curSelected].role != null){
			descTxt.text = contributors[curSelected].role;
		} else {
			descTxt.text = "";
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpCredits.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}