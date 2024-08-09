package note;

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

		var uiType:String = PlayState.curUiType;

		switch (uiType)
		{
			case 'pixel':
				loadGraphic(Paths.image('week6/weeb/pixelUI/arrows-pixels'), true, 19, 19);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				animation.add('green glow', [22]);
				animation.add('red glow', [23]);
				animation.add('blue glow', [21]);
				animation.add('purple glow', [20]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('week6/weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('ui/NOTE_assets');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				animation.addByPrefix('purple glow', 'Purple Active');
				animation.addByPrefix('green glow', 'Green Active');
				animation.addByPrefix('red glow', 'Red Active');
				animation.addByPrefix('blue glow', 'Blue Active');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		switch (noteData)
		{
			case PURP_NOTE:
				animation.play('purpleScroll');
			case BLUE_NOTE:
				animation.play('blueScroll');
			case GREEN_NOTE:
				animation.play('greenScroll');
			case RED_NOTE:
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			xOffset += width / 2;
			
			flipY = Config.downscroll;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}
			
			

			updateHitbox();

			xOffset -= width / 2;

			if (PlayState.curUiType == "pixel")
				xOffset += 36;

			if (prevNote.isSustainNote)
			{

				prevNote.isSustainEnd = false;
				
				switch (prevNote.noteData)
				{
					case GREEN_NOTE:
						prevNote.animation.play('greenhold');
					case RED_NOTE:
						prevNote.animation.play('redhold');
					case BLUE_NOTE:
						prevNote.animation.play('bluehold');
					case PURP_NOTE:
						prevNote.animation.play('purplehold');
				}
				
				var speed = PlayState.SONG.speed;

				if(Config.scrollSpeedOverride > 0){
					speed = Config.scrollSpeedOverride;
				}

				var mult:Float = 1;
				if(prevNote.isFake){ mult = 0.5; }

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.485 * speed;
				if(PlayState.curUiType == "pixel") {
					prevNote.scale.y *= 0.833 * (1.5 / 1.485); // Kinda weird, just roll with it.
				}
				
				prevNote.scale.y *= mult;

				prevNote.updateHitbox();

				if(prevNote.isFake){ prevNote.yOffset = prevNote.height; }
			}
		}

		if(type == "transparent"){
			alpha = 0.35;
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

			//Glow note stuff.

			if(Config.noteGlow){
				if (canBeHit && !isSustainNote && animation.curAnim.name.contains("Scroll")){
					glow();
				}

				if (tooLate && !isSustainNote && !animation.curAnim.name.contains("Scroll")){
					idle();
				}
			}
		}

	}

	public function glow():Void{

		switch (noteData)
		{
			case GREEN_NOTE:
				animation.play('green glow');
			case RED_NOTE:
				animation.play('red glow');
			case BLUE_NOTE:
				animation.play('blue glow');
			case PURP_NOTE:
				animation.play('purple glow');
		}

	}

	public function idle():Void{

		switch (noteData)
		{
			case GREEN_NOTE:
				animation.play('greenScroll');
			case RED_NOTE:
				animation.play('redScroll');
			case BLUE_NOTE:
				animation.play('blueScroll');
			case PURP_NOTE:
				animation.play('purpleScroll');
		}

	}
}
