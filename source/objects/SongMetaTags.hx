package objects;

#if sys
import sys.io.File;
#end

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import extensions.flixel.FlxTextExt;
import haxe.Json;

using StringTools;
using flixel.util.FlxSpriteUtil;

class SongMetaTags extends FlxSpriteGroup
{

    var meta:Dynamic;
    var size:Float = 0;
    var fontSize:Int = 24;

    public function new(_x:Float, _y:Float, _song:String) {

        super(_x, _y);

        var text = new FlxTextExt(0, 0, 0, "", fontSize);
        text.setFormat(Paths.font("vcr"), fontSize, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        meta = Json.parse(Utils.getText(Paths.json(_song + "/meta")));

        text.text = meta.name + "\n\nArtist: " + meta.artist;

        size = text.fieldWidth;
        
        var bg = new FlxSprite(fontSize/-2, fontSize/-2).makeGraphic(Math.floor(size + fontSize), Math.floor(text.height + fontSize), FlxColor.BLACK);
        bg.alpha = 0.67;

        text.text += "\n";

        add(bg);
        add(text);

        x -= size;
        visible = false;
        
    }



    public function start(){

        visible = true;

        FlxTween.tween(this, {x: x + size + (fontSize/2)}, 1, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween){
            FlxTween.tween(this, {x: x - size}, 1, {ease: FlxEase.quintIn, startDelay: 2, onComplete: function(twn:FlxTween){ this.destroy(); }});
        }});

    }
}
