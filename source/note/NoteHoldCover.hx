package note;

import config.Config;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

using StringTools;

class NoteHoldCover extends FlxSprite{

	var coverSkin:String = "Default";

	public var noteDirection:Int = -1;
	var splashAlpha = 0.7;
	var posOffset:FlxPoint = new FlxPoint();

	var referenceSprite:FlxSprite;

	var skin:NoteHoldCoverSkinBase;

	public function new(_referenceSprite:FlxSprite, direction:Int, _coverSkin:String){

		super(0, 0);

		referenceSprite = _referenceSprite;
		coverSkin = _coverSkin;
		noteDirection = direction;

		skin = new NoteHoldCoverSkinBase(coverSkin);

		frames = Paths.getSparrowAtlas(skin.info.path);
		antialiasing = skin.info.antialiasing;
		animation.addByPrefix("start", skin.info.anims[noteDirection].start.prefix, skin.info.anims[noteDirection].start.framerateRange[0], false);
		animation.addByPrefix("hold", skin.info.anims[noteDirection].hold.prefix, skin.info.anims[noteDirection].hold.framerateRange[0], true);
		animation.addByPrefix("end", skin.info.anims[noteDirection].splash.prefix, skin.info.anims[noteDirection].splash.framerateRange[0], false);
		animation.finishCallback = callback;
		animation.play("start");

		setGraphicSize(width * skin.info.scale);
		updateHitbox();
		
		offset.set(skin.info.offset[0], skin.info.offset[1]);
		posOffset.set(skin.info.positionOffset[0], skin.info.positionOffset[1]);
		splashAlpha = skin.info.alpha;
		
		visible = false;
	}

	override function update(elapsed:Float) {
		if(referenceSprite == null){ destroy(); }
		x = referenceSprite.x + posOffset.x;
		y = referenceSprite.y + posOffset.y;
		super.update(elapsed);
	}

	public function start() {
		visible = (Config.noteSplashType == 1 || Config.noteSplashType == 2 || Config.noteSplashType == 4);
		alpha = 1;
		animation.play("start");

		if(skin.info.anims[noteDirection].start.offset != null){
			offset.set(skin.info.anims[noteDirection].start.offset[0], skin.info.anims[noteDirection].start.offset[1]);
		}
		else{
			offset.set(skin.info.offset[0], skin.info.offset[1]);
		}

		if(skin.info.anims[noteDirection].start.positionOffset != null){
			posOffset.set(skin.info.anims[noteDirection].start.positionOffset[0], skin.info.anims[noteDirection].start.positionOffset[1]);
		}
		else{
			posOffset.set(skin.info.positionOffset[0], skin.info.positionOffset[1]);
		}
	}

	public function end(playSplash:Bool) {
		visible = playSplash && (Config.noteSplashType == 1 || Config.noteSplashType == 4);
		alpha = splashAlpha;
		animation.getByName("end").frameRate = FlxG.random.int(skin.info.anims[noteDirection].splash.framerateRange[0], skin.info.anims[noteDirection].splash.framerateRange[1]);
		animation.play("end");

		if(skin.info.anims[noteDirection].splash.offset != null){
			offset.set(skin.info.anims[noteDirection].splash.offset[0], skin.info.anims[noteDirection].splash.offset[1]);
		}
		else{
			offset.set(skin.info.offset[0], skin.info.offset[1]);
		}

		if(skin.info.anims[noteDirection].splash.positionOffset != null){
			posOffset.set(skin.info.anims[noteDirection].splash.positionOffset[0], skin.info.anims[noteDirection].splash.positionOffset[1]);
		}
		else{
			posOffset.set(skin.info.positionOffset[0], skin.info.positionOffset[1]);
		}
	}

	function callback(anim:String) {
		switch(anim){
			case "start":
				animation.play("hold");

				if(skin.info.anims[noteDirection].hold.offset != null){
					offset.set(skin.info.anims[noteDirection].hold.offset[0], skin.info.anims[noteDirection].hold.offset[1]);
				}
				else{
					offset.set(skin.info.offset[0], skin.info.offset[1]);
				}

				if(skin.info.anims[noteDirection].hold.positionOffset != null){
					posOffset.set(skin.info.anims[noteDirection].hold.positionOffset[0], skin.info.anims[noteDirection].hold.positionOffset[1]);
				}
				else{
					posOffset.set(skin.info.positionOffset[0], skin.info.positionOffset[1]);
				}

			case "end":
				visible = false;
		}
	}

}