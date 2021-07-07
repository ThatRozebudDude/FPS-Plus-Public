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

    var songsCached:Bool = false;
    var songs:Array<String> =   ["Tutorial", 
                                "Bopeebo", "Fresh", "Dadbattle", 
                                "Spookeez", "South", "Monster",
                                "Pico", "Philly", "Blammed", 
                                "Satin-Panties", "High", "Milf", 
                                "Cocoa", "Eggnog", "Winter-Horrorland", 
                                "Senpai", "Roses", "Thorns"];
                                
    //List of character graphics and some other stuff.
    //Just in case it want to do something with it later.
    var charactersCached:Bool = false;
    var characters:Array<String> =   ["BOYFRIEND", "bfCar", "christmas/bfChristmas", "weeb/bfPixel", "weeb/bfPixelsDEAD",
                                    "GF_assets", "gfCar", "christmas/gfChristmas", "weeb/gfPixel",
                                    "logoBumpin", "titleBG", "gfDanceTitle", "titleEnter",
                                    "DADDY_DEAREST", "spooky_kids_assets", "Monster_Assets",
                                    "Pico_FNF_assetss", "Mom_Assets", "momCar",
                                    "christmas/mom_dad_christmas_assets", "christmas/monsterChristmas",
                                    "weeb/senpai", "weeb/spirit", "weeb/senpaiCrazy"];

    var graphicsCached:Bool = false;
    var graphics:Array<String> =    ["limo/bgLimo", "limo/fastCarLol", "limo/limoDancer", "limo/limoDrive", "limo/limoSunset"];

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

        loadingText = new FlxText(5, FlxG.height - 30, 0, "Preloading Assets...", 24);
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
            loadingText.text = "Done!";
            splash.animation.play("end");
            splash.updateHitbox();
            splash.screenCenter();
            //FlxG.sound.play("assets/sounds/loadComplete.ogg");
        }
        
        super.update(elapsed);

    }

    function preload(){

        sys.thread.Thread.create(() -> {
            preloadMusic();
        });

        sys.thread.Thread.create(() -> {
            preloadCharacters();
        });

        sys.thread.Thread.create(() -> {
            preloadGraphics();
        });

    }

    function preloadMusic(){
        for(x in songs){
            FlxG.sound.cache("assets/music/" + x + "_Inst.ogg");
            trace("Chaching " + x);
        }
        FlxG.sound.cache("assets/music/klaskiiLoop.ogg");
        songsCached = true;
    }

    function preloadCharacters(){
        for(x in characters){
            var path = "assets/images/" + x + ".png";
            ImageCache.add(path);
            trace("Chaching " + x);
        }
        charactersCached = true;
    }

    function preloadGraphics(){
        for(x in graphics){
            var path = "assets/images/" + x + ".png";
            ImageCache.add(path);
            trace("Chaching " + x);
        }
        graphicsCached = true;
    }

}
