package ui.comboPopupSkins;

import flixel.math.FlxPoint;

class Pixel extends ComboPopupSkinBase
{
    
    public function new(){
        super();

        info.ratingsInfo = {
            path: "week6/weeb/pixelUI/ratings",
            position: new FlxPoint(0, -50),
            aa: false,
            scale: 6 * 0.7
        };
        info.numbersInfo = {
            path: "week6/weeb/pixelUI/numbers",
            position: new FlxPoint(-175, 5),
            aa: false,
            scale: 6 * 0.8
        };
        info.breakInfo = {
            path: "week6/weeb/pixelUI/ratings/comboBreak-pixel",
            position: new FlxPoint(0, -50),
            aa: false,
            scale: 6 * 0.7
        };

        info.ratingsHudScaleMultiply = 0.9;
        info.breakHudScaleMultiply = 0.9;
    }

}