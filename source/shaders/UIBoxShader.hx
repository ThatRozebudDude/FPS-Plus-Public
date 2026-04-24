package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class UIBoxShader extends FlxBasic
{

	public var shader(default, null):UIBoxShaderGLSL = new UIBoxShaderGLSL();
	public var borderSize(default, set):Float;
	public var fillColor(default, set):FlxColor;
	public var borderColor(default, set):FlxColor;

	public function new(_borderSize:Float = 2, _fillColor:FlxColor = 0xFF404040, _borderColor:FlxColor = 0xFF202020):Void{
		borderSize = _borderSize;
		fillColor = _fillColor;
		borderColor = _borderColor;
		super();
	}

	function set_borderSize(v:Float):Float{
		borderSize = v;
		shader.borderSize.value = [borderSize];
		return borderSize;
	}

	function set_fillColor(v:FlxColor):FlxColor{
		fillColor = v;
		shader.fillColor.value = [fillColor.redFloat, fillColor.greenFloat, fillColor.blueFloat];
		return fillColor;
	}

	function set_borderColor(v:FlxColor):FlxColor{
		borderColor = v;
		shader.borderColor.value = [borderColor.redFloat, borderColor.greenFloat, borderColor.blueFloat];
		return borderColor;
	}
}

class UIBoxShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float borderSize;
		uniform vec3 fillColor;
		uniform vec3 borderColor;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec2 pixelSize = vec2(1.0/openfl_TextureSize.x, 1.0/openfl_TextureSize.y);

			if(textureColor.a > 0.0){ textureColor.rgb /= textureColor.a; }
			else{ textureColor.rgb = vec3(0.0); }

			if(openfl_TextureCoordv.x < pixelSize.x * borderSize || openfl_TextureCoordv.x > 1.0 - (pixelSize.x * borderSize) || openfl_TextureCoordv.y < pixelSize.y * borderSize || openfl_TextureCoordv.y > 1.0 - (pixelSize.y * borderSize)){
				textureColor.rgb *= borderColor;
			}
			else{
				textureColor.rgb *= fillColor;
			}
			
			gl_FragColor = vec4(textureColor.rgb * textureColor.a, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}