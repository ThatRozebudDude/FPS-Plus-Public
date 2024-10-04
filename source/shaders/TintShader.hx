package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class TintShader extends FlxBasic
{

	public var shader(default, null):TintShaderGLSL = new TintShaderGLSL();

	public var tintColor(default, set):FlxColor;
	public var amount(default, set):Float = 1;

	public function new(_tintColor:FlxColor, _amount:Float = 1):Void{
		super();
		tintColor = _tintColor;
		amount = _amount;
	}

	function set_amount(v:Float):Float{
		amount = v;
		shader.tintAmount.value = [amount];
		return v;
	}

	function set_tintColor(v:FlxColor):FlxColor {
		tintColor = v;
		shader.tintColor.value = [v.redFloat, v.greenFloat, v.blueFloat, v.alphaFloat];
		return v;
	}
}

class TintShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec4 tintColor;
		uniform float tintAmount;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 outColor = mix(textureColor.rgb, tintColor.rgb * textureColor.a, tintAmount * tintColor.a);
			
			gl_FragColor = vec4(outColor, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}