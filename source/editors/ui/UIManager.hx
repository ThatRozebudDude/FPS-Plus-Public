package editors.ui;

import flixel.FlxG;
import flixel.util.FlxSignal.FlxTypedSignal;

class UIManager
{
	public static var globalManager:UIManager = new UIManager();

	private var _focused:UIElement = null;
	public var focused(get, set):UIElement;
	public var onFocusSwitch:FlxTypedSignal<UIElement->Void> = new FlxTypedSignal<UIElement->Void>();

	public var allowInteraction(default, set):Bool = true;

	public function new(){}

	public function clearFocused():Void{
		_focused = null;
		allowInteraction = false;
	}

	public function get_focused():UIElement{ return _focused; }

	public function set_focused(v:UIElement):UIElement{
		allowInteraction = false;
		if(_focused != null){ _focused.unfocus(); }
		_focused = v;
		if(_focused != null){ _focused.focus(); }
		onFocusSwitch.dispatch(_focused);
		return _focused;
	}

	public function set_allowInteraction(v:Bool):Bool{
		allowInteraction = v;
		if(!allowInteraction){ FlxG.signals.postUpdate.addOnce(function(){ allowInteraction = true; }); }
		return allowInteraction;
	}
}