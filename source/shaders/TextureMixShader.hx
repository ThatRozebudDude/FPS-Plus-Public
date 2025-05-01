package shaders;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class TextureMixShader extends FlxBasic
{

	public var shader(default, null):TextureMixShaderGLSL = new TextureMixShaderGLSL();
	public var mix(default, set):Float = 1;

	public function new(mixTexture:FlxGraphic, mixAmount:Float = 1):Void{
		super();
		changeMixTexture(mixTexture);
		mix = mixAmount;
	}

	function changeMixTexture(mixTexture:FlxGraphic):Void{
		shader.data.mixTexture.input = mixTexture.bitmap;
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

		vec4 texture2D_bilinear(sampler2D t, vec2 uv){
			vec2 texelSize = 1.0/openfl_TextureSize;
			vec2 f = fract(uv * openfl_TextureSize);
			uv += (.5 - f) * texelSize;    // move uv to texel centre
			vec4 tl = flixel_texture2D(t, uv);
			vec4 tr = flixel_texture2D(t, uv + vec2(texelSize.x, 0.0));
			vec4 bl = flixel_texture2D(t, uv + vec2(0.0, texelSize.y));
			vec4 br = flixel_texture2D(t, uv + vec2(texelSize.x, texelSize.y));
			vec4 tA = mix(tl, tr, f.x);
			vec4 tB = mix(bl, br, f.x);
			return mix(tA, tB, f.y);
		}

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 mixColor = texture2D_bilinear(mixTexture, openfl_TextureCoordv);
			
			gl_FragColor = mix(textureColor, mixColor, mixAmount);
		}')

	public function new()
	{
		super();
	}
}