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
	public var curCharacter:String = 'bf';

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

	public function new(x:Float, y:Float, ?character:String = "bf", ?_isPlayer:Bool = false, ?_enableDebug:Bool = false){

		debugMode = _enableDebug;
		animOffsets = new Map<String, Array<Dynamic>>();

		super(x, y);

		curCharacter = character;
		isPlayer = _isPlayer;

		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				
				createCharacterFromInfo("Gf");

			case 'gf-christmas':
				
				createCharacterFromInfo("GfChristmas");

			case 'gf-car':
				
				createCharacterFromInfo("GfCar");

			case 'gf-pixel':

				createCharacterFromInfo("GfPixel");

			case 'gf-tankmen':

				createCharacterFromInfo("GfTankmen");

			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('week7/bfAndGF');
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);

				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('bfCatch', 'BF catches GF', 24, false);
				
				addOffset("idle", 0, 0);
				addOffset("singUP", -29, 10);
				addOffset("singRIGHT", -41, 23);
				addOffset("singLEFT", 12, 7);
				addOffset("singDOWN", -10, -10);
				addOffset("singUPmiss", -29, 10);
				addOffset("singRIGHTmiss", -41, 23);
				addOffset("singLEFTmiss", 12, 7);
				addOffset("singDOWNmiss", -10, -10);
				addOffset("bfCatch", 0, 0);

				playAnim('idle');

				facesLeft = true;

				deathCharacter = "bf-holding-gf-dead";
				iconName = "bf";

			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('week7/bfHoldingGF-DEAD');
				animation.addByPrefix('firstDeath', "BF Dies with GF", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead with GF Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY confirm holding gf", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath', 37, 14);
				addOffset('deathLoop', 37, -3);
				addOffset('deathConfirm', 37, 28);
				playAnim('firstDeath');

				facesLeft = true;

				iconName = "bf";

			case 'dad':
				
				createCharacterFromInfo("Dad");

			case 'spooky':

				createCharacterFromInfo("Spooky");

			case 'mom':

				createCharacterFromInfo("Mom");

			case 'mom-car':

				createCharacterFromInfo("MomCar");

			case 'monster':

				createCharacterFromInfo("Monster");

			case 'monster-christmas':

				createCharacterFromInfo("MonsterChristmas");

			case 'pico':
				
				createCharacterFromInfo("Pico");

			case 'bf':

				createCharacterFromInfo("Bf");

			case 'bf-christmas':
				frames = Paths.getSparrowAtlas("week5/bfChristmas");
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				playAnim('idle');

				facesLeft = true;

				iconName = "bf";

			case 'bf-car':
				frames = Paths.getSparrowAtlas("week4/bfCar");
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				playAnim('idle');

				facesLeft = true;
				
				iconName = "bf";

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas("week6/bfPixel");
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP", -6);
				addOffset("singRIGHT");
				addOffset("singLEFT", -12);
				addOffset("singDOWN");
				addOffset("singUPmiss", -6);
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss", -12);
				addOffset("singDOWNmiss");

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				deathCharacter = "bf-pixel-dead";
				iconName = "bf-pixel";

				facesLeft = true;

			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas("week6/bfPixelsDEAD");
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('deathLoop', -36);
				addOffset('deathConfirm', -36);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				facesLeft = true;

				iconName = "bf-pixel";

			case 'bf-lil':
				loadGraphic(Paths.image("chartEditor/lilBf"), true, 300, 256);

				animation.add("idle", [0, 1], 12, true);

				animation.add("singLEFT", 	[3, 4, 5], 		12, false);
				animation.add("singDOWN", 	[6, 7, 8], 		12, false);
				animation.add("singUP", 	[9, 10, 11], 	12, false);
				animation.add("singRIGHT", 	[12, 13, 14], 	12, false);

				animation.add("singLEFTmiss", 	[3, 15, 15, 16, 16], 	24, false);
				animation.add("singDOWNmiss", 	[6, 18, 18, 19, 19], 	24, false);
				animation.add("singUPmiss", 	[9, 21, 21, 22, 22], 	24, false);
				animation.add("singRIGHTmiss", 	[12, 24, 24, 25, 25], 	24, false);

				animation.add("hey", [17, 20, 23], 12, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");
				addOffset("hey");

				playAnim('idle');

				facesLeft = true;
				antialiasing = false;

				iconName = "bf-lil";

			case 'senpai':
				frames = Paths.getSparrowAtlas("week6/senpai");
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 12, 36);
				addOffset("singRIGHT", 6);
				addOffset("singLEFT", 30);
				addOffset("singDOWN", 12);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				iconName = "senpai";

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas("week6/senpai");
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 6, 36);
				addOffset("singRIGHT");
				addOffset("singLEFT", 24, 6);
				addOffset("singDOWN", 6, 6);
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				iconName = "senpai-angry";

			case 'spirit':
				frames = Paths.getPackerAtlas("week6/spirit");
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -238);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -202, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				iconName = "spirit";

			case 'parents-christmas':
				
				createCharacterFromInfo("ParentsChristmas");

			case "tankman":
				frames = Paths.getSparrowAtlas("week7/tankmanCaptain");

				animation.addByPrefix('idle', "Tankman Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note ', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note ', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Right Note ', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Note Left ', 24, false);

				animation.addByPrefix('prettyGood', 'PRETTY GOOD', 24, false);
				animation.addByPrefix('ugh', 'TANKMAN UGH', 24, false);

				/*addOffset("idle", 0, 0);
				addOffset("singDOWN", 78, -106);
				addOffset("singRIGHT", -18, -30);
				addOffset("singUP", 51, 51);
				addOffset("singLEFT", 85, -11);
				addOffset("ugh", -14, -8);
				addOffset("prettyGood", 0, 15);*/

				addOffset("idle", 0, 0);
				addOffset("singLEFT", 91, -25);
				addOffset("singDOWN", 68, -106);
				addOffset("ugh", -14, -8);
				addOffset("singRIGHT", -23, -11);
				addOffset("singUP", 27, 58);
				addOffset("prettyGood", 101, 15);

				facesLeft = true;
				playAnim('idle');

				iconName = "tankman";

			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('week7/picoSpeaker');

				animation.addByPrefix('shoot1', "Pico shoot 1", 24, false);
				animation.addByPrefix('shoot2', "Pico shoot 2", 24, false);
				animation.addByPrefix('shoot3', "Pico shoot 3", 24, false);
				animation.addByPrefix('shoot4', "Pico shoot 4", 24, false);

				// here for now, will be replaced later for less copypaste
				addOffset("shoot3", 413, -64);
				addOffset("shoot1", 0, 0);
				addOffset("shoot4", 440, -19);
				addOffset("shoot2", 0, -128);

				playAnim('shoot1');

				iconName = "pico";

			case 'guy-lil':
				loadGraphic(Paths.image("chartEditor/lilOpp"), true, 300, 256);

				animation.add("idle", [0, 1], 12, true);

				animation.add("singLEFT", 	[3, 4, 5], 		12, false);
				animation.add("singDOWN", 	[6, 7, 8], 		12, false);
				animation.add("singUP", 	[9, 10, 11], 	12, false);
				animation.add("singRIGHT", 	[12, 13, 14], 	12, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");

				playAnim('idle');

				antialiasing = false;

				iconName = "face-lil";

		}

		dance();

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
					if (animation.curAnim == null || !animation.curAnim.name.startsWith('hair'))
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
			else { trace(AnimName + "-" + animSet + " not found. Reverting to " + AnimName); }
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
						playAnim(name, false, false, 10);
					case "singUP":
						playAnim(name, false, false, 8);
					case "singDOWN":
						playAnim(name, false, false, 7);
					case "singLEFT":
						playAnim(name, false, false, 5);
					case "singRIGHT":
						playAnim(name, false, false, 6);
				}

			case "pico-speaker":
				playAnim(animation.curAnim.name, false, false, animation.curAnim.numFrames - 3);

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

		//This should be used if you need to pass any weird non-standard data to the character (ex: pixel character scales)
		if(char.info.extraData != null){
			for(type => data in char.info.extraData){
				switch(type){
					case "stepsUntilRelease":
						stepsUntilRelease = data;
					case "scale":
						setGraphicSize(Std.int(width * data));
						updateHitbox();
					case "adjustHitboxSize":
						width += data[0];
						height += data[1];
					default:
						//Do nothing by default.
				}
			}
		}

		/*if(char.info.anims.length > 0){
			playAnim(char.info.anims[0].name);
		}*/

		danced = true;
		dance();

	}

	/*
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
	var loop:Bool;
	var flipX:Bool;
	var flipY:Bool;
	var offset:Array<Float>;
}

	info = {
            name: "",
            spritePath: "",
            frameLoadType: sparrow,
            iconName: "",
            deathCharacter: "",
            healthColor: null,
            facesLeft: false,
            hasLeftAndRightIdle: false,
            antialiasing: true,
            anims: []
        };
	*/
}
