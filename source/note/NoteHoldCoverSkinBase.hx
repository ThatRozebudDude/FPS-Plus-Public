package note;

import haxe.Json;

typedef HoldCoverAnimInfo = {
    var prefix:String;
    var framerateRange:Array<Int>;
    var offset:Array<Float>;
    var positionOffset:Array<Float>;
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

        addStartAnim(0, skinJson.animations.left.start.prefix, skinJson.animations.left.start.framerateRange, skinJson.animations.left.start.offset, skinJson.animations.left.start.positionOffset);
        addHoldAnim(0, skinJson.animations.left.hold.prefix, skinJson.animations.left.hold.framerateRange, skinJson.animations.left.hold.offset, skinJson.animations.left.hold.positionOffset);
        addSplashAnim(0, skinJson.animations.left.splash.prefix, skinJson.animations.left.splash.framerateRange, skinJson.animations.left.splash.offset, skinJson.animations.left.splash.positionOffset);

        addStartAnim(1, skinJson.animations.down.start.prefix, skinJson.animations.down.start.framerateRange, skinJson.animations.down.start.offset, skinJson.animations.down.start.positionOffset);
        addHoldAnim(1, skinJson.animations.down.hold.prefix, skinJson.animations.down.hold.framerateRange, skinJson.animations.down.hold.offset, skinJson.animations.down.hold.positionOffset);
        addSplashAnim(1, skinJson.animations.down.splash.prefix, skinJson.animations.down.splash.framerateRange, skinJson.animations.down.splash.offset, skinJson.animations.down.splash.positionOffset);

        addStartAnim(2, skinJson.animations.up.start.prefix, skinJson.animations.up.start.framerateRange, skinJson.animations.up.start.offset, skinJson.animations.up.start.positionOffset);
        addHoldAnim(2, skinJson.animations.up.hold.prefix, skinJson.animations.up.hold.framerateRange, skinJson.animations.up.hold.offset, skinJson.animations.up.hold.positionOffset);
        addSplashAnim(2, skinJson.animations.up.splash.prefix, skinJson.animations.up.splash.framerateRange, skinJson.animations.up.splash.offset, skinJson.animations.up.splash.positionOffset);

        addStartAnim(3, skinJson.animations.right.start.prefix, skinJson.animations.right.start.framerateRange, skinJson.animations.right.start.offset, skinJson.animations.right.start.positionOffset);
        addHoldAnim(3, skinJson.animations.right.hold.prefix, skinJson.animations.right.hold.framerateRange, skinJson.animations.right.hold.offset, skinJson.animations.right.hold.positionOffset);
        addSplashAnim(3, skinJson.animations.right.splash.prefix, skinJson.animations.right.splash.framerateRange, skinJson.animations.right.splash.offset, skinJson.animations.right.splash.positionOffset);
    }

    function addStartAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>, ?_offsetOverride:Array<Float> = null, _positionOffsetOverride:Array<Float> = null){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].start = {
            prefix: _prefix,
            framerateRange: _framerateRange,
            offset: _offsetOverride,
            positionOffset: _positionOffsetOverride
        };
    }

    function addHoldAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>, ?_offsetOverride:Array<Float> = null, _positionOffsetOverride:Array<Float> = null){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].hold = {
            prefix: _prefix,
            framerateRange: _framerateRange,
            offset: _offsetOverride,
            positionOffset: _positionOffsetOverride
        };
    }

    function addSplashAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>, ?_offsetOverride:Array<Float> = null, _positionOffsetOverride:Array<Float> = null){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].splash = {
            prefix: _prefix,
            framerateRange: _framerateRange,
            offset: _offsetOverride,
            positionOffset: _positionOffsetOverride
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