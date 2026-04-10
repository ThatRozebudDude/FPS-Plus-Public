package title;

import transition.data.InstantTransition;
import extensions.flixel.FlxUIStateExt;
import config.Config;
import flixel.FlxG;
import flixel.util.FlxColor;

using StringTools;

@:hscriptClass
class ScriptedTitleVideo extends TitleVideo implements polymod.hscript.HScriptedClass{}

class TitleVideo extends FlxUIStateExt
{
	var oldFPS:Int = VideoHandler.MAX_FPS;
	var video:VideoHandler;
	var titleState = new TitleScreen();

	override public function create():Void{

		customTransIn = new InstantTransition();
		customTransOut = new InstantTransition();

		super.create();

		if(!Main.novid){
			VideoHandler.MAX_FPS = 60;

			video = new VideoHandler();
			video.playMP4(Paths.video("klaskiiTitle"), function(){
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
		FlxG.switchState(titleState);
	}
	
}
