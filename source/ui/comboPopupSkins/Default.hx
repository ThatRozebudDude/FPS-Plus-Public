package ui.comboPopupSkins;

import flixel.math.FlxPoint;

class Default extends ComboPopupSkinBase
{
    
    public function new(){
        super();

        info.ratingsInfo = {
            path: "ui/ratings",
            position: new FlxPoint(0, -50),
            aa: true,
            scale: 0.7
        };
        info.numbersInfo = {
            path: "ui/numbers",
            position: new FlxPoint(-175, 5),
            aa: true,
            scale: 0.6
        };
        info.breakInfo = {
            path: "ui/ratings/comboBreak",
            position: new FlxPoint(0, -50),
            aa: true,
            scale: 0.6
        };

        info.ratingsHudScaleMultiply = 0.8;
        info.breakHudScaleMultiply = 0.8;
    }

}