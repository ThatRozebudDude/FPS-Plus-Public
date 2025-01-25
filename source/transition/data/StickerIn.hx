package transition.data;

import openfl.Assets;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
    Remove stickers from the screen.
**/
class StickerIn extends BaseTransition{

    override public function new(){
        
        super();

    }

    override public function play(){

        if(StickerOut.stickerInfo.length > 0){
            for(i in 0...StickerOut.stickerInfo.length){
                var stickerSprite = new FlxSprite(StickerOut.stickerInfo[i].pos.x, StickerOut.stickerInfo[i].pos.y).loadGraphic(StickerOut.stickerInfo[i].image);
                stickerSprite.centerOffsets();
                stickerSprite.angle = StickerOut.stickerInfo[i].angle;
                stickerSprite.antialiasing = true;
                add(stickerSprite);

                if(i == StickerOut.stickerInfo.length-1){
                    stickerSprite.angle = 0;
                    stickerSprite.screenCenter();
                }
            }

            removeNextStickers(0);
        }
        else{
            end();
        }
    }

    function removeNextStickers(currentIndex:Int) {

        var endAfter:Bool = false;

        FlxG.sound.play(Paths.sound("stickers/keyClick" + FlxG.random.int(1, 8)));

        for(i in 0...FlxG.random.int(0, StickerOut.maxStickersPerTick)){

            remove(members[(members.length - 1) - currentIndex]);

            currentIndex++;
            if(currentIndex >= StickerOut.stickerCount){
                endAfter = true;
                break;
            }
        }

        if(endAfter){
            StickerOut.stickerInfo = [];
            end();
        }
        else{
            new FlxTimer().start(StickerOut.stickerTime, function(t) {
                removeNextStickers(currentIndex);
            });
        }
        
    }

    override public function end() {
        for(i in 1...9){ Assets.cache.removeSound(Paths.sound("stickers/keyClick" + i)); }
        super.end();
    }

}