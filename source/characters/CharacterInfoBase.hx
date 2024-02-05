package characters;

import flixel.math.FlxPoint;
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
	var loop:Bool;
	var flipX:Bool;
	var flipY:Bool;
	var offset:Array<Float>;
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
}

class CharacterInfoBase
{

    public var info:CharacterInfo;

    public function new() {
        info = {
            name: "",
            spritePath: "",
            frameLoadType: sparrow,
            iconName: "",
            deathCharacter: "",
            healthColor: null,
            facesLeft: false,
            hasLeftAndRightIdle: false,
            antialiasing: true,
            anims: []
        };
    }

    inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
        return [_x, _y];
    }

    function add(_name:String, _offset:Array<Float>, _frames:Array<Int>, _frameRate:Float = 30.0, _looped:Bool = true, _flipX:Bool = false, _flipY:Bool = false):Void{
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

    function addByPrefix(_name:String, _offset:Array<Float>, _prefix:String, _frameRate:Float = 30.0, _looped:Bool = true, _flipX:Bool = false, _flipY:Bool = false):Void{
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

    function addByIndecies(_name:String, _offset:Array<Float>, _prefix:String, _indices:Array<Int>, _postfix:String, _frameRate:Float = 30, _looped:Bool = true, _flipX:Bool = false, _flipY:Bool = false):Void{
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

}