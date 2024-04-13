package characters;

import flixel.util.FlxColor;

enum AnimType {
    prefix;
    frames;
    indices;
}

enum FrameLoadType {
    sparrow;
    packer;
    load(frameWidth:Int, frameHeight:Int);
}

typedef AnimInfo = {
    var name:String;
	var type:AnimType;
    var data:AnimData;
}

typedef AnimData = {
	var prefix:String;
	var frames:Array<Int>;
	var postfix:String;
	var framerate:Float;
	var loop:LoopData;
	var flipX:Bool;
	var flipY:Bool;
	var offset:Array<Float>;
}

typedef LoopData = {
	var looped:Bool;
	var loopPoint:Int;
}

typedef CharacterInfo = {
	var name:String;
    var spritePath:String;
    var frameLoadType:FrameLoadType;
    var iconName:String;
    var deathCharacter:String;
    var healthColor:Null<FlxColor>;
    var facesLeft:Bool;
    var hasLeftAndRightIdle:Bool;
    var antialiasing:Bool;
    var anims:Array<AnimInfo>;
    var extraData:Map<String, Dynamic>;
}

/*  
*   NOTE ABOUT CHARACTER METADATA
*   To exclude characters from the character list add the metadata @charList(false) to the class. If this is not included it is interpreted as true.
*   To include characters in the GF list add the metadata @gfList(true) to the class. If this is not included it is interpreted as false.
*   You can use @charList(false) and @gfList(false) to hide the character from both lists.
*/  

/**
	This is the base class for character info. When making your own character make a new class extending this one.    
	@author Rozebud
**/
class CharacterInfoBase
{

    public var info:CharacterInfo;

    public function new() {
        info = {
            name: "",
            spritePath: "",
            frameLoadType: sparrow,
            iconName: "face",
            deathCharacter: "Bf",
            healthColor: null,
            facesLeft: false,
            hasLeftAndRightIdle: false,
            antialiasing: true,
            anims: [],
            extraData: null
        };
    }

    /**
	 * Generates the x and y offsets for an animation.
	 *
	 * @param   _x  The x offset of the animation.
	 * @param   _y  The y offset of the animation.
	 */
    inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
        return [_x, _y];
    }

    /**
	 * Generates the loop data for an animation.
	 *
	 * @param   _loop   Whether the animation loops or not.
	 * @param   _frame  The frame the animation goes to when looping. Note: positive values are the absolute frame, negative values are subtracted from the end of the animation.
	 */
    inline function loop(_loop:Bool, ?_frame:Int = 0):LoopData{
        return {looped: _loop, loopPoint: _frame};
    }

    /**
	 * Adds a new animation to the sprite.
	 *
	 * @param   _name       What this animation should be called (e.g. `"run"`).
	 * @param   _offset     The visual offset of the animation. Use `offset()` to generate the data.
	 * @param   _frames     An array of indices indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param   _frameRate  The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   _looped     Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 * @param   _flipX      Whether the frames should be flipped horizontally.
	 * @param   _flipY      Whether the frames should be flipped vertically.
	 */
    function add(_name:String, _offset:Array<Float>, _frames:Array<Int>, _frameRate:Float = 30.0, _looped:LoopData = null, _flipX:Bool = false, _flipY:Bool = false):Void{

        if(_looped == null){
            _looped = loop(true);
        }

        var animData:AnimData = {
            prefix: null,
            frames: _frames,
            postfix: null,
            framerate: _frameRate,
            loop: _looped,
            flipX: _flipX,
            flipY: _flipY,
            offset: _offset
        }
        var animInfo:AnimInfo = {
            name: _name,
            type: frames,
            data: animData
        }
        info.anims.push(animInfo);
    }

    /**
	 * Adds a new animation to the sprite.
	 *
	 * @param   _name       What this animation should be called (e.g. `"run"`).
	 * @param   _offset     The visual offset of the animation. Use `offset()` to generate the data.
	 * @param   _prefix     Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @param   _frameRate  The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   _looped     Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 * @param   _flipX      Whether the frames should be flipped horizontally.
	 * @param   _flipY      Whether the frames should be flipped vertically.
	 */
    function addByPrefix(_name:String, _offset:Array<Float>, _prefix:String, _frameRate:Float = 30.0, _looped:LoopData = null, _flipX:Bool = false, _flipY:Bool = false):Void{

        if(_looped == null){
            _looped = loop(true);
        }

        var animData:AnimData = {
            prefix: _prefix,
            frames: null,
            postfix: null,
            framerate: _frameRate,
            loop: _looped,
            flipX: _flipX,
            flipY: _flipY,
            offset: _offset
        }
        var animInfo:AnimInfo = {
            name: _name,
            type: prefix,
            data: animData
        }
        info.anims.push(animInfo);
    }

    /**
	 * Adds a new animation to the sprite.
	 *
	 * @param   _name       What this animation should be called (e.g. `"run"`).
	 * @param   _offset     The visual offset of the animation. Use `offset()` to generate the data.
	 * @param   _prefix     Common beginning of image names in the atlas (e.g. "tiles-").
	 * @param   _indices    An array of numbers indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param   _postfix    Common ending of image names in the atlas (e.g. `".png"`).
	 * @param   _frameRate  The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   _looped     Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 * @param   _flipX      Whether the frames should be flipped horizontally.
	 * @param   _flipY      Whether the frames should be flipped vertically.
	 */
    function addByIndices(_name:String, _offset:Array<Float>, _prefix:String, _indices:Array<Int>, _postfix:String, _frameRate:Float = 30, _looped:LoopData = null, _flipX:Bool = false, _flipY:Bool = false):Void{

        if(_looped == null){
            _looped = loop(true);
        }

        var animData:AnimData = {
            prefix: _prefix,
            frames: _indices,
            postfix: _postfix,
            framerate: _frameRate,
            loop: _looped,
            flipX: _flipX,
            flipY: _flipY,
            offset: _offset
        }
        var animInfo:AnimInfo = {
            name: _name,
            type: indices,
            data: animData
        }
        info.anims.push(animInfo);
    }

    /**
	 * Adds arbitrary data to the character that can be defined in `Character.hx`
	 *
	 * @param   key     The name that will be used to identify the data.
	 * @param   data    The data.
	 */
    function addExtraData(key:String, data:Dynamic):Void{
        if(info.extraData == null){
            info.extraData = new Map<String, Dynamic>();
        }
        info.extraData.set(key, data);
    }

}