package freeplay;

import flixel.util.FlxTimer;
import flixel.FlxG;
import openfl.display.BlendMode;
import Highscore.SongStats;
import flixel.tweens.FlxEase;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextBorderStyle;
import extensions.flixel.FlxTextExt;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

using StringTools;

class Capsule extends FlxSpriteGroup
{

    final capsuleScale:Float = 0.8;

    var selectColor:FlxColor = 0xFFFFFFFF;
    var deselectColor:FlxColor = 0xFF969A9D;
    var selectBorderColor:FlxColor = 0xFF6B9FBA;
    var deselectBorderColor:FlxColor = 0xFF3E508C;

    final noRankWidth:Float = 317;
    final rankWidth:Float = 275;

    var capsule:FlxSprite;
    var icon:FlxSprite;
    var text:FlxTextExt;
    var rank:FlxSprite;
    var sparkle:FlxSprite;

    public var song:String;
    public var album:String;
    public var week:Int;
    public var highscoreData:Array<SongStats> = [];
    public var difficulties:Array<Int> = [];
    public var skin:String;

    public var targetPos:FlxPoint = new FlxPoint();
    public var xPositionOffset:Float = 0;
    public var selected:Bool = true;

    public var doLerp:Bool = true;

    var scrollOffset:Float = 0;
    var scrollTween:FlxTween;

    public function new(_song:String, _displayName:String, _icon:String, _week:Int, _album:String = "vol1", _difficulties:Array<Int>, _skinInfo:Array<Dynamic>) {
        super();

        song = _song;
        week = _week;
        album = _album;
        difficulties = _difficulties;

        if(_skinInfo != null){
            skin = _skinInfo[0];
            selectColor = _skinInfo[1];
            deselectColor = _skinInfo[2];
            selectBorderColor = _skinInfo[3];
            deselectBorderColor = _skinInfo[4];
        }

        for(i in 0...3){
            highscoreData.push(Highscore.getScore(song, i));
        }

        capsule = new FlxSprite();
        capsule.frames = getSparrowPathWithSkin("menu/freeplay/freeplayCapsule");
        capsule.animation.addByPrefix("selected", "mp3 capsule w backing SELECTED", 24, true);
        capsule.animation.addByPrefix("deslected", "mp3 capsule w backing NOT SELECTED", 24, true);
        capsule.origin.set(0, 0);
        capsule.scale.set(capsuleScale, capsuleScale);
        capsule.antialiasing = true;
        
        capsule.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int){
            switch(name){
                case "deslected":
                    capsule.offset.set(-4, 0);
                default:
                    capsule.offset.set(0, 0);
            }
        }

        text = new FlxTextExt(95, 34, 0, _displayName, 32);
        text.setFormat(Paths.font("5by7"), 32, selectColor, LEFT, FlxTextBorderStyle.OUTLINE, selectBorderColor);
        text.borderSize = 1;
        text.antialiasing = true;
        scrollTween = FlxTween.tween(this, {}, 0);

        //var debugDot:FlxSprite = new FlxSprite(text.x, text.y).makeGraphic(2, 2, 0xFFFFAAFF);
        //var debugDot2:FlxSprite = new FlxSprite(0, 0).makeGraphic(4, 4, 0xFFAAFFFF);

        //temp before I add a json or something
        //because I have to add the animations and they dont have padding
        var iconXOffset:Float = 0;
        var iconYOffset:Float = 0;
        switch(_icon){
            case "parents-christmas":
                iconXOffset = -38;
        }
        icon = new FlxSprite(iconXOffset, iconYOffset);
        icon.frames = Paths.getSparrowAtlas("menu/freeplay/icons/" + _icon);
        icon.animation.addByPrefix("idle", "idle", 0, false);
        icon.animation.addByPrefix("confirm", "confirm0", 12, false);
        icon.animation.play("idle", true);
        icon.origin.set(0, 0);
        icon.scale.set(2, 2);

        rank = new FlxSprite(358, 27);
        rank.frames = Paths.getSparrowAtlas("menu/freeplay/rankbadges");
        rank.animation.addByPrefix("loss", "LOSS", 24, false);
        rank.animation.addByPrefix("good", "GOOD", 24, false);
        rank.animation.addByPrefix("great", "GREAT", 24, false);
        rank.animation.addByPrefix("excellent", "EXCELLENT", 24, false);
        rank.animation.addByPrefix("perfect", "PERFECT", 24, false);
        rank.animation.addByPrefix("gold", "GOLD", 24, false);
        rank.animation.play("loss");
        rank.antialiasing = true;
        rank.blend = BlendMode.ADD;
        rank.visible = false;

