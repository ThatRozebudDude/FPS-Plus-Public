package config;

import openfl.media.Sound;
import title.*;
import config.*;
import transition.data.*;

import flixel.FlxState;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.system.System;
//import openfl.utils.Future;
//import flixel.addons.util.FlxAsyncLoop;

using StringTools;

class CacheReload extends FlxState
{

    public static var doMusic = true;
    public static var doGraphics = true;

    var nextState:FlxState = new ConfigMenu();

    var splash:FlxSprite;
    //var dummy:FlxSprite;
    var loadingText:FlxText;

    var songsCached:Bool;
                                
    var charactersCached:Bool;
    var startCachingCharacters:Bool = false;
    var charI:Int = 0;

    var graphicsCached:Bool;
    var startCachingGraphics:Bool = false;
    var gfxI:Int = 0;

    var cacheStart:Bool = false;

	override function create()
	{
        songsCached = !FlxG.save.data.musicPreload2;
        charactersCached = !FlxG.save.data.charPreload2;
        graphicsCached = !FlxG.save.data.graphicsPreload2;

        if(doGraphics){
            GPUBitmap.disposeAll();
            ImageCache.cache.clear();
        }
        else{
            charactersCached = true;
            graphicsCached = true;
        }

        if(doMusic){
            Assets.cache.clear("music");
        }
        else{
            songsCached = true;
        }

        System.gc();

        var text = new FlxText(0, 0, 1280, "LOADING ASSETS...", 64);
	    text.scrollFactor.set(0, 0);
	    text.setFormat(Paths.font("vcr"), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.borderSize = 3;
	    text.borderQuality = 1;
        text.screenCenter(XY);
        add(text);

        preload();
        cacheStart = true;

        super.create();

    }

    override function update(elapsed) 
    {

        if(songsCached && charactersCached && graphicsCached){
            
            System.gc();
            FlxG.switchState(nextState);

        }

        if(startCachingCharacters){
            if(charI >= Startup.characters.length){
                //loadingText.text = "Characters cached...";
                //FlxG.sound.play(Paths.sound("tick"), 1);
                startCachingCharacters = false;
                charactersCached = true;
            }
            else{
                ImageCache.add(Paths.file(Startup.characters[charI], "images", "png"));
                charI++;
            }
        }

        if(startCachingGraphics){
            if(gfxI >= Startup.graphics.length){
                //loadingText.text = "Graphics cached...";
                //FlxG.sound.play(Paths.sound("tick"), 1);
                startCachingGraphics = false;
                graphicsCached = true;
            }
            else{
                ImageCache.add(Paths.file(Startup.graphics[gfxI], "images", "png"));
                gfxI++;
            }
        }
        
        super.update(elapsed);

    }

    function preload(){

        //loadingText.text = "Preloading Assets...";
        
        if(!songsCached){ 
            #if sys sys.thread.Thread.create(() -> { #end
                preloadMusic();
            #if sys }); #end
        }
        

        /*if(!charactersCached){
            var i = 0;
            var charLoadLoop = new FlxAsyncLoop(characters.length, function(){
                ImageCache.add(Paths.file(characters[i], "images", "png"));
                i++;
            }, 1);
        }

        for(x in characters){
            
            //trace("Chached " + x);
        }
        loadingText.text = "Characters cached...";
        charactersCached = true;*/

        if(!charactersCached){
            startCachingCharacters = true;
        }

        if(!graphicsCached){
            startCachingGraphics = true;
        }

    }

    function preloadMusic(){
        for(x in Startup.songs){
            if(Assets.exists(Paths.inst(x))){
                FlxG.sound.cache(Paths.inst(x));
            }
            else{
                FlxG.sound.cache(Paths.music(x));
            }
        }
        //loadingText.text = "Songs cached...";
        //FlxG.sound.play(Paths.sound("tick"), 1);
        songsCached = true;
    }

    /*
    function preloadCharacters(){
        for(x in Startup.characters){
            ImageCache.add(Paths.file(x, "images", "png"));
            //trace("Chached " + x);
        }
        loadingText.text = "Characters cached...";
        charactersCached = true;
    }

    function preloadGraphics(){
        for(x in Startup.graphics){
            ImageCache.add(Paths.file(x, "images", "png"));
            //trace("Chached " + x);
        }
        loadingText.text = "Graphics cached...";
        graphicsCached = true;
    }
    */

}
