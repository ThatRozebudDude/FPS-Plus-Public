package shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

class RuntimeShader extends FlxRuntimeShader
{

    public function new(?fragmentSourcePath:String, ?vertexSourcePath:String):Void{
        var frag:String = null;
        var vert:String = null;
        if (fragmentSourcePath != null){ frag = Assets.getText(fragmentSourcePath); }
        if (vertexSourcePath != null){ vert = Assets.getText(vertexSourcePath); }
        super(frag, vert);
    }

    public inline function setDouble(name:String, value:Float):Void         { setFloat(name, value); }

    public inline function setUInt(name:String, value:Int):Void             { setInt(name, value); }

    public inline function setBVec2(name:String, value:Array<Bool>):Void    { setBoolArray(name, value); }
    public inline function setBVec3(name:String, value:Array<Bool>):Void    { setBoolArray(name, value); }
    public inline function setBVec4(name:String, value:Array<Bool>):Void    { setBoolArray(name, value); }

    public inline function setIVec2(name:String, value:Array<Int>):Void     { setIntArray(name, value); }
    public inline function setIVec3(name:String, value:Array<Int>):Void     { setIntArray(name, value); }
    public inline function setIVec4(name:String, value:Array<Int>):Void     { setIntArray(name, value); }

    public inline function setUVec2(name:String, value:Array<Int>):Void     { setIntArray(name, value); }
    public inline function setUVec3(name:String, value:Array<Int>):Void     { setIntArray(name, value); }
    public inline function setUVec4(name:String, value:Array<Int>):Void     { setIntArray(name, value); }

    public inline function setVec2(name:String, value:Array<Float>):Void    { setFloatArray(name, value); }
    public inline function setVec3(name:String, value:Array<Float>):Void    { setFloatArray(name, value); }
    public inline function setVec4(name:String, value:Array<Float>):Void    { setFloatArray(name, value); }

    public inline function setDVec2(name:String, value:Array<Float>):Void   { setFloatArray(name, value); }
    public inline function setDVec3(name:String, value:Array<Float>):Void   { setFloatArray(name, value); }
    public inline function setDVec4(name:String, value:Array<Float>):Void   { setFloatArray(name, value); }

    public inline function setMat2(name:String, value:Array<Float>):Void    { setFloatArray(name, value); }
    public inline function setMat2x2(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }
    public inline function setMat2x3(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }
    public inline function setMat2x4(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }

    public inline function setMat3x2(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }
    public inline function setMat3(name:String, value:Array<Float>):Void    { setFloatArray(name, value); }
    public inline function setMat3x3(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }
    public inline function setMat3x4(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }

    public inline function setMat4x2(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }
    public inline function setMat4x3(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }
    public inline function setMat4(name:String, value:Array<Float>):Void    { setFloatArray(name, value); }
    public inline function setMat4x4(name:String, value:Array<Float>):Void  { setFloatArray(name, value); }


    
    public inline function getDouble(name:String):Float         { return getFloat(name); }

    public inline function getUInt(name:String):Int             { return getInt(name); }

    public inline function getBVec2(name:String):Array<Bool>    { return getBoolArray(name); }
    public inline function getBVec3(name:String):Array<Bool>    { return getBoolArray(name); }
    public inline function getBVec4(name:String):Array<Bool>    { return getBoolArray(name); }

    public inline function getIVec2(name:String):Array<Int>     { return getIntArray(name); }
    public inline function getIVec3(name:String):Array<Int>     { return getIntArray(name); }
    public inline function getIVec4(name:String):Array<Int>     { return getIntArray(name); }

    public inline function getUVec2(name:String):Array<Int>     { return getIntArray(name); }
    public inline function getUVec3(name:String):Array<Int>     { return getIntArray(name); }
    public inline function getUVec4(name:String):Array<Int>     { return getIntArray(name); }

    public inline function getVec2(name:String):Array<Float>    { return getFloatArray(name); }
    public inline function getVec3(name:String):Array<Float>    { return getFloatArray(name); }
    public inline function getVec4(name:String):Array<Float>    { return getFloatArray(name); }

    public inline function getDVec2(name:String):Array<Float>   { return getFloatArray(name); }
    public inline function getDVec3(name:String):Array<Float>   { return getFloatArray(name); }
    public inline function getDVec4(name:String):Array<Float>   { return getFloatArray(name); }

    public inline function getMat2(name:String):Array<Float>    { return getFloatArray(name); }
    public inline function getMat2x2(name:String):Array<Float>  { return getFloatArray(name); }
    public inline function getMat2x3(name:String):Array<Float>  { return getFloatArray(name); }
    public inline function getMat2x4(name:String):Array<Float>  { return getFloatArray(name); }

    public inline function getMat3x2(name:String):Array<Float>  { return getFloatArray(name); }
    public inline function getMat3(name:String):Array<Float>    { return getFloatArray(name); }
    public inline function getMat3x3(name:String):Array<Float>  { return getFloatArray(name); }
    public inline function getMat3x4(name:String):Array<Float>  { return getFloatArray(name); }

    public inline function getMat4x2(name:String):Array<Float>  { return getFloatArray(name); }
    public inline function getMat4x3(name:String):Array<Float>  { return getFloatArray(name); }
    public inline function getMat4(name:String):Array<Float>    { return getFloatArray(name); }
    public inline function getMat4x4(name:String):Array<Float>  { return getFloatArray(name); }
}