        sparkle = new FlxSprite(383, 48);
        sparkle.frames = Paths.getSparrowAtlas("menu/freeplay/sparkle");
        sparkle.animation.addByPrefix("sparkle", "", FlxG.random.int(23, 25), false);
        sparkle.animation.play("sparkle", true);
        sparkle.offset.set(30, 30);
        sparkle.offset.x += FlxG.random.int(-10, 10);
        sparkle.offset.y += FlxG.random.int(-10, 10);
        sparkle.animation.finishCallback = function(name) {
            sparkle.visible = false;
            new FlxTimer().start(FlxG.random.float(0.4, 1.2), function(t) {
                sparkle.visible = true;
                sparkle.offset.set(30, 30);
                sparkle.offset.x += FlxG.random.int(-10, 10);
                sparkle.offset.y += FlxG.random.int(-10, 10);
                sparkle.animation.play("sparkle", true);
            });
        }
        sparkle.scale.set(0.75, 0.75);
        sparkle.antialiasing = true;
        sparkle.alpha = 0;
        sparkle.blend = BlendMode.ADD;

        add(capsule);
        add(text);
        add(icon);
        add(rank);
        add(sparkle);
        //add(debugDot);
        //add(debugDot2);

        deslect();

    }

    override function update(elapsed:Float):Void{
        if(doLerp){
            x = Utils.fpsAdjsutedLerp(x, targetPos.x, 0.3) + xPositionOffset;
            y = Utils.fpsAdjsutedLerp(y, targetPos.y, 0.4);
    
            text.x = x + 95 + scrollOffset;
        }

        var rectPos = Utils.worldToLocal(text, x + 85, y + 24);
        text.clipRect = new FlxRect(rectPos.x, rectPos.y, (rank.visible ? rankWidth : noRankWidth), 48);

        super.update(elapsed);
    }

    public function select():Void{
        if(selected){ return; }
        capsule.animation.play("selected", true);
        text.color = selectColor;
        text.borderColor = selectBorderColor;
        selected = true;

        var minThing = noRankWidth - 20;
        var maxThing = noRankWidth - 10;
        if(rank.visible){
            minThing = rankWidth - 20;
            maxThing = rankWidth - 10;
        }

        if(text.width > minThing && text.width <= maxThing){
            scrollOffset = (text.width - minThing)/-2;
        }
        else if(text.width > maxThing){
            scrollEaseStart();
        }
    }

    public function deslect():Void{
        if(!selected){ return; }
        capsule.animation.play("deslected", true);
        text.color = deselectColor;
        text.borderColor = deselectBorderColor;
        selected = false;

        scrollTween.cancel();
        scrollOffset = 0;

        var minThing = noRankWidth - 20;
        var maxThing = noRankWidth - 10;
        if(rank.visible){
            minThing = rankWidth - 20;
            maxThing = rankWidth - 10;
        }

        if(text.width > minThing && text.width <= maxThing){
            scrollOffset = (text.width - minThing)/-2;
        }
    }

    public function confirm():Void{
        icon.animation.play("confirm", true);
    }

    public function showRank(difficulty:Int):Void{
        rank.visible = true;
        sparkle.alpha = 0;
        switch(highscoreData[difficulty].rank){
            case gold:
                rank.animation.play("gold", true);
                sparkle.alpha = 1;
            case perfect:
                rank.animation.play("perfect", true);
            case excellent:
                rank.animation.play("excellent", true);
            case great:
                rank.animation.play("great", true);
            case good:
                rank.animation.play("good", true);
            case loss:
                rank.animation.play("loss", true);
            default:
                rank.visible = false;
        }
    }

    function scrollEaseStart():Void{
        var number = noRankWidth - 20;
        if(rank.visible){ number = rankWidth - 20; }

        scrollTween = FlxTween.num(0, text.width - number, 5, {ease: FlxEase.sineInOut, startDelay: 1, onComplete: function(t) {
            scrollEaseBack();
        }}, function(v) {
            scrollOffset = -v;
        });
    }
    
    function scrollEaseBack():Void{
        var number = noRankWidth - 20;
        if(rank.visible){ number = rankWidth - 20; }

        scrollTween = FlxTween.num(text.width - number, 0, 5, {ease: FlxEase.sineInOut, startDelay: 1, onComplete: function(t) {
            scrollEaseStart();
        }}, function(v) {
            scrollOffset = -v;
        });
    }

    public function snapToTargetPos():Void{
        x = targetPos.x + xPositionOffset;
        y = targetPos.y;
    }

    public function intendedX(index:Int):Float {
		return (270 + (60 * (Math.sin(index+1)))) + 80;
	}

    public function intendedY(index:Int):Float {
		return (((index+1) * ((height * capsuleScale) + 10)) + 120) + 18 - (index < -1 ? 100 : 0);
	}

    inline function getSparrowPathWithSkin(path:String):flixel.graphics.frames.FlxAtlasFrames{
		var image:String = path;
		if(path.contains("menu/freeplay/")){
			image = image.split("menu/freeplay/")[1];
		}
		if(Utils.exists(Paths.image("menu/freeplay/skins/" + skin + "/" + image, true))){
			path = "menu/freeplay/skins/" + skin + "/" + image;
		}
		return Paths.getSparrowAtlas(path);
	}

}