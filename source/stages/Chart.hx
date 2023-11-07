package stages;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class Chart extends BasicStage
{

	var chartBlackBG:FlxSprite;

    public override function init(){
        name = 'chart';

		if(PlayState.fromChartEditor){
			startingZoom = 1;
			var chartBg = new FlxSprite().loadGraphic(ChartingState.screenshotBitmap.bitmapData);
			chartBg.antialiasing = true;
			addToBackground(chartBg);

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

		cameraMovementEnabled = false;
		extraCameraMovementAmount = 0;

		if(PlayState.fromChartEditor){
			cameraStartPosition = new FlxPoint(1280/2, 720/2);
		}
		else{
			cameraStartPosition = new FlxPoint(155, 600);
		}

    }

	public override function beat(curBeat){
		if(PlayState.fromChartEditor && curBeat == 0){
			FlxTween.tween(chartBlackBG, {alpha: 1}, Conductor.crochet / 1000 * 16);
		}
	}

	/*public function blackBGFade(){
		FlxTween.tween(chartBlackBG, {alpha: 1}, Conductor.crochet / 1000 * 16);
	}*/
}