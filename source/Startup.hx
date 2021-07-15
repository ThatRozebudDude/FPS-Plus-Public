package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Startup extends MusicBeatState
{

    var splash:FlxSprite;
    //var dummy:FlxSprite;
    var loadingText:FlxText;

    var songsCached:Bool = Main.skipsound;
    var songs:Array<String> =   ["Tutorial", 
                                "Bopeebo", "Fresh", "Dadbattle", 
                                "Spookeez", "South", "Monster",
                                "Pico", "Philly", "Blammed", 
                                "Satin-Panties", "High", "Milf", 
                                "Cocoa", "Eggnog", "Winter-Horrorland", 
                                "Senpai", "Roses", "Thorns"];
                                
    //List of character graphics and some other stuff.
    //Just in case it want to do something with it later.
    var charactersCached:Bool = Main.skipcharacters;
    var characters:Array<String> =   ["BOYFRIEND", "bfCar", "christmas/bfChristmas", "weeb/bfPixel", "weeb/bfPixelsDEAD",
                                    "GF_assets", "gfCar", "christmas/gfChristmas", "weeb/gfPixel",
                                    "DADDY_DEAREST", "spooky_kids_assets", "Monster_Assets",
                                    "Pico_FNF_assetss", "Mom_Assets", "momCar",
                                    "christmas/mom_dad_christmas_assets", "christmas/monsterChristmas",
                                    "weeb/senpai", "weeb/spirit", "weeb/senpaiCrazy"];

    var graphicsCached:Bool = Main.skipgraphics;
    var graphics:Array<String> =    ["logoBumpin", "titleBG", "gfDanceTitle", "titleEnter",
                                    "stageback", "stagefront", "stagecurtains",
                                    "halloween_bg",
                                    "philly/sky", "philly/city", "philly/behindTrain", "philly/train", "philly/street", "philly/win0", "philly/win1", "philly/win2", "philly/win3", "philly/win4",
                                    "limo/bgLimo", "limo/fastCarLol", "limo/limoDancer", "limo/limoDrive", "limo/limoSunset",
                                    "christmas/bgWalls", "christmas/upperBop", "christmas/bgEscalator", "christmas/christmasTree", "christmas/bottomBop", "christmas/fgSnow", "christmas/santa",
                                    "christmas/evilBG", "christmas/evilTree", "christmas/evilSnow",
                                    "weeb/weebSky", "weeb/weebSchool", "weeb/weebStreet", "weeb/weebTreesBack", "weeb/weebTrees", "weeb/petals", "weeb/bgFreaks",
                                    "weeb/animatedEvilSchool"];

    var cacheStart:Bool = false;

	override function create()
	{

        FlxG.mouse.visible = false;
        FlxG.sound.muteKeys = null;

        splash = new FlxSprite(0, 0);
        splash.frames = FlxAtlasFrames.fromSparrow('assets/images/fpsPlus/rozeSplash.png', 'assets/images/fpsPlus/rozeSplash.xml');
        splash.animation.addByPrefix('start', 'Splash Start', 24, false);
        splash.animation.addByPrefix('end', 'Splash End', 24, false);
        add(splash);
        splash.animation.play("start");
        splash.updateHitbox();
        splash.screenCenter();

        loadingText = new FlxText(5, FlxG.height - 30, 0, "", 24);
        loadingText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadingText);

        new FlxTimer().start(1.1, function(tmr:FlxTimer)
        {
            FlxG.sound.play("assets/sounds/splashSound.ogg");   
        });
        
        super.create();

    }

    override function update(elapsed) 
    {
        
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "start" && !cacheStart){
            preload(); 
            cacheStart = true;
        }
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "end"){
            FlxG.switchState(new TitleVidState());
            
        }

        if(songsCached && charactersCached && graphicsCached && !(splash.animation.curAnim.name == "end")){
            
            splash.animation.play("end");
            splash.updateHitbox();
            splash.screenCenter();

            new FlxTimer().start(0.3, function(tmr:FlxTimer)
            {
                loadingText.text = "Done!";
            });

            //FlxG.sound.play("assets/sounds/loadComplete.ogg");
        }
        
        super.update(elapsed);

    }

    function preload(){

        loadingText.text = "Preloading Assets...";

        if(!songsCached){
            sys.thread.Thread.create(() -> {
                preloadMusic();
            });
        }

        if(!charactersCached){
            sys.thread.Thread.create(() -> {
                preloadCharacters();
            });
        }

        if(!graphicsCached){
            sys.thread.Thread.create(() -> {
                preloadGraphics();
            });
        }

    }

    function preloadMusic(){
        for(x in songs){
            FlxG.sound.cache("assets/music/" + x + "_Inst.ogg");
            trace("Chached " + x);
        }
        FlxG.sound.cache("assets/music/klaskiiLoop.ogg");
        loadingText.text = "Songs cached...";
        songsCached = true;
    }

    function preloadCharacters(){
        for(x in characters){
            ImageCache.add("assets/images/" + x + ".png");
            trace("Chached " + x);
        }
        loadingText.text = "Characters cached...";
        charactersCached = true;
    }

    function preloadGraphics(){
        for(x in graphics){
            ImageCache.add("assets/images/" + x + ".png");
            trace("Chached " + x);
        }
        loadingText.text = "Graphics cached...";
        graphicsCached = true;
    }

}
