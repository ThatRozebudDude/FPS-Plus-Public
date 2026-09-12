package note;

import characters.CharacterInfoBase.AnimData;
import characters.CharacterInfoBase.AnimType;
import characters.CharacterInfoBase.FrameLoadType;
import flixel.math.FlxPoint;
import note.Note;

typedef NoteInfo = {
	var pathOverride:String;
	var pathsOverride:Array<String>;
	var frameLoadTypeOverride:FrameLoadType;
	var scrollAnim:NoteAnimInfo;
	var glowAnim:NoteAnimInfo;
}

typedef SustainInfo = {
	var pathOverride:String;
	var pathsOverride:Array<String>;
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
	var paths:Array<String>;
	var frameLoadType:FrameLoadType;
	
	var noteInfoList:Array<NoteInfo>;
	var sustainInfoList:Array<SustainInfo>;

	var functions:NoteFuncions;

	var canGlow:Bool;
	var scale:Float;
	var holdScaleAdjust:Float;
	var antialiasing:Bool;
	var offsets:Array<FlxPoint>;
	var holdOffsets:Array<FlxPoint>;
	var offset:FlxPointManager;
	var holdOffset:FlxPointManager;

	var noteSplashOverride:String;
	var holdCoverOverride:String;
}

typedef NoteFuncions = {
	var create:(Note)->Void;			//This function is run after the Character new() function is complete.
	var update:(Note, Float)->Void;		//This function is run every frame. Float is elapsed.
	var step:(Note, Int)->Void;			//This function is run every step. Int is the current step.
	var beat:(Note, Int)->Void;			//This function is run every beat. Int is the current beat.
	var destroy:(Note)->Void;			//This function is run every frame. Float is elapsed.
}

@:build(modding.GlobalScriptingTypesMacro.build())
class NoteSkinBase
{

	public var info:NoteSkinInfo = {
		path: null,
		paths: null,
		frameLoadType: null,

		noteInfoList: [
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				scrollAnim: null,
				glowAnim: null
			},
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				scrollAnim: null,
				glowAnim: null
			},
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				scrollAnim: null,
				glowAnim: null
			},
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				scrollAnim: null,
				glowAnim: null
			}
		],

		sustainInfoList: [
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				holdAnim: null,
				endAnim: null
			},
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				holdAnim: null,
				endAnim: null
			},
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				holdAnim: null,
				endAnim: null
			},
			{
				pathOverride: null,
				pathsOverride: null,
				frameLoadTypeOverride: null,
				holdAnim: null,
				endAnim: null
			}
		],

		functions: {
			create: null,
			update: null,
			step: null,
			beat: null,
			destroy: null,
		},

		canGlow: true,
		scale: 0.7,
		holdScaleAdjust: 1,
		antialiasing: true,
		offsets: [FlxPoint.get(), FlxPoint.get(), FlxPoint.get(), FlxPoint.get()],
		holdOffsets: [FlxPoint.get(), FlxPoint.get(), FlxPoint.get(), FlxPoint.get()],
		offset: null,
		holdOffset: null,
		noteSplashOverride: null,
		holdCoverOverride: null
	};

	public function new(){
		info.offset = new FlxPointManager(info.offsets);
		info.holdOffset = new FlxPointManager(info.holdOffsets);
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

	function setSparrow():FrameLoadType{ return FrameLoadType.sparrow; }
	function setPacker():FrameLoadType{ return FrameLoadType.packer; }
	function setLoad(frameWidth:Int, frameHeight:Int):FrameLoadType{ return FrameLoadType.load(frameWidth, frameHeight); }
	//function setAtlas():FrameLoadType{ return FrameLoadType.atlas; }
	function setMultiSparrow():FrameLoadType{ return FrameLoadType.multiSparrow; }

	public function toString():String{ return "NoteSkinBase"; }
}

/**
 * For backwards compatibility reasons. Yay.
 * Manages an array of FlxPoints and when a value is set in the manager every value in the array will be updated to the same value.
 */
class FlxPointManager
{

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	private var referencePoints:Array<FlxPoint>;

	public function new(points:Array<FlxPoint>){
		referencePoints = points ?? [];
	}

	public function set_x(v:Float):Float{
		x = v;
		for(point in referencePoints){ point.x = x; }
		return x;
	}

	public function set_y(v:Float):Float{
		y = v;
		for(point in referencePoints){ point.y = y; }
		return y;
	}

	inline public function set(xv:Float, yv:Float):Void{
		x = xv;
		y = yv;
	}

}