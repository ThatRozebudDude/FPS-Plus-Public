package note;

import haxe.Json;

typedef HoldCoverAnimInfo = {
    var prefix:String;
    var framerateRange:Array<Int>;
    var offsetOverride:Array<Float>;
    var positionOffsetOverride:Array<Float>;
}

typedef HoldCoverAnims = {
    var start:HoldCoverAnimInfo;
    var hold:HoldCoverAnimInfo;
    var splash:HoldCoverAnimInfo;
}

typedef NoteHoldCoverSkinInfo = {
    var path:String;
    var anims:Array<HoldCoverAnims>;
    var offset:Array<Float>;
    var positionOffset:Array<Float>;
    var alpha:Float;
    var antialiasing:Bool;
    var scale:Float;
}

class NoteHoldCoverSkinBase
{

    public var info:NoteHoldCoverSkinInfo = {
        path: null,
        offset: [0, 0],
        positionOffset: [0, 0],
        alpha: 1,
        antialiasing: true,
        scale: 1,
        anims: [
            {
                start: null,
                hold: null,
                splash: null
            },
            {
                start: null,
                hold: null,
                splash: null
            },
            {
                start: null,
                hold: null,
                splash: null
            },
            {
                start: null,
                hold: null,
                splash: null
            }
        ]
    };

    public function new(_skin:String){
        var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/noteHoldCover")));
        info.path = skinJson.path;
        if(skinJson.offset != null){ info.offset = skinJson.offset; }
        if(skinJson.positionOffset != null){ info.positionOffset = skinJson.positionOffset; }
        if(skinJson.alpha != null){ info.alpha = skinJson.alpha; }
        if(skinJson.antialiasing != null){ info.antialiasing = skinJson.antialiasing; }
        if(skinJson.scale != null){ info.scale = skinJson.scale; }

        addStartAnim(0, skinJson.animations.left.start.prefix, skinJson.animations.left.start.framerateRange, skinJson.animations.left.start.offsetOverride, skinJson.animations.left.start.positionOffsetOverride);
        addHoldAnim(0, skinJson.animations.left.hold.prefix, skinJson.animations.left.hold.framerateRange, skinJson.animations.left.hold.offsetOverride, skinJson.animations.left.hold.positionOffsetOverride);
        addSplashAnim(0, skinJson.animations.left.splash.prefix, skinJson.animations.left.splash.framerateRange, skinJson.animations.left.splash.offsetOverride, skinJson.animations.left.splash.positionOffsetOverride);

        addStartAnim(1, skinJson.animations.down.start.prefix, skinJson.animations.down.start.framerateRange, skinJson.animations.down.start.offsetOverride, skinJson.animations.down.start.positionOffsetOverride);
        addHoldAnim(1, skinJson.animations.down.hold.prefix, skinJson.animations.down.hold.framerateRange, skinJson.animations.down.hold.offsetOverride, skinJson.animations.down.hold.positionOffsetOverride);
        addSplashAnim(1, skinJson.animations.down.splash.prefix, skinJson.animations.down.splash.framerateRange, skinJson.animations.down.splash.offsetOverride, skinJson.animations.down.splash.positionOffsetOverride);

        addStartAnim(2, skinJson.animations.up.start.prefix, skinJson.animations.up.start.framerateRange, skinJson.animations.up.start.offsetOverride, skinJson.animations.up.start.positionOffsetOverride);
        addHoldAnim(2, skinJson.animations.up.hold.prefix, skinJson.animations.up.hold.framerateRange, skinJson.animations.up.hold.offsetOverride, skinJson.animations.up.hold.positionOffsetOverride);
        addSplashAnim(2, skinJson.animations.up.splash.prefix, skinJson.animations.up.splash.framerateRange, skinJson.animations.up.splash.offsetOverride, skinJson.animations.up.splash.positionOffsetOverride);

        addStartAnim(3, skinJson.animations.right.start.prefix, skinJson.animations.right.start.framerateRange, skinJson.animations.right.start.offsetOverride, skinJson.animations.right.start.positionOffsetOverride);
        addHoldAnim(3, skinJson.animations.right.hold.prefix, skinJson.animations.right.hold.framerateRange, skinJson.animations.right.hold.offsetOverride, skinJson.animations.right.hold.positionOffsetOverride);
        addSplashAnim(3, skinJson.animations.right.splash.prefix, skinJson.animations.right.splash.framerateRange, skinJson.animations.right.splash.offsetOverride, skinJson.animations.right.splash.positionOffsetOverride);
    }

    function addStartAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>, ?_offsetOverride:Array<Float> = null, _positionOffsetOverride:Array<Float> = null){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].start = {
            prefix: _prefix,
            framerateRange: _framerateRange,
            offsetOverride: _offsetOverride,
            positionOffsetOverride: _positionOffsetOverride
        };
    }

    function addHoldAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>, ?_offsetOverride:Array<Float> = null, _positionOffsetOverride:Array<Float> = null){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].hold = {
            prefix: _prefix,
            framerateRange: _framerateRange,
            offsetOverride: _offsetOverride,
            positionOffsetOverride: _positionOffsetOverride
        };
    }

    function addSplashAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>, ?_offsetOverride:Array<Float> = null, _positionOffsetOverride:Array<Float> = null){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].splash = {
            prefix: _prefix,
            framerateRange: _framerateRange,
            offsetOverride: _offsetOverride,
            positionOffsetOverride: _positionOffsetOverride
        };
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

    public function toString():String{ return "NoteHoldCoverSkinBase"; }
}