package note;

import haxe.Json;

typedef HoldCoverAnimInfo = {
    var prefix:String;
    var framerateRange:Array<Int>;
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

        addStartAnim(0, skinJson.animations.left.start.prefix, skinJson.animations.left.start.framerateRange);
        addHoldAnim(0, skinJson.animations.left.hold.prefix, skinJson.animations.left.hold.framerateRange);
        addSplashAnim(0, skinJson.animations.left.splash.prefix, skinJson.animations.left.splash.framerateRange);

        addStartAnim(1, skinJson.animations.down.start.prefix, skinJson.animations.down.start.framerateRange);
        addHoldAnim(1, skinJson.animations.down.hold.prefix, skinJson.animations.down.hold.framerateRange);
        addSplashAnim(1, skinJson.animations.down.splash.prefix, skinJson.animations.down.splash.framerateRange);

        addStartAnim(2, skinJson.animations.up.start.prefix, skinJson.animations.up.start.framerateRange);
        addHoldAnim(2, skinJson.animations.up.hold.prefix, skinJson.animations.up.hold.framerateRange);
        addSplashAnim(2, skinJson.animations.up.splash.prefix, skinJson.animations.up.splash.framerateRange);

        addStartAnim(3, skinJson.animations.right.start.prefix, skinJson.animations.right.start.framerateRange);
        addHoldAnim(3, skinJson.animations.right.hold.prefix, skinJson.animations.right.hold.framerateRange);
        addSplashAnim(3, skinJson.animations.right.splash.prefix, skinJson.animations.right.splash.framerateRange);
    }

    function addStartAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].start = {
            prefix: _prefix,
            framerateRange: _framerateRange
        };
    }

    function addHoldAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].hold = {
            prefix: _prefix,
            framerateRange: _framerateRange
        };
    }

    function addSplashAnim(_direction:Int, _prefix:String, _framerateRange:Array<Int>){
        if(_framerateRange == null){ _framerateRange = [24, 24]; }
        if(_framerateRange.length == 1){ _framerateRange.push(_framerateRange[0]); }
        info.anims[_direction].splash = {
            prefix: _prefix,
            framerateRange: _framerateRange
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