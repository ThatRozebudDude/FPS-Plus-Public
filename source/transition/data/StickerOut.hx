package transition.data;

import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import sys.FileSystem;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
    Cover the screen in stickers.
**/
class StickerOut extends BaseTransition{

    public static var stickerInfo:Array<StickerInfo> = [];

    var stickerList:Array<String> = [];
    var excludePos:Array<FlxPoint> = [];

    public static final stickerCount:Int = 100;
    public static final maxStickersPerTick:Int = 4;
    public static final stickerTime:Float = 1/48;
    public static final stickerDistance:Float = 10;

    override public function new(?_sets:Array<String>){
        
        super();

        if(_sets == null){ 
            _sets = Utils.readDirectory("assets/images/ui/stickers/"); 
        }

        for(set in _sets){
            for(path in Utils.readDirectory("assets/images/ui/stickers/" + set + "/")){
                stickerList.push("assets/images/ui/stickers/" + set + "/" + path);
            }
        }

    }

    override public function play(){

        for(i in 0...stickerCount){
            var sticker:StickerInfo = {
                image: stickerList[FlxG.random.int(0, stickerList.length-1)],
                pos: generateRandomOutSideDistance(),
                angle: FlxG.random.float(0, 360)
            }
            stickerInfo.push(sticker);
        }

        addNextStickers(0);
    }

    function addNextStickers(currentIndex:Int) {

        var endAfter:Bool = false;

        FlxG.sound.play(Paths.sound("stickers/keyClick" + FlxG.random.int(1, 8)));

        var randomTick = FlxG.random.int(0, maxStickersPerTick);

        for(i in 0...randomTick){
            var stickerSprite = new FlxSprite(stickerInfo[currentIndex].pos.x, stickerInfo[currentIndex].pos.y).loadGraphic(stickerInfo[currentIndex].image);
            stickerSprite.centerOffsets();
            stickerSprite.angle = stickerInfo[currentIndex].angle;
            stickerSprite.antialiasing = true;
            add(stickerSprite);

            if(i == randomTick-1){
                var randomScale = FlxG.random.float(0.95, 1.05);
                stickerSprite.scale.set(randomScale, randomScale);
            }

            if(currentIndex == stickerInfo.length-1){
                stickerSprite.scale.set(1.1, 1.1);
                stickerSprite.angle = 0;
                stickerSprite.screenCenter();
            }

            FlxTween.tween(stickerSprite.scale, {x: 1, y: 1}, 2/24);
            
            currentIndex++;
            if(currentIndex >= stickerCount){
                endAfter = true;
                break;
            }
        }

        if(endAfter){
            new FlxTimer().start(0.5, function(t) {
                end();
            });
        }
        else{
            new FlxTimer().start(stickerTime, function(t) {
                addNextStickers(currentIndex);
            });
        }
        
    }

    function generateRandomOutSideDistance():FlxPoint{

        var r = new FlxPoint();

        for(i in 0...30){
            var exit:Bool = true;
            r.set(FlxG.random.int(-200, 1280), FlxG.random.int(-200, 720));
            for(x in excludePos){
                exit = !withinDistance(r, x, stickerDistance);
                if(!exit){ break; }
            }
            if(exit){ break; }
        }

        excludePos.push(r);
        return r;
    }

    function withinDistance(a:FlxPoint, b:FlxPoint, distance:Float):Bool{
        return (Math.abs(a.x - b.x) <= distance) || (Math.abs(a.y - b.y) <= distance);
    }

}


typedef StickerInfo = {
    image:String,
    pos:FlxPoint,
    angle:Float
}