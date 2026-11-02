package note;

import flixel.graphics.frames.FlxFrame;
import config.Config;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxShader;

class NoteSustain extends FlxSprite
{

	public var strumTime:Float = 0;
	public var length:Float = 0;
	public var direction:Int = 0;
	public var mustPress:Bool = false;
	public var type:String = "";
	public var typePrefix:String = "";
	public var parent:Note;

	public var started:Bool = false;

	var noteSkin:NoteSkinBase;
	public var noteSplashOverride:String;
	public var holdCoverOverride:String;

	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	var frameSource:FlxSprite = new FlxSprite();
	var holdFrame:FlxFrame;
	var endFrame:FlxFrame;

	var sustainShader:SustainShader;

	public var maxScore:Int;
	public var scoreGiven:Int = 0;
	public var stepTimer:Float = 0;

	public var hitCallback:(NoteSustain, Character)->Void = null;
	public var missCallback:(NoteSustain, Character)->Void = null;

	inline public static final SAFE_DROP_TIME:Float = 90; //The time in milliseconds that the sustain finishes early so that releasing the sustain isn't so tight.

	public function new(_strumTime:Float, _length:Float, _direction:Int, _mustPress:Bool, _type:String, ?_parent:Note){
		super();

		makeGraphic(1, 1, 0xFFFFFFFF);
		scrollFactor.set(0, 0);

		strumTime = Math.max(_strumTime + Config.offset, 0);
		length = _length;
		direction = _direction;
		mustPress = _mustPress;
		parent = _parent;
		
		if(_type != null){
			type = _type;
			typePrefix = type.split(";")[0];
		}

		getFramesFromNoteSkin();

		alpha = noteSkin.info.holdAlpha;
		blend = noteSkin.info.holdBlend;

		xOffset = noteSkin.info.holdOffsets[direction].x;
		yOffset = noteSkin.info.holdOffsets[direction].y;

		maxScore = Std.int(Scoring.HOLD_SCORE_PER_SECOND * (length/1000));
	}

	public function setSustainLength(scrollSpeed:Float):Void{
		scale.x = holdFrame.frame.width * noteSkin.info.scale;
		scale.y = length * Note.SCROLL_SPEED_MULTIPLIER * scrollSpeed;
		updateHitbox();
		setShaderValues();
	}

	function getFramesFromNoteSkin():Void{
		var noteSkinClassName:String = Note.defaultSkin;

		if(NoteType.types.exists(typePrefix)){
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

		antialiasing = noteSkin.info.antialiasing;
		noteSplashOverride = noteSkin.info.noteSplashOverride;
		holdCoverOverride = noteSkin.info.holdCoverOverride;

		var path = defaultPath;
		var paths = defaultPaths;
		var frameLoadType = defaultLoadType;
		
		if(noteSkin.info.sustainInfoList[direction].pathOverride != null){ path = noteSkin.info.sustainInfoList[direction].pathOverride; }
		if(noteSkin.info.sustainInfoList[direction].pathsOverride != null){ paths = noteSkin.info.sustainInfoList[direction].pathsOverride; }
		if(noteSkin.info.sustainInfoList[direction].frameLoadTypeOverride != null){ frameLoadType = noteSkin.info.sustainInfoList[direction].frameLoadTypeOverride; }
		switch(frameLoadType){
			case sparrow:
				frameSource.frames = Paths.getSparrowAtlas(path);
			case packer:
				frameSource.frames = Paths.getPackerAtlas(path);
			case load(fw, fh):
				frameSource.loadGraphic(Paths.image(path), true, fw, fh);
			case multiSparrow:
				frameSource.frames = Paths.getMultipleSparrowAtlas(paths);
			default:
				trace("not supported, sorry :[");
		}
		switch(noteSkin.info.sustainInfoList[direction].holdAnim.type){
			case prefix:
				frameSource.animation.addByPrefix("hold", noteSkin.info.sustainInfoList[direction].holdAnim.data.prefix, noteSkin.info.sustainInfoList[direction].holdAnim.data.framerate, true, noteSkin.info.sustainInfoList[direction].holdAnim.data.flipX, noteSkin.info.sustainInfoList[direction].holdAnim.data.flipY);
			case frame:
				frameSource.animation.add("hold", noteSkin.info.sustainInfoList[direction].holdAnim.data.frames, noteSkin.info.sustainInfoList[direction].holdAnim.data.framerate, true, noteSkin.info.sustainInfoList[direction].holdAnim.data.flipX, noteSkin.info.sustainInfoList[direction].holdAnim.data.flipY);
		}
		switch(noteSkin.info.sustainInfoList[direction].endAnim.type){
			case prefix:
				frameSource.animation.addByPrefix("end", noteSkin.info.sustainInfoList[direction].endAnim.data.prefix, noteSkin.info.sustainInfoList[direction].endAnim.data.framerate, true, noteSkin.info.sustainInfoList[direction].endAnim.data.flipX, noteSkin.info.sustainInfoList[direction].endAnim.data.flipY);
			case frame:
				frameSource.animation.add("end", noteSkin.info.sustainInfoList[direction].endAnim.data.frames, noteSkin.info.sustainInfoList[direction].endAnim.data.framerate, true, noteSkin.info.sustainInfoList[direction].endAnim.data.flipX, noteSkin.info.sustainInfoList[direction].endAnim.data.flipY);
		}

		//Improve this later, maybe add animation support or something.
		holdFrame = frameSource.frames.getByIndex(frameSource.animation.getByName("hold").frames[0]);
		endFrame = frameSource.frames.getByIndex(frameSource.animation.getByName("end").frames[0]);
	}

	function setShaderValues():Void{
		sustainShader ??= new SustainShader();

		sustainShader.sustainDimensions.value = [width, height];
		sustainShader.sustainScale.value = [noteSkin.info.scale];

		sustainShader.data.noteTexture.input = frameSource.frames.parent.bitmap;
		sustainShader.noteTextureDimensions.value = [frameSource.frames.parent.width, frameSource.frames.parent.height];

		sustainShader.holdFrame.value = [holdFrame.uv.left, holdFrame.uv.top, holdFrame.uv.right, holdFrame.uv.bottom];
		sustainShader.holdDimensions.value = [holdFrame.frame.width, holdFrame.frame.height];
		sustainShader.holdRotated.value = [(holdFrame.angle == -90)];

		sustainShader.endFrame.value = [endFrame.uv.left, endFrame.uv.top, endFrame.uv.right, endFrame.uv.bottom];
		sustainShader.endDimensions.value = [endFrame.frame.width, endFrame.frame.height];
		sustainShader.endRotated.value = [(endFrame.angle == -90)];

		sustainShader.antialiasing.value = [noteSkin.info.antialiasing];
		sustainShader.loopTexture.value = [true];
		sustainShader.flipped.value = [Config.downscroll];

		shader = sustainShader;
	}

}



class SustainShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec2 sustainDimensions;
		uniform float sustainScale;

