package ui;

import characters.CharacterInfoBase.FrameLoadType;
import note.NoteSkinBase.NoteAnimInfo;
import flixel.math.FlxPoint;
import haxe.Json;

typedef AllArrowsInfo = {
    var notePath:String;
    var noteFrameLoadType:FrameLoadType;
    var arrowInfo:Array<StaticArrowGraphicInfo>;
    var scale:Float;
    var antialiasing:Bool;

    var splashClass:String;
    var coverPath:String;
}

typedef StaticArrowGraphicInfo = {
    var staticInfo:NoteAnimInfo;
    var pressedInfo:NoteAnimInfo;
    var confrimedInfo:NoteAnimInfo;
}

class HudNoteSkinBase{

    public var info:AllArrowsInfo = {
        notePath: null,
        noteFrameLoadType: null,
        scale: 1,
        antialiasing: true,
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

    public function new(_skin:String){
        var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/hudNote")));
        info.notePath = skinJson.path;

        if(skinJson.frameLoadType.type == "sparrow") { info.noteFrameLoadType = sparrow; }
        else if(skinJson.frameLoadType.type == "load") { info.noteFrameLoadType = load(skinJson.frameLoadType.dimensions[0], skinJson.frameLoadType.dimensions[1]); }

        if(skinJson.scale != null) { info.scale = skinJson.scale; }
        if(skinJson.antialiasing != null) { info.antialiasing = skinJson.antialiasing; }

        if(skinJson.splash != null)      { info.splashClass = skinJson.splash; }
        else                                    { info.splashClass = "Default"; }
        if(skinJson.holdCover != null)   { info.coverPath = skinJson.holdCover; }
        else                                    { info.coverPath = "Default"; }

        if(info.noteFrameLoadType == sparrow){
            setStaticAnimPrefix(0, skinJson.arrows.left.idle.prefix, skinJson.arrows.left.idle.framerate, skinJson.arrows.left.idle.offset);
            setPressedAnimPrefix(0, skinJson.arrows.left.pressed.prefix, skinJson.arrows.left.pressed.framerate, skinJson.arrows.left.pressed.offset);
            setConfirmedAnimPrefix(0, skinJson.arrows.left.confirm.prefix, skinJson.arrows.left.confirm.framerate, skinJson.arrows.left.confirm.offset);

            setStaticAnimPrefix(1, skinJson.arrows.down.idle.prefix, skinJson.arrows.down.idle.framerate, skinJson.arrows.down.idle.offset);
            setPressedAnimPrefix(1, skinJson.arrows.down.pressed.prefix, skinJson.arrows.down.pressed.framerate, skinJson.arrows.down.pressed.offset);
            setConfirmedAnimPrefix(1, skinJson.arrows.down.confirm.prefix, skinJson.arrows.down.confirm.framerate, skinJson.arrows.down.confirm.offset);

            setStaticAnimPrefix(2, skinJson.arrows.up.idle.prefix, skinJson.arrows.up.idle.framerate, skinJson.arrows.up.idle.offset);
            setPressedAnimPrefix(2, skinJson.arrows.up.pressed.prefix, skinJson.arrows.up.pressed.framerate, skinJson.arrows.up.pressed.offset);
            setConfirmedAnimPrefix(2, skinJson.arrows.up.confirm.prefix, skinJson.arrows.up.confirm.framerate, skinJson.arrows.up.confirm.offset);

            setStaticAnimPrefix(3, skinJson.arrows.right.idle.prefix, skinJson.arrows.right.idle.framerate, skinJson.arrows.right.idle.offset);
            setPressedAnimPrefix(3, skinJson.arrows.right.pressed.prefix, skinJson.arrows.right.pressed.framerate, skinJson.arrows.right.pressed.offset);
            setConfirmedAnimPrefix(3, skinJson.arrows.right.confirm.prefix, skinJson.arrows.right.confirm.framerate, skinJson.arrows.right.confirm.offset);
        }
        else{
            setStaticAnimFrames(0, skinJson.arrows.left.idle.frames, skinJson.arrows.left.idle.framerate, skinJson.arrows.left.idle.offset);
            setPressedAnimFrames(0, skinJson.arrows.left.pressed.frames, skinJson.arrows.left.pressed.framerate, skinJson.arrows.left.pressed.offset);
            setConfirmedAnimFrames(0, skinJson.arrows.left.confirm.frames, skinJson.arrows.left.confirm.framerate, skinJson.arrows.left.confirm.offset);

            setStaticAnimFrames(1, skinJson.arrows.down.idle.frames, skinJson.arrows.down.idle.framerate, skinJson.arrows.down.idle.offset);
            setPressedAnimFrames(1, skinJson.arrows.down.pressed.frames, skinJson.arrows.down.pressed.framerate, skinJson.arrows.down.pressed.offset);
            setConfirmedAnimFrames(1, skinJson.arrows.down.confirm.frames, skinJson.arrows.down.confirm.framerate, skinJson.arrows.down.confirm.offset);

            setStaticAnimFrames(2, skinJson.arrows.up.idle.frames, skinJson.arrows.up.idle.framerate, skinJson.arrows.up.idle.offset);
            setPressedAnimFrames(2, skinJson.arrows.up.pressed.frames, skinJson.arrows.up.pressed.framerate, skinJson.arrows.up.pressed.offset);
            setConfirmedAnimFrames(2, skinJson.arrows.up.confirm.frames, skinJson.arrows.up.confirm.framerate, skinJson.arrows.up.confirm.offset);

            setStaticAnimFrames(3, skinJson.arrows.right.idle.frames, skinJson.arrows.right.idle.framerate, skinJson.arrows.right.idle.offset);
            setPressedAnimFrames(3, skinJson.arrows.right.pressed.frames, skinJson.arrows.right.pressed.framerate, skinJson.arrows.right.pressed.offset);
            setConfirmedAnimFrames(3, skinJson.arrows.right.confirm.frames, skinJson.arrows.right.confirm.framerate, skinJson.arrows.right.confirm.offset);
        }
    }

    function setStaticAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 24, ?_offset:Array<Float>, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        info.arrowInfo[_direction].staticInfo = {
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

    function setStaticAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 24, ?_offset:Array<Float>, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        info.arrowInfo[_direction].staticInfo = {
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

    function setPressedAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 24, ?_offset:Array<Float>, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        info.arrowInfo[_direction].pressedInfo = {
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

    function setPressedAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 24, ?_offset:Array<Float>, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        info.arrowInfo[_direction].pressedInfo = {
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

    function setConfirmedAnimPrefix(_direction:Int, _prefix:String, _framerate:Float = 24, ?_offset:Array<Float>, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        info.arrowInfo[_direction].confrimedInfo = {
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

    function setConfirmedAnimFrames(_direction:Int, _frames:Array<Int>, _framerate:Float = 24, ?_offset:Array<Float>, _flipX:Bool = false, _flipY:Bool = false):Void{
        if (_offset == null) { _offset = [0, 0]; }
        info.arrowInfo[_direction].confrimedInfo = {
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

    inline function arrowInfo(direction:Int):StaticArrowGraphicInfo{
        return info.arrowInfo[direction];
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

    var player(get, never):Bool;
    @:noCompletion inline function get_player()     { return false; }
    var opponent(get, never):Bool;
    @:noCompletion inline function get_opponent()   { return true; }

    function setSparrow():FrameLoadType{ return FrameLoadType.sparrow; }
    //function setPacker():FrameLoadType{ return FrameLoadType.packer; }
    function setLoad(frameWidth:Int, frameHeight:Int):FrameLoadType{ return FrameLoadType.load(frameWidth, frameHeight); }
    //function setAtlas():FrameLoadType{ return FrameLoadType.atlas; }

    public function toString():String{ return "HudNoteSkinBase"; }
}