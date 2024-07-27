package;

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

    private var baseWidth:Float = 0;
    private var baseHeight:Float = 0;

    var loopNextFrame:Bool = false;

    public function new(?_x:Float, ?_y:Float, _path:String) {
        super(_x, _y, _path);
        anim.callback = animCallback;
    }

    override function loadAtlas(Path:String) {
        super.loadAtlas(Path);
        baseWidth = pixels.width/2;
        baseHeight = pixels.height/2;
        width = baseWidth;
        height = baseHeight;
    }

    public function addAnimationByLabel(name:String, label:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
        var labels = anim.getFrameLabels();
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

    public function playAnim(name:String, ?force:Bool = true, ?reverse:Bool = false, ?frameOffset:Int = 0):Void{

        if(!animInfoMap.exists(name)){
            trace("ANIMATION " + name + " DOES NOT EXIST");
            return;
        }

        curAnim = name;
        finishedAnim = false;
        loopNextFrame = false;

        if(frameOffset >= animInfoMap.get(name).length){
            frameOffset = animInfoMap.get(name).length - 1;
        }

		anim.framerate = animInfoMap.get(name).framerate;
		anim.play("", force, reverse, animInfoMap.get(name).startFrame + frameOffset);
    }

    function animCallback(name:String, frame:Int):Void{
		var animInfo = animInfoMap.get(curAnim);

        if(frameCallback != null){ frameCallback(curAnim, frame - animInfo.startFrame, frame); }

        if(loopNextFrame){
            playAnim(curAnim, true, false, animInfo.loopFrame);
        }

        if(frame >= (animInfo.startFrame + animInfo.length) - 1){

            if(animInfo.looped){
                loopNextFrame = true;
                finishedAnim = true;
            }
            else{
                anim.pause();
                finishedAnim = true;
            }

            if(animationEndCallback != null){ animationEndCallback(curAnim); }
        }
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

        super.update(elapsed);
    }

    override function updateHitbox():Void{
        width = Math.abs(scale.x) * baseWidth;
		height = Math.abs(scale.y) * baseHeight;
    }

}