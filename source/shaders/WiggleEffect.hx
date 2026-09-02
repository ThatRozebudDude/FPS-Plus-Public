package shaders;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.system.FlxAssets.FlxShader;

enum WiggleEffectType
{
	DREAMY;
	WAVY;
	HEAT_WAVE_HORIZONTAL;
	HEAT_WAVE_VERTICAL;
	FLAG;
}

class WiggleEffect
{
	public var shader(default, null):WiggleShader = new WiggleShader();
	public var effectType(default, set):WiggleEffectType = DREAMY;
	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
	public var antialiasing(default, set):Bool = false;

	public function new():Void{
		shader.uTime.value = [0];
	}

	public function update(elapsed:Float):Void{
		shader.uTime.value[0] += elapsed;
	}

	function set_effectType(v:WiggleEffectType):WiggleEffectType{
		effectType = v;
		shader.effectType.value = [WiggleEffectType.getConstructors().indexOf(Std.string(v))];
		return v;
	}

	function set_waveSpeed(v:Float):Float{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}
	
	function set_antialiasing(v:Bool):Bool{
		antialiasing = v;
		shader.antialiasing.value = [antialiasing];
		return v;
	}
}

class WiggleShader extends FlxShader
{
	@:glFragmentSource("
		#pragma header

		#define EFFECT_TYPE_DREAMY 0
		#define EFFECT_TYPE_WAVY 1
		#define EFFECT_TYPE_HEAT_WAVE_HORIZONTAL 2
		#define EFFECT_TYPE_HEAT_WAVE_VERTICAL 3
		#define EFFECT_TYPE_FLAG 4

		// Which out of several effects should be used.
		uniform float uTime;

		// Which out of several effects should be used.
		uniform int effectType;

		// How fast the waves move over time.
		uniform float uSpeed;

		// Number of waves over time.
		uniform float uFrequency;

		// How much the pixels are going to stretch over the waves.
		uniform float uWaveAmplitude;

		// Whether to snap the UV coordinate to the center of the pixel. Set this to false for pixel art stuff.
		uniform bool antialiasing;

		vec2 sineWave(vec2 pt){
			vec2 offset = vec2(0.0);
			vec2 pixelSize = vec2(1.0/openfl_TextureSize);

			// Snap input UV to the pixel's center if antialiasing is disabled.
			if(!antialiasing){
				pt.x = floor(pt.x / pixelSize.x) * pixelSize.x + (pixelSize.x * 0.5);
				pt.y = floor(pt.y / pixelSize.y) * pixelSize.y + (pixelSize.y * 0.5);
			}
					
			if(effectType == EFFECT_TYPE_DREAMY){
				offset.y = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
				offset.x = sin((pt.y + offset.y) * (uFrequency / 2.0) + uTime * (uSpeed / 2.0)) * (uWaveAmplitude / 2.0);
			}
			else if(effectType == EFFECT_TYPE_WAVY){
				offset.y = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if(effectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL){
				offset.x = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if(effectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL){
				offset.y = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if(effectType == EFFECT_TYPE_FLAG){
				offset.y = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
				offset.x = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;
			}
							
			return vec2(pt.x + offset.x, pt.y + offset.y);
		}

		void main(){
			vec2 uv = sineWave(openfl_TextureCoordv);
			gl_FragColor = flixel_texture2D(bitmap, uv);
		}
	")

	public function new(){ super(); }
}
