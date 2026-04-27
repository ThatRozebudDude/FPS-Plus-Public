package editors.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class UIElement	extends FlxTypedSpriteGroup<FlxSprite>
{
	public var elementWidth:Float;
	public var elementHeight:Float;
	public var manager:UIManager;

	public function new(_x:Float = 0.0, _y:Float = 0.0, _maxSize:Int = 0){
		super(_x, _y, _maxSize);
		if(manager == null){ manager = UIManager.globalManager; }
	}

	public function focus():Void{}
	public function unfocus():Void{}
}