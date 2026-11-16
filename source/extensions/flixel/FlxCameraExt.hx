package extensions.flixel;

import animate.internal.RenderTexture;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.OpenGLRenderer;
import openfl.geom.ColorTransform;
import shaders.CustomBlendShader;

class FlxCameraExt extends FlxCamera
{

	override function __get__rotated__matrix():FlxMatrix{
		__angleMatrix.identity();
		__angleMatrix.translate(-width * 0.5, -height * 0.5);
		if(shakeMatrixFix){
			__angleMatrix.translate(_fxShakeXOffset, _fxShakeYOffset);
		}
		__angleMatrix.scale(scaleX, scaleY);
		//__angleMatrix.scale(totalScaleX, totalScaleY);
		if(!(_sinScrollAngle == 0 && _cosScrollAngle == 1)){
			__angleMatrix.rotateWithTrig(_cosScrollAngle, _sinScrollAngle);
		}
		__angleMatrix.translate(width * 0.5, height * 0.5);
		//__angleMatrix.translate(x, y); //EVIL!
		__angleMatrix.scale(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
		return __angleMatrix;
	}
	
}