package shaders;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class TheShaderThatTurnsEverythingOrange extends FlxBasic
{
	public var shader(default, null):TheShaderThatTurnsEverythingOrangeGLSL = new TheShaderThatTurnsEverythingOrangeGLSL();
}

class TheShaderThatTurnsEverythingOrangeGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		void main(){
			gl_FragColor = vec4(1.0, 0.5, 0.0, 1.0);
		}')

	public function new()
	{
		super();
	}
}