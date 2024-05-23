package freeplay;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextBorderStyle;
import extensions.flixel.FlxTextExt;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Capsule extends FlxSpriteGroup
{

    final capsuleScale:Float = 0.8;

    final selectColor:FlxColor = 0xFFFFFFFF;
    final deselectColor:FlxColor = 0xFF969A9D;
    final selectBorderColor:FlxColor = 0xFF6B9FBA;
    final deselectBorderColor:FlxColor = 0xFF3E508C;

    var capsule:FlxSprite;
    var icon:FlxSprite;
    var text:FlxTextExt;
    public var song:String;
    public var album:String;
    public var week:Int;

    public var targetPos:FlxPoint = new FlxPoint();
    public var xPositionOffset:Float = 0;
    public var selected:Bool = true;

    public function new(_song:String, _displayName:String, _icon:String, _week:Int, ?_album:String = "vol1") {
        super();

        song = _song;
        week = _week;
        album = _album;

        capsule = new FlxSprite();
        capsule.frames = Paths.getSparrowAtlas("menu/freeplay/freeplayCapsule");
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

        var iconXOffset:Float = 0;
        switch(_icon){
            case "parents-christmas":
                iconXOffset = -24;
        }
        icon = new FlxSprite(iconXOffset, 0).loadGraphic(Paths.image("menu/freeplay/icons/" + _icon));
        icon.origin.set(0, 0);
        icon.scale.set(2, 2);

        add(capsule);
        add(text);
        add(icon);

        deslect();

    }

    override function update(elapsed:Float) {
        x = Utils.fpsAdjsutedLerp(x, targetPos.x, 0.3) + xPositionOffset;
        y = Utils.fpsAdjsutedLerp(y, targetPos.y, 0.4);

        super.update(elapsed);
    }

    public function select():Void{
        if(selected){ return; }
        capsule.animation.play("selected", true);
        text.color = selectColor;
        text.borderColor = selectBorderColor;
        selected = true;
    }

    public function deslect():Void{
        if(!selected){ return; }
        capsule.animation.play("deslected", true);
        text.color = deselectColor;
        text.borderColor = deselectBorderColor;
        selected = false;
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

}