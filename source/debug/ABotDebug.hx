package debug;

import objects.ABot;
import flixel.math.FlxPoint;
import characters.CharacterInfoBase;
import config.Config;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class ABotDebug extends FlxState
{

	var abot:ABot;

	var ePos:FlxPoint = new FlxPoint(-506, -494);
	var ebPos:FlxPoint = new FlxPoint(50, 250);
	var sPos:FlxPoint = new FlxPoint();
	var bPos:FlxPoint = new FlxPoint(147, 31);
	var vPos:FlxPoint = new FlxPoint(203, 88);

	override function create() {

		var bg = new FlxSprite().makeGraphic(1280, 720, 0xFF888888);
		add(bg);

		abot = new ABot(0, 0);
		abot.screenCenterAdjusted(XY);
		add(abot);

	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.anyJustPressed([ONE])){
			abot.bop();
		}
		if(FlxG.keys.anyJustPressed([TWO])){
			abot.lookLeft();
		}
		if(FlxG.keys.anyJustPressed([THREE])){
			abot.lookRight();
		}

		if(FlxG.keys.anyJustPressed([SPACE])){
			trace("bg: " + bPos);
			trace("eyes: " + ePos);
			trace("eyeBack: " + ebPos);
			trace("system: " + sPos);
			trace("visualizer: " + vPos);
		}

		var moveAmount = 1;
		if(FlxG.keys.anyPressed([SHIFT])){
			moveAmount = 10;
		}

		//reposition bg
		if(FlxG.keys.anyJustPressed([W])){
			bPos.y -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([S])){
			bPos.y += moveAmount;
		}
		if(FlxG.keys.anyJustPressed([A])){
			bPos.x -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([D])){
			bPos.x += moveAmount;
		}

		//reposition eyes
		if(FlxG.keys.anyJustPressed([T])){
			ebPos.y -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([G])){
			ebPos.y += moveAmount;
		}
		if(FlxG.keys.anyJustPressed([F])){
			ebPos.x -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([H])){
			ebPos.x += moveAmount;
		}

		//reposition eye back
		if(FlxG.keys.anyJustPressed([I])){
			ePos.y -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([K])){
			ePos.y += moveAmount;
		}
		if(FlxG.keys.anyJustPressed([J])){
			ePos.x -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([L])){
			ePos.x += moveAmount;
		}

		//reposition visualizer
		if(FlxG.keys.anyJustPressed([UP])){
			vPos.y -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([DOWN])){
			vPos.y += moveAmount;
		}
		if(FlxG.keys.anyJustPressed([LEFT])){
			vPos.x -= moveAmount;
		}
		if(FlxG.keys.anyJustPressed([RIGHT])){
			vPos.x += moveAmount;
		}

		@:privateAccess{
			abot.bg.x = abot.x + bPos.x;
			abot.bg.y = abot.y + bPos.y;
			abot.eyes.x = abot.x + ePos.x;
			abot.eyes.y = abot.y + ePos.y;
			abot.system.x = abot.x + sPos.x;
			abot.system.y = abot.y + sPos.y;
			abot.visualizer.x = abot.x + vPos.x;
			abot.visualizer.y = abot.y + vPos.y;
			abot.eyeBack.x = abot.x + ebPos.x;
			abot.eyeBack.y = abot.y + ebPos.y;
		}

	}

}
