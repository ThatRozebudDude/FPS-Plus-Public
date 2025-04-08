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
	public var curvePower(default, set):Float = 1;

	public function new(?_power:Float = 2, ?_fadeVal:Float = 1, ?_curvePower:Float = 1){
		super();
		power = _power;
		fadeVal = _fadeVal;
		curvePower = _curvePower;
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

	function set_curvePower(v:Float):Float {
		curvePower = v;
		shader.curvePower.value = [curvePower];
		return v;
	}
}

class MultiplyFadeShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float fadeAmt;
		uniform float power;
		uniform float curvePower;

		void main(){
			vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 unMultColor = vec3(0.0);
			if(tex.a > 0.0){ unMultColor = tex.rgb / tex.a; }
			vec3 finalColor = pow(unMultColor, vec3(power / mix(1.0, power, pow(fadeAmt, curvePower)))) * fadeAmt;
			gl_FragColor = vec4(finalColor * tex.a, tex.a);
		}

	')

	public function new()
	{
		super();
	}
}