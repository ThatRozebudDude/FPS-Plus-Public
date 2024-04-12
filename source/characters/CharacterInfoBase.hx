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

    inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
        return [_x, _y];
    }

    inline function loop(_loop:Bool, ?_frame:Int = 0):LoopData{
        return {looped: _loop, loopPoint: _frame};
    }

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

    function addExtraData(key:String, data:Dynamic):Void{
        if(info.extraData == null){
            info.extraData = new Map<String, Dynamic>();
        }
        info.extraData.set(key, data);
    }

}