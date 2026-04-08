package shaders;

import flixel.FlxBasic;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxCamera;
import flixel.FlxG;

class CustomBlendShader extends FlxBasic
{
	public var shader(default, null):CustomBlendShaderGLSL = new CustomBlendShaderGLSL();

	// only different name purely for hashlink fix
	public var sourceSwag(default, set):BitmapData;

	function set_sourceSwag(value:BitmapData):BitmapData
	{
		shader.sourceSwag.input = value;
		return sourceSwag = value;
	}

	public var backgroundSwag(default, set):BitmapData;

	function set_backgroundSwag(value:BitmapData):BitmapData
	{
		shader.backgroundSwag.input = value;
		return backgroundSwag = value;
	}

	// name change make sure it's not the same variable name as whatever is in the shader file
	public var blendSwag(default, set):BlendMode;

	function set_blendSwag(value:BlendMode):BlendMode
	{
		shader.blendMode.value = [cast(value, Int)];
		return blendSwag = value;
	}
}

class CustomBlendShaderGLSL extends FlxShader
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

		// equals (frame.left, frame.top, frame.right, frame.bottom)
		uniform vec4 uFrameBounds;

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

		// screen coord -> frame coord conversion
		// returns normalized frame coord
		vec2 screenToFrame(vec2 screenCoord) {
			float left = uFrameBounds.x;
			float top = uFrameBounds.y;
			float right = uFrameBounds.z;
			float bottom = uFrameBounds.w;
			float width = right - left;
			float height = bottom - top;

			float clampedX = clamp(screenCoord.x, left, right);
			float clampedY = clamp(screenCoord.y, top, bottom);

			return vec2(
				(clampedX - left) / (width),
				(clampedY - top) / (height)
			);
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

		uniform sampler2D sourceSwag;
		uniform sampler2D backgroundSwag;
		uniform int blendMode;

		// The functions below are needed for the following blend modes:
		// - HUE
		// - SATURATION
		// - COLOR
		// - LUMINOSITY
		// They're here at the top to prevent some cluttering!
		// - Abnormal

		float minVec3(vec3 color)
		{
			return min(min(color.r, color.g), color.b);
		}

		float maxVec3(vec3 color)
		{
			return max(max(color.r, color.g), color.b);
		}

		float lum(vec3 color)
		{
			return dot(color, vec3(0.30, 0.59, 0.11));
		}

		float sat(vec3 color)
		{
			return maxVec3(color) - minVec3(color);
		}

		vec3 clipColor(vec3 color)
		{
			float luminance = lum(color);
			float minColor = minVec3(color);
			float maxColor = maxVec3(color);

			if (minColor < 0.0)
			{
				color = luminance + ((color - luminance) * luminance) / (luminance - minColor);
			}

			if (maxColor > 1.0)
			{
				color = luminance + ((color - luminance) * (1.0 - luminance)) / (maxColor - luminance);
			}

			return color;
		}

		vec3 setLum(vec3 colorBase, vec3 colorLum)
		{
			vec3 delta = colorLum - lum(colorBase);
			vec3 c = colorBase;
			c.r = c.r + delta.r;
			c.g = c.g + delta.g;
			c.b = c.b + delta.b;
			return clipColor(c);
		}

		vec3 setSat(vec3 c, float s)
		{
			float colorMin = minVec3(c);
			float colorMax = maxVec3(c);

			if (colorMax > colorMin)
			{
				if (c.r > colorMin && c.r < colorMax)
				{
				c.r = (((c.r - colorMin) * s) / (colorMax - colorMin));
				}
				else if (c.g > colorMin && c.g < colorMax)
				{
				c.g = (((c.g - colorMin) * s) / (colorMax - colorMin));
				}
				else if (c.b > colorMin && c.b < colorMax)
				{
				c.b = (((c.b - colorMin) * s) / (colorMax - colorMin));
				}

				if (c.r == colorMax)
				c.r = s;
				else if (c.r == colorMin)
				c.r = 0.0;

				if (c.g == colorMax)
				c.g = s;
				else if (c.g == colorMin)
				c.g = 0.0;

				if (c.b == colorMax)
				c.b = s;
				else if (c.b == colorMin)
				c.b = 0.0;
			}
			else
			{
				c = vec3(0.0);
			}

			return c;
		}

		const int DARKEN = 2;
		const int DIFFERENCE = 3;
		const int HARDLIGHT = 5;
		const int INVERT = 6;
		const int LIGHTEN = 8;
		const int OVERLAY = 11;
		const int COLORDODGE = 15;
		const int COLORBURN = 16;
		const int SOFTLIGHT = 17;
		const int EXCLUSION = 18;
		const int HUE = 19;
		const int SATURATION = 20;
		const int COLOR = 21;
		const int LUMINOSITY = 22;

		vec3 screen(vec3 bg, vec3 src)
		{
			return 1.0 - (1.0 - bg) * (1.0 - src);
		}

		vec3 hardlight(vec3 bg, vec3 src)
		{
			vec3 c1 = bg * src * 2.0;
			vec3 c2 = screen(bg, 2.0 * src - 1.0);
			return mix(c2, c1, vec3(lessThanEqual(src, vec3(0.5))));
		}

		vec3 difference(vec3 bg, vec3 src)
		{
			return abs(bg - src);
		}

		vec3 invert(vec3 bg)
		{
			return vec3(1.0) - bg;
		}

		vec3 colordodge(vec3 bg, vec3 src)
		{
			if (bg == vec3(0.0))
			{
				return vec3(0.0);
			}
			else if (src == vec3(1.0))
			{
				return vec3(1.0);
			}
			else
			{
				vec3 res = bg / (vec3(1.0) - src);
				return min(vec3(1.0), res);
			}
		}

		vec3 colorburn(vec3 bg, vec3 src)
		{
			if (bg == vec3(1.0))
			{
				return vec3(1.0);
			}
			else if (src == vec3(0.0))
			{
				return vec3(0.0);
			}
			else
			{
				return 1.0 - min(vec3(1.0), (vec3(1.0) - bg) / src);
			}
		}

		vec3 softlight(vec3 bg, vec3 src)
		{
			vec3 blended = mix(((16.0 * bg - 12.0) * bg + 4.0) * bg, sqrt(bg), step(0.25, bg));
			vec3 result = mix(
				bg - (1.0 - 2.0 * src) * bg * (1.0 - bg),
				bg + (2.0 * src - 1.0) * (blended - bg),
				step(0.5, src)
			);

			return result;
		}

		vec3 exclusion(vec3 bg, vec3 src)
		{
			return bg + src - vec3(2.0) * bg * src;
		}

		vec3 hue(vec3 bg, vec3 src)
		{
			return setLum(setSat(src, sat(bg)), vec3(lum(bg)));
		}

		vec3 saturation(vec3 bg, vec3 src)
		{
			return setLum(setSat(bg, sat(src)), vec3(lum(bg)));
		}

		vec3 color(vec3 bg, vec3 src)
		{
			return setLum(src, vec3(lum(bg)));
		}

		vec3 blend(vec3 bg, vec3 src)
		{
			if (blendMode == DARKEN)
			{
				return min(bg, src);
			}
			else if (blendMode == HARDLIGHT)
			{
				return hardlight(bg, src);
			}
			else if (blendMode == LIGHTEN)
			{
				return max(bg, src);
			}
			else if (blendMode == OVERLAY)
			{
				// NOTE: OVERLAY is the inverse of HARDLIGHT
				return hardlight(src, bg);
			}
			else if (blendMode == DIFFERENCE)
			{
				return difference(bg, src);
			}
			else if (blendMode == INVERT)
			{
				return invert(bg);
			}
			else if (blendMode == COLORDODGE)
			{
				return colordodge(bg, src);
			}
			else if (blendMode == COLORBURN)
			{
				return colorburn(bg, src);
			}
			else if (blendMode == SOFTLIGHT)
			{
				return softlight(bg, src);
			}
			else if (blendMode == EXCLUSION)
			{
				return exclusion(bg, src);
			}
			else if (blendMode == HUE)
			{
				return hue(bg, src);
			}
			else if (blendMode == SATURATION)
			{
				return saturation(bg, src);
			}
			else if (blendMode == COLOR)
			{
				return color(bg, src);
			}
			else if (blendMode == LUMINOSITY)
			{
				// NOTE: LUMINOSITY is the inverse of COLOR
				return color(src, bg);
			}
			else
			{
				return vec3(1, 0, 1);
			}
		}

		void main()
		{
			vec4 bg = flixel_texture2D(backgroundSwag, openfl_TextureCoordv);
			vec4 src = flixel_texture2D(sourceSwag, screenCoord);

			// Un-premultiply the alpha before blending
			src.rgb = src.a > 0.0 ? src.rgb / src.a : src.rgb;

			vec3 res = blend(bg.rgb, src.rgb);
			gl_FragColor = vec4(mix(bg.rgb, res.rgb, src.a), mix(bg.a, 1.0, src.a));
		}
	")

	public function new(){
		super();
		uScreenResolution.value = [FlxG.width, FlxG.height];
		uCameraBounds.value = [0, 0, FlxG.width, FlxG.height];
		uFrameBounds.value = [0, 0, FlxG.width, FlxG.height];
	}

	public function updateViewInfo(screenWidth:Float, screenHeight:Float, camera:FlxCamera):Void{
		uScreenResolution.value = [screenWidth, screenHeight];
		uCameraBounds.value = [camera.viewLeft, camera.viewTop, camera.viewRight, camera.viewBottom];
	}
}