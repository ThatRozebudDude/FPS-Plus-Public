package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Startup extends MusicBeatState
{

    var splash:FlxSprite;
    //var dummy:FlxSprite;
    var loadingText:FlxText;

    var songs:Array<String> =   ["Tutorial", 
                                "Bopeebo", "Fresh", "Dadbattle", 
                                "Spookeez", "South", "Monster",
                                "Pico", "Philly", "Blammed", 
                                "Satin-Panties", "High", "Milf", 
                                "Cocoa", "Eggnog", "Winter-Horrorland", 
                                "Senpai", "Roses", "Thorns"];

	override function create()
	{

        FlxG.mouse.visible = false;

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
        
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "start"){
            preload();  
        }
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "end"){
            FlxG.switchState(new TitleVidState());
            
        }
        
        super.update(elapsed);

    }

    function preload(){

        for(x in songs){
            FlxG.sound.cache("assets/music/" + x + "_Inst.ogg");
        }

        FlxG.sound.cache("assets/music/klaskiiLoop.ogg");
       
        loadingText.text = "Done!";
        splash.animation.play("end");
        splash.updateHitbox();
        splash.x = -13;
        splash.y = -12;
        //FlxG.sound.play("assets/sounds/loadComplete.ogg");

    }

}
