package ui;

import ui.ComboPopup.PopupInfo;

typedef ComboPopupSkinInfo = {
    var ratingsInfo:PopupInfo;
    var numbersInfo:PopupInfo;
    var breakInfo:PopupInfo;

    var ratingsHudScaleMultiply:Float;
    var numbersHudScaleMultiply:Float;
    var breakHudScaleMultiply:Float;
}

class ComboPopupSkinBase{

    public var info:ComboPopupSkinInfo = {
        ratingsInfo: null,
        numbersInfo: null,
        breakInfo: null,
        ratingsHudScaleMultiply: 1,
        numbersHudScaleMultiply: 1,
        breakHudScaleMultiply: 1,
    };

    public function new(){}

    public function toString():String{ return "ComboPopupSkinBase"; }
}