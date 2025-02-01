package characters;

import note.Note;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import Character.AttachedAction;

enum AnimType {
	prefix;
	frames;
	indices;
	label;
	start;
	startAtLabel;
}

enum FrameLoadType {
	sparrow;
	packer;
	load(frameWidth:Int, frameHeight:Int);
	atlas;
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

typedef CharacterFunctions = {
	var create:(Character)->Void;				//This function is run after the Character new() function is complete.
	var update:(Character, Float)->Void;		//This function is run every frame. Float is elapsed.
	var dance:(Character)->Void;				//This function is run after default dance behavior.
	var danceOverride:(Character)->Void;		//This function replaces the default dance behavior.
	var beat:(Character, Int)->Void;			//This function is run every beat. Int is curBeat. Called after dance().
	var step:(Character, Int)->Void;			//This function is run every step. Int is curStep. Called before dance().
	var playAnim:(Character, String)->Void;		//This function is run after the Character playAnim() function is complete. String is the name of the animation given to playAnim().
	var idleEnd:(Character)->Void;				//This function is run after default idleEnd behavior.
	var idleEndOverride:(Character)->Void;		//This function replaces the default idleEnd behavior.
	var frame:(Character, String, Int)->Void;	//This function is run every animation frame. String is the current animation. Int is the current frame.
	var animationEnd:(Character, String)->Void; //This function is run when an animation is finished. String is the finished animation.
	var add:(Character)->Void;					//This function is run when the character is added to the state.
	var deathCreate:(Character)->Void;			//This function is run after the character is created in the game over state.
	var deathAdd:(Character)->Void;				//This function is run after the character is added to the game over state.
	var songStart:(Character)->Void;			//This function is run when the song starts.
	var noteHit:(Character, Note)->Void;		//This function is run when the character hits a note.
	var noteMiss:(Character, Int, Bool)->Void;	//This function is run when the character misses a note.
}

typedef CharacterInfo = {
	var name:String;
	var spritePath:String;
	var frameLoadType:FrameLoadType;
	var iconName:String;
	var deathCharacter:String;
	var resultsCharacter:String;
	var healthColor:Null<FlxColor>;
	var facesLeft:Bool;
	var antialiasing:Bool;
	var anims:Array<AnimInfo>;
	var idleSequence:Array<String>;
	var focusOffset:FlxPoint;
	var deathOffset:FlxPoint;
	var animChains:Map<String, String>;
	var functions:CharacterFunctions;
	var actions:Map<String, (Character)->Void>;
	var extraData:Map<String, Dynamic>;
}

/*	
*	NOTE ABOUT CHARACTER METADATA
*	To exclude characters from the character list add the metadata @charList(false) to the class. If this is not included it is interpreted as true.
*	To include characters in the GF list add the metadata @gfList(true) to the class. If this is not included it is interpreted as false.
*	You can use @charList(false) and @gfList(false) to hide the character from both lists.
*/	

/**
	This is the base class for character info. When making your own character make a new class extending this one.
	@author Rozebud
**/
@:build(modding.GlobalScriptingTypesMacro.build())
class CharacterInfoBase
{

	public var includeInCharacterList:Bool = true;
	public var includeInGfList:Bool = false;

	public var info:CharacterInfo = {
		name: "",
		spritePath: "",
		frameLoadType: sparrow,
		iconName: "face",
		deathCharacter: "Bf",
		resultsCharacter: "BoyfriendResults",
		healthColor: null,
		facesLeft: false,
		antialiasing: true,
		anims: [],
		idleSequence: ["idle"],
		focusOffset: new FlxPoint(150, -100),
		deathOffset: new FlxPoint(),
		animChains: null,
		functions: {
			create: null,
			update: null,
			dance: null,
			danceOverride: null,
			beat: null,
			step: null,
			playAnim: null,
			idleEnd: null,
			idleEndOverride: null,
			frame: null,
			animationEnd: null,
			add: null,
			deathCreate: null,
			deathAdd: null,
			songStart: null,
			noteHit: null,
			noteMiss: null,
		},
		actions: null,
		extraData: null
	};

	public var characterReference:Character;

	public function new() {}

	/**
	 * Generates the x and y offsets for an animation.
	 *
	 * @param	_x	The x offset of the animation.
	 * @param	_y	The y offset of the animation.
	 */
	inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
		return [_x, _y];
	}

