package shaders;

import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

/*
A shader that aims to replicate Adobe Animate's Adjust Color filter.
Basically just used to apply color adjusts to sprites without needing a whole new sprite sheet. 
Adapted from Andrey-Postelzhuk's shader found here: https://forum.unity.com/threads/hue-saturation-brightness-contrast-shader.260649/
Hue rotation stuff is from here: https://www.w3.org/TR/filter-effects/#feColorMatrixElement
A lot of stuff needed to be changed to make it more accurate to Adobe Animate's Adjust Color filter or just to make it work in general.
Written by Rozebud :]
*/

class AdjustColorShader extends FlxBasic
{
	public var shader(default, null):AdjustColorShaderGLSL = new AdjustColorShaderGLSL();

	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;
	public var contrast(default, set):Float = 0;

	public function new(_brightness:Float = 0, _hue:Float = 0, _contrast:Float = 0, _saturation:Float = 0):Void{
		super();
		brightness = _brightness;
		hue = _hue;
		contrast = _contrast;
		saturation = _saturation;
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	function set_hue(v:Float):Float{
		hue = v;
		shader.hue.value = [hue];
		return v;
	}

	function set_saturation(v:Float):Float{
		saturation = v;
		shader.saturation.value = [saturation];
		return v;
	}

	function set_brightness(v:Float):Float{
		brightness = v;
		shader.brightness.value = [brightness];
		return v;
	}

	function set_contrast(v:Float):Float{
		contrast = v;
		shader.contrast.value = [contrast];
		return v;
	}

}

class AdjustColorShaderGLSL extends FlxShader
{
	@:glFragmentSource("
		#pragma header
		
		//A shader that aims to replicate Adobe Animate's Adjust Color filter.
		//Basically just used to apply color adjusts to sprites without needing a whole new sprite sheet. 
		//Adapted from Andrey-Postelzhuk's shader found here: https://forum.unity.com/threads/hue-saturation-brightness-contrast-shader.260649/
		//Hue rotation stuff is from here: https://www.w3.org/TR/filter-effects/#feColorMatrixElement
		//A lot of stuff needed to be changed to make it more accurate to Adobe Animate's Adjust Color filter or just to make it work in general.
		//Written by Rozebud :]

		uniform float hue;
		uniform float saturation;
		uniform float brightness;
		uniform float contrast;

		const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
		const float e = 2.718281828459045;

		vec3 applyHueRotate(vec3 aColor, float aHue){
			float angle = radians(aHue);

			mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
			mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
			mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
			mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

			return m * aColor;
		}

		vec3 applySaturation(vec3 aColor, float value){
			if(value > 0.0){ value = value * 3.0; }
			value = (1.0 + (value / 100.0));
			vec3 grayscale = vec3(dot(aColor, grayscaleValues));
			return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
		}

		vec3 applyContrast(vec3 aColor, float value){
			value = (1.0 + (value / 100.0));
			if(value > 1.0){
				value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0; //Just roll with it...
				value += 1.0;
			}
			return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
		}

		vec3 applyHSBCEffect(vec3 color){

			//Brightness
			color = color + ((brightness) / 255.0);

			//Hue
			color = applyHueRotate(color, hue);

			//Contrast
			color = applyContrast(color, contrast);

			//Saturation
			color = applySaturation(color, saturation);
			
			return color;
		}

		void main(){

			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 outColor = applyHSBCEffect(textureColor.rgb);

			gl_FragColor = vec4(outColor, textureColor.a);
		}")

	public function new()
	{
		super();
	}
}
