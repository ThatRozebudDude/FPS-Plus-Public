package graphics;

import animate.FlxAnimate;
import animate.FlxAnimateAssets;
import animate.FlxAnimateFrames;
import animate.FlxAnimateJson;
import animate.internal.SymbolItem;
import animate.internal.Timeline;
import animate.internal.elements.Element;
import animate.internal.elements.SymbolInstance;
import data.OrderedMap;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import flixel.util.typeLimit.OneOfTwo;
import haxe.Json;
import haxe.io.Path;
import modding.PolymodHandler;

using StringTools;

typedef AtlasAnimInfo = {
	startFrame:Int,
	length:Int,
	framerate:Float,
	looped:Bool,
	loopFrame:Null<Int>,
	animationName:String
}

#if BACKWARD_COMPATIBILITY
typedef FrameLabelInfo = {
	labels:Array<String>,
	index:Int
}
#end

class AtlasSprite extends FlxAnimate
{
	public var animInfoMap:Map<String, AtlasAnimInfo> = new Map<String, AtlasAnimInfo>();

	public var curAnim:String;
	public var finishedAnim:Bool = true;
	public var isLooping:Bool = false;

	public var frameCallback:(String, Int, Int)->Void;
	public var animationEndCallback:String->Void;

	public var onFrameChange:FlxTypedSignal<(String, Int, Int)->Void> = new FlxTypedSignal();
	public var onFinish:FlxTypedSignal<String->Void> = new FlxTypedSignal();

	public var timelines:OrderedMap<String, Timeline> = new OrderedMap<String, Timeline>();

	private var didAnimFinishCheck:Bool = false;

	#if BACKWARD_COMPATIBILITY
	private var isOld:Bool = false; //This is set when the atlas is loaded from a mod that is from a version before the change to flixel-animate.
	private var frameLabelInfo:Array<FrameLabelInfo>; //Used to get length between labels for old label animation adding.
	#end

	public function new(_x:Float = 0, _y:Float = 0, ?_path:OneOfTwo<String, Array<Dynamic>>, ?_settings:FlxAnimateSettings){
		super(_x, _y, null, null);
		if(_path != null){
			loadAtlas(_path, _settings);
		}
	}

	public function loadAtlas(_path:OneOfTwo<String, Array<Dynamic>>, ?_settings:FlxAnimateSettings):Void{
		if(_path is String){
			var path:String = cast(_path, String);
			var frameSet:FlxAnimateFrames = loadAndCache(path, false, _settings);
			timelines.set(path, frameSet.timeline);
			frames = frameSet;
		}
		else if(_path is Array){
			var paths:Array<Dynamic> = cast(_path, Array<Dynamic>);
			if(paths.length <= 0){
				trace("CANNOT LOAD 0 PATHS, ABORTING ATLAS LOAD!");
				return;
			}
			else if(paths.length == 1){
				var frameSet:FlxAnimateFrames = loadAndCache(paths[0], false, _settings);
				timelines.set(paths[0], frameSet.timeline);
				frames = frameSet;
			}
			else{
				var framesToCombine:Array<FlxAnimateFrames> = [];
				for(path in paths){
					var frameSet:FlxAnimateFrames = loadAndCache(path, false, _settings);
					timelines.set(path, frameSet.timeline);
					framesToCombine.push(frameSet);
				}
				var finalFrames:FlxAtlasFrames = FlxAnimateFrames.combineAtlas(framesToCombine[0], framesToCombine[1]);
				if(paths.length > 2){
					for(i in 2...paths.length){
						finalFrames = FlxAnimateFrames.combineAtlas(finalFrames, framesToCombine[i]);
					}
				}
				frames = finalFrames;
			}
		}

		//trace(anim.getDefaultTimeline());
		//trace(anim.getCollectionTimelines());
		//trace(timelines);

		for(k => v in timelines){
			anim.addByTimeline("_timeline_" + k, v, 24, false);
		}
		
		anim.onFrameChange.add(onFrameChangeLogic);
		anim.onFinish.add(onFinishLogic);

		#if BACKWARD_COMPATIBILITY
		//Auto setup stage matrix stuff to provide backwards compatibility with older mods.
		if(Assets.exists(_path + "/spritemap1.png")){
			var fromMod:String = PolymodHandler.getAssetModFolder(_path + "/spritemap1.png");
			if((fromMod != null && PolymodHandler.getSeparatedVersionNumber(PolymodHandler.getModMetaFromFolder(fromMod).api_version)[1] <= 7)){ //API version that old atlas stuff uses.
				isOld = true;

				applyStageMatrix = true;
				origin.set(-timeline.getBoundsOrigin().x, -timeline.getBoundsOrigin().y); //Scales from the origin of the symbol instead of the center of the sprite.

				frameLabelInfo = [];
				populateFrameLabelInfo();
			}
		}
		#end
	}

