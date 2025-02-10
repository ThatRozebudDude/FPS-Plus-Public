package note;

import note.noteSkins.*;
import config.*;

import flixel.FlxSprite;
//import polymod.format.ParseRules.TargetSignatureElement;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var inRange:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var type:String = "";

	public var didTooLateAction:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainEnd:Bool = true;
	public var isFake:Bool = false;

	public var noteScore:Float = 1;

	public var playedEditorClick:Bool = false;
	public var editorBFNote:Bool = false;
	public var absoluteNumber:Int;

	public var editor = false;

	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var hitCallback:(Note, Character)->Void = null;
	public var missCallback:(Int, Character)->Void = null;

	var noteSkin:NoteSkinBase;
	public var canGlow:Bool;

	public var noteSplashOverride:String;

	var graphicScale:Float;

	inline public static final swagWidth:Float = 112/*160 * 0.7*/;
	inline public static final PURP_NOTE:Int = 0;
	inline public static final GREEN_NOTE:Int = 2;
	inline public static final BLUE_NOTE:Int = 1;
	inline public static final RED_NOTE:Int = 3;

	public function new(_strumTime:Float, _noteData:Int, _type:String, ?_editor = false, ?_prevNote:Note, ?_sustainNote:Bool = false){
		
		super();

		if (_type != null)
			type = _type;

		if (_prevNote == null)
			_prevNote = this;

		prevNote = _prevNote;
		isSustainNote = _sustainNote;

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		editor = _editor;
		
		if(!editor){
			strumTime = _strumTime + Config.offset;
			if(strumTime < 0) {
				strumTime = 0;
			}
		}
		else {
			strumTime = _strumTime;
		}

		noteData = _noteData;

		var noteSkinClassName:String = PlayState.uiSkinNames.note;

		if(NoteType.typeSkins.exists(type)){
			noteSkinClassName = NoteType.typeSkins.get(type);
		}

		if(!ScriptableNoteSkin.listScriptClasses().contains(noteSkinClassName)){ noteSkinClassName = "DefaultNoteSkin"; }
		noteSkin = ScriptableNoteSkin.init(noteSkinClassName);

		var defaultPath = noteSkin.info.path;
		var defaultLoadType = noteSkin.info.frameLoadType;
		canGlow = noteSkin.info.canGlow;
		antialiasing = noteSkin.info.antialiasing;
		noteSplashOverride = noteSkin.info.noteSplashOverride;

		var path = defaultPath;
		var frameLoadType = defaultLoadType;
		if(!isSustainNote){
			if(noteSkin.info.noteInfoList[noteData].pathOverride != null){ path = noteSkin.info.noteInfoList[noteData].pathOverride; }
			if(noteSkin.info.noteInfoList[noteData].frameLoadTypeOverride != null){ frameLoadType = noteSkin.info.noteInfoList[noteData].frameLoadTypeOverride; }
			switch(frameLoadType){
				case sparrow:
					frames = Paths.getSparrowAtlas(path);
				case packer:
					frames = Paths.getPackerAtlas(path);
				case load(fw, fh):
					loadGraphic(Paths.image(path), true, fw, fh);
				default:
					trace("not supported, sorry :[");
			}
			switch(noteSkin.info.noteInfoList[noteData].scrollAnim.type){
				case prefix:
					animation.addByPrefix("scroll", noteSkin.info.noteInfoList[noteData].scrollAnim.data.prefix, noteSkin.info.noteInfoList[noteData].scrollAnim.data.framerate, true, noteSkin.info.noteInfoList[noteData].scrollAnim.data.flipX, noteSkin.info.noteInfoList[noteData].scrollAnim.data.flipY);
				case frame:
					animation.add("scroll", noteSkin.info.noteInfoList[noteData].scrollAnim.data.frames, noteSkin.info.noteInfoList[noteData].scrollAnim.data.framerate, true, noteSkin.info.noteInfoList[noteData].scrollAnim.data.flipX, noteSkin.info.noteInfoList[noteData].scrollAnim.data.flipY);
			}
			if(canGlow){
				switch(noteSkin.info.noteInfoList[noteData].glowAnim.type){
					case prefix:
						animation.addByPrefix("glow", noteSkin.info.noteInfoList[noteData].glowAnim.data.prefix, noteSkin.info.noteInfoList[noteData].glowAnim.data.framerate, true, noteSkin.info.noteInfoList[noteData].glowAnim.data.flipX, noteSkin.info.noteInfoList[noteData].glowAnim.data.flipY);
					case frame:
						animation.add("glow", noteSkin.info.noteInfoList[noteData].glowAnim.data.frames, noteSkin.info.noteInfoList[noteData].glowAnim.data.framerate, true, noteSkin.info.noteInfoList[noteData].glowAnim.data.flipX, noteSkin.info.noteInfoList[noteData].glowAnim.data.flipY);
				}
			}
		}
		else{
			if(noteSkin.info.sustainInfoList[noteData].pathOverride != null){ path = noteSkin.info.sustainInfoList[noteData].pathOverride; }
			if(noteSkin.info.sustainInfoList[noteData].frameLoadTypeOverride != null){ frameLoadType = noteSkin.info.sustainInfoList[noteData].frameLoadTypeOverride; }
			switch(frameLoadType){
				case sparrow:
					frames = Paths.getSparrowAtlas(path);
				case packer:
					frames = Paths.getPackerAtlas(path);
				case load(fw, fh):
					loadGraphic(Paths.image(path), true, fw, fh);
				default:
					trace("not supported, sorry :[");
			}
			switch(noteSkin.info.sustainInfoList[noteData].holdAnim.type){
				case prefix:
					animation.addByPrefix("hold", noteSkin.info.sustainInfoList[noteData].holdAnim.data.prefix, noteSkin.info.sustainInfoList[noteData].holdAnim.data.framerate, true, noteSkin.info.sustainInfoList[noteData].holdAnim.data.flipX, noteSkin.info.sustainInfoList[noteData].holdAnim.data.flipY);
				case frame:
					animation.add("hold", noteSkin.info.sustainInfoList[noteData].holdAnim.data.frames, noteSkin.info.sustainInfoList[noteData].holdAnim.data.framerate, true, noteSkin.info.sustainInfoList[noteData].holdAnim.data.flipX, noteSkin.info.sustainInfoList[noteData].holdAnim.data.flipY);
			}
			switch(noteSkin.info.sustainInfoList[noteData].endAnim.type){
				case prefix:
					animation.addByPrefix("holdEnd", noteSkin.info.sustainInfoList[noteData].endAnim.data.prefix, noteSkin.info.sustainInfoList[noteData].endAnim.data.framerate, true, noteSkin.info.sustainInfoList[noteData].endAnim.data.flipX, noteSkin.info.sustainInfoList[noteData].endAnim.data.flipY);
				case frame:
					animation.add("holdEnd", noteSkin.info.sustainInfoList[noteData].endAnim.data.frames, noteSkin.info.sustainInfoList[noteData].endAnim.data.framerate, true, noteSkin.info.sustainInfoList[noteData].endAnim.data.flipX, noteSkin.info.sustainInfoList[noteData].endAnim.data.flipY);
			}
		}

		setGraphicSize(Std.int(width * noteSkin.info.scale));
		updateHitbox();
		graphicScale = scale.x;

		animation.play("scroll");

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			xOffset += width / 2;
			
			flipY = Config.downscroll;

			animation.play("holdEnd");

			updateHitbox();

			xOffset -= width / 2;
			xOffset += noteSkin.info.offset.x;

			yOffset = noteSkin.info.offset.y;

			if (prevNote.isSustainNote){
				prevNote.isSustainEnd = false;
				prevNote.animation.play("hold");
				prevNote.updateHoldLength();
			}
		}

		if(noteSkin.info.functions.create != null){
			noteSkin.info.functions.create(this);
		}

	}

	override function update(elapsed:Float){

		super.update(elapsed);

		if(!editor){
			if (mustPress){
				if(isSustainNote){
					canBeHit = (strumTime < Conductor.songPosition + Conductor.badZone && (prevNote == null ? true : prevNote.wasGoodHit));
					if(wasGoodHit && isSustainEnd && (Config.noteSplashType == 1 || Config.noteSplashType == 4)){
						visible = false;
						if(prevNote != null && prevNote.isSustainNote){
							prevNote.visible = false;
						}
					}
				}
				else{
					canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
							 && strumTime < Conductor.songPosition + Conductor.safeZoneOffset);
				}

				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit){
					tooLate = true;
				}
				
			}
			else {
				canBeHit = (strumTime <= Conductor.songPosition);
			}

			inRange = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					&& !wasGoodHit;

			//Glow note stuff.

			if(Config.noteGlow){
				if (canBeHit && !isSustainNote && animation.curAnim.name == "scroll" && canGlow){
					glow();
				}

				if (tooLate && !isSustainNote && animation.curAnim.name == "glow"){
					idle();
				}
			}

			if(noteSkin.info.functions.update != null){
				noteSkin.info.functions.update(this, elapsed);
			}
		}

	}

	inline public function glow():Void{
		animation.play("glow");
	}

	inline public function idle():Void{
		animation.play("scroll");
	}

	public function updateHoldLength(_speedMultiplier:Float = 1){
		if(!isSustainNote || isSustainEnd){ return; }

		var speed = PlayState.SONG.speed;
		if(Config.scrollSpeedOverride > 0){
			speed = Config.scrollSpeedOverride;
		}
		speed *= _speedMultiplier;

		scale.y = graphicScale;
		scale.y *= Conductor.stepCrochet / 100 * 1.485 * speed;
		scale.y *= noteSkin.info.holdScaleAdjust;
		scale.y *= isFake ? 0.5 : 1;
		updateHitbox();

		if(isFake){ yOffset = noteSkin.info.offset.y + height; }
	}

	override public function destroy() {
		if(noteSkin.info.functions.destroy != null){
			noteSkin.info.functions.destroy(this);
		}

		super.destroy();
	}
}
