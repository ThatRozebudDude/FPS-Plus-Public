package objects;

#if sys
import sys.io.File;
#end

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import extensions.flixel.FlxTextExt;

using StringTools;
using flixel.util.FlxSpriteUtil;

class SongCaptions extends FlxSpriteGroup
{

    var text:FlxTextExt;
    var bg:FlxSprite;

    var meta:Array<Array<String>> = [];
    var size:Float = 0;
    var fontSize:Int = 24;

    public function new(_isDownScroll:Bool = false) {

        super();

        text = new FlxTextExt(0, !_isDownScroll ? 540 : 140, 0, "", fontSize);
        text.setFormat(Paths.font("vcr"), fontSize, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        bg = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
        bg.alpha = 0.67;


        add(bg);
        add(text);

        hide();
    }



    public function hide(){ visible = false; }

    public function display(_text:String){
        visible = true;

        text.text = _text;
        text.screenCenter(X);

        bg.setGraphicSize(Math.floor(text.width + fontSize), Math.floor(text.height + fontSize));
        bg.updateHitbox();
        bg.y = text.y - (fontSize / 2);
        bg.screenCenter(X);

        text.text += "\n";
    }
}
