package results;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import Highscore.Rank;
import flixel.group.FlxSpriteGroup;
import Utils.OrderedMap;

class ResultsCharacter extends FlxSpriteGroup
{
    var rank:Rank;

    public var goldText:Array<String> =      ["PERFECT"];
    public var perfectText:Array<String> =   ["PERFECT"];
    public var excellentText:Array<String> = ["EXCELLENT"];
    public var greatText:Array<String> =     ["GREAT"];
    public var goodText:Array<String> =      ["GOOD"];
    public var lossText:Array<String> =      ["LOSS"];

    public var gradientTopColor:FlxColor = 0xFFFECC5C;
    public var gradientBottomColor:FlxColor = 0xFFFDC05C;
    public var scrollingTextColor:FlxColor = 0xFFFEDA6C;

    public function new(_rank:Rank) {
        super();
        rank = _rank;
        setup();
    }

    public function setup():Void{}

    public function playAnim():Void{}

    public function playIntroSong():Void{}

    public function playSong():Void{}
}