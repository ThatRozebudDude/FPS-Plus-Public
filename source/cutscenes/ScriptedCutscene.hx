package cutscenes;

import PlayState.VocalType;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxBasic;

@:build(modding.GlobalScriptingTypesMacro.build())
class ScriptedCutscene extends FlxBasic
{

	public var totalTime:Float = 0;

	public var started(get, never):Bool;
	var __started:Bool = false;

	public var events:Array<Array<Dynamic>> = [];

	public function new(args:Array<Dynamic>){ super(); }

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(__started){
			if(events.length > 0){
				totalTime += elapsed;
			}
			else{
				Utils.destroyWhenAvailable(this);
			}
			
			for(event in events){
				if(event[0] > totalTime){ break; }
				else{
					if(event[1] != null){
						event[1]();
					}
					events.remove(event);
				}
			}
		} 
	}

	/**
	 * Starts the cutscene.
	 */
	public function start():Void{
		for(event in events){
			if(event[0] > 0){ break; }
			else{
				if(event[1] != null){
					event[1]();
				}
				events.remove(event);
			}
		}
		__started = true;
	}

	/**
	 * Adds an event that will be processed once the cutscene is started.
	 *
	 * @param   _time		The time in seconds that the event will occur at.
	 * @param   _function	The function that will be run when the event is called.
	 */
	public function addEvent(_time:Float, _function:Void->Void):Void{
		events.push([_time, _function]);
		events.sort((a, b) -> { Utils.sign(a[0] - b[0]); });
	}

	/**
	 * Adds an object to the background element layer in PlayState.
	**/
	public function addToBackgroundLayer(x:FlxBasic):Void{
		PlayState.instance.backgroundLayer.add(x);
	}

	/**
	 * Removes an object from the background element layer in PlayState.
	**/
	public function removeFromBackgroundLayer(x:FlxBasic):Void{
		PlayState.instance.backgroundLayer.remove(x);
	}

	/**
	 * Adds an object to the girlfriend layer in PlayState.
	**/
	public function addToGfLayer(x:FlxBasic):Void{
		PlayState.instance.gfLayer.add(x);
	}

	/**
	 * Removes an object from the girlfriend layer in PlayState.
	**/
	public function removeFromGfLayer(x:FlxBasic):Void{
		PlayState.instance.gfLayer.remove(x);
	}

	/**
	 * Adds an object to the middle element layer in PlayState.
	**/
	public function addToMiddleLayer(x:FlxBasic):Void{
		PlayState.instance.middleLayer.add(x);
	}

	/**
	 * Removes an object from the middle element layer in PlayState.
	**/
	public function removeFromMiddleLayer(x:FlxBasic):Void{
		PlayState.instance.middleLayer.remove(x);
	}

	/**
	 * Adds an object to the character layer in PlayState.
	**/
	public function addToCharacterLayer(x:FlxBasic):Void{
		PlayState.instance.characterLayer.add(x);
	}

	/**
	 * Removes an object from the character layer in PlayState.
	**/
	public function removeFromCharacterLayer(x:FlxBasic):Void{
		PlayState.instance.characterLayer.remove(x);
	}

	/**
	 * Adds an object to the foreground element layer in PlayState.
	**/
	public function addToForegroundLayer(x:FlxBasic):Void{
		PlayState.instance.foregroundLayer.add(x);
	}

	/**
	 * Removes an object from the foreground element layer in PlayState.
	**/
	public function removeFromForegroundLayer(x:FlxBasic):Void{
		PlayState.instance.foregroundLayer.remove(x);
	}

	/**
	 * Adds an object from the overlay element layer in PlayState.
	**/
	public function addToOverlayLayer(x:FlxBasic):Void{
		PlayState.instance.overlayLayer.add(x);
	}

	/**
	 * Removes an object from the overlay element layer in PlayState.
	**/
	public function removeFromOverlayLayer(x:FlxBasic):Void{
		PlayState.instance.overlayLayer.remove(x);
	}

	/**
	 * Adds an object from the HUD element layer in PlayState.
	**/
	public function addToHudLayer(x:FlxBasic):Void{
		PlayState.instance.hudLayer.add(x);
	}

	/**
	 * Removes an object from the HUD element layer in PlayState.
	**/
	public function removeHudLayer(x:FlxBasic):Void{
		PlayState.instance.hudLayer.remove(x);
	}

	/**
	 * Adds an object to the current state.
	**/
	public function addGeneric(x:FlxBasic):Void{
		FlxG.state.add(x);
	}

	/**
	 * Removes an object from the current state.
	**/
	public function removeGeneric(x:FlxBasic):Void{
		FlxG.state.remove(x);
	}

	/**
	 * Adds an object to the current substate.
	**/
	public function addGenericSubstate(x:FlxBasic):Void{
		FlxG.state.subState.add(x);
	}

	/**
	 * Removes an object from the current substate.
	**/
	public function removeGenericSubstate(x:FlxBasic):Void{
		FlxG.state.subState.remove(x);
	}

	public function next(?doCamFadeIn:Bool = true):Void{
		if(PlayState.instance.inEndingCutscene){ PlayState.instance.endSong(); }
		else{
			if(!playstate.stage.instantStart){
				PlayState.instance.startCountdown();
			}
			else{
				PlayState.instance.instantStart();
			}
			if(doCamFadeIn){
				fadeInHud();
			}
		}  
	}

	public function focusCameraBasedOnFirstSection(_time:Float = 1.9, _ease:Null<flixel.tweens.EaseFunction>):Void{
		if(_ease == null){_ease = FlxEase.expoOut;}
		if(PlayState.SONG.notes[0].mustHitSection){ PlayState.instance.camFocusBF(0, 0, _time, _ease); }
		else{ PlayState.instance.camFocusOpponent(0, 0, _time, _ease); }
	}

	public function fadeInHud():Void{
		tween.cancelTweensOf(playstate.hudShader);
		playstate.hudShader.alpha = 0;
		tween.tween(playstate.hudShader, {alpha: 1}, 0.3);
	}

	public function fadeOutHud():Void{
		tween.cancelTweensOf(playstate.hudShader);
		playstate.hudShader.alpha = 1;
		tween.tween(playstate.hudShader, {alpha: 0}, 0.3);
	}

	function get_started():Bool{ return __started; }
}