package;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths
{

    inline static public function image(key:String):Dynamic{

        var data:String = 'assets/images/$key.png';

        if(ImageCache.exists(data)){
            //trace(key + " is in the cache");
            return ImageCache.get(data);
        }
        else{
            //trace(key + " loading from file");
            return data;
        }
            
    }

    inline static public function xml(key:String){
        return 'assets/images/$key.xml';
    }

    inline static public function sound(key:String){
        return 'assets/sounds/$key.ogg';
    }

    inline static public function music(key:String){
        return 'assets/music/$key.ogg';
    }

    inline static public function getSparrowAtlas(key:String){
        return FlxAtlasFrames.fromSparrow(image(key), xml(key));
    }

    inline static public function getPackerAtlas(key:String){
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key), 'assets/images/$key.txt');
    }



}