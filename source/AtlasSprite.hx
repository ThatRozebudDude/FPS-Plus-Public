package;

import animate.FlxAnimateAssets;
import animate.FlxAnimateJson;
import animate.internal.SymbolItem;
import animate.internal.Timeline;
import animate.internal.elements.SymbolInstance;
import flixel.math.FlxMatrix;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import animate.FlxAnimate;
import animate.FlxAnimateFrames;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import haxe.io.Path;
import haxe.Json;
import modding.PolymodHandler;

using StringTools;

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

	var loopCurrentAnim:Bool = false;
	var animFinishTimer:Float = -1;
	var animFinishTime:Float = -1;

	public function new(?_x:Float, ?_y:Float, ?_path:String, ?_settings:FlxAnimateSettings) {
		super(_x, _y, null, null);
		if(_path != null){
			loadAtlas(_path, _settings);
		}
	}

	public function loadAtlas(_path:String, ?_settings:FlxAnimateSettings){
		//frames = loadAndCache(_path.path, false, _settings); //Cache stuff is broken for now. Sad.
		frames = FlxAnimateFrames.fromAnimate(_path, null, null, null, false, _settings);
		anim.addByTimeline("___full", anim.getDefaultTimeline(), 24, false);
		anim.onFrameChange.add(animCallback);

		if(Assets.exists(_path + "/spritemap1.png")){
			var fromMod:String = PolymodHandler.getAssetModFolder(_path + "/spritemap1.png");
			if(fromMod != null && PolymodHandler.getSeparatedVersionNumber(PolymodHandler.getModMetaFromFolder(fromMod).api_version)[1] <= 7){ //API version that old atlas stuff uses.
				applyStageMatrix = true;
			}
		}
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

		//Can't rely on normal force behavior so I have to recreate it.
		if(!force && curAnim == name && !finishedAnim && anim.curAnim != null && anim.curAnim.reversed == reverse){
			return;
		}

		curAnim = name;
		animFinishTimer = -1;
		animFinishTime = -1;
		if(!_partOfLoop){
			finishedAnim = false;
		}
		loopCurrentAnim = animInfoMap.get(name).looped;

		if(frameOffset >= animInfoMap.get(name).length){
			frameOffset = animInfoMap.get(name).length - 1;
		}

		anim.getByName("___full").frameRate = animInfoMap.get(name).framerate;
		anim.play("___full", true, reverse, animInfoMap.get(name).startFrame + frameOffset);
	}

	function animCallback(name:String, frame:Int, index:Int):Void{
		var animInfo:AtlasAnimInfo = animInfoMap.get(curAnim);

		//Debug info about animation.
		//trace(curAnim + "\t" + frame + "\t" + (frame - animInfo.startFrame) + "/" + animInfo.length + "\t" + index);

		if(frameCallback != null){ frameCallback(curAnim, frame - animInfo.startFrame, frame); }

		if(frame >= (animInfo.startFrame + animInfo.length) - 1 || frame < animInfo.startFrame){
			//anim.curAnim.curFrame = (animInfo.startFrame + animInfo.length) - 1; //GET THIS TO DO SOMETHING IT CRASHES THE GAME AND DARNELL FLICKERS ONCE IN THE CHAIN ANIM
			anim.pause();
			animFinishTimer = 0;
			animFinishTime = 1/(animInfo.framerate);
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

		if(animFinishTimer >= 0){
			animFinishTimer += elapsed;
			if(animFinishTimer >= animFinishTime){
				animFinishTimer = -1;
				animFinishTime = -1;
				finishedAnim = true;
				if(loopCurrentAnim){
					playAnim(curAnim, true, false, animInfoMap.get(curAnim).loopFrame, true);
				}
				if(animationEndCallback != null){ animationEndCallback(curAnim); }
			}
		}

		super.update(elapsed);
	}

	//Combines FlxAnimateFrames.fromAnimate(), FlxAnimateFrames._fromAnimatePath(), and FlxAnimateFrames._fromAnimateInput() in a way that uses the FPS Plus image cache instead of Flixel's built in bitmap cache.
	static function loadAndCache(animate:String, ?unique:Bool = false, ?settings:FlxAnimateSettings):FlxAnimateFrames{
		


		//This is the fromAnimate() part.



		@:privateAccess
		if (!unique && FlxAnimateFrames._cachedAtlases.exists(animate)){
			var cachedAtlas = FlxAnimateFrames._cachedAtlases.get(animate);
			var isAtlasDestroyed = false;

			// Check if the atlas is complete
			// For most cases this shouldnt be an issue but theres a ton of people who make their
			// own flixel caching systems that dont work nice with this.
			// For anyone out there listening, if theres a better option, PLEASE help, this is crap
			// - maru
			for (spritemap in cast(cachedAtlas.parent, FlxAnimateSpritemapCollection).spritemaps){
				if (#if (flixel >= "5.6.0") spritemap.isDestroyed #else spritemap.shader == null #end){
					isAtlasDestroyed = true;
					break;
				}
			}

			// Another check for individual frames (may have combined frames from a Sparrow)
			if (!isAtlasDestroyed){
				for (frame in cachedAtlas.frames){
					if (frame == null || frame.parent == null || frame.frame == null){
						isAtlasDestroyed = true;
						break;
					}
				}
			}

			// Destroy previously cached atlas if incomplete, and create a new instance
			if (isAtlasDestroyed){
				FlxG.log.warn('Texture Atlas with the key "$animate" was previously cached, but incomplete. Was it incorrectly destroyed?');
				cachedAtlas.destroy();
				FlxAnimateFrames._cachedAtlases.remove(animate);
			}
			else{
				return cachedAtlas;
			}
		}



		//This is the _fromAnimatePath() part.



		var hasAnimation:Bool = FlxAnimateAssets.exists(animate + "/Animation.json", TEXT);
		if (!hasAnimation){
			FlxG.log.warn('No Animation.json file was found for path "$animate".');
			return null;
		}
		
		@:privateAccess
		var animation = FlxAnimateFrames.getTextFromPath(animate + "/Animation.json");
		var isInlined = !FlxAnimateAssets.exists(animate + "/metadata.json", TEXT);
		var libraryList:Null<Array<String>> = null;
		var spritemaps:Array<SpritemapInput> = [];
		@:privateAccess
		var metadata:Null<String> = isInlined ? null : FlxAnimateFrames.getTextFromPath(animate + "/metadata.json");

		@:privateAccess
		if (!isInlined){
			var list = FlxAnimateFrames.listWithFilter(animate + "/LIBRARY", (str) -> str.endsWith(".json"), true);
			libraryList = list.map((str) -> {
				str = str.split("/LIBRARY/").pop();
				return Path.withoutExtension(str);
			});
		}

		// Load all spritemaps
		@:privateAccess
		var spritemapList = FlxAnimateFrames.listWithFilter(animate, (file) -> file.startsWith("spritemap"), false);
		var jsonList = spritemapList.filter((file) -> file.endsWith(".json"));

		for (sm in jsonList){
			var id = sm.split("spritemap")[1].split(".")[0];
			var imageFile = spritemapList.filter((file) -> file.startsWith('spritemap$id') && !file.endsWith(".json"))[0];

			var imagePath = animate + "/" + imageFile;
			imagePath = imagePath.split(".png")[0].split("assets/images/")[1];

			@:privateAccess
			spritemaps.push({
				source: Paths.image(imagePath),
				json: FlxAnimateFrames.getTextFromPath('$animate/$sm')
			});
		}

		if (spritemaps.length <= 0){
			FlxG.log.warn('No spritemaps were found for key "$animate". Is the texture atlas incomplete?');
			return null;
		}


		
		//This is the _fromAnimateInput() part.



		var animData:AnimationJson = null;
		try{
			animData = Json.parse(animation);
		}
		catch (e){
			FlxG.log.warn('Couldnt load Animation.json with input "$animation". Is the texture atlas missing?');
			return null;
		}

		if (spritemaps == null || spritemaps.length <= 0){
			FlxG.log.warn('No spritemaps were added for key "$animate".');
			return null;
		}

		var frames = new FlxAnimateFrames(null);
		@:privateAccess{
			frames.path = animate;
			frames._symbolDictionary = animData.SD;
			frames._isInlined = isInlined;
			frames._libraryList = libraryList;
			frames._settings = settings;
		}

		var spritemapCollection = new FlxAnimateSpritemapCollection(frames);
		frames.parent = spritemapCollection;

		// Load all spritemaps
		for (sm in spritemaps){
			var atlas = new FlxAtlasFrames(sm.source);
			var spritemap:SpritemapJson = Json.parse(sm.json);

			for (sprite in spritemap.ATLAS.SPRITES){
				var sprite = sprite.SPRITE;
				var rect = FlxRect.get(sprite.x, sprite.y, sprite.w, sprite.h);
				var size = FlxPoint.get(sprite.w, sprite.h);
				atlas.addAtlasFrame(rect, size, FlxPoint.get(), sprite.name, sprite.rotated ? ANGLE_NEG_90 : ANGLE_0);
			}

			frames.addAtlas(atlas);
			spritemapCollection.addSpritemap(sm.source);
		}

		var metadata:MetadataJson = (metadata == null) ? animData.MD : Json.parse(metadata);

		frames.frameRate = metadata.FRT;
		frames.timeline = new Timeline(animData.AN.TL, frames, animData.AN.SN);
		@:privateAccess
		frames.dictionary.set(frames.timeline.name, new SymbolItem(frames.timeline)); // Add main symbol to the library too

		// stage background color
		var w = metadata.W;
		var h = metadata.H;
		frames.stageRect = (w > 0 && h > 0) ? FlxRect.get(0, 0, w, h) : FlxRect.get(0, 0, 1280, 720);
		frames.stageColor = FlxColor.fromString(metadata.BGC);

		// stage instance of the main symbol
		var stageInstance:Null<SymbolInstanceJson> = animData.AN.STI;
		frames.matrix = (stageInstance != null) ? stageInstance.MX.toMatrix() : new FlxMatrix();

		// clear the temp data crap
		@:privateAccess{
			frames._symbolDictionary = null;
			frames._libraryList = [];
			frames._settings = null;

			FlxAnimateFrames._cachedAtlases.set(animate, frames);
		}
		
		return frames;
	}

}