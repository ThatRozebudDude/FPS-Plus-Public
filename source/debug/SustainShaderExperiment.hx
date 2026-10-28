package debug;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.system.FlxAssets.FlxShader;
import modding.PolymodHandler;

using StringTools;

class SustainShaderExperiment extends FlxState
{

	var sustainDisplay:FlxSprite;
	var sustainShader:SustainShader;
	
	override function create(){
		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		//Normal notes.
		var noteFrames = Paths.getSparrowAtlas("test/NOTE_assets"); //I used a local mod to retexture the down sustain so it's easier to see the texture repeat.
		var downSustainPiece = noteFrames.getAllByPrefix("blue hold piece")[0];
		var downSustainEnd = noteFrames.getAllByPrefix("blue hold end")[0];
		var noteScale:Float = 1;

		//Pixel notes.
		// var noteFrames = FlxTileFrames.fromGraphic(Paths.image("test/arrowEnds"), FlxPoint.get(9, 6)); //I used a local mod to retexture the down sustain so it's easier to see the texture repeat.
		// var downSustainPiece = noteFrames.getByIndex(1);
		// var downSustainEnd = noteFrames.getByIndex(5);
		// var noteScale:Float = 6;

		trace(downSustainPiece.frame.width + "\t" + downSustainPiece.frame.height);
		trace(downSustainEnd.frame.width + "\t" + downSustainEnd.frame.height);

		sustainDisplay = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFFFFFFFF);
		sustainDisplay.scale.set(downSustainPiece.frame.width * noteScale, 200);
		sustainDisplay.updateHitbox();
		sustainDisplay.screenCenter();
		sustainDisplay.alpha = 0.6;
		add(sustainDisplay);

		sustainShader = new SustainShader();
		sustainShader.sustainDimensions.value = [sustainDisplay.width, sustainDisplay.height];
		sustainShader.sustainScale.value = [noteScale];
		sustainShader.data.noteTexture.input = noteFrames.parent.bitmap;
		sustainShader.noteTextureDimensions.value = [noteFrames.parent.width, noteFrames.parent.height];
		sustainShader.pieceFrame.value = [downSustainPiece.uv.left, downSustainPiece.uv.top, downSustainPiece.uv.right, downSustainPiece.uv.bottom];
		sustainShader.pieceDimensions.value = [downSustainPiece.frame.width, downSustainPiece.frame.height];
		sustainShader.endFrame.value = [downSustainEnd.uv.left, downSustainEnd.uv.top, downSustainEnd.uv.right, downSustainEnd.uv.bottom];
		sustainShader.endDimensions.value = [downSustainEnd.frame.width, downSustainEnd.frame.height];
		sustainShader.antialiasing.value = [true];
		sustainShader.loopTexture.value = [true];

		sustainDisplay.shader = sustainShader;

		super.create();
	}

	override function update(elapsed:Float){
		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload();
		}

		if(FlxG.keys.anyPressed([SHIFT])){
			if(FlxG.keys.anyPressed([UP])){
				sustainDisplay.scale.y += 1;
				sustainDisplay.updateHitbox();
				sustainDisplay.screenCenter();
			}

			if(FlxG.keys.anyPressed([DOWN])){
				sustainDisplay.scale.y -= 1;
				sustainDisplay.updateHitbox();
				sustainDisplay.screenCenter();
			}
		}
		else{
			if(FlxG.keys.anyJustPressed([UP])){
				sustainDisplay.scale.y += 25;
				sustainDisplay.updateHitbox();
				sustainDisplay.screenCenter();
			}

			if(FlxG.keys.anyJustPressed([DOWN])){
				sustainDisplay.scale.y -= 25;
				sustainDisplay.updateHitbox();
				sustainDisplay.screenCenter();
			}
		}
		
		if(FlxG.keys.anyJustPressed([Z])){
			sustainShader.antialiasing.value = [!sustainShader.antialiasing.value[0]];
		}
		
		if(FlxG.keys.anyJustPressed([X])){
			sustainShader.loopTexture.value = [!sustainShader.loopTexture.value[0]];
		}

		sustainShader.sustainDimensions.value = [sustainDisplay.width, sustainDisplay.height];

		super.update(elapsed);
	}

}

