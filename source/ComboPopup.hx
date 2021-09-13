package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class ComboPopup extends FlxSpriteGroup
{

	public function new(_x:Float, _y:Float, _ratingInfo:Array<Dynamic>, _numberInfo:Array<Dynamic>, _comboBreak:String)
	{
		super(_x, _y);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
