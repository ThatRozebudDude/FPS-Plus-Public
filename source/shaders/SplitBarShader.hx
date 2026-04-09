package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class SplitBarShader extends FlxBasic
{

	public var shader(default, null):SplitBarShaderGLSL = new SplitBarShaderGLSL();

	public var rightColor(default, set):FlxColor = 0xFF66FF33;
	public var leftColor(default, set):FlxColor = 0xFFFF0000;
	public var percent(default, set):Float = 0.5;
	public var borderSize(default, set):Float = 5;

	public function new(_rightColor:FlxColor = 0xFF66FF33, _leftColor:FlxColor = 0xFFFF0000, _percent:Float = 1, _borderSize:Float = 5):Void{
		super();
		rightColor = _rightColor;
		leftColor = _leftColor;
		percent = _percent;
		borderSize = _borderSize;
	}

	function set_percent(v:Float):Float{
		percent = v;
		shader.percent.value = [percent];
		return v;
	}
	
	function set_borderSize(v:Float):Float{
		borderSize = v;
		shader.borderSize.value = [borderSize];
		return v;
	}

	function set_rightColor(v:FlxColor):FlxColor{
		rightColor = v;
		shader.rightColor.value = [rightColor.redFloat, rightColor.greenFloat, rightColor.blueFloat];
		return v;
	}

	function set_leftColor(v:FlxColor):FlxColor{
		leftColor = v;
		shader.leftColor.value = [leftColor.redFloat, leftColor.greenFloat, leftColor.blueFloat];
		return v;
	}

	public function setPercentBasedOnHealth(v:Float):Float{
		percent = 1-(v/2);
		return percent;
	}

}

class SplitBarShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec3 rightColor;
		uniform vec3 leftColor;
		uniform float percent;
		uniform float borderSize;

		const float borderTolerance = 0.5;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec2 pixelSize = vec2(1.0/openfl_TextureSize.x, 1.0/openfl_TextureSize.y);

			if(textureColor.a > 0.0){ textureColor.rgb /= textureColor.a; }
			else{ textureColor.rgb = vec3(0.0); }

			if((openfl_TextureCoordv.x) - (pixelSize.x * max(borderSize - borderTolerance, 0.0)) < percent * (1.0 - (max(borderSize - borderTolerance, 0.0) * pixelSize.x * 2.0))){
				textureColor.rgb = textureColor.rgb * leftColor;
			}
			else{
				textureColor.rgb = textureColor.rgb * rightColor;
			}
			
			gl_FragColor = vec4(textureColor.rgb * textureColor.a, textureColor.a);
		}
	')

	public function new(){ super(); }
}