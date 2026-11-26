package transition.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.Assets;

/**
	Cover the screen in stickers.
**/
class StickerOut extends BaseTransition{

	public static var stickerInfo:Array<StickerInfo> = [];
	public static var excludePos:Array<FlxPoint> = [];
	public static var stickerList:Array<Array<String>> = [];

	public static final STICKER_COUNT:Int = 100;
	public static final MAX_STICKERS_PER_TICK:Int = 4;
	public static final STICKER_TIME:Float = 1/48;
	public static final STICKER_DISTANCE:Float = 10;

	override public function new(?_sets:Array<String>){
		super();
		generateStickerList(_sets);
	}

	override public function play(){
		generateStickerInfo();
		addNextStickers(0);
	}

	public static function generateStickerList(?sets:Array<String>):Void{
		stickerList = [];

		if(sets == null){
			sets = Utils.readDirectory("assets/images/ui/stickers/");
		}
		else{
			sets = Tags.getTagsFromArray(sets, "stickers", true);
		}

		for(set in sets){
			stickerList.push([]);
			for(path in Utils.readDirectory("assets/images/ui/stickers/" + set + "/")){
				stickerList[stickerList.length-1].push(("ui/stickers/" + set + "/" + path).split(".png")[0]);
			}
		}
	}

	public static function generateStickerInfo():Void{
		stickerInfo = [];
		excludePos = [];
		for(i in 0...STICKER_COUNT){
			final randomCharacter:Int = FlxG.random.int(0, stickerList.length-1);
			final randomSticker:Int = FlxG.random.int(0, stickerList[randomCharacter].length-1);
			var sticker:StickerInfo = {
				image: stickerList[randomCharacter][randomSticker],
				pos: generateRandomOutSideDistance(),
				angle: FlxG.random.float(0, 360)
			}
			stickerInfo.push(sticker);
		}
	}

	function addNextStickers(currentIndex:Int) {
		var endAfter:Bool = false;

		FlxG.sound.play(Paths.sound("stickers/keyClick" + FlxG.random.int(1, 8)));

		var randomTick = FlxG.random.int(0, MAX_STICKERS_PER_TICK);

		for(i in 0...randomTick){
			var stickerSprite = new FlxSprite(stickerInfo[currentIndex].pos.x, stickerInfo[currentIndex].pos.y).loadGraphic(Paths.image(stickerInfo[currentIndex].image));
			stickerSprite.centerOffsets();
			stickerSprite.angle = stickerInfo[currentIndex].angle;
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
			if(currentIndex >= STICKER_COUNT){
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
			new FlxTimer().start(STICKER_TIME, function(t) {
				addNextStickers(currentIndex);
			});
		}
	}

	static function generateRandomOutSideDistance():FlxPoint{
		var r = new FlxPoint();

		for(i in 0...30){
			var exit:Bool = true;
			r.set(FlxG.random.int(-200, 1280), FlxG.random.int(-200, 720));
			for(x in excludePos){
				exit = !withinDistance(r, x, STICKER_DISTANCE);
				if(!exit){ break; }
			}
			if(exit){ break; }
		}

		excludePos.push(r);
		return r;
	}

	static function withinDistance(a:FlxPoint, b:FlxPoint, distance:Float):Bool{
		return (Math.abs(a.x - b.x) <= distance) || (Math.abs(a.y - b.y) <= distance);
	}

	override public function end() {
		for(i in 1...9){ Assets.cache.removeSound(Paths.sound("stickers/keyClick" + i)); }
		super.end();
	}

}


typedef StickerInfo = {
	image:String,
	pos:FlxPoint,
	angle:Float
}