package ui;

import characters.CharacterInfoBase.FrameLoadType;
import note.NoteSkinBase.NoteAnimInfo;
import flixel.math.FlxPoint;

typedef AllArrowsInfo = {
    var notePath:String;
    var noteFrameLoadType:FrameLoadType;
    var arrowInfo:Array<StaticArrowGraphicInfo>;
    var scale:Float;
    var anitaliasing:Bool;

    var splashClass:String;
    var coverPath:String;
}

typedef StaticArrowGraphicInfo = {
    var staticInfo:NoteAnimInfo;
    var pressedInfo:NoteAnimInfo;
    var confrimedInfo:NoteAnimInfo;
}

typedef HudNoteSkinInfo = {
    var notes:AllArrowsInfo;
    var opponentNotes:AllArrowsInfo;
}

class HudNoteSkinBase{

    public var info:HudNoteSkinInfo;

    public function new(){
        
        info = {
            notes: {
                notePath: null,
                noteFrameLoadType: null,
                scale: 1,
                anitaliasing: true,
                splashClass: null,
                coverPath: null,
                arrowInfo:[
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    },
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    },
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    },
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    }
                ]
            },
            opponentNotes: null
        }

    }

    function setStaticAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 24, ?_offset:Array<Float>, _enemy:Bool = false, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        if(!_enemy){
            info.notes.arrowInfo[_direction].staticInfo = {
                type: prefix,
                data: {
                    prefix: _prefix,
                    frames: null,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
        else{
            initOppNotesIfNull();
            info.opponentNotes.arrowInfo[_direction].staticInfo = {
                type: prefix,
                data: {
                    prefix: _prefix,
                    frames: null,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
    }

    function setStaticAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 24, ?_offset:Array<Float>, _enemy:Bool = false, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        if(!_enemy){
            info.notes.arrowInfo[_direction].staticInfo = {
                type: frames,
                data: {
                    prefix: null,
                    frames: _frames,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
        else{
            initOppNotesIfNull();
            info.opponentNotes.arrowInfo[_direction].staticInfo = {
                type: frames,
                data: {
                    prefix: null,
                    frames: _frames,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
    }

    function setPressedAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 24, ?_offset:Array<Float>, _enemy:Bool = false, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        if(!_enemy){
            info.notes.arrowInfo[_direction].pressedInfo = {
                type: prefix,
                data: {
                    prefix: _prefix,
                    frames: null,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
        else{
            initOppNotesIfNull();
            info.opponentNotes.arrowInfo[_direction].pressedInfo = {
                type: prefix,
                data: {
                    prefix: _prefix,
                    frames: null,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
    }

    function setPressedAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 24, ?_offset:Array<Float>, _enemy:Bool = false, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        if(!_enemy){
            info.notes.arrowInfo[_direction].pressedInfo = {
                type: frames,
                data: {
                    prefix: null,
                    frames: _frames,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
        else{
            initOppNotesIfNull();
            info.opponentNotes.arrowInfo[_direction].pressedInfo = {
                type: frames,
                data: {
                    prefix: null,
                    frames: _frames,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
    }

    function setConfirmedAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 24, ?_offset:Array<Float>, _enemy:Bool = false, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        if(!_enemy){
            info.notes.arrowInfo[_direction].confrimedInfo = {
                type: prefix,
                data: {
                    prefix: _prefix,
                    frames: null,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
        else{
            initOppNotesIfNull();
            info.opponentNotes.arrowInfo[_direction].confrimedInfo = {
                type: prefix,
                data: {
                    prefix: _prefix,
                    frames: null,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
    }

    function setConfirmedAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 24, ?_offset:Array<Float>, _enemy:Bool = false, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        if(!_enemy){
            info.notes.arrowInfo[_direction].confrimedInfo = {
                type: frames,
                data: {
                    prefix: null,
                    frames: _frames,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
        else{
            initOppNotesIfNull();
            info.opponentNotes.arrowInfo[_direction].confrimedInfo = {
                type: frames,
                data: {
                    prefix: null,
                    frames: _frames,
                    postfix: null,
                    framerate: _framerate,
                    loop: null,
                    flipX: _flipX,
                    flipY: _flipY,
                    offset: _offset
                }
            }
        }
    }

    function initOppNotesIfNull():Void{
        if(info.opponentNotes == null){
            info.opponentNotes = {
                notePath: null,
                noteFrameLoadType: null,
                scale: 1,
                anitaliasing: true,
                splashClass: null,
                coverPath: null,
                arrowInfo:[
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    },
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    },
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    },
                    {
                    staticInfo: null,
                    pressedInfo: null,
                    confrimedInfo: null
                    }
                ]
            };
        }
    }

    inline function arrowInfo(direction:Int):StaticArrowGraphicInfo{
        return info.notes.arrowInfo[direction];
    }

    inline function opponentArrowInfo(direction:Int):StaticArrowGraphicInfo{
        return info.opponentNotes.arrowInfo[direction];
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

    var left(get, never):Int;
    @:noCompletion inline function get_left()   { return 0; }
    var down(get, never):Int;
    @:noCompletion inline function get_down()   { return 1; }
    var up(get, never):Int;
    @:noCompletion inline function get_up()     { return 2; }
    var right(get, never):Int;
    @:noCompletion inline function get_right()  { return 3; }

    var player(get, never):Bool;
    @:noCompletion inline function get_player()     { return false; }
    var opponent(get, never):Bool;
    @:noCompletion inline function get_opponent()   { return true; }

}