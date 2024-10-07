package;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxSignal;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import characters.CharacterInfoBase;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import stages.elements.*;

using StringTools;

class Character extends FlxSpriteGroup
{

	//Global character properties.
	public static final LOOP_ANIM_ON_HOLD:Bool = true;		//Determines whether hold notes will loop the sing animation. Default is true.
	public static final HOLD_LOOP_WAIT:Bool = true;			//Determines whether hold notes will only loop the sing animation if 4 frames of animation have passed. Default is true for FPS Plus, false for base game.
	public static final USE_IDLE_END:Bool = false;			//Determines whether you will go back to the start of the idle or the end of the idle when letting go of a note. Default is false.
	public static final PREVENT_SHORT_IDLE:Bool = true;		//Prevents characters from quickly playing a few frames of their idles inbetween hitting notes. Default is true for FPS Plus, false for base game.
	public static final PREVENT_SHORT_SING:Bool = true;		//Prevents characters from quickly playing a few frames of their sing animation when hitting multiple notes. Default is true for FPS Plus, false for base game.
	public static final SHORT_SING_TOLERENCE:Float = 20;	//Millisecond tolerence for PREVENT_SHORT_SING detection.

	public var animOffsets:Map<String, Array<Dynamic>>;
	private var originalAnimOffsets:Map<String, Array<Dynamic>>;
	private var animLoopPoints:Map<String, Int>;
	public var repositionPoint:FlxPoint = new FlxPoint();
	public var debugMode:Bool = false;
	public var noLogic:Bool = false;

	public var isPlayer:Bool = false;
	public var isGirlfriend:Bool = false;
	public var curCharacter:String = "bf";
	public var charClass:String = "Bf";

	public var holdTimer:Float = 0;
	public var stepsUntilRelease:Float = 4;
	public var isSinging:Bool = false;
	public var timeInCurrentAnimation:Float = 0;
	public var lastSingTime:Float = -5000;

	public var canAutoAnim:Bool = true;
	public var danceLockout:Bool = false;
	public var animSet:String = "";

	public var deathCharacter:String = "bf";
	public var iconName:String = "face";
	public var characterColor:Null<FlxColor> = null;

	public var curAnim:String = "";

	var facesLeft:Bool = false;

	public var idleSequence:Array<String> = ["idle"];
	public var idleSequenceIndex:Int = 0;

	public var focusOffset:FlxPoint;
	public var deathOffset:FlxPoint;
	public var deathDelay:Float = 0.5;

	public var worldPopupOffset:FlxPoint = new FlxPoint();

	var character:FlxSprite;
	var atlasCharacter:AtlasSprite;
	public var characterInfo:CharacterInfoBase;

	var curOffset = new FlxPoint();

	//var added:Bool = false;

	public var deathSound:String = "gameOver/fnf_loss_sfx";
	public var deathSong:String = "gameOver/gameOver";
	public var deathSongEnd:String = "gameOver/gameOverEnd";

	public var onPlayAnim:FlxTypedSignal<(String, Bool, Bool, Int) -> Void> = new FlxTypedSignal();
	public var onSing:FlxTypedSignal<(String, Bool, Bool, Int) -> Void> = new FlxTypedSignal();
	public var onDance:FlxTypedSignal<Void -> Void> = new FlxTypedSignal();

