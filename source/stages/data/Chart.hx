package stages.data;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class Chart extends BaseStage
{

	var chartBlackBG:FlxSprite;

    public override function init(){
        name = "chart";

		if(PlayState.fceForLilBuddies){
			startingZoom = 1;
			var chartBg = new FlxSprite().loadGraphic(debug.ChartingState.screenshotBitmap.bitmapData);
			chartBg.antialiasing = true;

			if(chartBg.width != 1280 || chartBg.height != 720){
				if(chartBg.width/1280 < chartBg.height/720){
					var newScale = 1280 / chartBg.width;
					chartBg.setGraphicSize(1280, newScale * chartBg.height);
					chartBg.updateHitbox();
					chartBg.y -= (chartBg.height - 720)/2;
				}
				else{
					var newScale = 720 / chartBg.height;
					chartBg.setGraphicSize(newScale * chartBg.width, 720);
					chartBg.updateHitbox();
					chartBg.x -= (chartBg.width - 1280)/2;
				}
			}

			addToBackground(chartBg);

			debug.ChartingState.screenshotBitmap = null;

			chartBlackBG = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF000000);
			chartBlackBG.alpha = 0;
			addToBackground(chartBlackBG);
		}
		else{
			startingZoom = 2.8;
		}

		var blackBGThing = new FlxSprite(32, 432).makeGraphic(280, 256, 0xFF000000);
		addToBackground(blackBGThing);

		var lilStage = new FlxSprite(32, 432).loadGraphic(Paths.image("chartEditor/lilStage"));
		addToBackground(lilStage);

		gf().visible = false;
		boyfriend().setPosition(32, 432);
		dad().setPosition(32, 432);

		useStartPoints = false;

		cameraMovementEnabled = false;
		extraCameraMovementAmount = 0;

		if(PlayState.fceForLilBuddies){
			cameraStartPosition = new FlxPoint(1280/2, 720/2);
		}
		else{
			cameraStartPosition = new FlxPoint(155, 600);
		}

    }

	public override function beat(curBeat){
		if(PlayState.fceForLilBuddies && curBeat == 0){
			FlxTween.tween(chartBlackBG, {alpha: 1}, Conductor.crochet / 1000 * 16);
		}
	}
}