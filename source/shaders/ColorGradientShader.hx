package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class ColorGradientShader extends FlxBasic
{

	public var shader(default, null):ColorGradientShaderGLSL = new ColorGradientShaderGLSL();

	public var blackColor(default, set):FlxColor = 0xFF000000;
	public var whiteColor(default, set):FlxColor = 0xFFFFFFFF;

	public function new(_blackColor:FlxColor = 0xFF000000, _whiteColor:FlxColor = 0xFFFFFFFF):Void{
		super();
		blackColor = _blackColor;
		whiteColor = _whiteColor;
	}


	function set_blackColor(value:FlxColor):FlxColor {
		blackColor = value;
		shader.blackColor.value = [blackColor.redFloat, blackColor.greenFloat, blackColor.blueFloat, blackColor.alphaFloat];
		return value;
	}

	function set_whiteColor(value:FlxColor):FlxColor {
		whiteColor = value;
		shader.whiteColor.value = [whiteColor.redFloat, whiteColor.greenFloat, whiteColor.blueFloat, whiteColor.alphaFloat];
		return value;
	}
}

class ColorGradientShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec4 blackColor;
		uniform vec4 whiteColor;

		void main()
		{
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 outColor = mix(blackColor.rgb, whiteColor.rgb, textureColor.a > 0.0 ? textureColor.r/textureColor.a : 0.0);

			gl_FragColor = vec4(outColor * textureColor.a, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}