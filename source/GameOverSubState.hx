package;

import extensions.flixel.FlxCameraExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubState extends BaseGameOverSubState
{
	public var bf:Character;
	public var camFollow:FlxObject;

	var cameraPanDelayTimer:FlxTimer;

	var bfX:Float; 
	var bfY:Float;
	var bfChar:String;

	public var camGameOver:FlxCameraExt;

	public function new(_x:Float, _y:Float, camX:Float, camY:Float, camZoom:Float, character:String){
		super();

		camGameOver = new FlxCameraExt();
		camGameOver.zoom = camZoom;
		camGameOver.filters = [];
		FlxG.cameras.add(camGameOver, false);
		cameras = [camGameOver];

		bfChar = character;

		bfX = _x;
		bfY = _y;

		Conductor.songPosition = 0;

		camFollow = new FlxObject(camX, camY, 1, 1);
		add(camFollow);

		camGameOver.follow(camFollow, LOCKON);
	}

	override function create(){
		bf = new Character(bfX, bfY, bfChar, true);
		if(bf.characterInfo.info.functions.deathCreate != null){
			bf.characterInfo.info.functions.deathCreate(bf);
		}
		add(bf);
		if(bf.characterInfo.info.functions.deathAdd != null){
			bf.characterInfo.info.functions.deathAdd(bf);
		}
		bf.repositionDeath();
		bf.playAnim("firstDeath", true);
		
		cameraPanDelayTimer = new FlxTimer().start(bf.deathDelay, function(t) {
			FlxTween.tween(camFollow, {x: bf.getMidpoint().x + bf.deathOffset.x, y: bf.getMidpoint().y + bf.deathOffset.y}, 3, {ease: FlxEase.expoOut});
		});
		
		if(bf.deathSound != null){
			FlxG.sound.play(Paths.sound(bf.deathSound));
		}
		
		super.create();
	}

	override function update(elapsed:Float){
		if(Binds.justPressed("menuAccept") && !isEnding){
			endBullshit();
		}

		if(Binds.justPressed("menuBack") && !isEnding){
			FlxG.sound.music.stop();
			isEnding = true;
			FlxG.sound.play(Paths.sound("cancelMenu"));

			PlayState.instance.returnToMenu();

			camGameOver.fade(FlxColor.BLACK, 0.1, false);	
		}

		if(bf.curAnim == "firstDeath" && bf.curAnimFinished() && !isEnding){
			bf.playAnim("deathLoop");

			if(bf.deathSong != null){
				FlxG.sound.playMusic(Paths.music(bf.deathSong));
			}

			loop();
		}

		if(FlxG.sound.music.playing){
			Conductor.songPosition = FlxG.sound.music.time;
		}

		super.update(elapsed);
	}

	override function beatHit(){
		super.beatHit();
	}

	var isEnding:Bool = false;

	function endBullshit():Void{
		var songEnd:FlxSound;

		isEnding = true;
		bf.playAnim("deathConfirm", true);
		FlxG.sound.music.stop();
		if(bf.deathSongEnd != null){
			songEnd = FlxG.sound.play(Paths.music(bf.deathSongEnd));
		}

		end();

		new FlxTimer().start(0.6, function(tmr:FlxTimer){
			camGameOver.fade(FlxColor.BLACK, 1, false, function(){
				if(songEnd != null && songEnd.playing){ songEnd.fadeOut(0.5); }
				restartSong();
			});
		});
	}
}

@:build(modding.GlobalScriptingTypesMacro.build())
class BaseGameOverSubState extends MusicBeatSubState
{

	public static var instance:BaseGameOverSubState;

	public function new(){
		instance = this;
		super();
	}

	override function create(){
		for(script in PlayState.instance.scripts){ script.gameOverStart(); }
		super.create();
	}

	override function update(elapsed:Float){
		for(script in PlayState.instance.scripts){ script.gameOverUpdate(elapsed); }
		super.update(elapsed);
	}

	override function destroy(){
		instance = null;
		super.destroy();
	}

	function loop():Void{
		for(script in PlayState.instance.scripts){ script.gameOverLoop(); }
	}
	
	function end():Void{
		for(script in PlayState.instance.scripts){ script.gameOverEnd(); }
	}

	function restartSong():Void{
		PlayState.instance.keepFromChartEditor = true;
		PlayState.replayStartCutscene = false;
		if(PlayState.instance.instSong != null){
			PlayState.overrideInsturmental = PlayState.instance.instSong;
		}
		PlayState.instance.switchState(new PlayState());
	}

	function exitToMenu():Void{
		PlayState.sectionStart = false;
		PlayState.instance.returnToMenu();
	}

}

@:hscriptClass
class ScriptableGameOverSubState extends BaseGameOverSubState implements polymod.hscript.HScriptedClass{}