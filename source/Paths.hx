package;

#if sys
import sys.FileSystem;
#end

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import caching.*;

using StringTools;

class Paths
{

    static final audioExtension:String = "ogg";

    inline static public function file(key:String, location:String, extension:String):String{
        if(location.endsWith("/")){ location = location.substring(0, location.length-1); } //Prevent people from accidentally using 2 slashes.
        var data:String = 'assets/$location/$key.$extension';
        return data;

    }

    inline static public function image(key:String, forceLoadFromDisk:Bool = false):Dynamic{

        var data:String = file(key, "images", "png");

        if(ImageCache.exists(data) && !forceLoadFromDisk){
            return ImageCache.get(data);
        }
        else if(!forceLoadFromDisk){
            if(ImageCache.localCache.exists(data)){
                return ImageCache.localCache.get(data);
            }
            else{
                return ImageCache.addLocal(data);
            }
        }
        else{
            return data;
        }
    }

    inline static public function xml(key:String, ?location:String = "images"){
        return file(key, location, "xml");
    }

    inline static public function text(key:String, ?location:String = "data"){
        return file(key, location, "txt");
    }

    inline static public function json(key:String, ?location:String = "data/songs"){
        return file(key, location, "json");
    }

    inline static public function sound(key:String){
        var data:String = file(key, "sounds", audioExtension);
        if(!AudioCache.trackedSounds.contains(data)){
            AudioCache.trackedSounds.push(data);
        }
        return data;
    }

    inline static public function music(key:String){
        return file(key, "music", audioExtension);
    }

    inline static public function voices(key:String, type:String = ""){
        if(type.length > 0){ type = "-" + type; }
        return 'assets/songs/$key/Voices$type.$audioExtension';
    }

    inline static public function inst(key:String){
        return 'assets/songs/$key/Inst.$audioExtension';
    }

    inline static public function getSparrowAtlas(key:String, ?xmlFile:String){
        if(xmlFile == null){ xmlFile = key; }
        return FlxAtlasFrames.fromSparrow(image(key), xml(xmlFile));
    }

    inline static public function getPackerAtlas(key:String, ?textFile:String){
        if(textFile == null){ textFile = key; }
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key), text(textFile, "images"));
    }

    inline static public function getTextureAtlas(key:String){
        return 'assets/images/$key';
    }

    inline static public function video(key:String){
        return file(key, "videos", "mp4");
    }
    
    inline static public function font(key:String, ?extension:String = "ttf"){
        return file(key, "fonts", extension);
    }

    inline static public function shader(key:String, ?extension:String = "frag"){
        return file(key, "data/shaders", extension);
    }

}