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

typedef HudNoteSkinInfo = {
    var notes:AllArrowsInfo;
    var opponentNotes:AllArrowsInfo;
}

class HudNoteSkinBase{

    public var info:HudNoteSkinInfo = {
        notes: {
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
        },
        opponentNotes: null
    };

    public function new(_skin:String){
        var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/hudNote")));
        info.notes.notePath = skinJson.player.path;

        if(skinJson.player.frameLoadType.type == "sparrow") { info.notes.noteFrameLoadType = sparrow; }
        else if(skinJson.player.frameLoadType.type == "load") { info.notes.noteFrameLoadType = load(skinJson.player.frameLoadType.dimensions[0], skinJson.player.frameLoadType.dimensions[1]); }

        if(skinJson.player.scale != null) { info.notes.scale = skinJson.player.scale; }
        if(skinJson.player.antialiasing != null) { info.notes.antialiasing = skinJson.player.antialiasing; }

        if(skinJson.player.splash != null)      { info.notes.splashClass = skinJson.player.splash; }
        else                                    { info.notes.splashClass = "Default"; }
        if(skinJson.player.holdCover != null)   { info.notes.coverPath = skinJson.player.holdCover; }
        else                                    { info.notes.coverPath = "Default"; }

        if(info.notes.noteFrameLoadType == sparrow){
            setStaticAnimPrefix(0, skinJson.player.arrows.left.idle.prefix, skinJson.player.arrows.left.idle.framerate, skinJson.player.arrows.left.idle.offset, false);
            setPressedAnimPrefix(0, skinJson.player.arrows.left.pressed.prefix, skinJson.player.arrows.left.pressed.framerate, skinJson.player.arrows.left.pressed.offset, false);
            setConfirmedAnimPrefix(0, skinJson.player.arrows.left.confirm.prefix, skinJson.player.arrows.left.confirm.framerate, skinJson.player.arrows.left.confirm.offset, false);

            setStaticAnimPrefix(1, skinJson.player.arrows.down.idle.prefix, skinJson.player.arrows.down.idle.framerate, skinJson.player.arrows.down.idle.offset, false);
            setPressedAnimPrefix(1, skinJson.player.arrows.down.pressed.prefix, skinJson.player.arrows.down.pressed.framerate, skinJson.player.arrows.down.pressed.offset, false);
            setConfirmedAnimPrefix(1, skinJson.player.arrows.down.confirm.prefix, skinJson.player.arrows.down.confirm.framerate, skinJson.player.arrows.down.confirm.offset, false);

            setStaticAnimPrefix(2, skinJson.player.arrows.up.idle.prefix, skinJson.player.arrows.up.idle.framerate, skinJson.player.arrows.up.idle.offset, false);
            setPressedAnimPrefix(2, skinJson.player.arrows.up.pressed.prefix, skinJson.player.arrows.up.pressed.framerate, skinJson.player.arrows.up.pressed.offset, false);
            setConfirmedAnimPrefix(2, skinJson.player.arrows.up.confirm.prefix, skinJson.player.arrows.up.confirm.framerate, skinJson.player.arrows.up.confirm.offset, false);

            setStaticAnimPrefix(3, skinJson.player.arrows.right.idle.prefix, skinJson.player.arrows.right.idle.framerate, skinJson.player.arrows.right.idle.offset, false);
            setPressedAnimPrefix(3, skinJson.player.arrows.right.pressed.prefix, skinJson.player.arrows.right.pressed.framerate, skinJson.player.arrows.right.pressed.offset, false);
            setConfirmedAnimPrefix(3, skinJson.player.arrows.right.confirm.prefix, skinJson.player.arrows.right.confirm.framerate, skinJson.player.arrows.right.confirm.offset, false);
        }
        else{
            setStaticAnimFrames(0, skinJson.player.arrows.left.idle.frames, skinJson.player.arrows.left.idle.framerate, skinJson.player.arrows.left.idle.offset, false);
            setPressedAnimFrames(0, skinJson.player.arrows.left.pressed.frames, skinJson.player.arrows.left.pressed.framerate, skinJson.player.arrows.left.pressed.offset, false);
            setConfirmedAnimFrames(0, skinJson.player.arrows.left.confirm.frames, skinJson.player.arrows.left.confirm.framerate, skinJson.player.arrows.left.confirm.offset, false);

            setStaticAnimFrames(1, skinJson.player.arrows.down.idle.frames, skinJson.player.arrows.down.idle.framerate, skinJson.player.arrows.down.idle.offset, false);
            setPressedAnimFrames(1, skinJson.player.arrows.down.pressed.frames, skinJson.player.arrows.down.pressed.framerate, skinJson.player.arrows.down.pressed.offset, false);
            setConfirmedAnimFrames(1, skinJson.player.arrows.down.confirm.frames, skinJson.player.arrows.down.confirm.framerate, skinJson.player.arrows.down.confirm.offset, false);

            setStaticAnimFrames(2, skinJson.player.arrows.up.idle.frames, skinJson.player.arrows.up.idle.framerate, skinJson.player.arrows.up.idle.offset, false);
            setPressedAnimFrames(2, skinJson.player.arrows.up.pressed.frames, skinJson.player.arrows.up.pressed.framerate, skinJson.player.arrows.up.pressed.offset, false);
            setConfirmedAnimFrames(2, skinJson.player.arrows.up.confirm.frames, skinJson.player.arrows.up.confirm.framerate, skinJson.player.arrows.up.confirm.offset, false);

            setStaticAnimFrames(3, skinJson.player.arrows.right.idle.frames, skinJson.player.arrows.right.idle.framerate, skinJson.player.arrows.right.idle.offset, false);
            setPressedAnimFrames(3, skinJson.player.arrows.right.pressed.frames, skinJson.player.arrows.right.pressed.framerate, skinJson.player.arrows.right.pressed.offset, false);
            setConfirmedAnimFrames(3, skinJson.player.arrows.right.confirm.frames, skinJson.player.arrows.right.confirm.framerate, skinJson.player.arrows.right.confirm.offset, false);
        }

        if(skinJson.opponent != null){
            info.opponentNotes.notePath = skinJson.opponent.path;

            if(skinJson.opponent.frameLoadType.type == "sparrow") { info.opponentNotes.noteFrameLoadType = sparrow; }
            else if(skinJson.opponent.frameLoadType.type == "load") { info.opponentNotes.noteFrameLoadType = load(skinJson.opponent.frameLoadType.dimensions[0], skinJson.opponent.frameLoadType.dimensions[1]); }

            if(skinJson.opponent.scale != null) { info.opponentNotes.scale = skinJson.opponent.scale; }
            if(skinJson.opponent.antialiasing != null) { info.opponentNotes.antialiasing = skinJson.opponent.antialiasing; }

            if(skinJson.opponent.splash != null)      { info.opponentNotes.splashClass = skinJson.opponent.splash; }
            else                                    { info.opponentNotes.splashClass = "Default"; }
            if(skinJson.opponent.holdCover != null)   { info.opponentNotes.coverPath = skinJson.opponent.holdCover; }
            else                                    { info.opponentNotes.coverPath = "Default"; }

            if(info.opponentNotes.noteFrameLoadType == sparrow){
                setStaticAnimPrefix(0, skinJson.opponent.arrows.left.idle.prefix, skinJson.opponent.arrows.left.idle.framerate, skinJson.opponent.arrows.left.idle.offset, true);
                setPressedAnimPrefix(0, skinJson.opponent.arrows.left.pressed.prefix, skinJson.opponent.arrows.left.pressed.framerate, skinJson.opponent.arrows.left.pressed.offset, true);
                setConfirmedAnimPrefix(0, skinJson.opponent.arrows.left.confirm.prefix, skinJson.opponent.arrows.left.confirm.framerate, skinJson.opponent.arrows.left.confirm.offset, true);

                setStaticAnimPrefix(1, skinJson.opponent.arrows.down.idle.prefix, skinJson.opponent.arrows.down.idle.framerate, skinJson.opponent.arrows.down.idle.offset, true);
                setPressedAnimPrefix(1, skinJson.opponent.arrows.down.pressed.prefix, skinJson.opponent.arrows.down.pressed.framerate, skinJson.opponent.arrows.down.pressed.offset, true);
                setConfirmedAnimPrefix(1, skinJson.opponent.arrows.down.confirm.prefix, skinJson.opponent.arrows.down.confirm.framerate, skinJson.opponent.arrows.down.confirm.offset, true);

                setStaticAnimPrefix(2, skinJson.opponent.arrows.up.idle.prefix, skinJson.opponent.arrows.up.idle.framerate, skinJson.opponent.arrows.up.idle.offset, true);
                setPressedAnimPrefix(2, skinJson.opponent.arrows.up.pressed.prefix, skinJson.opponent.arrows.up.pressed.framerate, skinJson.opponent.arrows.up.pressed.offset, true);
                setConfirmedAnimPrefix(2, skinJson.opponent.arrows.up.confirm.prefix, skinJson.opponent.arrows.up.confirm.framerate, skinJson.opponent.arrows.up.confirm.offset, true);

                setStaticAnimPrefix(3, skinJson.opponent.arrows.right.idle.prefix, skinJson.opponent.arrows.right.idle.framerate, skinJson.opponent.arrows.right.idle.offset, true);
                setPressedAnimPrefix(3, skinJson.opponent.arrows.right.pressed.prefix, skinJson.opponent.arrows.right.pressed.framerate, skinJson.opponent.arrows.right.pressed.offset, true);
                setConfirmedAnimPrefix(3, skinJson.opponent.arrows.right.confirm.prefix, skinJson.opponent.arrows.right.confirm.framerate, skinJson.opponent.arrows.right.confirm.offset, true);
            }
            else{
                setStaticAnimFrames(0, skinJson.opponent.arrows.left.idle.frames, skinJson.opponent.arrows.left.idle.framerate, skinJson.opponent.arrows.left.idle.offset, true);
                setPressedAnimFrames(0, skinJson.opponent.arrows.left.pressed.frames, skinJson.opponent.arrows.left.pressed.framerate, skinJson.opponent.arrows.left.pressed.offset, true);
                setConfirmedAnimFrames(0, skinJson.opponent.arrows.left.confirm.frames, skinJson.opponent.arrows.left.confirm.framerate, skinJson.opponent.arrows.left.confirm.offset, true);

                setStaticAnimFrames(1, skinJson.opponent.arrows.down.idle.frames, skinJson.opponent.arrows.down.idle.framerate, skinJson.opponent.arrows.down.idle.offset, true);
                setPressedAnimFrames(1, skinJson.opponent.arrows.down.pressed.frames, skinJson.opponent.arrows.down.pressed.framerate, skinJson.opponent.arrows.down.pressed.offset, true);
                setConfirmedAnimFrames(1, skinJson.opponent.arrows.down.confirm.frames, skinJson.opponent.arrows.down.confirm.framerate, skinJson.opponent.arrows.down.confirm.offset, true);

                setStaticAnimFrames(2, skinJson.opponent.arrows.up.idle.frames, skinJson.opponent.arrows.up.idle.framerate, skinJson.opponent.arrows.up.idle.offset, true);
                setPressedAnimFrames(2, skinJson.opponent.arrows.up.pressed.frames, skinJson.opponent.arrows.up.pressed.framerate, skinJson.opponent.arrows.up.pressed.offset, true);
                setConfirmedAnimFrames(2, skinJson.opponent.arrows.up.confirm.frames, skinJson.opponent.arrows.up.confirm.framerate, skinJson.opponent.arrows.up.confirm.offset, true);

                setStaticAnimFrames(3, skinJson.opponent.arrows.right.idle.frames, skinJson.opponent.arrows.right.idle.framerate, skinJson.opponent.arrows.right.idle.offset, true);
                setPressedAnimFrames(3, skinJson.opponent.arrows.right.pressed.frames, skinJson.opponent.arrows.right.pressed.framerate, skinJson.opponent.arrows.right.pressed.offset, true);
                setConfirmedAnimFrames(3, skinJson.opponent.arrows.right.confirm.frames, skinJson.opponent.arrows.right.confirm.framerate, skinJson.opponent.arrows.right.confirm.offset, true);
            }
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