	public function new(x:Float, y:Float, ?_character:String = "Bf", ?_isPlayer:Bool = false, ?_isGirlfriend:Bool = false, ?_enableDebug:Bool = false){

		debugMode = _enableDebug;
		animOffsets = new Map<String, Array<Dynamic>>();
		originalAnimOffsets = new Map<String, Array<Dynamic>>();
		animLoopPoints = new Map<String, Int>();

		super(x, y);

		isPlayer = _isPlayer;
		isGirlfriend = _isGirlfriend;

		antialiasing = true;

		charClass = _character;

		createCharacterFromInfo(charClass);

		if (((facesLeft && !isPlayer) || (!facesLeft && isPlayer)) && !debugMode){

			if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
				setFlipX(true);

				if (character.animation.getByName('singRIGHT') != null){
					var oldRight = character.animation.getByName("singRIGHT").frames;
					var oldRightOffset = animOffsets.get("singRIGHT");
					var oldRightOffsetOriginal = originalAnimOffsets.get("singRIGHT");
					character.animation.getByName("singRIGHT").frames = character.animation.getByName("singLEFT").frames;
					animOffsets.set("singRIGHT", animOffsets.get("singLEFT"));
					originalAnimOffsets.set("singRIGHT", originalAnimOffsets.get("singLEFT"));
					character.animation.getByName('singLEFT').frames = oldRight;
					animOffsets.set("singLEFT", oldRightOffset);
					originalAnimOffsets.set("singLEFT", oldRightOffsetOriginal);
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (character.animation.getByName('singRIGHTmiss') != null){
					var oldMiss = character.animation.getByName("singRIGHTmiss").frames;
					var oldMissOffset = animOffsets.get("singRIGHTmiss");
					var oldMissOffsetOriginal = originalAnimOffsets.get("singRIGHTmiss");
					character.animation.getByName("singRIGHTmiss").frames = character.animation.getByName("singLEFTmiss").frames;
					animOffsets.set("singRIGHTmiss", animOffsets.get("singLEFTmiss"));
					originalAnimOffsets.set("singRIGHTmiss", originalAnimOffsets.get("singLEFTmiss"));
					character.animation.getByName('singLEFTmiss').frames = oldMiss;
					animOffsets.set("singLEFTmiss", oldMissOffset);
					originalAnimOffsets.set("singLEFTmiss", oldMissOffsetOriginal);
				}
			}
			else { //Code for atlas characters
				setFlipX(true);

				if (atlasCharacter.animInfoMap.get("singRIGHT") != null){
					var oldRight = atlasCharacter.animInfoMap.get("singRIGHT");
					var oldRightOffset = animOffsets.get("singRIGHT");
					var oldRightOffsetOriginal = originalAnimOffsets.get("singRIGHT");
					atlasCharacter.animInfoMap.set("singRIGHT", atlasCharacter.animInfoMap.get("singLEFT"));
					animOffsets.set("singRIGHT", animOffsets.get("singLEFT"));
					originalAnimOffsets.set("singRIGHT", originalAnimOffsets.get("singLEFT"));
					atlasCharacter.animInfoMap.set("singLEFT", oldRight);
					animOffsets.set("singLEFT", oldRightOffset);
					originalAnimOffsets.set("singLEFT", oldRightOffsetOriginal);
				}

				if (atlasCharacter.animInfoMap.get("singRIGHTmiss") != null){
					var oldMiss = atlasCharacter.animInfoMap.get("singRIGHTmiss");
					var oldMissOffset = animOffsets.get("singRIGHTmiss");
					var oldMissOffsetOriginal = originalAnimOffsets.get("singRIGHTmiss");
					atlasCharacter.animInfoMap.set("singRIGHTmiss", atlasCharacter.animInfoMap.get("singLEFTmiss"));
					animOffsets.set("singRIGHTmiss", animOffsets.get("singLEFTmiss"));
					originalAnimOffsets.set("singRIGHTmiss", originalAnimOffsets.get("singLEFTmiss"));
					atlasCharacter.animInfoMap.set("singLEFTmiss", oldMiss);
					animOffsets.set("singLEFTmiss", oldMissOffset);
					originalAnimOffsets.set("singLEFTmiss", oldMissOffsetOriginal);
				}
			}

		}

		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			character.animation.finishCallback = animationEnd;
			character.animation.callback = frameUpdate;
		}
		else { //Code for atlas characters
			atlasCharacter.animationEndCallback = animationEnd;
			atlasCharacter.frameCallback = frameUpdate;
		}

