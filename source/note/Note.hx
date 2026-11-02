package note;

import config.Config;
import flixel.FlxSprite;

using StringTools;

typedef HitRegion = {
	var sick:Float;
	var good:Float;
	var bad:Float;
	var shit:Float;
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var direction:Int = 0;
	public var canBeHit:Bool = false;
	public var inRange:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var type:String = "";
	public var typePrefix:String = "";

	public var hitRegion:HitRegion = {sick: DEFAULT_SICK_REGION, good: DEFAULT_GOOD_REGION, bad: DEFAULT_BAD_REGION, shit: DEFAULT_SHIT_REGION};

	public var didTooLateAction:Bool = false;

	public var sustain:NoteSustain = null;

	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var hitCallback:(Note, Character)->Void = null;
	public var missCallback:Dynamic = null;

	public var scoringFunction:(Float, String)->Int = null;
	public var hitHealFunction:(Float, String)->Float = null;
	public var missScorePenalty:Int = 0;
	public var missDamage:Float = 0;

	var noteSkin:NoteSkinBase;
	public var canGlow:Bool;

	public var noteSplashOverride:String;
	public var holdCoverOverride:String;

	public static var defaultSkin:String = "Default";

	inline public static final PURPLE_NOTE:Int = 0;
	inline public static final GREEN_NOTE:Int = 2;
	inline public static final BLUE_NOTE:Int = 1;
	inline public static final RED_NOTE:Int = 3;

	inline public static final DEFAULT_SHIT_REGION:Float = 160;
	inline public static final DEFAULT_BAD_REGION:Float = 135;
	inline public static final DEFAULT_GOOD_REGION:Float = 90;
	inline public static final DEFAULT_SICK_REGION:Float = 45;

	inline public static final SCROLL_SPEED_MULTIPLIER:Float = 0.45;

	public function new(_strumTime:Float, _direction:Int, _type:String, _mustPress:Bool){
		super();

		if(_type != null){
			type = _type;
			typePrefix = type.split(";")[0];
		}

		mustPress = _mustPress;

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		
		strumTime = Math.max(_strumTime + Config.offset, 0);

		direction = _direction;

		var noteSkinClassName:String = defaultSkin;

		if(NoteType.types.exists(typePrefix)){
			hitRegion = NoteType.types.get(typePrefix).scoring.hitRegion;
			noteSkinClassName = NoteType.types.get(typePrefix).skin;
		}

		if(ScriptableNoteSkin.listScriptClasses().contains("noteskins."+noteSkinClassName)){
			noteSkinClassName = "noteskins."+noteSkinClassName;
		}
		#if BACKWARD_COMPATIBILITY
		else if(ScriptableNoteSkin.listScriptClasses().contains(noteSkinClassName)){}
		#end
		else{ noteSkinClassName = "noteskins.Default"; }

		noteSkin = ScriptableNoteSkin.scriptInit(noteSkinClassName);

		var defaultPath:String = noteSkin.info.path;
		var defaultPaths:Array<String> = noteSkin.info.paths;
		var defaultLoadType = noteSkin.info.frameLoadType;
		canGlow = noteSkin.info.canGlow;
		antialiasing = noteSkin.info.antialiasing;
		noteSplashOverride = noteSkin.info.noteSplashOverride;
		holdCoverOverride = noteSkin.info.holdCoverOverride;

		var path = defaultPath;
		var paths = defaultPaths;
		var frameLoadType = defaultLoadType;
		if(noteSkin.info.noteInfoList[direction].pathOverride != null){ path = noteSkin.info.noteInfoList[direction].pathOverride; }
		if(noteSkin.info.noteInfoList[direction].pathsOverride != null){ paths = noteSkin.info.noteInfoList[direction].pathsOverride; }
		if(noteSkin.info.noteInfoList[direction].frameLoadTypeOverride != null){ frameLoadType = noteSkin.info.noteInfoList[direction].frameLoadTypeOverride; }
		switch(frameLoadType){
			case sparrow:
				frames = Paths.getSparrowAtlas(path);
			case packer:
				frames = Paths.getPackerAtlas(path);
			case load(fw, fh):
				loadGraphic(Paths.image(path), true, fw, fh);
			case multiSparrow:
				frames = Paths.getMultipleSparrowAtlas(paths);
			default:
				trace("not supported, sorry :[");
		}
		switch(noteSkin.info.noteInfoList[direction].scrollAnim.type){
			case prefix:
				animation.addByPrefix("scroll", noteSkin.info.noteInfoList[direction].scrollAnim.data.prefix, noteSkin.info.noteInfoList[direction].scrollAnim.data.framerate, true, noteSkin.info.noteInfoList[direction].scrollAnim.data.flipX, noteSkin.info.noteInfoList[direction].scrollAnim.data.flipY);
			case frame:
				animation.add("scroll", noteSkin.info.noteInfoList[direction].scrollAnim.data.frames, noteSkin.info.noteInfoList[direction].scrollAnim.data.framerate, true, noteSkin.info.noteInfoList[direction].scrollAnim.data.flipX, noteSkin.info.noteInfoList[direction].scrollAnim.data.flipY);
		}
		if(canGlow){
			switch(noteSkin.info.noteInfoList[direction].glowAnim.type){
				case prefix:
					animation.addByPrefix("glow", noteSkin.info.noteInfoList[direction].glowAnim.data.prefix, noteSkin.info.noteInfoList[direction].glowAnim.data.framerate, true, noteSkin.info.noteInfoList[direction].glowAnim.data.flipX, noteSkin.info.noteInfoList[direction].glowAnim.data.flipY);
				case frame:
					animation.add("glow", noteSkin.info.noteInfoList[direction].glowAnim.data.frames, noteSkin.info.noteInfoList[direction].glowAnim.data.framerate, true, noteSkin.info.noteInfoList[direction].glowAnim.data.flipX, noteSkin.info.noteInfoList[direction].glowAnim.data.flipY);
			}
		}

		scale.set(noteSkin.info.scale, noteSkin.info.scale);
		updateHitbox();
		scrollFactor.set(0, 0);

		animation.play("scroll");

		alpha = noteSkin.info.alpha;
		blend = noteSkin.info.blend;

		xOffset = noteSkin.info.offsets[direction].x;
		yOffset = noteSkin.info.offsets[direction].y;


		if(noteSkin.info.functions.create != null){
			noteSkin.info.functions.create(this);
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		//Glow note stuff.
		if(Config.noteGlow){
			if(canBeHit && animation.curAnim.name == "scroll" && canGlow){
				glow();
			}

			if (tooLate && animation.curAnim.name == "glow"){
				idle();
			}
		}

		if(noteSkin.info.functions.update != null){
			noteSkin.info.functions.update(this, elapsed);
		}
	}

	public function updateCanHit(songPosition:Float = 0, hitRegionFactor:Float = 1){
		if(mustPress){
			canBeHit = (strumTime > songPosition - (hitRegion.shit * hitRegionFactor) && strumTime < songPosition + (hitRegion.shit * hitRegionFactor));

			if(strumTime < songPosition - (hitRegion.shit * hitRegionFactor) && !wasGoodHit){
				tooLate = true;
			}
			
		}
		else{
			canBeHit = (strumTime <= songPosition);
		}

		inRange = (strumTime > songPosition - (hitRegion.shit * hitRegionFactor)
				&& strumTime < songPosition + (hitRegion.shit * hitRegionFactor))
				&& (!wasGoodHit);
	}

	inline public function glow():Void{
		animation.play("glow");
	}

	inline public function idle():Void{
		animation.play("scroll");
	}

	public function beat(curBeat:Int):Void{
		if(noteSkin.info.functions.beat != null){
			noteSkin.info.functions.beat(this, curBeat);
		}
	}

	public function step(curStep:Int):Void{
		if(noteSkin.info.functions.step != null){
			noteSkin.info.functions.step(this, curStep);
		}
	}

	override public function destroy() {
		if(noteSkin.info.functions.destroy != null){
			noteSkin.info.functions.destroy(this);
		}

		super.destroy();
	}
}