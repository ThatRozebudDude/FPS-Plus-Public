package;

import characters.CharacterInfoBase;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import stages.elements.*;

using StringTools;

class Character extends FlxSprite
{

	//Global character properties.
	public static final LOOP_ANIM_ON_HOLD:Bool = true; 	//Determines whether hold notes will loop the sing animation. Default is true.
	public static final HOLD_LOOP_WAIT:Bool = true; 	//Determines whether hold notes will only loop the sing animation if 4 frames of animation have passed. Default is true for FPS Plus, false for base game.
	public static final USE_IDLE_END:Bool = false; 		//Determines whether you will go back to the start of the idle or the end of the idle when letting go of a note. Default is false.

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = "bf";
	public var charClass:String = "Bf";

	public var holdTimer:Float = 0;
	public var stepsUntilRelease:Float = 4;

	public var canAutoAnim:Bool = true;
	public var danceLockout:Bool = false;
	public var animSet:String = "";

	public var deathCharacter:String = "bf";
	public var iconName:String = "face";
	public var characterColor:Null<FlxColor> = null;

	var facesLeft:Bool = false;
	var hasLeftAndRightIdle:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "Bf", ?_isPlayer:Bool = false, ?_enableDebug:Bool = false){

		debugMode = _enableDebug;
		animOffsets = new Map<String, Array<Dynamic>>();

		super(x, y);

		isPlayer = _isPlayer;

		antialiasing = true;

		charClass = character;

		createCharacterFromInfo(charClass);

		if (((facesLeft && !isPlayer) || (!facesLeft && isPlayer)) && !debugMode){

			flipX = true;

			// var animArray
			var oldRight = animation.getByName("singRIGHT").frames;
			var oldRightOffset = animOffsets.get("singRIGHT");
			animation.getByName("singRIGHT").frames = animation.getByName("singLEFT").frames;
			animOffsets.set("singRIGHT", animOffsets.get("singLEFT"));
			animation.getByName('singLEFT').frames = oldRight;
			animOffsets.set("singLEFT", oldRightOffset);

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singRIGHTmiss') != null){
				var oldMiss = animation.getByName("singRIGHTmiss").frames;
				var oldMissOffset = animOffsets.get("singRIGHTmiss");
				animation.getByName("singRIGHTmiss").frames = animation.getByName("singLEFTmiss").frames;
				animOffsets.set("singRIGHTmiss", animOffsets.get("singLEFTmiss"));
				animation.getByName('singLEFTmiss').frames = oldMiss;
				animOffsets.set("singLEFTmiss", oldMissOffset);
			}
		}

		animation.finishCallback = animationEnd;

		if(characterColor == null){
			characterColor = (isPlayer) ? 0xFF66FF33 : 0xFFFF0000;
		}

	}

	override function update(elapsed:Float){
		
		if (!debugMode){
			if (!isPlayer){
				if (animation.curAnim.name.startsWith('sing')){
					holdTimer += elapsed;
				}
				
				if (holdTimer >= Conductor.stepCrochet * stepsUntilRelease * 0.001 && canAutoAnim){
					if(USE_IDLE_END){ 
						idleEnd(); 
					}
					else{ 
						dance(); 
						danceLockout = true;
					}
					holdTimer = 0;
				}
			}
			else{
				if (animation.curAnim.name.startsWith('sing')){
					holdTimer += elapsed;
				}
				else{
					holdTimer = 0;
				}
					
				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && canAutoAnim){
					if(USE_IDLE_END){ 
						idleEnd(); 
					}
					else{ 
						dance(); 
						danceLockout = true;
					}
				}
			}
	
			switch (curCharacter)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
	
				case "pico-speaker":
					// for pico??
					if (TankmenBG.animationNotes.length > 0){
						if (Conductor.songPosition > TankmenBG.animationNotes[0][0]){
							//trace('played shoot anim' + TankmenBG.animationNotes[0][1]);
	
							var shootAnim:Int = 1;
	
							if (TankmenBG.animationNotes[0][1] >= 2)
								shootAnim = 3;
	
							shootAnim += FlxG.random.int(0, 1);
	
							playAnim('shoot' + shootAnim, true);
							TankmenBG.animationNotes.shift();
						}
					}
			}
		}

		super.update(elapsed);
		changeOffsets();

	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{

			if(danceLockout){
				danceLockout = false;
				return;
			}

			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', true);
						else
							playAnim('danceLeft', true);
					}

				case "pico-speaker":
					playAnim('shoot1');

				default:
					if(hasLeftAndRightIdle){
						danced = !danced;

						if (danced)
							playAnim('danceRight', true);
						else
							playAnim('danceLeft', true);
					}
					else{
						playAnim('idle', true);
					}
					
			}
		}
	}

	public function idleEnd(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case "pico-speaker":
					playAnim(animation.curAnim.name, true, false, animation.getByName(animation.curAnim.name).numFrames - 1);
				default:
					if(hasLeftAndRightIdle){
						playAnim('danceRight', true, false, animation.getByName('danceRight').numFrames - 1);
					}
					else{
						playAnim('idle', true, false, animation.getByName('idle').numFrames - 1);
					}
					
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{

		if(animSet != ""){
			if(animation.exists(AnimName + "-" + animSet)){
				AnimName = AnimName + "-" + animSet;
			}
			//else { trace(AnimName + "-" + animSet + " not found. Reverting to " + AnimName); }
		}

		animation.play(AnimName, Force, Reversed, Frame);
		changeOffsets();

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	function changeOffsets() {
		if (animOffsets.exists(animation.curAnim.name)) { 
			var animOffset = animOffsets.get(animation.curAnim.name);

			var xOffsetAdjust:Float = animOffset[0];
			if(flipX == true){
				xOffsetAdjust *= -1;
				xOffsetAdjust += frameWidth;
				xOffsetAdjust -= width;
			}

			var yOffsetAdjust:Float = animOffset[1];
			/*if(flipY == true){
				yOffsetAdjust *= -1;
				yOffsetAdjust += frameHeight;
				yOffsetAdjust -= height;
			}*/

			offset.set(xOffsetAdjust, yOffsetAdjust); 
		}
		else { offset.set(0, 0); }
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function animationEnd(name:String){

		danceLockout = false;

		switch(curCharacter){
			case "dad" | "mom" | "mom-car" | "bf-car":
				playAnim(name, true, false, animation.getByName(name).numFrames - 4);

			case "bf" | "bf-christmas" | "bf-pixel" | "bf-holding-gf" | "pico":
				if(name.contains("miss")){
					playAnim(name, true, false, animation.getByName(name).numFrames - 4);
				}

			case "bf-lil" | "guy-lil":
				if(name.contains("miss")){
					playAnim(name, true, false, animation.getByName(name).numFrames - 4);
				}
				else{
					playAnim(name, true, false, animation.getByName(name).numFrames - 2);
				}

			case "monster-christmas" | "monster":
				switch(name){
					case "idle":
						playAnim(name, true, false, 10);
					case "singUP":
						playAnim(name, true, false, 8);
					case "singDOWN":
						playAnim(name, true, false, 7);
					case "singLEFT":
						playAnim(name, true, false, 5);
					case "singRIGHT":
						playAnim(name, true, false, 6);
				}

			case "pico-speaker":
				playAnim(animation.curAnim.name, true, false, animation.curAnim.numFrames - 3);

		}

	}

	function createCharacterFromInfo(name:String) {

		var characterClass = Type.resolveClass("characters." + name);
		if(characterClass == null){ characterClass = characters.Bf; }
		var char:CharacterInfoBase = Type.createInstance(characterClass, []);
		
		curCharacter = char.info.name;
		iconName = char.info.iconName;
		deathCharacter = char.info.deathCharacter;
		characterColor = char.info.healthColor;
		facesLeft = char.info.facesLeft;
		hasLeftAndRightIdle = char.info.hasLeftAndRightIdle;
		antialiasing = char.info.antialiasing;

		switch(char.info.frameLoadType){
			case load(x, y):
				loadGraphic(Paths.image(char.info.spritePath), true, x, y);
			case sparrow:
				frames = Paths.getSparrowAtlas(char.info.spritePath);
			case packer:
				frames = Paths.getPackerAtlas(char.info.spritePath);
		}

		for(x in char.info.anims){
			switch(x.type){
				case frames:
					animation.add(x.name, x.data.frames, x.data.framerate, x.data.loop, x.data.flipX, x.data.flipY);
				case prefix:
					animation.addByPrefix(x.name, x.data.prefix, x.data.framerate, x.data.loop, x.data.flipX, x.data.flipY);
				case indices:
					animation.addByIndices(x.name, x.data.prefix, x.data.frames, x.data.postfix, x.data.framerate, x.data.loop, x.data.flipX, x.data.flipY);
			}
			addOffset(x.name, x.data.offset[0], x.data.offset[1]);
		}

		if(char.info.anims.length > 0){
			playAnim(char.info.anims[0].name);
			danced = true;
			dance();
		}

		//This should be used if you need to pass any weird non-standard data to the character
		if(char.info.extraData != null){
			for(type => data in char.info.extraData){
				switch(type){
					case "stepsUntilRelease":
						stepsUntilRelease = data;
					case "scale":
						setGraphicSize(Std.int(width * data));
						updateHitbox();
					default:
						//Do nothing by default.
				}
			}
		}

	}

}
