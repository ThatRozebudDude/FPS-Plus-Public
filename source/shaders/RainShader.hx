package shaders;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class RainShader extends FlxBasic
{

	public var uTime(default, set):Float = 0;
	public var uScale(default, set):Float = 0;
	public var uIntensity(default, set):Float = 0;

	public var timeScale:Float = 1;

	public var shader(default, null):RainShaderGLSL = new RainShaderGLSL();

	public function new(_intensity:Float, _scale:Float):Void{
		super();
		uIntensity = _intensity;
		uScale = _scale;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		uTime += elapsed * timeScale;
		shader.updateViewInfo(FlxG.width, FlxG.height, PlayState.instance.camGame);
	}


	function set_uTime(value:Float):Float {
		uTime = value;
		shader.uTime.value = [value];
		return value;
	}

	function set_uScale(value:Float):Float {
		uScale = value;
		shader.uScale.value = [value];
		return value;
	}

	function set_uIntensity(value:Float):Float {
		uIntensity = value;
		shader.uIntensity.value = [value];
		return value;
	}
}

class RainShaderGLSL extends FlxShader
{
	@:glVertexHeader('
		// normalized screen coord
		//   (0, 0) is the top left of the window
		//   (1, 1) is the bottom right of the window
		varying vec2 screenCoord;
	', true)
	@:glVertexBody('
		screenCoord = vec2(
			openfl_TextureCoord.x > 0.0 ? 1.0 : 0.0,
			openfl_TextureCoord.y > 0.0 ? 1.0 : 0.0
		);
	')

	@:glFragmentHeader('
		// normalized screen coord
		//   (0, 0) is the top left of the window
		//   (1, 1) is the bottom right of the window
		varying vec2 screenCoord;

		// equals (FlxG.width, FlxG.height)
		uniform vec2 uScreenResolution;

		// equals (camera.viewLeft, camera.viewTop, camera.viewRight, camera.viewBottom)
		uniform vec4 uCameraBounds;

		// screen coord -> world coord conversion
		// returns world coord in px
		vec2 screenToWorld(vec2 screenCoord) {
			float left = uCameraBounds.x;
			float top = uCameraBounds.y;
			float right = uCameraBounds.z;
			float bottom = uCameraBounds.w;
			vec2 scale = vec2(right - left, bottom - top);
			vec2 offset = vec2(left, top);
			return screenCoord * scale + offset;
		}

		// world coord -> screen coord conversion
		// returns normalized screen coord
		vec2 worldToScreen(vec2 worldCoord) {
			float left = uCameraBounds.x;
			float top = uCameraBounds.y;
			float right = uCameraBounds.z;
			float bottom = uCameraBounds.w;
			vec2 scale = vec2(right - left, bottom - top);
			vec2 offset = vec2(left, top);
			return (worldCoord - offset) / scale;
		}

		// internally used to get the maximum `openfl_TextureCoordv`
		vec2 bitmapCoordScale() {
			return openfl_TextureCoordv / screenCoord;
		}

		// internally used to compute bitmap coord
		vec2 screenToBitmap(vec2 screenCoord) {
			return screenCoord * bitmapCoordScale();
		}

		// samples the frame buffer using a screen coord
		vec4 sampleBitmapScreen(vec2 screenCoord) {
			return texture2D(bitmap, screenToBitmap(screenCoord));
		}

		// samples the frame buffer using a world coord
		vec4 sampleBitmapWorld(vec2 worldCoord) {
			return sampleBitmapScreen(worldToScreen(worldCoord));
		}
	', true)

	@:glFragmentSource("
		#pragma header

		// TODO: shouldn't this be isolated?

		//
		// Description : Array and textureless GLSL 2D/3D/4D simplex
		//               noise functions.
		//      Author : Ian McEwan, Ashima Arts.
		//  Maintainer : stegu
		//     Lastmod : 20201014 (stegu)
		//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
		//               Distributed under the MIT License. See LICENSE file.
		//               https://github.com/ashima/webgl-noise
		//               https://github.com/stegu/webgl-noise
		//

		vec3 mod289(vec3 x) {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
		}

		vec4 mod289(vec4 x) {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
		}

		vec4 permute(vec4 x) {
			return mod289(((x*34.0)+10.0)*x);
		}

		vec4 taylorInvSqrt(vec4 r) {
			return 1.79284291400159 - 0.85373472095314 * r;
		}

		float snoise(vec3 v) {
			const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
			const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

			// First corner
			vec3 i  = floor(v + dot(v, C.yyy) );
			vec3 x0 =   v - i + dot(i, C.xxx) ;

			// Other corners
			vec3 g = step(x0.yzx, x0.xyz);
			vec3 l = 1.0 - g;
			vec3 i1 = min( g.xyz, l.zxy );
			vec3 i2 = max( g.xyz, l.zxy );

			//   x0 = x0 - 0.0 + 0.0 * C.xxx;
			//   x1 = x0 - i1  + 1.0 * C.xxx;
			//   x2 = x0 - i2  + 2.0 * C.xxx;
			//   x3 = x0 - 1.0 + 3.0 * C.xxx;
			vec3 x1 = x0 - i1 + C.xxx;
			vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
			vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

			// Permutations
			i = mod289(i);
			vec4 p = permute( permute( permute(
						i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
					+ i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
					+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

			// Gradients: 7x7 points over a square, mapped onto an octahedron.
			// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
			float n_ = 0.142857142857; // 1.0/7.0
			vec3  ns = n_ * D.wyz - D.xzx;

			vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

			vec4 x_ = floor(j * ns.z);
			vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

			vec4 x = x_ *ns.x + ns.yyyy;
			vec4 y = y_ *ns.x + ns.yyyy;
			vec4 h = 1.0 - abs(x) - abs(y);

			vec4 b0 = vec4( x.xy, y.xy );
			vec4 b1 = vec4( x.zw, y.zw );

			//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
			//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
			vec4 s0 = floor(b0)*2.0 + 1.0;
			vec4 s1 = floor(b1)*2.0 + 1.0;
			vec4 sh = -step(h, vec4(0.0));

			vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
			vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

			vec3 p0 = vec3(a0.xy,h.x);
			vec3 p1 = vec3(a0.zw,h.y);
			vec3 p2 = vec3(a1.xy,h.z);
			vec3 p3 = vec3(a1.zw,h.w);

			//Normalise gradients
			vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
			p0 *= norm.x;
			p1 *= norm.y;
			p2 *= norm.z;
			p3 *= norm.w;

			// Mix final noise value
			vec4 m = max(0.5 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
			m = m * m;
			return 105.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
											dot(p2,x2), dot(p3,x3) ) );
		}










		// prevent auto field generation
		#define UNIFORM uniform

		uniform float uScale;
		uniform float uIntensity;
		uniform float uTime;

		float rand(vec2 a) {
			return fract(sin(dot(mod(a, vec2(1000.0)).xy, vec2(12.9898, 78.233))) * 43758.5453);
		}

		float ease(float t) {
			return t * t * (3.0 - 2.0 * t);
		}

		float rainDist(vec2 p, float scale, float intensity) {
			// scale everything
			p *= 0.1;
			// sheer
			p.x += p.y * 0.1;
			// scroll
			p.y -= uTime * 500.0 / scale;
			// expand Y
			p.y *= 0.03;
			float ix = floor(p.x);
			// shift Y
			p.y += mod(ix, 2.0) * 0.5 + (rand(vec2(ix)) - 0.5) * 0.3;
			float iy = floor(p.y);
			vec2 index = vec2(ix, iy);
			// mod
			p -= index;
			// shift X
			p.x += (rand(index.yx) * 2.0 - 1.0) * 0.35;
			// distance
			vec2 a = abs(p - 0.5);
			float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
			// decimate
			bool empty = rand(index) < mix(1.0, 0.1, intensity);
			return empty ? 1.0 : res;
		}

		void main() {
			vec2 wpos = screenToWorld(screenCoord);
			vec2 origWpos = wpos;
			float intensity = uIntensity;

			vec3 add = vec3(0);
			float rainSum = 0.0;

			const int numLayers = 4;
			float scales[4];
			scales[0] = 1.0;
			scales[1] = 1.8;
			scales[2] = 2.6;
			scales[3] = 4.8;

			for (int i = 0; i < numLayers; i++) {
				float scale = scales[i];
				float r = rainDist(wpos * scale / uScale + 500.0 * float(i), scale, intensity);
				if (r < 0.0) {
					float v = (1.0 - exp(r * 5.0)) / scale * 2.0;
					wpos.x += v * 10.0 * uScale;
					wpos.y -= v * 2.0 * uScale;
					add += vec3(0.1, 0.15, 0.2) * v;
					rainSum += (1.0 - rainSum) * 0.75;
				}
			}

			vec3 color = sampleBitmapWorld(wpos).xyz;

			vec3 rainColor = vec3(0.4, 0.5, 0.8);
			color += add;
			color = mix(color, rainColor, 0.1 * rainSum);

			gl_FragColor = vec4(color, 1);
		}
	")

	public function new(){
		super();
		uScreenResolution.value = [FlxG.width, FlxG.height];
	}

	public function updateViewInfo(screenWidth:Float, screenHeight:Float, camera:FlxCamera):Void{
		uScreenResolution.value = [screenWidth, screenHeight];
		uCameraBounds.value = [camera.viewLeft, camera.viewTop, camera.viewRight, camera.viewBottom];
	}
}