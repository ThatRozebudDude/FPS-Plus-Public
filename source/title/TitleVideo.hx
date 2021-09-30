package title;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

using StringTools;

class TitleVideo extends FlxState
{

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var oldFPS:Int = VideoHandler.MAX_FPS;

	var video:VideoHandler;

	override public function create():Void
	{

		super.create();

		FlxG.sound.cache(Paths.music("klaskiiLoop"));

		if(!Main.novid){

			VideoHandler.MAX_FPS = 60;

			video = new VideoHandler();

			video.playMP4(Paths.video('klaskiiTitle'), function(){
				FlxG.camera.flash(FlxColor.WHITE, 60);
				FlxG.sound.playMusic(Paths.music("klaskiiLoop"), 0.75);
				Conductor.changeBPM(158);
				FlxG.switchState(new TitleScreen());
				#if web
					VideoHandler.MAX_FPS = oldFPS;
				#end
			}, false, true);

			add(video);
			
		}
		else{
			FlxG.camera.flash(FlxColor.WHITE, 60);
			FlxG.sound.playMusic(Paths.music("klaskiiLoop"), 0.75);
			Conductor.changeBPM(158);
			FlxG.switchState(new TitleScreen());
		}
	}

	override public function update(elapsed:Float){

		super.update(elapsed);

	}
	
}
