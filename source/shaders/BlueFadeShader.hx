package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class BlueFadeShader extends FlxBasic
{

	public var shader(default, null):BlueFadeShaderGLSL = new BlueFadeShaderGLSL();

	public var fadeVal(default, set):Float = 1;

	public function new(_fadeVal:Float = 1):Void{
		super();
		fadeVal = _fadeVal;
	}

	function set_fadeVal(v:Float):Float{
		fadeVal = v;
		shader.fadeAmt.value = [fadeVal];
		return v;
	}

}

class BlueFadeShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

        uniform float fadeAmt;

        void main(){
			vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 finalColor = mix(vec3(0.0, 0.0, tex.b) * fadeAmt, vec3(tex.rgb) * fadeAmt, fadeAmt);
			gl_FragColor = vec4(finalColor, tex.a);
        }

    ')

	public function new()
	{
		super();
	}
}