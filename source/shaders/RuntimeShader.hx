package shaders;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxRuntimeShader;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import graphics.AtlasSprite;
import openfl.utils.Assets;

class RuntimeShader extends FlxRuntimeShader
{


	@:glFragmentHeader("
		uniform vec4 attachedSpriteFrameBounds; //(frame.left, frame.top, frame.right, frame.bottom)
		uniform float attachedSpriteFrameRotation;
		uniform bool attachedSpriteFlipX;
		uniform bool attachedSpriteFlipY;
	", true)

	public var attachedSprite(default, set):FlxSprite = null;
	private var attachedSpriteIsAtlas:Bool = false;

	public function new(?fragmentSource:String, ?vertexSource:String):Void{
		var frag:String = null;
		var vert:String = null;
		if (fragmentSource != null){
			if(Utils.exists(fragmentSource)){ //Treat as path first.
				frag = Assets.getText(fragmentSource);
			}
			else{ //Otherwise just use it as a source directly.
				frag = fragmentSource;
			}
		}
		if (vertexSource != null){
			if(Utils.exists(vertexSource)){
				vert = Assets.getText(vertexSource);
			}
			else{
				vert = vertexSource;
			}
		}
		super(frag, vert);

		setVec4("attachedSpriteFrameBounds", [0, 0, 1, 1]);
		setFloat("attachedSpriteFrameRotation", 0);
		setBool("attachedSpriteFlipX", false);
		setBool("attachedSpriteFlipY", false);

		FlxG.signals.preDraw.add(preDraw);
		FlxG.signals.preStateSwitch.addOnce(preStateSwitch);
	}

	public function attachCharacter(character:Character):Void{
		attachedSprite = character.getSprite();
		character.applyShader(this);
	}

	public function set_attachedSprite(v:FlxSprite):FlxSprite{
		if(attachedSprite != null){
			if(!attachedSpriteIsAtlas){
				attachedSprite.animation.onFrameChange.remove(attachedSpriteFrameChange);
			}
		}

		if(v == null){
			setVec4("attachedSpriteFrameBounds", [0, 0, 1, 1]);
			setFloat("attachedSpriteFrameRotation", 0);
			setBool("attachedSpriteFlipX", false);
			setBool("attachedSpriteFlipY", false);
			return attachedSprite = null;
		}

		attachedSprite = v;

		if(attachedSprite is AtlasSprite){
			attachedSpriteIsAtlas = true;
			setVec4("attachedSpriteFrameBounds", [0, 0, 1, 1]);
			setFloat("attachedSpriteFrameRotation", 0);
		}
		else{
			attachedSprite.animation.onFrameChange.add(attachedSpriteFrameChange);
			attachedSpriteIsAtlas = false;
			updateFrameInfo(attachedSprite.frame);
		}

		return attachedSprite;
	}

	private function attachedSpriteFrameChange(name:String, frame:Int, index:Int):Void{
		if(attachedSprite == null){ return; }

		if(!attachedSpriteIsAtlas){
			updateFrameInfo(attachedSprite.frame);
		}
	}

	private function updateFrameInfo(frame:FlxFrame):Void{
		if(attachedSprite == null){ return; }
		setVec4("attachedSpriteFrameBounds", [frame.uv.left, frame.uv.top, frame.uv.right, frame.uv.bottom]);
		setFloat("attachedSpriteFrameRotation", frame.angle * FlxAngle.TO_RAD);
	}

	/*private function updateFrameInfoAtlas():Void{
		if(attachedSprite == null){ return; }
		setVec4("attachedSpriteFrameBounds", [0, 0, 1, 1]);
		setFloat("attachedSpriteFrameRotation", 0);
	}*/

	private function preDraw():Void{
		if(attachedSprite == null){ return; }
		setBool("attachedSpriteFlipX", attachedSprite.flipX);
		setBool("attachedSpriteFlipY", attachedSprite.flipY);
	}
	
	private function preStateSwitch():Void{
		FlxG.signals.preDraw.remove(preDraw);
		attachedSprite = null;
	}

	override public function toString():String{ return "RuntimeShader"; }



	//Alias get and set functions that make modifying values in the shader more understandable.

	public inline function setDouble(name:String, value:Float):Void			{ setFloat(name, value); }

	public inline function setUInt(name:String, value:Int):Void				{ setInt(name, value); }

	public inline function setBVec2(name:String, value:Array<Bool>):Void	{ setBoolArray(name, value); }
	public inline function setBVec3(name:String, value:Array<Bool>):Void	{ setBoolArray(name, value); }
	public inline function setBVec4(name:String, value:Array<Bool>):Void	{ setBoolArray(name, value); }

	public inline function setIVec2(name:String, value:Array<Int>):Void		{ setIntArray(name, value); }
	public inline function setIVec3(name:String, value:Array<Int>):Void		{ setIntArray(name, value); }
	public inline function setIVec4(name:String, value:Array<Int>):Void		{ setIntArray(name, value); }

	public inline function setUVec2(name:String, value:Array<Int>):Void		{ setIntArray(name, value); }
	public inline function setUVec3(name:String, value:Array<Int>):Void		{ setIntArray(name, value); }
	public inline function setUVec4(name:String, value:Array<Int>):Void		{ setIntArray(name, value); }

	public inline function setVec2(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setVec3(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setVec4(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }

	public inline function setDVec2(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setDVec3(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setDVec4(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }

	public inline function setMat2(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat2x2(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat2x3(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat2x4(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }

	public inline function setMat3x2(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat3(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat3x3(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat3x4(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }

	public inline function setMat4x2(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat4x3(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat4(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }
	public inline function setMat4x4(name:String, value:Array<Float>):Void	{ setFloatArray(name, value); }

	public inline function setSampler2D(name:String, value:FlxGraphic):Void	{ setBitmapData(name, value.bitmap); }
	public inline function setColor(name:String, value:FlxColor):Void		{ setFloatArray(name, [value.redFloat, value.greenFloat, value.blueFloat, value.alphaFloat]); }


	
	public inline function getDouble(name:String):Float			{ return getFloat(name); }

	public inline function getUInt(name:String):Int				{ return getInt(name); }

	public inline function getBVec2(name:String):Array<Bool>	{ return getBoolArray(name); }
	public inline function getBVec3(name:String):Array<Bool>	{ return getBoolArray(name); }
	public inline function getBVec4(name:String):Array<Bool>	{ return getBoolArray(name); }

	public inline function getIVec2(name:String):Array<Int>		{ return getIntArray(name); }
	public inline function getIVec3(name:String):Array<Int>		{ return getIntArray(name); }
	public inline function getIVec4(name:String):Array<Int>		{ return getIntArray(name); }

	public inline function getUVec2(name:String):Array<Int>		{ return getIntArray(name); }
	public inline function getUVec3(name:String):Array<Int>		{ return getIntArray(name); }
	public inline function getUVec4(name:String):Array<Int>		{ return getIntArray(name); }

	public inline function getVec2(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getVec3(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getVec4(name:String):Array<Float>	{ return getFloatArray(name); }

	public inline function getDVec2(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getDVec3(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getDVec4(name:String):Array<Float>	{ return getFloatArray(name); }

	public inline function getMat2(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat2x2(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat2x3(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat2x4(name:String):Array<Float>	{ return getFloatArray(name); }

	public inline function getMat3x2(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat3(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat3x3(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat3x4(name:String):Array<Float>	{ return getFloatArray(name); }

	public inline function getMat4x2(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat4x3(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat4(name:String):Array<Float>	{ return getFloatArray(name); }
	public inline function getMat4x4(name:String):Array<Float>	{ return getFloatArray(name); }

	public inline function getSampler2D(name:String):FlxGraphic	{ return FlxGraphic.fromBitmapData(getBitmapData(name)); }
	public inline function getColor(name:String):FlxColor		{ return FlxColor.fromRGBFloat(getFloatArray(name)[0], getFloatArray(name)[1], getFloatArray(name)[2], getFloatArray(name)[3]); }

}