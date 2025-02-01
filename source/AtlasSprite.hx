package;

import flixel.math.FlxMatrix;
import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;

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

	private var largestRenderedWidth(default, set):Float = 0;
	private var largestRenderedHeight(default, set):Float = 0;

	var loopTimer:Float = -1;
	var loopTime:Float = -1;

	public function new(?_x:Float, ?_y:Float, _path:String) {
		super(_x, _y, _path);
		anim.onFrame.add(animCallback);
	}

	override function loadAtlas(Path:String) {
		super.loadAtlas(Path);
		//baseWidth = pixels.width/2;
		//baseHeight = pixels.height/2;
		//width = baseWidth;
		//height = baseHeight;
		//draw();
	}

	public function addAnimationByLabel(name:String, label:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
		var labels = [];
		for(tempLabel in anim.getFrameLabels()){ labels.push(tempLabel.name); }
		if(!labels.contains(label)){
			trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
			return;
		}

		var frame = anim.getFrameLabel(label);

		var nextAnimFrame:Int;
		if(labels.indexOf(label) < labels.length - 1){
			nextAnimFrame = anim.getFrameLabel(labels[labels.indexOf(label)+1]).index;
		}
		else{
			nextAnimFrame = anim.length;
		}

		var length = nextAnimFrame - frame.index;

		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: frame.index,
			length: length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame
		});
	}

	public function addAnimationByFrame(name:String, frame:Int, length:Null<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
		if(length == null){
			length = anim.length;
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
		var labels = [];
		for(tempLabel in anim.getFrameLabels()){ labels.push(tempLabel.name); }
		if(!labels.contains(label)){
			trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
			return;
		}

		var frame = anim.getFrameLabel(label);

		if(length == null){
			length = anim.length;
		}
		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: frame.index,
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
			loopFrame = anim.length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: 0,
			length: anim.length,
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

		anim.framerate = animInfoMap.get(name).framerate;
		anim.play("", force, reverse, animInfoMap.get(name).startFrame + frameOffset);
	}

	function animCallback(frame:Int):Void{
		var animInfo:AtlasAnimInfo = animInfoMap.get(curAnim);

		if(frameCallback != null){ frameCallback(curAnim, frame - animInfo.startFrame, frame); }

		if(frame >= (animInfo.startFrame + animInfo.length) - 1 || frame < animInfo.startFrame){
			anim.curFrame = (animInfo.startFrame + animInfo.length) - 1;
			anim.pause();
			finishedAnim = true;
			if(animationEndCallback != null){ animationEndCallback(curAnim); }

			if(animInfo.looped){
				loopTimer = 0;
				loopTime = 1/(animInfo.framerate);
			}
		}

		//trace("w: " + width + "\th: " + height);
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

		if(flipX){ offset.x = -width; }
		else { offset.x = 0; }

		if(flipY){ offset.y = -height; }
		else { offset.y = 0; }

		if(loopTimer >= 0){
			loopTimer += elapsed;
			if(loopTimer >= loopTime){
				playAnim(curAnim, true, false, animInfoMap.get(curAnim).loopFrame, true);
			}
		}

		super.update(elapsed);
	}

	public override function draw():Void{
		_matrix.identity();
		if (flipX){
			_matrix.a *= -1;
	
			_matrix.tx += width;
	
		}
		if (flipY){
			_matrix.d *= -1;
			_matrix.ty += height;
		}
	
		_flashRect.setEmpty();
	
		parseElement(anim.curInstance, _matrix, colorTransform, cameras, scrollFactor);
	
		frameWidth = Math.round(_flashRect.width);
		frameHeight = Math.round(_flashRect.height);

		largestRenderedWidth = Math.max(_flashRect.width, width);
		largestRenderedHeight = Math.max(_flashRect.height, height);
	
		relativeX = _flashRect.x - x;
		relativeY = _flashRect.y - y;
	
		if (showPivot){
			drawLimb(_pivot, new FlxMatrix(1, 0, 0, 1, origin.x - _pivot.frame.width * 0.5, origin.y - _pivot.frame.height * 0.5), cameras);
			drawLimb(_indicator, new FlxMatrix(1, 0, 0, 1, -_indicator.frame.width * 0.5, -_indicator.frame.height * 0.5), cameras);
		}
	}

	override function updateHitbox():Void{
		width = Math.abs(scale.x) * largestRenderedWidth;
		height = Math.abs(scale.y) * largestRenderedHeight;
		//trace("Updating hitbox!");
	}


	function set_largestRenderedWidth(value:Float):Float {
		if(value > largestRenderedWidth){ 
			updateHitbox();
			largestRenderedWidth = value;
		}
		return value;
	}

	function set_largestRenderedHeight(value:Float):Float {
		if(value > largestRenderedHeight){ 
			updateHitbox();
			largestRenderedHeight = value;
		}
		return value;
	}
}