		if(characterColor == null){
			characterColor = (isPlayer) ? 0xFF66FF33 : 0xFFFF0000;
		}

	}

	override function update(elapsed:Float){
		
		if (!debugMode && !noLogic){
			if (!isPlayer){
				//opponent stuff
				if (isSinging){
					holdTimer += elapsed;
				}
				else{
					holdTimer = 0;
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
				//player stuff
				if (isSinging){
					holdTimer += elapsed;
				}
				else{
					holdTimer = 0;
				}
					
				if (curAnim.endsWith('miss') && curAnimFinished() && canAutoAnim){
					if(USE_IDLE_END){ 
						idleEnd(); 
					}
					else{ 
						dance(); 
						danceLockout = true;
					}
				}
			}

			if(characterInfo.info.functions.update != null){
				characterInfo.info.functions.update(this, elapsed);
			}
		}

		timeInCurrentAnimation += elapsed;

		super.update(elapsed);

	}

	public function dance(?ignoreDebug:Bool = false):Void{
		if ((!debugMode || ignoreDebug) && !noLogic)
		{

			if(danceLockout){
				danceLockout = false;
				return;
			}

			if(characterInfo.info.functions.danceOverride != null){
				characterInfo.info.functions.danceOverride(this);
			}
			else{
				defaultDanceBehavior();
			}

			if(characterInfo.info.functions.dance != null){
				characterInfo.info.functions.dance(this);
			}

			onDance.dispatch();

		}
	}

	public function defaultDanceBehavior():Void{
		if(idleSequence.length > 0){
			idleSequenceIndex = idleSequenceIndex % idleSequence.length;
			playAnim(idleSequence[idleSequenceIndex], true);
			idleSequenceIndex++;
		}
	}

	public function idleEnd(?ignoreDebug:Bool = false):Void{
		if (!debugMode || ignoreDebug){
			if(characterInfo.info.functions.idleEndOverride != null){
				characterInfo.info.functions.idleEndOverride(this);
			}
			else{
				defaultIdleEndBehavior();
			}

			if(characterInfo.info.functions.idleEnd != null){
				characterInfo.info.functions.idleEnd(this);
			}
		}
	}

	public function defaultIdleEndBehavior():Void{
		if(idleSequence.length > 0){
			playAnim(idleSequence[idleSequence.length-1], true, false, getAnimLength(idleSequence[idleSequence.length-1]) - 1);
		}
	}

	public function beat(curBeat:Int):Void{
		if(characterInfo.info.functions.beat != null && !noLogic){
			characterInfo.info.functions.beat(this, curBeat);
		}
	}

	public function step(curStep:Int):Void{
		if(characterInfo.info.functions.step != null && !noLogic){
			characterInfo.info.functions.step(this, curStep);
		}
	}

	/**
	 * Plays an animation based on the parameters.
	 *
	 * @param	AnimName				The name of the animation you want to play. Will automatic be suffixed with "-" followed by whatever `animSet` is set to if it's not an empty string.
	 * @param	Force					If `true` it will force the animation to play no matter what. If `false` the animation will only play if it isn't currently playing or is finished.
	 * @param	Reversed				If `true` the animation will play backwards.
	 * @param	Frame					The frame number that the animation should start on.
	 * @param	isPartOfLoopingAnim		***DO NOT USE THIS.*** This is used by `Character.hx` to determine if the function is being used to loop an animation.
	 * 
	 * @return  						Returns `true` if the animation was played. Returns `false` if the animation wasn't found and could not be played.
	 */
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, ?isPartOfLoopingAnim:Bool = false):Bool{

		if(animSet != "" && !isPartOfLoopingAnim){
			if(animOffsets.exists(AnimName + "-" + animSet)){
				AnimName = AnimName + "-" + animSet;
			}
		}

		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			if(character.animation.getByName(AnimName) == null) { return false; }
			character.animation.play(AnimName, Force, Reversed, Frame);
		}
		else{ //Code for atlas characters
			if(atlasCharacter.animInfoMap.get(AnimName) == null) { return false; }
			atlasCharacter.playAnim(AnimName, Force, Reversed, Frame);
		}

		//Change/reset variables n stuff
		if(!isPartOfLoopingAnim){
			curAnim = AnimName;
			changeOffsets();
			isSinging = false;
			timeInCurrentAnimation = 0;
			onPlayAnim.dispatch(AnimName, Force, Reversed, Frame);
			if(characterInfo.info.functions.playAnim != null){
				characterInfo.info.functions.playAnim(this, AnimName);
			}
		}

		return true;

	}

	//You can treat any animation as a singing animation instead of requiring "sing" to be in the animation name.
	public function singAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, ?isPartOfLoopingAnim:Bool = false) {
		var animPlayed:Bool = playAnim(AnimName, Force, Reversed, Frame, isPartOfLoopingAnim);
		if(animPlayed){
			isSinging = true;
			lastSingTime = Conductor.songPosition;
			onSing.dispatch(AnimName, Force, Reversed, Frame);
		}
	}

	function changeOffsets() {
		if (animOffsets.exists(curAnim)) { 
			var animOffset = animOffsets.get(curAnim);

			var xOffsetAdjust:Float = animOffset[0];
			if(getFlipX()){
				xOffsetAdjust *= -1;
				if(characterInfo.info.frameLoadType != atlas){
					xOffsetAdjust += getFrameWidth();
					xOffsetAdjust -= getWidth();
				}
			}

			var yOffsetAdjust:Float = animOffset[1];
			if(getFlipY()){
				yOffsetAdjust *= -1;
				if(characterInfo.info.frameLoadType != atlas){
					yOffsetAdjust += getFrameHeight();
					yOffsetAdjust -= getHeight();
				}
			}

			curOffset.set(-xOffsetAdjust, -yOffsetAdjust);

		}
		else {
			curOffset.set(0, 0);
		}

		updateCharacterPostion();
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0, ?addToOriginal:Bool = false){
		animOffsets[name] = [x, y];
		if(addToOriginal){ originalAnimOffsets[name] = [x, y]; }
	}

	function animationEnd(name:String){
		danceLockout = false;
		
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			//custom method for looping animations since the anim end callback doesnt run on looped anmations normally
			if(animLoopPoints.exists(name)){
				playAnim(name, true, false, animLoopPoints.get(name), true);
			}
		}
		//Not needed for atlas since this is built in to the AtlasSprite functionality.

		if(!debugMode){
			//Checks for and plays a chained animation.
			if(characterInfo.info.animChains.exists(name)){
				playAnim(characterInfo.info.animChains.get(name));
			}

			if(characterInfo.info.functions.animationEnd != null){
				characterInfo.info.functions.animationEnd(this, name);
			}
		}
		
	}

	function frameUpdate(name:String, frameNumber:Int, frameIndex:Int){
		changeOffsets();

		if(!debugMode){
			if(characterInfo.info.functions.frame != null){
				characterInfo.info.functions.frame(this, name, frameNumber);
			}
		}
	}

	function createCharacterFromInfo(name:String):Void{

		var characterClass = Type.resolveClass("characters.data." + name);
		if(characterClass == null){ characterClass = characters.data.Bf; }
		characterInfo = Type.createInstance(characterClass, []);

		characterInfo.characterReference = this;
		
		curCharacter = characterInfo.info.name;
		iconName = characterInfo.info.iconName;
		deathCharacter = characterInfo.info.deathCharacter;
		characterColor = characterInfo.info.healthColor;
		facesLeft = characterInfo.info.facesLeft;
		idleSequence = characterInfo.info.idleSequence;
		focusOffset = characterInfo.info.focusOffset;
		deathOffset = characterInfo.info.deathOffset;

		if(isPlayer){ focusOffset.x *= -1; }

		if(characterInfo.info.animChains == null){ characterInfo.info.animChains = new Map<String, String>(); }

		switch(characterInfo.info.frameLoadType){
			case load(fw, fh):
				character = new FlxSprite();
				character.loadGraphic(Paths.image(characterInfo.info.spritePath), true, fw, fh);
			case sparrow:
				character = new FlxSprite();
				character.frames = Paths.getSparrowAtlas(characterInfo.info.spritePath);
			case packer:
				character = new FlxSprite();
				character.frames = Paths.getPackerAtlas(characterInfo.info.spritePath);
			case atlas:
				atlasCharacter = new AtlasSprite(0, 0, Paths.getTextureAtlas(characterInfo.info.spritePath));
		}

		for(x in characterInfo.info.anims){
			switch(x.type){
				case frames:
					character.animation.add(x.name, x.data.frames, x.data.framerate, false, x.data.flipX, x.data.flipY);
				case prefix:
					character.animation.addByPrefix(x.name, x.data.prefix, x.data.framerate, false, x.data.flipX, x.data.flipY);
				case indices:
					character.animation.addByIndices(x.name, x.data.prefix, x.data.frames, x.data.postfix, x.data.framerate, false, x.data.flipX, x.data.flipY);
				case label:
					atlasCharacter.addAnimationByLabel(x.name, x.data.prefix, x.data.framerate, x.data.loop.looped, x.data.loop.loopPoint);
				case start:
					atlasCharacter.addAnimationByFrame(x.name, x.data.frames[0], x.data.frames[1], x.data.framerate, x.data.loop.looped, x.data.loop.loopPoint);
				case startAtLabel:
					atlasCharacter.addAnimationStartingAtLabel(x.name, x.data.prefix, x.data.frames[0], x.data.framerate, x.data.loop.looped, x.data.loop.loopPoint);
			}

			if(characterInfo.info.frameLoadType != atlas){
				if(x.data.loop.looped){
					if(x.data.loop.loopPoint < 0){
						animLoopPoints.set(x.name, character.animation.getByName(x.name).numFrames + x.data.loop.loopPoint);
					}
					else{
						animLoopPoints.set(x.name, x.data.loop.loopPoint);
					}
				}
			}
			
			addOffset(x.name, x.data.offset[0], x.data.offset[1], true);

		}

		if(characterInfo.info.anims.length > 0){
			playAnim(characterInfo.info.anims[0].name);
			dance();
		}

		//This should be used if you need to pass any weird non-standard data to the character
		if(characterInfo.info.extraData != null){
			for(type => data in characterInfo.info.extraData){
				switch(type){
					case "stepsUntilRelease":
						stepsUntilRelease = data;
					case "scale":
						changeCharacterScale(data);
					case "reposition":
						repositionPoint.set(data[0], data[1]);
					case "deathDelay":
						deathDelay = data;
					case "deathSound":
						deathSound = data;
					case "deathSong":
						deathSong = data;
					case "deathSongEnd":
						deathSongEnd = data;
					case "worldPopupOffset":
						worldPopupOffset.set(data[0], data[1]);
					default:
						//Do nothing by default.
				}
			}
		}

		if(characterInfo.info.functions.create != null){
			characterInfo.info.functions.create(this);
		}

		if(character != null){ 
			character.antialiasing = characterInfo.info.antialiasing;
			add(character);
		}
		if(atlasCharacter != null){
			atlasCharacter.antialiasing = characterInfo.info.antialiasing;
			add(atlasCharacter);
		}

	}

	//Update character scale and adjust the character's offsets
	public function changeCharacterScale(_scaleX:Float, ?_scaleY:Null<Float> = null):Void{
		if(debugMode){ return; }
		if(_scaleY == null){ _scaleY = _scaleX; }

		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			character.scale.set(_scaleX, _scaleY);
			character.updateHitbox();
			var offsetBase = new FlxPoint(offset.x, offset.y);
			for(name => pos in animOffsets){
				addOffset(name, offsetBase.x + (originalAnimOffsets.get(name)[0] * _scaleX), offsetBase.y + (originalAnimOffsets.get(name)[1] * _scaleY));
			}
		}
		else{ //Code for atlas characters
			atlasCharacter.scale.set(_scaleX, _scaleY);
			atlasCharacter.updateHitbox();
			var offsetBase = new FlxPoint(offset.x, offset.y);
			for(name => pos in animOffsets){
				addOffset(name, offsetBase.x + (originalAnimOffsets.get(name)[0] * _scaleX), offsetBase.y + (originalAnimOffsets.get(name)[1] * _scaleY));
			}
		}
		
	}

	function updateCharacterPostion():Void{
		if(character != null){ //Code for sheet characters
			character.setPosition(x + curOffset.x, y + curOffset.y);
		}
		else if(atlasCharacter != null){ //Code for atlas characters
			atlasCharacter.setPosition(x + curOffset.x, y + curOffset.y);
		}
	}

	public function attachCharacter(child:Character, attachedActions:Array<AttachedAction>){
		if(attachedActions.contains(withDance)){
			onDance.add(function(){
				child.dance();
			});
		}
		if(attachedActions.contains(withSing)){
			onSing.add(function(anim:String, force:Bool, reverse:Bool, frame:Int){
				child.singAnim(anim, force, reverse, frame);
			});
		}
		if(attachedActions.contains(withPlayAnim)){
			onPlayAnim.add(function(anim:String, force:Bool, reverse:Bool, frame:Int){
				child.playAnim(anim, force, reverse, frame);
			});	
		}
	}

	public function doAction(action:String){
		if(characterInfo.info.actions == null) { return; }
		else{
			if(characterInfo.info.actions.get(action) != null){
				characterInfo.info.actions.get(action)(this);
			}
			else{
				trace("Action \"" + action + "\" not found.");
			}
		}
	}

	//Checks if the object has a custom applyShader function and runs that if found. Basically just used for ABot as of right now.
	public function applyShader(shader:FlxShader):Void{
		for(member in members){
			if(Type.getInstanceFields(Type.getClass(member)).contains("applyShader")){
				Reflect.callMethod(member, Reflect.field(member, "applyShader"), [shader]);
			}
			else{ member.shader = shader; }
		}
	}

	public function reposition():Void{
		x += repositionPoint.x;
		y += repositionPoint.y;

		for(member in members){
			member.x += repositionPoint.x;
			member.y += repositionPoint.y;
		}

		updateCharacterPostion();
	}



	public function setFlipX(value:Bool):Void {
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			character.flipX = value;
		}
		else{ //Code for atlas characters
			atlasCharacter.flipX = value;
		}
	}

	public function setFlipY(value:Bool):Void {
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			character.flipY = value;
		}
		else{ //Code for atlas characters
			atlasCharacter.flipY = value;
		}
	}

	public function getFlipX():Bool {
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.flipX;
		}
		else{ //Code for atlas characters
			return atlasCharacter.flipX;
		}
	}

	public function getFlipY():Bool {
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.flipY;
		}
		else{ //Code for atlas characters
			return atlasCharacter.flipY;
		}
	}

	public function getWidth():Float{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.width;
		}
		else{ //Code for atlas characters
			return atlasCharacter.width;
		}
	}

	public function getHeight():Float{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.height;
		}
		else{ //Code for atlas characters
			return atlasCharacter.height;
		}
	}

	public function getFrameWidth():Int{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.frameWidth;
		}
		else{ //Code for atlas characters
			return atlasCharacter.frameWidth;
		}
	}

	public function getFrameHeight():Int{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.frameHeight;
		}
		else{ //Code for atlas characters
			return atlasCharacter.frameHeight;
		}
	}

	public function getScale():FlxPoint{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.scale;
		}
		else{ //Code for atlas characters
			return atlasCharacter.scale;
		}
	}

	public function getAntialising():Bool{
		return characterInfo.info.antialiasing;
	}
	
	override function getMidpoint(?point:FlxPoint):FlxPoint {
		if (point == null)
			point = FlxPoint.get();
		return point.set(x + getWidth() * 0.5, y + getHeight() * 0.5);
	}

	override function getGraphicMidpoint(?point:FlxPoint):FlxPoint {
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			if (point == null)
				point = FlxPoint.get();
			return point.set(x + character.frameWidth * 0.5 * getScale().x, y + character.frameHeight * 0.5 * getScale().y);
		}
		else{ //Code for atlas characters
			if (point == null)
				point = FlxPoint.get();
			return point.set(x + atlasCharacter.frameWidth * 0.5 * getScale().x, y + atlasCharacter.frameHeight * 0.5 * getScale().y);
		}
	}

	public function getAnimLength(name:String):Int{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.animation.getByName(name).numFrames;
		}
		else{ //Code for atlas characters
			return atlasCharacter.animInfoMap.get(name).length;
		}
	}

	public function curAnimFrame():Int{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.animation.curAnim.curFrame;
		}
		else{ //Code for atlas characters
			return atlasCharacter.anim.curFrame - atlasCharacter.animInfoMap.get(curAnim).startFrame;
		}
	}

	public function setCurAnimFrame(frameNumber:Int):Void{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			character.animation.curAnim.curFrame = frameNumber;
		}
		else{ //Code for atlas characters
			atlasCharacter.anim.curFrame = atlasCharacter.animInfoMap.get(curAnim).startFrame + frameNumber;
		}
	}

	public function getCurAnimFramerate():Float{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.animation.curAnim.frameRate;
		}
		else{ //Code for atlas characters
			return atlasCharacter.anim.framerate;
		}
	}

	public function curAnimFinished():Bool{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character.animation.curAnim.finished;
		}
		else{ //Code for atlas characters
			return !atlasCharacter.anim.isPlaying;
		}
	}

	public override function setPosition(X:Float = 0, Y:Float = 0) {
		super.setPosition(X, Y);
		updateCharacterPostion();
	}

	override function set_x(Value:Float):Float {
		x = Value;
		updateCharacterPostion();
		return Value;
	}

	override function set_y(Value:Float):Float {
		y = Value;
		updateCharacterPostion();
		return Value;
	}

	public function getSprite():FlxSprite{
		if(characterInfo.info.frameLoadType != atlas){ //Code for sheet characters
			return character;
		}
		else{ //Code for atlas characters
			return atlasCharacter;
		}
	}

	public function getShader():FlxShader{
		if(character != null){ //Code for sheet characters
			return character.shader;
		}
		else if(atlasCharacter != null){ //Code for atlas characters
			return atlasCharacter.shader;
		}
		return null;
	}

}

enum AttachedAction {
    withDance;
	withSing;
	withPlayAnim;
}