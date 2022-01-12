package transition.data;

import openfl.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
    The base class for state transitions.
**/
class BasicTransition extends FlxSpriteGroup{

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
        if(state != null){
            FlxG.switchState(state);
            System.gc();
        }
        else{
            this.destroy();
        }
    }

}