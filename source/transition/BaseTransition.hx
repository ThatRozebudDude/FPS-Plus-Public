package transition;

import caching.*;
import extensions.flixel.FlxUIStateExt;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
	The base class for state transitions.
**/
class BaseTransition extends FlxSpriteGroup{

	public var state:FlxState = null;

	/**
		Just a standard constructor.
		
		For custom animations, `super()` should be called at the top of the constructor.
	**/
	override public function new(){
		super();
	}

	/**
		Override this function to create the actual animated parts.
			
		For custom animations, a `super()` call is not needed.
	**/
	public function play(){
		end();
	}

	/**
		Function that should be called after the animation is done. 

		This shouldn't need to be overrided, but you can for whatever edge case you might have.
	**/
	public function end(){
		FlxUIStateExt.inTransition = false;
		
		if(state != null){ //State exit animation.
			//FlxG.signals.postStateSwitch.addOnce(Utils.gc);
			FlxG.signals.preStateCreate.addOnce(function(state){
				if(!ImageCache.keepCache){
					ImageCache.clear();
					AudioCache.clear();
				}
				ImageCache.keepCache = false; // Make sure to set this to false to avoid clutter
				Utils.gc();
			});

			FlxG.switchState(state);
		}
		else{ //State intro animation.
			FlxG.signals.postUpdate.addOnce(Utils.gc);
			FlxG.cameras.remove(cameras[0], true);
			this.destroy();
		}
	}

}