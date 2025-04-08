package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class MultiplyFadeShader extends FlxBasic
{

	public var shader(default, null):MultiplyFadeShaderGLSL = new MultiplyFadeShaderGLSL();

	public var fadeVal(default, set):Float = 1;
	public var power(default, set):Float = 1;

	public function new(?_power:Float = 2, ?_fadeVal:Float = 1){
		super();
		power = _power;
		fadeVal = _fadeVal;
	}

	function set_fadeVal(v:Float):Float{
		fadeVal = v;
		shader.fadeAmt.value = [fadeVal];
		return v;
	}

	function set_power(v:Float):Float {
		power = v;
		shader.power.value = [power];
		return v;
	}
}

class MultiplyFadeShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float fadeAmt;
		uniform float power;

		void main(){
			vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 unMultColor = vec3(0.0);
			if(tex.a > 0.0){ unMultColor = tex.rgb / tex.a; }
			vec3 finalColor = mix(pow(unMultColor, vec3(power)) * fadeAmt, unMultColor * fadeAmt, fadeAmt);
			gl_FragColor = vec4(finalColor * tex.a, tex.a);
		}

	')

	public function new()
	{
		super();
	}
}