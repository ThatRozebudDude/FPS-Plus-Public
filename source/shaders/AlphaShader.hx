package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class AlphaShader extends FlxBasic
{

	public var shader(default, null):AlphaShaderGLSL = new AlphaShaderGLSL();

	public var alpha(default, set):Float = 1;

	public function new(_alpha:Float = 1):Void{
		super();
		alpha = _alpha;
	}

	function set_alpha(v:Float):Float{
		alpha = v;
		shader.shaderAlpha.value = [alpha];
		return v;
	}

}

class AlphaShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float shaderAlpha;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor = vec4(vec3(textureColor.rgb) * shaderAlpha, textureColor.a * shaderAlpha);
		}')

	public function new()
	{
		super();
	}
}