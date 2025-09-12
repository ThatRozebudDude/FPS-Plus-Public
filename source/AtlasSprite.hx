package;

import flixel.math.FlxMatrix;
import flixel.util.FlxTimer;
import animate.FlxAnimate;
import animate.FlxAnimateFrames;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import Paths.TextureAtlasData;

typedef AtlasAnimInfo = {
	startFrame:Int,
	length:Int,
	framerate:Float,
	looped:Bool,
	loopFrame:Null<Int>
}

class AtlasSprite extends FlxAnimate
{

	public var animInfoMap:Map<String, AtlasAnimInfo> = new Map<String, AtlasAnimInfo>();

	public var curAnim:String;
	public var finishedAnim:Bool = true;

	public var frameCallback:(String, Int, Int)->Void;
	public var animationEndCallback:String->Void;

	var loopTimer:Float = -1;
	var loopTime:Float = -1;

	//Will offset the sprite so that (0, 0) in the symbol in animation will be where the sprite is position at.
	public var positionAtSymbolOrigin:Bool = false;

	public function new(?_x:Float, ?_y:Float, ?_path:TextureAtlasData, ?_settings:FlxAnimateSettings) {
		super(_x, _y, null, null);
		if(_path != null){
			loadAtlas(_path, _settings);
		}
	}

	public function loadAtlas(_path:TextureAtlasData, ?_settings:FlxAnimateSettings){
		frames = FlxAnimateFrames.fromAnimate(_path.path, null, null, null, false, _settings);
		anim.addByTimeline("___full", anim.getDefaultTimeline(), 24, false);
		anim.onFrameChange.add(animCallback);
		if(_path.old){ 
			applyStageMatrix = true;
			positionAtSymbolOrigin = true;
		}
		positionAtSymbolOrigin = true;
	}

	public function addAnimationByLabel(name:String, label:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
		var foundFrames = anim.findFrameLabelIndices(label);
		if(foundFrames.length <= 0){
			trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
			return;
		}

		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = foundFrames.length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: foundFrames[0],
			length: foundFrames.length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame
		});
	}

	public function addAnimationByFrame(name:String, frame:Int, length:Null<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
		if(length == null){
			length = anim.getByName("___full").frames.length;
		}
		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: frame,
			length: length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame
		});
	}

	public function addAnimationStartingAtLabel(name:String, label:String, length:Null<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
		var foundFrames = anim.findFrameLabelIndices(label);
		if(foundFrames.length <= 0){
			trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
			return;
		}

		if(length == null){
			length = anim.getByName("___full").frames.length;
		}
		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: foundFrames[0],
			length: length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame
		});
	}

	public function addFullAnimation(name:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null) {
		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = anim.getByName("___full").frames.length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: 0,
			length: anim.getByName("___full").frames.length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame
		});
	}

	public function playAnim(name:String, ?force:Bool = true, ?reverse:Bool = false, ?frameOffset:Int = 0, ?_partOfLoop:Bool = false):Void{

		if(!animInfoMap.exists(name)){
			trace("ANIMATION " + name + " DOES NOT EXIST");
			return;
		}

		curAnim = name;
		loopTimer = -1;
		loopTime = -1;
		if(!_partOfLoop){
			finishedAnim = false;
		}

		if(frameOffset >= animInfoMap.get(name).length){
			frameOffset = animInfoMap.get(name).length - 1;
		}

		anim.getByName("___full").frameRate = animInfoMap.get(name).framerate;
		anim.play("___full", force, reverse, animInfoMap.get(name).startFrame + frameOffset);
	}

	function animCallback(name:String, index:Int, frame:Int):Void{
		var animInfo:AtlasAnimInfo = animInfoMap.get(curAnim);

		if(positionAtSymbolOrigin){
			offset.set(-anim.getDefaultTimeline().getBoundsOrigin(null, true).x, -anim.getDefaultTimeline().getBoundsOrigin(null, true).y);
		}

		if(frameCallback != null){ frameCallback(curAnim, frame - animInfo.startFrame, frame); }

		if(frame >= (animInfo.startFrame + animInfo.length) - 1 || frame < animInfo.startFrame){
			//anim.curAnim.curFrame = (animInfo.startFrame + animInfo.length) - 1;
			anim.pause();
			finishedAnim = true;

			if(animationEndCallback != null){ animationEndCallback(curAnim); }

			if(animInfo.looped){
				loopTimer = 0;
				loopTime = 1/(animInfo.framerate);
			}
		}
	}

	public function pause():Void{
		anim.pause();
	}

	public function resume():Void{
		anim.resume();
	}

	override function set_flipX(Value:Bool):Bool {
		flipX = Value;
		return super.set_flipX(Value);
	}

	override function set_flipY(Value:Bool):Bool {
		flipY = Value;
		return super.set_flipY(Value);
	}

	override function update(elapsed:Float):Void{

		//if(flipX){ offset.x = -width; }
		//else { offset.x = 0; }

		//if(flipY){ offset.y = -height; }
		//else { offset.y = 0; }

		if(loopTimer >= 0){
			loopTimer += elapsed;
			if(loopTimer >= loopTime){
				playAnim(curAnim, true, false, animInfoMap.get(curAnim).loopFrame, true);
			}
		}

		super.update(elapsed);
	}
}

/*
static function getGraphic(path:String):FlxGraphic{
		trace("we do this instead");
		if(ImageCache.exists(path)){
			return ImageCache.get(path).graphic;
		}
		else{
			return ImageCache.loadLocal(path).graphic;
		}
	}
*/

//Not working but maybe i can get it to work later? idk.
#if !display
#if macro
class FlxAnimateFramesMacro
{
	//Override the FlxAnimateFrames `getGraphic()` function to use my image caching stuff instead of Flixel's normal bitmap cache.
	public static macro function changeGetGraphic():Array<haxe.macro.Expr.Field>{
		var fields = haxe.macro.Context.getBuildFields();
		for(field in fields){
			if(field.name == "getGraphic"){
				var originalExpression = f.expr;
				f.expr = macro {
					trace("we do this instead");
					if(ImageCache.exists(path)){
						return ImageCache.get(path).graphic;
					}
					else{
						return ImageCache.loadLocal(path).graphic;
					}
				};
				trace("Modified animate.FlxAnimateFrames.getGraphic()");
			}
		}
		return fields;
	}
}
#end
#end