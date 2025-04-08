package shaders;

class BlueFadeShader extends ColorFadeShader
{

	public function new(_fadeVal:Float = 1){
		super(0xFF0000FF, _fadeVal);
	}

}