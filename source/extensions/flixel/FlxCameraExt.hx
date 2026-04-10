package extensions.flixel;

import openfl.Lib;
import openfl.display.OpenGLRenderer;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.FlxG;
import animate.internal.RenderTexture;

import shaders.CustomBlendShader;

//Extension that uses shaders to support additional blend modes on devices that do not support Khronos extensions.
//Based on V-Slice's FunkinCamera.

@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.TextureBase)
@:access(flixel.graphics.FlxGraphic)
@:access(flixel.graphics.frames.FlxFrame)
@:access(openfl.display.OpenGLRenderer)
@:access(openfl.geom.ColorTransform)
class FlxCameraExt extends FlxCamera
{
	public static var hasKhronosExtension(get, never):Bool;
	static function get_hasKhronosExtension(){
		return OpenGLRenderer.__complexBlendsSupported ?? false;
	}

	static var renderer(get, default):OpenGLRenderer;
	static inline function get_renderer():OpenGLRenderer{
		if (renderer == null){
			renderer = new OpenGLRenderer(FlxG.stage.context3D);
			renderer.__worldTransform = new openfl.geom.Matrix();
			renderer.__worldColorTransform = new ColorTransform();
		}

		return renderer;
	}

	static final KHR_BLEND_MODES:Array<BlendMode> = [
		DARKEN,
		HARDLIGHT,
		OVERLAY,
		DIFFERENCE,
		COLORDODGE,
		COLORBURN,
		SOFTLIGHT,
		EXCLUSION,
		HUE,
		SATURATION,
		COLOR,
		LUMINOSITY
  	];

	var _blendShader:CustomBlendShader;
	var _backgroundFrame:FlxFrame;

	var _blendRenderTexture:RenderTexture;
	var _backgroundRenderTexture:RenderTexture;

	var _cameraTexture:BitmapData;
	var _cameraMatrix:FlxMatrix;

	var clampedScale:Float = Math.max(1, Lib.current.stage.window.scale);

	override public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, zoom:Float = 0){
		super(x, y, width, height, zoom);
 			
		//Only set up blend shader stuff if Khronos extension isn't available.
		if(!hasKhronosExtension){
			_backgroundFrame = new FlxFrame(new FlxGraphic('', null));
			_backgroundFrame.frame = new FlxRect();

			_blendShader = new CustomBlendShader();

			clampedScale = Math.max(1, Lib.current.stage.window.scale);

			_backgroundRenderTexture = new RenderTexture(this.width, this.height);
			_blendRenderTexture = new RenderTexture(this.width, this.height);

			_cameraMatrix = new FlxMatrix();
			_cameraTexture = new BitmapData(Std.int(this.width * clampedScale), Std.int(this.height * clampedScale));
		}
	}

	override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void{
		if(KHR_BLEND_MODES.contains(blend) && !hasKhronosExtension){
			drawCameraScreen(_cameraTexture, this);

			_backgroundFrame.frame.set(0, 0, this.width, this.height);

			this.clearDrawStack();
			this.canvas.graphics.clear();

			_blendRenderTexture.init(this.width, this.height);
			_blendRenderTexture.drawToCamera((camera, frameMatrix) -> {
				var pivotX:Float = width / 2;
				var pivotY:Float = height / 2;

				frameMatrix.copyFrom(matrix);
				frameMatrix.translate(-pivotX, -pivotY);
				frameMatrix.scale(this.scaleX, this.scaleY);
				frameMatrix.translate(pivotX, pivotY);
				camera.drawPixels(frame, pixels, frameMatrix, transform, null, smoothing, shader);
			});
			_blendRenderTexture.render();

			_blendShader.sourceSwag = _blendRenderTexture.graphic.bitmap;
			_blendShader.backgroundSwag = _cameraTexture;

			_blendShader.blendSwag = blend;
			_blendShader.shader.updateViewInfo(width, height, this);

			_backgroundFrame.parent.bitmap = _blendRenderTexture.graphic.bitmap;

			_backgroundRenderTexture.init(Std.int(this.width * clampedScale), Std.int(this.height * clampedScale));
			_backgroundRenderTexture.drawToCamera((camera, matrix) -> {
				camera.zoom = this.zoom;
				matrix.scale(clampedScale, clampedScale);
				camera.drawPixels(_backgroundFrame, null, matrix, canvas.transform.colorTransform, null, false, _blendShader.shader);
			});

			_backgroundRenderTexture.render();

			//resize the frame so it always fills the screen
			_cameraMatrix.identity();
			_cameraMatrix.scale(1 / (this.scaleX * clampedScale), 1 / (this.scaleY * clampedScale));
			_cameraMatrix.translate(((width - width / this.scaleX) * 0.5), ((height - height / this.scaleY) * 0.5));

			super.drawPixels(_backgroundRenderTexture.graphic.imageFrame.frame, null, _cameraMatrix, null, null, smoothing, null);
		}
		else{
			super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
		}
	}


	public static function drawCameraScreen(bitmap:BitmapData, camera:FlxCamera, clearBitmap:Bool = true, drawFlashSprite:Bool = false):BitmapData{
		var matrix:FlxMatrix = new FlxMatrix();
		var pivotX:Float = FlxG.scaleMode.scale.x;
		var pivotY:Float = FlxG.scaleMode.scale.y;

		matrix.setTo(1 / pivotX, 0, 0, 1 / pivotY, camera.flashSprite.x / pivotX, camera.flashSprite.y / pivotY);

		if(clearBitmap){
			bitmap.__fillRect(bitmap.rect, 0, true);
		}

		camera.render();
		camera.flashSprite.__update(false, true);

		renderer.__cleanup();

		renderer.setShader(renderer.__defaultShader);
		renderer.__allowSmoothing = false;
		renderer.__pixelRatio = Lib.current.stage.window.scale;
		renderer.__worldAlpha = 1 / camera.flashSprite.__worldAlpha;
		renderer.__worldTransform.copyFrom(camera.flashSprite.__renderTransform);
		renderer.__worldTransform.invert();
		renderer.__worldTransform.concat(matrix);
		renderer.__worldColorTransform.__copyFrom(camera.flashSprite.__worldColorTransform);
		renderer.__worldColorTransform.__invert();
		renderer.__setRenderTarget(bitmap);

		if(drawFlashSprite){
			bitmap.__drawGL(camera.flashSprite, renderer);
		}
		else{
			bitmap.__drawGL(camera.canvas, renderer);
		}

		return bitmap;
	}

	override function destroy():Void{
		super.destroy();

		if(!hasKhronosExtension){
			_blendRenderTexture.destroy();
			_backgroundRenderTexture.destroy();
			_cameraTexture.dispose();
		}
	}
	
}