	/**
	 * Generates the loop data for an animation.
	 *
	 * @param	_loop	Whether the animation loops or not.
	 * @param	_frame	The frame the animation goes to when looping. Note: positive values are the absolute frame, negative values are subtracted from the end of the animation.
	 */
	inline function loop(_loop:Bool, ?_frame:Int = 0):LoopData{
		return {looped: _loop, loopPoint: _frame};
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param	_name		What this animation should be called (e.g. `"run"`).
	 * @param	_offset		The visual offset of the animation. Use `offset()` to generate the data.
	 * @param	_frames		An array of indices indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param	_frameRate	The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param	_looped		Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 * @param	_flipX		Whether the frames should be flipped horizontally.
	 * @param	_flipY		Whether the frames should be flipped vertically.
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
	 * @param	_name		What this animation should be called (e.g. `"run"`).
	 * @param	_offset		The visual offset of the animation. Use `offset()` to generate the data.
	 * @param	_prefix		Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @param	_frameRate	The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param	_looped		Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 * @param	_flipX		Whether the frames should be flipped horizontally.
	 * @param	_flipY		Whether the frames should be flipped vertically.
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
	 * @param	_name		What this animation should be called (e.g. `"run"`).
	 * @param	_offset		The visual offset of the animation. Use `offset()` to generate the data.
	 * @param	_prefix		Common beginning of image names in the atlas (e.g. "tiles-").
	 * @param	_indices	An array of numbers indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param	_postfix	Common ending of image names in the atlas (e.g. `".png"`).
	 * @param	_frameRate	The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param	_looped		Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 * @param	_flipX		Whether the frames should be flipped horizontally.
	 * @param	_flipY		Whether the frames should be flipped vertically.
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
	 * Adds a new animation to the sprite.
	 * Texture Atlas sprites only!
	 *
	 * @param	_name		What this animation should be called (e.g. `"run"`).
	 * @param	_offset		The visual offset of the animation. Use `offset()` to generate the data.
	 * @param	_label		The name of the label that the animation starts on.
	 * @param	_frameRate	The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param	_looped		Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 */
	function addByLabel(_name:String, _offset:Array<Float>, _label:String, _frameRate:Float = 30.0, _looped:LoopData = null):Void{

		if(_looped == null){
			_looped = loop(true);
		}

		var animData:AnimData = {
			prefix: _label,
			frames: null,
			postfix: null,
			framerate: _frameRate,
			loop: _looped,
			flipX: false,
			flipY: false,
			offset: _offset
		}
		var animInfo:AnimInfo = {
			name: _name,
			type: label,
			data: animData
		}
		info.anims.push(animInfo);
	}

	/**
	 * Adds a new animation to the sprite.
	 * Texture Atlas sprites only!
	 *
	 * @param	_name		What this animation should be called (e.g. `"run"`).
	 * @param	_offset		The visual offset of the animation. Use `offset()` to generate the data.
	 * @param	_start		The frame number that the animation starts on. (Zero indexed).
	 * @param	_length		The length in frames of the animation.
	 * @param	_frameRate	The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param	_looped		Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 */
	 function addByFrame(_name:String, _offset:Array<Float>, _start:Int, _length:Int, _frameRate:Float = 30.0, _looped:LoopData = null):Void{

		if(_looped == null){
			_looped = loop(true);
		}

		var animData:AnimData = {
			prefix: null,
			frames: [_start, _length],
			postfix: null,
			framerate: _frameRate,
			loop: _looped,
			flipX: false,
			flipY: false,
			offset: _offset
		}
		var animInfo:AnimInfo = {
			name: _name,
			type: start,
			data: animData
		}
		info.anims.push(animInfo);
	}

	/**
	 * Adds a new animation to the sprite.
	 * Texture Atlas sprites only!
	 *
	 * @param	_name		What this animation should be called (e.g. `"run"`).
	 * @param	_offset		The visual offset of the animation. Use `offset()` to generate the data.
	 * @param	_label		The frame number that the animation starts on. (Zero indexed).
	 * @param	_length		The length in frames of the animation.
	 * @param	_frameRate	The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param	_looped		Whether or not the animation loops and what frame it loops on. Use `loop()` to generate the data.
	 */
	 function addByStartingAtLabel(_name:String, _offset:Array<Float>, _label:String, _length:Int, _frameRate:Float = 30.0, _looped:LoopData = null):Void{

		if(_looped == null){
			_looped = loop(true);
		}

		var animData:AnimData = {
			prefix: _label,
			frames: [_length],
			postfix: null,
			framerate: _frameRate,
			loop: _looped,
			flipX: false,
			flipY: false,
			offset: _offset
		}
		var animInfo:AnimInfo = {
			name: _name,
			type: startAtLabel,
			data: animData
		}
		info.anims.push(animInfo);
	}

	/**
	 * Adds an animation chain that will automatically play the chained animation followinf the first animation.
	 *
	 * @param	firstAnim		The name of the animation that the chained animation will follow.
	 * @param	chainedAnim		The name of the chained animation.
	 */
	 function addAnimChain(firstAnim:String, chainedAnim:String):Void{
		if(info.animChains == null){
			info.animChains = new Map<String, String>();
		}
		info.animChains.set(firstAnim, chainedAnim);
	}

	/**
	 * Adds a function that can be called via a string by the character.
	 *
	 * @param	key		The name that will be used to identify the action.
	 * @param	data	The function.
	 */
	 function addAction(key:String, data:(Character)->Void):Void{
		if(info.actions == null){
			info.actions = new Map<String, (Character)->Void>();
		}
		info.actions.set(key, data);
	}

	/**
	 * Adds arbitrary data to the character that can be defined in `Character.hx`
	 *
	 * @param	key		The name that will be used to identify the data.
	 * @param	data	The data.
	 */
	function addExtraData(key:String, data:Dynamic):Void{
		if(info.extraData == null){
			info.extraData = new Map<String, Dynamic>();
		}
		info.extraData.set(key, data);
	}

	inline function addToCharacter(x:FlxSprite)			{ characterReference.add(x); }
	inline function removeFromCharacter(x:FlxSprite)	{ characterReference.remove(x); }

	inline function addToState(x:FlxBasic)				{ FlxG.state.add(x); }
	inline function removeFromState(x:FlxBasic)			{ FlxG.state.remove(x); }
	inline function addToSubstate(x:FlxBasic)			{ FlxG.state.subState.add(x); }
	inline function removeFromSubstate(x:FlxBasic)		{ FlxG.state.subState.remove(x); }

	function setSparrow():FrameLoadType{ return FrameLoadType.sparrow; }
	function setPacker():FrameLoadType{ return FrameLoadType.packer; }
	function setLoad(frameWidth:Int, frameHeight:Int):FrameLoadType{ return FrameLoadType.load(frameWidth, frameHeight); }
	function setAtlas():FrameLoadType{ return FrameLoadType.atlas; }

	public function toString():String{ return ""+info; }
}