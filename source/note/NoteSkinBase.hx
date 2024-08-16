package note;

import note.Note;
import flixel.math.FlxPoint;
import characters.CharacterInfoBase.FrameLoadType;
import characters.CharacterInfoBase.AnimData;
import characters.CharacterInfoBase.AnimType;

typedef NoteInfo = {
    var pathOverride:String;
    var frameLoadTypeOverride:FrameLoadType;
    var scrollAnim:NoteAnimInfo;
    var glowAnim:NoteAnimInfo;
}

typedef SustainInfo = {
    var pathOverride:String;
    var frameLoadTypeOverride:FrameLoadType;
    var holdAnim:NoteAnimInfo;
    var endAnim:NoteAnimInfo;
}

typedef NoteAnimInfo = {
    var type:AnimType;
    var data:AnimData;
}

typedef NoteSkinInfo = {
    var path:String;
    var frameLoadType:FrameLoadType;
    
    var noteInfoList:Array<NoteInfo>;
    var sustainInfoList:Array<SustainInfo>;

    var functions:NoteFuncions;

    var canGlow:Bool;
    var scale:Float;
    var holdScaleAdjust:Float;
    var antialiasing:Bool;
    var offset:FlxPoint;
}

typedef NoteFuncions = {
	var create:(Note)->Void;               //This function is run after the Character new() function is complete.
	var update:(Note, Float)->Void;        //This function is run every frame. Float is elapsed.
}

class NoteSkinBase
{

    public var info:NoteSkinInfo;

    public function new(){
        info = {
            path: null,
            frameLoadType: null,

            noteInfoList: [
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    scrollAnim: null,
                    glowAnim: null
                },
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    scrollAnim: null,
                    glowAnim: null
                },
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    scrollAnim: null,
                    glowAnim: null
                },
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    scrollAnim: null,
                    glowAnim: null
                }
            ],

            sustainInfoList: [
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    holdAnim: null,
                    endAnim: null
                },
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    holdAnim: null,
                    endAnim: null
                },
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    holdAnim: null,
                    endAnim: null
                },
                {
                    pathOverride: null,
                    frameLoadTypeOverride: null,
                    holdAnim: null,
                    endAnim: null
                }
            ],

            functions: {
                create: null,
                update: null,
            },

            canGlow: true,
            scale: 0.7,
            holdScaleAdjust: 1,
            antialiasing: true,
            offset: new FlxPoint()
        };
    }



    function setScrollAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.noteInfoList[_direction].scrollAnim = {
            type: prefix,
            data: {
                prefix: _prefix,
                frames: null,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setScrollAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.noteInfoList[_direction].scrollAnim = {
            type: frames,
            data: {
                prefix: null,
                frames: _frames,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setGlowAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.noteInfoList[_direction].glowAnim = {
            type: prefix,
            data: {
                prefix: _prefix,
                frames: null,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setGlowAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.noteInfoList[_direction].glowAnim = {
            type: frames,
            data: {
                prefix: null,
                frames: _frames,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setHoldAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.sustainInfoList[_direction].holdAnim = {
            type: prefix,
            data: {
                prefix: _prefix,
                frames: null,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setHoldAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.sustainInfoList[_direction].holdAnim = {
            type: frames,
            data: {
                prefix: null,
                frames: _frames,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setEndAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.sustainInfoList[_direction].endAnim = {
            type: prefix,
            data: {
                prefix: _prefix,
                frames: null,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }

    function setEndAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 0, _flipX:Bool = false, _flipY:Bool = false):Void{
        info.sustainInfoList[_direction].endAnim = {
            type: frames,
            data: {
                prefix: null,
                frames: _frames,
                postfix: null,
                framerate: _framerate,
                loop: null,
                flipX: _flipX,
                flipY: _flipY,
                offset: null
            }
        };
    }



    inline function noteInfo(direction:Int):NoteInfo{
        return info.noteInfoList[direction];
    }

    inline function sustainInfo(direction:Int):SustainInfo{
        return info.sustainInfoList[direction];
    }

    var left(get, never):Int;
    @:noCompletion inline function get_left()   { return 0; }
    var down(get, never):Int;
    @:noCompletion inline function get_down()   { return 1; }
    var up(get, never):Int;
    @:noCompletion inline function get_up()     { return 2; }
    var right(get, never):Int;
    @:noCompletion inline function get_right()  { return 3; }

}