package menus.title;

import config.Config;
import extensions.flixel.FlxUIStateExt;
import flixel.FlxG;
import graphics.VideoHandler;
import menus.mainMenu.MainMenuState;
import transition.data.InstantTransition;

using StringTools;

class TitleVideo extends FlxUIStateExt
{
	var oldFPS:Int = VideoHandler.MAX_FPS;
	var video:VideoHandler;
	var titleState = new TitleScreen();

	override public function create():Void{

		customTransIn = new InstantTransition();
		customTransOut = new InstantTransition();

		super.create();

		if(!Main.launchArguments.no_vid){
			VideoHandler.MAX_FPS = 60;

			video = new VideoHandler();
			video.playMP4(Paths.video("intro"), function(){
				next();
				#if web
				VideoHandler.MAX_FPS = oldFPS;
				#end
			}, false);

			add(video);
		}
		else{
			next();
		}
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		FlxG.mouse.visible = false;

		if(Binds.justPressed("menuAccept")){
			video.skip();
		}
	}

	function next():Void{
		if(Config.flashingLights){
			FlxG.camera.flash(0xFFFFFFFF, 60);
		}
		else{
			FlxG.camera.flash(0xFF000000, 60);
		}

		MainMenuState.playMenuMusic();
		switchState(titleState);
	}
	
}