	#if BACKWARD_COMPATIBILITY
	function populateFrameLabelInfo():Void{
		var addedIndecies:Array<Int> = [];
		for(layer in anim.getDefaultTimeline().layers){
			for(frame in layer.frames){
				var frameName = frame.name.rtrim();
				if(frameName != ""){
					if(addedIndecies.contains(frame.index)){
						for(x in frameLabelInfo){
							if(x.index == frame.index){
								x.labels.push(frameName);
							}
						}
					}
					else{
						frameLabelInfo.push({labels: [frameName], index: frame.index});
					}
				}
			}
		}
		frameLabelInfo.sort(function(a,b){
			return FlxSort.byValues(FlxSort.ASCENDING, a.index, b.index);
		});
		//trace(frameLabelInfo);
	}

	function getLabelFrameIndex(label:String):Int{
		for(info in frameLabelInfo){
			if(info.labels.contains(label)){
				return info.index;
			}
		}
		return -1;
	}
	
	function getLabelInfoIndex(label:String):Int{
		for(i in 0...frameLabelInfo.length){
			if(frameLabelInfo[i].labels.contains(label)){
				return i;
			}
		}
		return -1;
	}
	#end

	public function addAnimationByLabel(name:String, label:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null, ?path:String = null):Void{
		#if BACKWARD_COMPATIBILITY
		//Emulates the old method of label animation adding where it's based on distance between labels instead of label frame duration.
		if(isOld){
			var labelIndex = getLabelInfoIndex(label);
			if(labelIndex == -1){
				trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
				return;
			}
			var length:Int = (labelIndex < frameLabelInfo.length-1) ? frameLabelInfo[labelIndex+1].index - frameLabelInfo[labelIndex].index : anim.getByName("_timeline_" + timelines.copyKeys()[0]).frames.length - frameLabelInfo[labelIndex].index;
			addAnimationStartingAtLabel(name, label, length, framerate, looped, loopFrame);
			return;
		}
		#end

		path ??= timelines.copyKeys()[0];
		if(!timelines.exists(path)){
			path = timelines.copyKeys()[0];
		}

		var foundFrames = anim.findFrameLabelIndices(label, timelines.get(path));
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
			loopFrame: loopFrame,
			animationName: "_timeline_" + path
		});
	}

	public function addAnimationByFrame(name:String, frame:Int, length:Null<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null, ?path:String = null):Void{
		path ??= timelines.copyKeys()[0];
		if(!timelines.exists(path)){
			path = timelines.copyKeys()[0];
		}

		if(length == null){
			length = anim.getByName("_timeline_" + path).frames.length;
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
			loopFrame: loopFrame,
			animationName: "_timeline_" + path
		});
	}

	public function addAnimationStartingAtLabel(name:String, label:String, length:Null<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null, ?path:String = null):Void{
		path ??= timelines.copyKeys()[0];
		if(!timelines.exists(path)){
			path = timelines.copyKeys()[0];
		}

		var foundFrames = anim.findFrameLabelIndices(label, timelines.get(path));
		if(foundFrames.length <= 0){
			trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
			return;
		}

		if(length == null){
			length = anim.getByName("_timeline_" + path).frames.length;
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
			loopFrame: loopFrame,
			animationName: "_timeline_" + path
		});
	}

	public function addFullAnimation(name:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null, ?path:String = null):Void{
		path ??= timelines.copyKeys()[0];
		if(!timelines.exists(path)){
			path = timelines.copyKeys()[0];
		}

		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = anim.getByName("_timeline_" + path).frames.length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: 0,
			length: anim.getByName("_timeline_" + path).frames.length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame,
			animationName: "_timeline_" + path
		});
	}

	public function addAnimationBySymbol(name:String, symbolName:String, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null):Void{
		if(!anim.exists("_symbol_" + symbolName)){
			if(library.existsSymbol(symbolName)){
				anim.addBySymbol("_symbol_" + symbolName, symbolName, framerate, false);
			}
			else{
				trace("SYMBOL " + symbolName + " NOT FOUND, ABORTING ANIM ADD");
				return;
			}
		}

		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = anim.getByName("_symbol_" + symbolName).frames.length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: 0,
			length: anim.getByName("_symbol_" + symbolName).frames.length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame,
			animationName: "_symbol_" + symbolName
		});
	}

	public function addAnimationOffsetFromLabel(name:String, label:String, offset:Int, length:Null<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null, ?path:String = null):Void{
		path ??= timelines.copyKeys()[0];
		if(!timelines.exists(path)){
			path = timelines.copyKeys()[0];
		}

		var foundFrames = anim.findFrameLabelIndices(label, timelines.get(path));
		if(foundFrames.length <= 0){
			trace("LABEL " + label + " NOT FOUND, ABORTING ANIM ADD");
			return;
		}

		if(length == null){
			length = anim.getByName("_timeline_" + path).frames.length;
		}
		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: foundFrames[0] + offset,
			length: length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame,
			animationName: "_timeline_" + path
		});
	}

	public function addAnimationFromLabelIndices(name:String, label:String, indices:Array<Int>, ?framerate:Float = 24, ?looped:Bool = false, ?loopFrame:Null<Int> = null, ?path:String = null):Void{
		path ??= timelines.copyKeys()[0];
		if(!timelines.exists(path)){
			path = timelines.copyKeys()[0];
		}

		if(indices == null || indices.length <= 0){
			trace("CANNOT CREATE " + name + " BASED ON PROVIDED INDICES, ABORTING ANIM ADD");
			return;
		}

		var indicesString:String = combineIndicesToString(indices);

		if(!anim.exists("_frames_" + path + "_" + label + "_" + indicesString)){
			anim.addByFrameLabelIndices("_frames_" + path + "_" + label + "_" + indicesString, label, indices, framerate, false, timelines.get(path));
		}

		if(looped && loopFrame == null){
			loopFrame = 0;
		}
		else if(looped && loopFrame < 0){
			loopFrame = indices.length + loopFrame;
		}

		animInfoMap.set(name, {
			startFrame: 0,
			length: indices.length,
			framerate: framerate,
			looped: looped,
			loopFrame: loopFrame,
			animationName: "_frames_" + path + "_" + label + "_" + indicesString
		});
	}

	private inline function combineIndicesToString(indices:Array<Int>, indexOffset:Int = 0):String{
		var r:String = "";
		for(index in indices){
			r += (index + indexOffset) + "_";
		}
		return r.substr(0, r.length-1);
	}

	//public version of playAnim so that people can't use _partOfLoop.
	public function playAnim(name:String, ?force:Bool = true, ?reverse:Bool = false, ?frameOffset:Int = 0):Void{
		_playAnim(name, force, reverse, frameOffset);
	}

	private function _playAnim(name:String, ?force:Bool = true, ?reverse:Bool = false, ?frameOffset:Int = 0, ?_partOfLoop:Bool = false):Void{

		if(!animInfoMap.exists(name)){
			trace("ANIMATION " + name + " DOES NOT EXIST");
			return;
		}

		var animInfo:AtlasAnimInfo = animInfoMap.get(name);

		//Can't rely on normal force behavior so I have to recreate it.
		if(!force && curAnim == name && !finishedAnim && anim.curAnim != null && anim.curAnim.reversed == reverse){
			return;
		}

		didAnimFinishCheck = false;

		curAnim = name;
		if(!_partOfLoop){
			finishedAnim = false;
			isLooping = false;
		}

		if(frameOffset >= animInfo.length){
			frameOffset = animInfo.length - 1;
		}

		anim.getByName(animInfo.animationName).frameRate = animInfo.framerate;
		anim.play(animInfo.animationName, true, reverse, animInfo.startFrame + frameOffset);
	}

	private function onFrameChangeLogic(name:String, frame:Int, index:Int):Void{
		var animInfo:AtlasAnimInfo = animInfoMap.get(curAnim);

		if(frameCallback != null){ frameCallback(curAnim, frame - animInfo.startFrame, frame); }
		onFrameChange.dispatch(curAnim, frame - animInfo.startFrame, frame);

		if((frame >= (animInfo.startFrame + animInfo.length) || frame < animInfo.startFrame) && !didAnimFinishCheck){
			animationEndBehavior(animInfo);
		}
	}
	
	private function onFinishLogic(name:String):Void{
		if(!didAnimFinishCheck){
			animationEndBehavior(animInfoMap.get(curAnim));
		}
	}

	private function animationEndBehavior(animInfo:AtlasAnimInfo){
		didAnimFinishCheck = true; //Prevents the anim.play from causing an infinite loop.
		anim.play(anim.curAnim.name, true, false, (animInfo.startFrame + animInfo.length) - 1); //Prevents the game from potentially showing the next frame of animation if the game lags right before the animation ends.
		anim.pause();

		if(animInfo.looped){
			_playAnim(curAnim, true, false, animInfo.loopFrame, true);
			isLooping = true;
		}
		else{ finishedAnim = true; }
		if(animationEndCallback != null){ animationEndCallback(curAnim); }
		onFinish.dispatch(curAnim);
	}

	//Taken from base game's FunkinSprite.
	/**
	* Returns the first element of a symbol in the atlas.
	* @param symbol The symbol to get elements from.
	* @return The first element of the symbol. WARNING: Can be null.
	*/
	public function getFirstElement(symbol:String):Null<Element>{
		var symbolElements:Array<Element> = getSymbolElements(symbol);
		return symbolElements.length > 0 ? symbolElements[0] : null;
	}

	//Taken from base game's FunkinSprite.
	/**
	* Returns the elements of a symbol in the atlas.
	* @param symbol The symbol to get elements from.
	*/
	public function getSymbolElements(symbol:String):Array<Element>{
		var symbolInstance:Null<SymbolItem> = this.library.getSymbol(symbol);

		if(symbolInstance == null){
			throw 'Symbol not found in atlas: ${symbol}';
			return [];
		}

		var elements:Array<Element> = symbolInstance.timeline.getElementsAtIndex(0);

		if (elements?.length == 0){
			trace('WARNING: No Atlas Elements found for "$symbol" symbol.');
		}

		return elements ?? [];
	}
  
	//Taken from base game's FunkinSprite.
	/**
	* Scales an element by a certain multiplier.
	* @param element The element to scale.
	* @param scale The scale multiplier.
	* @param positionOffset The offset to apply to `tx` and `ty` after scaling.
	* (Or in other words, the position of the element.)
	*/
	public function scaleElement(element:Element, scale:Float, positionOffset:Float = 0, scaleEverything:Bool = false):Void{
		var elementMatrix:FlxMatrix = element.matrix;

		if (scaleEverything){
			elementMatrix.scale(scale, scale);
			return;
		}

		var symbolInstance:SymbolInstance = element.parentFrame.convertToSymbol(0, 1);
		var transformPoint:FlxPoint = symbolInstance.transformationPoint;

		elementMatrix.a += scale;
		elementMatrix.d += scale;

		elementMatrix.tx -= transformPoint.x * scale;
		elementMatrix.ty -= transformPoint.y * scale;

		elementMatrix.tx -= positionOffset;
		elementMatrix.ty -= positionOffset;
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

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	override public function draw():Void{
		super.draw();
	}

	//Combines FlxAnimateFrames.fromAnimate(), FlxAnimateFrames._fromAnimatePath(), and FlxAnimateFrames._fromAnimateInput() in a way that uses the FPS Plus image cache instead of Flixel's built in bitmap cache.
	public static function loadAndCache(animate:String, ?unique:Bool = false, ?settings:FlxAnimateSettings):FlxAnimateFrames{
		


		//This is the fromAnimate() part.



		/*@:privateAccess
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
		}*/



		//This is the _fromAnimatePath() part.



		var hasAnimation:Bool = FlxAnimateAssets.exists(animate + "/Animation.json", TEXT);
		if (!hasAnimation){
			FlxG.log.warn('No Animation.json file was found for path "$animate".');
			return null;
		}
		
		@:privateAccess
		var animation = FlxAnimateFrames.getTextFromPath(animate + "/Animation.json");
		var isInlined = !Utils.readDirectory(animate).contains("metadata.json");
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
		var spritemapList = Utils.readDirectory(animate);
		for(f in spritemapList){
			if(!f.startsWith("spritemap")){ spritemapList.remove(f); }
		}
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
			@:privateAccess
			var graphic = FlxGraphic.fromBitmapData(cast(sm.source, FlxGraphic).bitmap.clone());
			var atlas = new FlxAtlasFrames(graphic);
			var spritemap:SpritemapJson = Json.parse(sm.json);

			for (sprite in spritemap.ATLAS.SPRITES){
				var sprite = sprite.SPRITE;
				var rect = FlxRect.get(sprite.x, sprite.y, sprite.w, sprite.h);
				var size = FlxPoint.get(sprite.w, sprite.h);
				atlas.addAtlasFrame(rect, size, FlxPoint.get(), sprite.name, sprite.rotated ? ANGLE_NEG_90 : ANGLE_0);
			}

			frames.addAtlas(atlas);
			spritemapCollection.addSpritemap(graphic);
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

			//FlxAnimateFrames._cachedAtlases.set(animate, frames);
		}
		
		return frames;
	}

}