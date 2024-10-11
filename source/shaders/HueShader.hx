package shaders;

import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

/*
A shader that aims to replicate Adobe Animate's Adjust Color filter with the ability to add a tinted multiply layer similar to how Animate mixes color.
Basically just used to apply color adjusts to sprites without needing a whole new sprite sheet. 
Adapted from Andrey-Postelzhuk's shader found here: https://forum.unity.com/threads/hue-saturation-brightness-contrast-shader.260649/
A lot of stuff needed to be changed to make it more accurate to Adobe Animate's Adjust Color filter or just to make it work in general.
*/


class HueShader extends FlxBasic
{
	public var shader(default, null):HueShaderGLSL = new HueShaderGLSL();

	public var hue(default, set):Float = 0;

	public function new(_hue:Float = 0):Void{
		super();
		hue = _hue;
	}

	function set_hue(v:Float):Float{
		hue = v;
		shader.hue.value = [hue];
		return v;
	}

}

class HueShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float hue;

		vec3 applyHue(vec3 aColor, float aHue){
            float angle = radians(aHue);
            vec3 k = vec3(0.57735, 0.57735, 0.57735);
            float cosAngle = cos(angle);
            return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1.0 - cosAngle);
        }

		void main(){

			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 outColor = applyHue(textureColor.rgb, hue);

			gl_FragColor = vec4(outColor, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}