/*
	Renders the note sustain using a shader over a blank sprite.
	The goal is to render a whole sustain with a single object instead of multiple objects pieced together.
	This prevents gaps in the sustain notes, which doesn't usually happen but is reliant on finding magic numbers and sometimes you can still briefly see them in screenshots an such.
	This is kinda similar to how base game does it but it's actually not and it's a completely different approach.
	I don't know if or when I'll implement this but I wanted to start working on something for it.
*/

class SustainShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec2 sustainDimensions;
		uniform float sustainScale;

		uniform sampler2D noteTexture;
		uniform vec2 noteTextureDimensions;

		uniform vec4 pieceFrame;
		uniform vec2 pieceDimensions;
		
		uniform vec4 endFrame;
		uniform vec2 endDimensions;

		uniform bool antialiasing;
		uniform bool loopTexture;
		
		//Allows for texture filtering on a sampler2D.
		vec4 texture2D_bilinear(sampler2D t, vec2 uv){
			vec2 texelSize = 1.0/noteTextureDimensions;
			vec2 p = uv * noteTextureDimensions - 0.5;
			vec2 f = fract(p);
			uv = floor(p) * texelSize + texelSize * 0.5;
			vec4 tl = flixel_texture2D(t, uv);
			vec4 tr = flixel_texture2D(t, uv + vec2(texelSize.x, 0.0));
			vec4 bl = flixel_texture2D(t, uv + vec2(0.0, texelSize.y));
			vec4 br = flixel_texture2D(t, uv + vec2(texelSize.x, texelSize.y));
			vec4 tA = mix(tl, tr, f.x);
			vec4 tB = mix(bl, br, f.x);
			return mix(tA, tB, f.y);
		}

		float remapToRange(float value, float start1, float stop1, float start2, float stop2){
			return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
		}

		void main(){
			vec2 pixelSize = 1.0/sustainDimensions;
			vec2 uv = openfl_TextureCoordv;

			float endLength = pixelSize.y * endDimensions.y * sustainScale;

			if(openfl_TextureCoordv.y < 1.0 - endLength){ //Piece
				if(loopTexture){ //Loop the texture multiple times vertically.
					float multiplier = sustainDimensions.y/pieceDimensions.y;
					uv = vec2(remapToRange(openfl_TextureCoordv.x, 0.0, 1.0, pieceFrame.x, pieceFrame.z), remapToRange(mod(openfl_TextureCoordv.y * (multiplier/sustainScale), 1.0), 0.0, 1.0 - endLength, pieceFrame.y, pieceFrame.w));
					uv.y = clamp(uv.y, pieceFrame.y + (0.5/noteTextureDimensions.y), pieceFrame.w - (0.5/noteTextureDimensions.y));
				}
				else{ //Strech the texture instead of looping it.
					uv = vec2(remapToRange(openfl_TextureCoordv.x, 0.0, 1.0, pieceFrame.x, pieceFrame.z), remapToRange(openfl_TextureCoordv.y, 0.0, 1.0 - endLength, pieceFrame.y, pieceFrame.w));
					uv.y = clamp(uv.y, pieceFrame.y + (0.5/noteTextureDimensions.y), pieceFrame.w - (0.5/noteTextureDimensions.y));
				}
				
			}
			else{ //End
				uv = vec2(remapToRange(openfl_TextureCoordv.x, 0.0, 1.0, endFrame.x, endFrame.z), remapToRange(openfl_TextureCoordv.y, 1.0 - endLength, 1.0, endFrame.y, endFrame.w));
				uv.y = max(uv.y, endFrame.y + 0.5/noteTextureDimensions.y);
			}

			gl_FragColor = antialiasing ? texture2D_bilinear(noteTexture, uv) : flixel_texture2D(noteTexture, uv);
		}'
	)

	public function new(){ super(); }
}