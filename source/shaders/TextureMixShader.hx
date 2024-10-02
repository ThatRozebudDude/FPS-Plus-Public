package shaders;

import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class TextureMixShader extends FlxBasic
{

	public var shader(default, null):TextureMixShaderGLSL = new TextureMixShaderGLSL();
	public var mix(default, set):Float = 1;

	public function new(mixTexturePath:String, mixAmount:Float = 1):Void{
		super();
		shader.data.mixTexture.input = BitmapData.fromFile(mixTexturePath);
		mix = mixAmount;
	}

	function changeMixTexture(mixTexturePath:String):Void{
		shader.data.mixTexture.input = BitmapData.fromFile(mixTexturePath);
	}

	function set_mix(v:Float):Float{
		mix = v;
		shader.mixAmount.value = [mix];
		return v;
	}
}

class TextureMixShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform sampler2D mixTexture;
		uniform float mixAmount;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 mixColor = flixel_texture2D(mixTexture, openfl_TextureCoordv);
			
			gl_FragColor = mix(textureColor, mixColor, mixAmount);
		}')

	public function new()
	{
		super();
	}
}