package ui;

import flixel.math.FlxPoint;
import ui.ComboPopup.PopupInfo;
import haxe.Json;

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

	public function new(_skin:String){
		var skinJson = Json.parse(Utils.getText(Paths.json(_skin, "data/uiSkins/comboPopup")));
		info.ratingsInfo = {
			path: skinJson.ratings.path,
			position: new FlxPoint(0, -50),
			aa: true,
			scale: 1
		};

		if(skinJson.ratings.position != null)		{ info.ratingsInfo.position.set(skinJson.ratings.position[0], skinJson.ratings.position[1]); }
		if(skinJson.ratings.antialiasing != null)	{ info.ratingsInfo.aa = skinJson.ratings.antialiasing; }
		if(skinJson.ratings.scale != null)			{ info.ratingsInfo.scale = skinJson.ratings.scale; }

		info.numbersInfo = {
			path: skinJson.numbers.path,
			position: new FlxPoint(-175, 5),
			aa: true,
			scale: 1
		};

		if(skinJson.numbers.position != null)		{ info.numbersInfo.position.set(skinJson.numbers.position[0], skinJson.numbers.position[1]); }
		if(skinJson.numbers.antialiasing != null)	{ info.numbersInfo.aa = skinJson.numbers.antialiasing; }
		if(skinJson.numbers.scale != null)			{ info.numbersInfo.scale = skinJson.numbers.scale; }

		info.breakInfo = {
			path: skinJson.comboBreak.path,
			position: new FlxPoint(0, -50),
			aa: true,
			scale: 1
		};

		if(skinJson.comboBreak.position != null)		{ info.breakInfo.position.set(skinJson.comboBreak.position[0], skinJson.comboBreak.position[1]); }
		if(skinJson.comboBreak.antialiasing != null)	{ info.breakInfo.aa = skinJson.comboBreak.antialiasing; }
		if(skinJson.comboBreak.scale != null)			{ info.breakInfo.scale = skinJson.comboBreak.scale; }

		if(skinJson.ratings.hudScaleMutltiplier != null)	{ info.ratingsHudScaleMultiply = skinJson.ratings.hudScaleMutltiplier; }
		if(skinJson.numbers.hudScaleMutltiplier != null)	{ info.numbersHudScaleMultiply = skinJson.numbers.hudScaleMutltiplier; }
		if(skinJson.comboBreak.hudScaleMutltiplier != null)	{ info.breakHudScaleMultiply = skinJson.comboBreak.hudScaleMutltiplier; }
	}

	public function toString():String{ return "ComboPopupSkinBase"; }
}