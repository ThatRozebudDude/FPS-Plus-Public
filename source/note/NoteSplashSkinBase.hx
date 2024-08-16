package note;

import flixel.math.FlxPoint;

typedef NoteSplashAnim = {
    var prefix:String;
    var framerateRange:Array<Int>;
    var offset:Array<Float>;
}

typedef NoteSplashSkinInfo = {
    var path:String;
    var anims:Array<Array<NoteSplashAnim>>;

    var randomRotation:Bool;
    var limitedRotationAngles:Bool;

    var alpha:Float;
    var antialiasing:Bool;
    var scale:Float;
}

class NoteSplashSkinBase
{
 
    public var info:NoteSplashSkinInfo;

    public function new(){
        
        info = {
            path: null,
            anims: [
                [], [], [], []
            ],
            randomRotation: true,
            limitedRotationAngles: false,
            alpha: 1,
            antialiasing: true,
            scale: 1
        }

    }

    function addAnim(_direction:Int, _name:String, ?_framerateRange:Array<Int>, ?_offset:Array<Float>) {
        if(_offset == null){ _offset = [0, 0]; }
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].push({
            prefix: _name,
            framerateRange: _framerateRange,
            offset: _offset
        });
    }

    /**
	 * Generates the x and y offsets for an animation.
	 *
	 * @param   _x  The x offset of the animation.
	 * @param   _y  The y offset of the animation.
	 */
    inline function offset(_x:Float = 0, _y:Float = 0):Array<Float>{
        return [_x, _y];
    }

    var left(get, never):Int;
    @:noCompletion inline function get_left()   { return 0; }
    var down(get, never):Int;
    @:noCompletion inline function get_down()   { return 1; }
    var up(get, never):Int;
    @:noCompletion inline function get_up()     { return 2; }
    var right(get, never):Int;
    @:noCompletion inline function get_right()  { return 3; }

}