		uniform sampler2D noteTexture;
		uniform vec2 noteTextureDimensions;

		uniform vec4 holdFrame;
		uniform vec2 holdDimensions;
		uniform bool holdRotated;
		
		uniform vec4 endFrame;
		uniform vec2 endDimensions;
		uniform bool endRotated;

		uniform bool antialiasing;
		uniform bool loopTexture;
		uniform bool flipped;
		
		//Allows for texture filtering on a sampler2D.
		vec4 texture2D_bilinear(sampler2D t, vec2 uv){
			vec2 texelSize = 1.0/noteTextureDimensions;
			vec2 p = uv * noteTextureDimensions - 0.5;
			vec2 f = fract(p);
			uv = floor(p) * texelSize + texelSize * 0.5;
			vec4 tl = flixel_texture2D(t, uv);
			vec4 tr = flixel_texture2D(t, uv + vec2(texelSize.x, 0.0));
			vec4 bl = flixel_texture2D(t, uv + vec2(0.0, texelSize.y));
			vec4 br = flixel_texture2D(t, uv + vec2(texelSize.x, texelSize.y));
			vec4 tA = mix(tl, tr, f.x);
			vec4 tB = mix(bl, br, f.x);
			return mix(tA, tB, f.y);
		}

		float remapToRange(float value, float start1, float stop1, float start2, float stop2){
			return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
		}

		vec2 fixRotation(vec2 uv, vec4 frame){
			vec2 pivot = vec2(mix(frame.x, frame.z, 0.5), mix(frame.y, frame.w, 0.5));
			vec2 p = uv - pivot;
			return (vec2(-p.y, p.x) * vec2((frame.z-frame.x)/(frame.w-frame.y), (frame.w-frame.y)/(frame.z-frame.x))) + pivot;
		}

		void main(){
			vec2 pixelSize = 1.0/sustainDimensions;

			vec2 uv = openfl_TextureCoordv;
			if(flipped){ uv.y = 1.0 - uv.y; }

			float holdHeight = holdDimensions.y;
			if(holdRotated){ holdHeight = holdDimensions.x; }

			float endHeight = endDimensions.y;
			if(endRotated){ endHeight = endDimensions.x; }

			float endLength = pixelSize.y * endHeight * sustainScale;

			if(uv.y < 1.0 - endLength){ //Hold
				if(loopTexture){ //Loop the texture multiple times vertically.
					float multiplier = (sustainDimensions.y/holdHeight)/sustainScale;
					uv = vec2(remapToRange(uv.x, 0.0, 1.0, holdFrame.x, holdFrame.z), remapToRange(mod(uv.y * multiplier, 1.0), 0.0, 1.0 - endLength, holdFrame.y, holdFrame.w));
					uv.y = clamp(uv.y, holdFrame.y + (0.5/noteTextureDimensions.y), holdFrame.w - (0.5/noteTextureDimensions.y));
				}
				else{ //Strech the texture instead of looping it.
					uv = vec2(remapToRange(uv.x, 0.0, 1.0, holdFrame.x, holdFrame.z), remapToRange(uv.y, 0.0, 1.0 - endLength, holdFrame.y, holdFrame.w));
					uv.y = clamp(uv.y, holdFrame.y + (0.5/noteTextureDimensions.y), holdFrame.w - (0.5/noteTextureDimensions.y));
				}
				if(holdRotated){
					uv = fixRotation(uv, holdFrame);
				}
			}
			else{ //End
				uv = vec2(remapToRange(uv.x, 0.0, 1.0, endFrame.x, endFrame.z), remapToRange(uv.y, 1.0 - endLength, 1.0, endFrame.y, endFrame.w));
				uv.y = max(uv.y, endFrame.y + 0.5/noteTextureDimensions.y);
				if(endRotated){
					uv = fixRotation(uv, endFrame);
				}
			}

			gl_FragColor = antialiasing ? texture2D_bilinear(noteTexture, uv) : flixel_texture2D(noteTexture, uv);
		}'
	)

	public function new(){ super(); }
}