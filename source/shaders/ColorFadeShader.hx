package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class ColorFadeShader extends FlxBasic
{

	public var shader(default, null):ColorFadeShaderGLSL = new ColorFadeShaderGLSL();

	public var fadeVal(default, set):Float = 1;
	public var color(default, set):FlxColor = 0xFFFFFFFF;

	public function new(_color:FlxColor, ?_fadeVal:Float = 1){
		super();
		color = _color;
		fadeVal = _fadeVal;
	}

	function set_fadeVal(v:Float):Float{
		fadeVal = v;
		shader.fadeAmt.value = [fadeVal];
		return v;
	}


	function set_color(v:FlxColor):FlxColor {
		color = v;
		shader.color.value = [v.redFloat, v.greenFloat, v.blueFloat];
		return v;
	}
}

class ColorFadeShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float fadeAmt;
		uniform vec3 color;

		void main(){
			vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 finalColor = mix(tex.rgb * color * fadeAmt, tex.rgb * fadeAmt, fadeAmt);
			gl_FragColor = vec4(finalColor, tex.a);
		}

	')

	public function new()
	{
		super();
	}
}